
function runShader() {

    const processId = currentProcess;
    buildProgram();
    if (typeof loadTexture !== 'undefined' && loadTexture) {
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

        if (typeof textureReady !== 'undefined' && textureReady != null && textureReady == false) {
            console.log("Texture not ready");
            requestAnimationFrame(renderLoop);
            return;
        }

        if (!paused) {
            gl.viewport(0, 0, canvas.width, canvas.height);
            gl.clear(gl.COLOR_BUFFER_BIT);

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
runNewShader();


async function submitShader() {
    await cleanupWebGL();
    const processId = currentProcess;

    buildProgram();
    attachPositionBuffer();
    const resolutionLocation = gl.getUniformLocation(program, "u_resolution");
    const timeLocation = gl.getUniformLocation(program, "u_time");
    attachFrameBuffer();

    async function renderLoop() {

        if (currentProcess !== processId) {
            gl.clear(gl.COLOR_BUFFER_BIT);
            return "error";
        }

        const error = gl.getError();
        if (error !== gl.NO_ERROR) {
            console.error("WebGL Error:", error);
            return "error";
        }


        if (typeof textureReady !== 'undefined' && textureReady != null && textureReady == false) {
            console.log("Texture not ready");
            renderLoop();
            return;
        }

        if (typeof loadTexture !== 'undefined' && loadTexture) {
            attachImageTexture();
        }
        const results = await Promise.all(timeList.map(async t => {
            gl.viewport(0, 0, canvas.width, canvas.height);
            gl.clearColor(0, 0, 0, 1);
            gl.clear(gl.COLOR_BUFFER_BIT);

            gl.uniform2f(resolutionLocation, 800, 600);
            gl.uniform1f(timeLocation, t);

            gl.drawArrays(gl.TRIANGLES, 0, 6);
            const pixels = new Uint8Array(800 * 600 * 4); // RGBA
            gl.readPixels(0, 0, 800, 600, gl.RGBA, gl.UNSIGNED_BYTE, pixels);

            return sha256(pixels);
        }));

        return results;
    }

    modalProcessStart();
    const results = await renderLoop();
    const pixelString = results.join('');

    const finalRes = sha256(pixelString);
    console.log(finalRes);

    setModalMessage("Verifying With Server...");

    verifyShaderOutput(finalRes);
    runNewShader();
}