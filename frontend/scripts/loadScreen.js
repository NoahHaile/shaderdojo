
let fragmentShaderLoadingBodySource = `
// Original shader by Danilo Guanabara
void main() {
    vec3 c;
    float l, z = u_time;
    vec2 fragCoord = gl_FragCoord.xy;
    
    for(int i = 0; i < 3; i++) {
        vec2 uv, p = fragCoord / u_resolution.xy;
        uv = p;
        p -= 0.5;
        p.x *= u_resolution.x / u_resolution.y;
        z += 0.07;
        l = length(p);
        uv += p / l * (sin(z) + 1.0) * abs(sin(l * 9.0 - z - z));
        c[i] = 0.01 / length(mod(uv, 1.0) - 0.5);
    }
    
    gl_FragColor = vec4(c / l, u_time);
}
`


function runWaitingShader() {

    const processId = currentProcess;
    buildWaitingProgram(fragmentShaderLoadingBodySource);
    if (typeof loadTexture !== "undefined" && loadTexture) {
        attachImageTexture();
    }
    attachPositionBuffer();

    const resolutionLocation = gl.getUniformLocation(program, "u_resolution");
    const timeLocation = gl.getUniformLocation(program, "u_time");

    playShader();
    function renderLoop(time) {

        if (currentProcess !== processId) {
            gl.clear(gl.COLOR_BUFFER_BIT);
            return;
        }

        const error = gl.getError();
        if (error !== gl.NO_ERROR) {
            console.error("WebGL Error:", error);
            return;
        }

        if (typeof loadTexture !== "undefined" && loadTexture && textureReady != null && textureReady == false) {
            console.log("Texture not ready");
            requestAnimationFrame(renderLoop);
            return;
        }

        if (!paused) {
            gl.viewport(0, 0, canvas.width, canvas.height);


            gl.uniform2f(resolutionLocation, canvas.width, canvas.height);
            if (!startTime) {
                startTime = time * 0.001 - offset;
            }
            gl.uniform1f(timeLocation, time * 0.001 - startTime);
            setTrackedTime(time * 0.001 - startTime);

            gl.drawArrays(gl.TRIANGLES, 0, 6);
        }
        requestAnimationFrame(renderLoop);
    }
    requestAnimationFrame(renderLoop);
}

runWaitingShader();

