import { forwardRef, useEffect, useImperativeHandle, useRef } from 'react';
import {
    buildFragmentShader, createProgram, makeFullScreenQuad,
    VERTEX_SHADER_SOURCE, type ShaderProgram,
} from '../shader-pipeline';

export interface ShaderCanvasHandle {
    /** Recompile + run with a new fragment body. Returns true if the shader compiled. */
    run(fragmentBody: string): boolean;
    pause(): void;
    resume(): void;
    setTime(t: number): void;
    /** Returns true if paused. */
    isPaused(): boolean;
}

interface Props {
    /** Initial fragment shader body. Header is prepended automatically. */
    initialBody: string;
    /** Called every frame with the current shader time (post-offset). */
    onTimeChange?: (t: number) => void;
    /** Called once on mount so the parent can decide when to actually start rendering. */
    autoStart?: boolean;
    className?: string;
}

/**
 * Self-contained WebGL canvas. React only mounts and forwards a handle —
 * all WebGL state lives in refs so re-renders never disturb it.
 *
 * StrictMode-safe: the cleanup function fully tears down GL state so a
 * double-invoke in dev re-initializes cleanly.
 */
export const ShaderCanvas = forwardRef<ShaderCanvasHandle, Props>(function ShaderCanvas(
    { initialBody, onTimeChange, autoStart = true, className },
    ref,
) {
    const canvasRef = useRef<HTMLCanvasElement | null>(null);
    const glRef = useRef<WebGLRenderingContext | null>(null);
    const programRef = useRef<ShaderProgram | null>(null);
    const bufferRef  = useRef<WebGLBuffer | null>(null);
    const textureRef = useRef<WebGLTexture | null>(null);
    const imageSizeRef = useRef<{ w: number; h: number }>({ w: 1, h: 1 });

    // Mutable runtime state (must not trigger re-render)
    const stateRef = useRef({
        rafId: 0 as number,
        startMs: 0,
        elapsed: 0,            // u_time fed to the shader
        paused: false,
        currentBody: '',
        onTimeChange,
    });
    stateRef.current.onTimeChange = onTimeChange;

    useImperativeHandle(ref, () => ({
        run(body: string) {
            const ok = compileAndUse(body);
            if (ok) {
                stateRef.current.currentBody = body;
                if (stateRef.current.paused) stateRef.current.paused = false;
            }
            return ok;
        },
        pause() { stateRef.current.paused = true; },
        resume() { stateRef.current.paused = false; },
        setTime(t: number) { stateRef.current.elapsed = t; stateRef.current.startMs = performance.now() - t * 1000; },
        isPaused() { return stateRef.current.paused; },
    }), []);

    function compileAndUse(body: string): boolean {
        const gl = glRef.current;
        if (!gl) return false;
        if (programRef.current) gl.deleteProgram(programRef.current.program);

        const fs = buildFragmentShader(body);
        const next = createProgram(gl, VERTEX_SHADER_SOURCE, fs);
        if (!next) return false;
        programRef.current = next;
        gl.useProgram(next.program);

        if (!bufferRef.current) bufferRef.current = makeFullScreenQuad(gl);
        if (next.positionLoc >= 0 && bufferRef.current) {
            gl.bindBuffer(gl.ARRAY_BUFFER, bufferRef.current);
            gl.enableVertexAttribArray(next.positionLoc);
            gl.vertexAttribPointer(next.positionLoc, 2, gl.FLOAT, false, 0, 0);
        }
        // Texture unit 0 holds the lesson image. Set the sampler binding
        // once per program — it sticks until the program is replaced.
        if (next.uImage) gl.uniform1i(next.uImage, 0);
        return true;
    }

    useEffect(() => {
        const canvas = canvasRef.current;
        if (!canvas) return;

        // Match canvas backing store to its CSS size, with DPR scaling.
        const resize = () => {
            const dpr = window.devicePixelRatio || 1;
            canvas.width  = Math.max(1, Math.round(canvas.clientWidth  * dpr));
            canvas.height = Math.max(1, Math.round(canvas.clientHeight * dpr));
        };

        const gl = canvas.getContext('webgl', { preserveDrawingBuffer: false });
        if (!gl) {
            console.warn('WebGL not supported');
            return;
        }
        glRef.current = gl;

        // Bind unit 0 to a 1x1 white placeholder so sampler reads are well-defined
        // before the real lesson texture finishes decoding.
        const tex = gl.createTexture();
        textureRef.current = tex;
        gl.activeTexture(gl.TEXTURE0);
        gl.bindTexture(gl.TEXTURE_2D, tex);
        gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, true);
        gl.pixelStorei(gl.UNPACK_PREMULTIPLY_ALPHA_WEBGL, false);
        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, 1, 1, 0, gl.RGBA, gl.UNSIGNED_BYTE,
            new Uint8Array([255, 255, 255, 255]));
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);

        // Async-load the real lesson texture; swap it in once decoded.
        // Cancelled via a stale-mount flag in case the component unmounts mid-load.
        let staleMount = false;
        (async () => {
            const img = new Image();
            img.src = '/textures/lesson-image.png';
            try {
                await img.decode();
            } catch {
                return;
            }
            if (staleMount || !glRef.current || !textureRef.current) return;
            gl.bindTexture(gl.TEXTURE_2D, textureRef.current);
            gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, true);
            gl.pixelStorei(gl.UNPACK_PREMULTIPLY_ALPHA_WEBGL, false);
            gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, img);
            imageSizeRef.current = { w: img.naturalWidth, h: img.naturalHeight };
        })();

        // First compile
        if (!compileAndUse(initialBody)) {
            console.warn('Initial shader failed to compile');
        }
        stateRef.current.currentBody = initialBody;
        stateRef.current.startMs = performance.now();
        stateRef.current.elapsed = 0;
        stateRef.current.paused = !autoStart;

        resize();
        window.addEventListener('resize', resize);

        const tick = (nowMs: number) => {
            const st = stateRef.current;
            const prog = programRef.current;
            if (!prog) { st.rafId = requestAnimationFrame(tick); return; }

            if (!st.paused) {
                st.elapsed = (nowMs - st.startMs) / 1000;
            }

            resize();
            gl.viewport(0, 0, canvas.width, canvas.height);
            gl.clearColor(0, 0, 0, 1);
            gl.clear(gl.COLOR_BUFFER_BIT);
            if (prog.uResolution) gl.uniform2f(prog.uResolution, canvas.width, canvas.height);
            if (prog.uTime)       gl.uniform1f(prog.uTime, st.elapsed);
            if (prog.uImageResolution) {
                const sz = imageSizeRef.current;
                gl.uniform2f(prog.uImageResolution, sz.w, sz.h);
            }
            gl.drawArrays(gl.TRIANGLES, 0, 6);

            if (st.onTimeChange) st.onTimeChange(st.elapsed);
            st.rafId = requestAnimationFrame(tick);
        };
        stateRef.current.rafId = requestAnimationFrame(tick);

        return () => {
            staleMount = true;
            const st = stateRef.current;
            cancelAnimationFrame(st.rafId);
            window.removeEventListener('resize', resize);
            const prog = programRef.current;
            if (prog && gl) gl.deleteProgram(prog.program);
            if (bufferRef.current && gl) gl.deleteBuffer(bufferRef.current);
            if (textureRef.current && gl) gl.deleteTexture(textureRef.current);
            programRef.current = null;
            bufferRef.current = null;
            textureRef.current = null;
            glRef.current = null;
        };
        // Mount once. initialBody/autoStart only matter on mount; live updates
        // come through the imperative handle.
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, []);

    return (
        <canvas
            ref={canvasRef}
            className={'block w-full h-full bg-black ' + (className ?? '')}
        />
    );
});
