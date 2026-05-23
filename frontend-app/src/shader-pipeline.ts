// WebGL primitives kept deliberately framework-free.
//
// The header MUST stay byte-identical to backend/api/src/validator.service.ts's
// FRAGMENT_HEADER and to the legacy frontend's `fragmentShaderHeader`, or hash
// equality with the validator's canonical render will break.

export const FRAGMENT_HEADER =
    '\nprecision mediump float;\nuniform vec2 u_resolution;\nuniform float u_time;\n\n';

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

function compile(gl: WebGLRenderingContext, type: number, src: string): WebGLShader | null {
    const s = gl.createShader(type);
    if (!s) return null;
    gl.shaderSource(s, src);
    gl.compileShader(s);
    if (!gl.getShaderParameter(s, gl.COMPILE_STATUS)) {
        const log = gl.getShaderInfoLog(s);
        console.warn('Shader compile error:', log);
        gl.deleteShader(s);
        return null;
    }
    return s;
}

export interface ShaderProgram {
    program: WebGLProgram;
    uResolution: WebGLUniformLocation | null;
    uTime: WebGLUniformLocation | null;
    positionLoc: number;
}

export function createProgram(gl: WebGLRenderingContext, vsSource: string, fsSource: string): ShaderProgram | null {
    const vs = compile(gl, gl.VERTEX_SHADER, vsSource);
    const fs = compile(gl, gl.FRAGMENT_SHADER, fsSource);
    if (!vs || !fs) return null;

    const program = gl.createProgram();
    if (!program) return null;
    gl.attachShader(program, vs);
    gl.attachShader(program, fs);
    gl.linkProgram(program);
    if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
        console.warn('Program link error:', gl.getProgramInfoLog(program));
        gl.deleteProgram(program);
        return null;
    }
    return {
        program,
        uResolution: gl.getUniformLocation(program, 'u_resolution'),
        uTime: gl.getUniformLocation(program, 'u_time'),
        positionLoc: gl.getAttribLocation(program, 'aVertexPosition'),
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
