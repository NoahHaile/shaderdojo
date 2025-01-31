
const canvas = document.getElementById("shaderCanvas");
const gl = canvas.getContext("webgl");

const vertexShaderSource = `
  attribute vec4 a_position;
  void main() {
    gl_Position = a_position;
  }
`;

const fragmentShaderHeader = `
precision mediump float;
uniform vec2 u_resolution;
uniform float u_time;

`

function createShader(gl, type, source) {
    const shader = gl.createShader(type);
    gl.shaderSource(shader, source);
    gl.compileShader(shader);
    if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
        console.error("Shader compilation error:", gl.getShaderInfoLog(shader));
        gl.deleteShader(shader);
        return null;
    }
    return shader;
}

function createProgram(gl, vertexSource, fragmentSource) {
    const vertexShader = createShader(gl, gl.VERTEX_SHADER, vertexSource);
    const fragmentShader = createShader(gl, gl.FRAGMENT_SHADER, fragmentSource);

    const program = gl.createProgram();
    gl.attachShader(program, vertexShader);
    gl.attachShader(program, fragmentShader);
    gl.linkProgram(program);

    if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
        console.error("Program linking error:", gl.getProgramInfoLog(program));
        return null;
    }
    return program;
}



function buildFragmentShader() {
    var editor = ace.edit("editor");
    let text = fragmentShaderHeader;
    if (typeof loadTexture !== "undefined" && loadTexture) {
        text += `
uniform sampler2D u_texture;
`
    }
    text += editor.getValue();
    return text;
}

function buildForWaitingFragmentShader(body) {
    let text = fragmentShaderHeader;
    if (typeof loadTexture !== "undefined" && loadTexture) {
        text += `
uniform sampler2D u_texture;
`
    }
    text += body;
    return text;
}

let program = null;
function buildProgram() {
    const fragmentShaderSource = buildFragmentShader();
    if (program != null)
        gl.deleteProgram(program);
    program = createProgram(gl, vertexShaderSource, fragmentShaderSource);
    gl.useProgram(program);
}

function buildWaitingProgram(body) {
    const fragmentShaderSource = buildForWaitingFragmentShader(body);
    if (program != null)
        gl.deleteProgram(program);
    program = createProgram(gl, vertexShaderSource, fragmentShaderSource);
    gl.useProgram(program);
}


let imageTexture = null;
function buildImageTexture() {
    imageTexture = loadTexture(gl);
}
if (typeof loadTexture !== "undefined" && loadTexture) {
    buildImageTexture();
}

function attachImageTexture() {
    const textureLocation = gl.getUniformLocation(program, "u_texture");
    gl.activeTexture(gl.TEXTURE1);
    gl.bindTexture(gl.TEXTURE_2D, imageTexture);
    gl.uniform1i(textureLocation, 1);
}


let positionBuffer = null;
function buildPositionBuffer() {
    positionBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);
    gl.bufferData(
        gl.ARRAY_BUFFER,
        new Float32Array([
            -1, -1,
            1, -1,
            -1, 1,
            -1, 1,
            1, -1,
            1, 1,
        ]),
        gl.STATIC_DRAW
    );
}
buildPositionBuffer();


function attachPositionBuffer() {
    const positionAttributeLocation = gl.getAttribLocation(program, "a_position");
    gl.enableVertexAttribArray(positionAttributeLocation);
    gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);
    gl.vertexAttribPointer(positionAttributeLocation, 2, gl.FLOAT, false, 0, 0);
}

async function cleanupWebGL() {
    currentProcess++;
    gl.useProgram(null);
    gl.bindBuffer(gl.ARRAY_BUFFER, null);
    gl.bindTexture(gl.TEXTURE_2D, null);
    gl.bindFramebuffer(gl.FRAMEBUFFER, null);

    console.log("WebGL resources cleaned up.");
}

function wait(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function runNewShader() {
    await cleanupWebGL();
    runShader();
}

let frameBuffer;
function buildFrameBuffer() {
    framebuffer = gl.createFramebuffer();
}
buildFrameBuffer();

function attachFrameBuffer() {
    gl.bindFramebuffer(gl.FRAMEBUFFER, framebuffer);

    const offscreenTexture = gl.createTexture();
    gl.bindTexture(gl.TEXTURE_2D, offscreenTexture);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, canvas.width, canvas.height, 0, gl.RGBA, gl.UNSIGNED_BYTE, null);

    // Set texture parameters
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);

    // Attach the texture to the framebuffer
    gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, offscreenTexture, 0);

    // Check framebuffer status
    if (gl.checkFramebufferStatus(gl.FRAMEBUFFER) !== gl.FRAMEBUFFER_COMPLETE) {
        console.error("Framebuffer is not complete");
        return;
    }

}