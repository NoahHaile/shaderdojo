// WebGL primitives kept deliberately framework-free.
//
// The header MUST stay byte-identical to backend/api/src/validator.service.ts's
// FRAGMENT_HEADER and to the legacy frontend's `fragmentShaderHeader`, or hash
// equality with the validator's canonical render will break.

export const FRAGMENT_HEADER =
    '\nprecision mediump float;\nuniform vec2 u_resolution;\nuniform float u_time;\nuniform sampler2D u_image;\nuniform vec2 u_image_resolution;\n\n';

export const VERTEX_SHADER_SOURCE = `
  attribute vec4 aVertexPosition;
  precision mediump float;
  void main() {
    gl_Position = aVertexPosition;
  }
`;

export function buildFragmentShader(body: string): string {
    return FRAGMENT_HEADER + body;
}

interface CompileResult { shader: WebGLShader | null; error: string | null; }

function compile(gl: WebGLRenderingContext, type: number, src: string): CompileResult {
    const s = gl.createShader(type);
    if (!s) return { shader: null, error: 'gl.createShader returned null' };
    gl.shaderSource(s, src);
    gl.compileShader(s);
    if (!gl.getShaderParameter(s, gl.COMPILE_STATUS)) {
        const log = gl.getShaderInfoLog(s) ?? 'unknown shader compile error';
        gl.deleteShader(s);
        return { shader: null, error: log };
    }
    return { shader: s, error: null };
}

export interface ShaderProgram {
    program: WebGLProgram;
    uResolution: WebGLUniformLocation | null;
    uTime: WebGLUniformLocation | null;
    uImage: WebGLUniformLocation | null;
    uImageResolution: WebGLUniformLocation | null;
    positionLoc: number;
}

export interface ProgramResult {
    program: ShaderProgram | null;
    error: string | null;
}

export function createProgram(gl: WebGLRenderingContext, vsSource: string, fsSource: string): ProgramResult {
    const vs = compile(gl, gl.VERTEX_SHADER, vsSource);
    if (vs.error) return { program: null, error: `vertex shader: ${vs.error}` };
    const fs = compile(gl, gl.FRAGMENT_SHADER, fsSource);
    if (fs.error) return { program: null, error: `fragment shader: ${fs.error}` };
    if (!vs.shader || !fs.shader) return { program: null, error: 'shader compile returned null' };

    const program = gl.createProgram();
    if (!program) return { program: null, error: 'gl.createProgram returned null' };
    gl.attachShader(program, vs.shader);
    gl.attachShader(program, fs.shader);
    gl.linkProgram(program);
    if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
        const log = gl.getProgramInfoLog(program) ?? 'unknown link error';
        gl.deleteProgram(program);
        return { program: null, error: `link: ${log}` };
    }
    return {
        program: {
            program,
            uResolution: gl.getUniformLocation(program, 'u_resolution'),
            uTime: gl.getUniformLocation(program, 'u_time'),
            uImage: gl.getUniformLocation(program, 'u_image'),
            uImageResolution: gl.getUniformLocation(program, 'u_image_resolution'),
            positionLoc: gl.getAttribLocation(program, 'aVertexPosition'),
        },
        error: null,
    };
}

export function makeFullScreenQuad(gl: WebGLRenderingContext): WebGLBuffer | null {
    const buf = gl.createBuffer();
    if (!buf) return null;
    gl.bindBuffer(gl.ARRAY_BUFFER, buf);
    gl.bufferData(
        gl.ARRAY_BUFFER,
        new Float32Array([
            -1, -1,  1, -1,  -1, 1,
            -1,  1,  1, -1,   1, 1,
        ]),
        gl.STATIC_DRAW,
    );
    return buf;
}
