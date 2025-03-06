const express = require('express');
const bodyParser = require('body-parser');
const puppeteer = require('puppeteer');
const crypto = require('crypto');
const path = require('path');
const fs = require('fs');

const app = express();
const port = 3000;

// Middleware to parse JSON bodies
app.use(bodyParser.json());

// Serve static files (e.g., HTML, CSS, JS)
app.use(express.static('public'));

// Ensure the temp directory exists
const tempDir = path.join(__dirname, 'temp');
if (!fs.existsSync(tempDir)) {
    fs.mkdirSync(tempDir);
}

// Global browser instance
let browser;
(async () => {
    browser = await puppeteer.launch({
        headless: true,
        args: ['--no-sandbox', '--disable-setuid-sandbox']
    });
})();

// Endpoint to execute shader code
app.post('/execute-shader', async (req, res) => {
    const { vertexShader, fragmentShader, time } = req.body;

    if (!vertexShader || !fragmentShader) {
        return res.status(400).json({ error: 'Vertex and fragment shaders are required.' });
    }

    // Generate unique file names
    const randomId = crypto.randomBytes(8).toString('hex'); // Random ID for this request
    const htmlFileName = `shader_${randomId}.html`;
    const htmlFilePath = path.join(tempDir, htmlFileName);

    try {
        // Generate the HTML file for the shader
        const htmlContent = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>WebGL Shader</title>
  <style>
    body { margin: 0; }
    /* Optional CSS styling */
    canvas { display: block; }
  </style>
</head>
<body>
  <!-- Set the canvas dimensions with attributes -->
  <canvas id="glcanvas" width="400" height="400"></canvas>
  <script>
    const canvas = document.getElementById('glcanvas');
    const gl = canvas.getContext('webgl');
    if (!gl) {
      console.error('WebGL not supported');
    }
    
    // Set the viewport to match the canvas dimensions
    gl.viewport(0, 0, canvas.width, canvas.height);
    
    // Set a default clear color (black) and clear the canvas
    gl.clearColor(0.0, 0.0, 0.0, 1.0);
    gl.clear(gl.COLOR_BUFFER_BIT);

    // Vertex Shader source
    const vsSource = \`${vertexShader}\`;

    // Fragment Shader source
    const fsSource = \`${fragmentShader}\`;

    // Compile Shader Function
    function compileShader(gl, source, type) {
      const shader = gl.createShader(type);
      gl.shaderSource(shader, source);
      gl.compileShader(shader);
      if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
        console.error('Shader compilation error:', gl.getShaderInfoLog(shader));
        gl.deleteShader(shader);
        return null;
      }
      return shader;
    }

    const vertexShaderObj = compileShader(gl, vsSource, gl.VERTEX_SHADER);
    const fragmentShaderObj = compileShader(gl, fsSource, gl.FRAGMENT_SHADER);

    // Create and link the shader program
    const shaderProgram = gl.createProgram();
    gl.attachShader(shaderProgram, vertexShaderObj);
    gl.attachShader(shaderProgram, fragmentShaderObj);
    gl.linkProgram(shaderProgram);
    if (!gl.getProgramParameter(shaderProgram, gl.LINK_STATUS)) {
      console.error('Program linking error:', gl.getProgramInfoLog(shaderProgram));
    }

    gl.useProgram(shaderProgram);

    // Set up geometry (a simple rectangle covering the canvas)
    const positionBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);
    const positions = [
      -1.0, -1.0,
       1.0, -1.0,
      -1.0,  1.0,
       1.0,  1.0,
    ];
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(positions), gl.STATIC_DRAW);

    // Look up the attribute location in the shader
    const positionAttributeLocation = gl.getAttribLocation(shaderProgram, 'aVertexPosition');
    gl.enableVertexAttribArray(positionAttributeLocation);
    gl.vertexAttribPointer(positionAttributeLocation, 2, gl.FLOAT, false, 0, 0);

    // Set uniforms (if your shader expects a uTime uniform)
    const timeUniformLocation = gl.getUniformLocation(shaderProgram, 'uTime');
    const timeValue = ${time ? time : '0.0'};
    gl.uniform1f(timeUniformLocation, timeValue);

    // Clear and draw the rectangle
    gl.clear(gl.COLOR_BUFFER_BIT);
    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);

    // Signal that rendering is complete
    window.renderComplete = true;
  </script>
</body>
</html>
`;

        // Write the HTML file
        fs.writeFileSync(htmlFilePath, htmlContent);

        // Track rendering start time
        const startTime = Date.now();

        // Launch Puppeteer and capture the output
        const page = await browser.newPage();
        await page.goto(`file://${htmlFilePath}`);

        // Wait for rendering (adjust delay as needed)
        await new Promise(resolve => setTimeout(resolve, 44000));

        // Capture screenshot to a buffer
        const screenshotBuffer = await page.screenshot({ encoding: 'binary' });

        // Save the screenshot to a file
        const screenshotFileName = `screenshot_${randomId}.png`;
        const screenshotFilePath = path.join(tempDir, screenshotFileName);
        fs.writeFileSync(screenshotFilePath, screenshotBuffer);

        // Track rendering end time
        const endTime = Date.now();

        await page.close();

        // Clean up the HTML file
        fs.unlinkSync(htmlFilePath);

        console.log(`Shader rendered in ${endTime - startTime}ms. Screenshot saved to ${screenshotFilePath}`);

        // Send the image buffer as the response
        res.set('Content-Type', 'image/png');
        res.send(screenshotBuffer);
    } catch (error) {
        console.error('Error executing shader:', error);
        res.status(500).json({ error: 'Failed to execute shader.' });
        if (fs.existsSync(htmlFilePath)) fs.unlinkSync(htmlFilePath);
    }
});

// Start the server
app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
});
