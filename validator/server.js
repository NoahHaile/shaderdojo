
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

// Global browser instance
let browser;
(async () => {
  browser = await puppeteer.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });
})();

let locked = false; // Lock flag
const MAX_RETRIES = 5; // Maximum retry attempts

app.post('/execute-shader', async (req, res) => {
  let attempts = 0;

  function tryExecute() {
    if (!locked) {
      locked = true;
      return executeShader(req, res)
        .finally(() => {
          // Always unlock after executeShader completes
          locked = false;
        });
    }

    if (attempts >= MAX_RETRIES) {
      return res
        .status(429)
        .json({ error: 'Server is busy, please try again later.' });
    }

    attempts++;
    const delay = Math.floor(Math.random() * 2000) + 1000;
    console.log(`Request is locked. Retrying in ${delay} ms... (Attempt ${attempts})`);
    setTimeout(tryExecute, delay);
  }

  tryExecute();
});

async function executeShader(req, res) {
  const { vertexShader, fragmentShader, time } = req.body;

  if (!vertexShader || !fragmentShader) {
    return res
      .status(400)
      .json({ error: 'Vertex and fragment shaders are required.' });
  }

  const randomId = crypto.randomBytes(8).toString('hex');
  const htmlFileName = `shader_${randomId}.html`;
  const htmlFilePath = path.join(__dirname, 'temp', htmlFileName);
  let page; // To keep track of the Puppeteer page

  try {
    const htmlContent = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>WebGL Shader</title>
  <style>body { margin: 0; } canvas { display: block; }</style>
</head>
<body>
  <canvas id="glcanvas" width="400" height="400"></canvas>
  <script>
    const canvas = document.getElementById('glcanvas');
    const gl = canvas.getContext('webgl');
    if (!gl) { console.error('WebGL not supported'); }

    gl.viewport(0, 0, canvas.width, canvas.height);
    gl.clearColor(0.0, 0.0, 0.0, 1.0);
    gl.clear(gl.COLOR_BUFFER_BIT);

    const vsSource = \`${vertexShader}\`;
    const fsSource = \`${fragmentShader}\`;

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

    const shaderProgram = gl.createProgram();
    gl.attachShader(shaderProgram, vertexShaderObj);
    gl.attachShader(shaderProgram, fragmentShaderObj);
    gl.linkProgram(shaderProgram);
    if (!gl.getProgramParameter(shaderProgram, gl.LINK_STATUS)) {
      console.error('Program linking error:', gl.getProgramInfoLog(shaderProgram));
    }

    gl.useProgram(shaderProgram);

    const positionBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);
    const positions = [-1.0, -1.0, 1.0, -1.0, -1.0, 1.0, 1.0, 1.0];
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(positions), gl.STATIC_DRAW);

    const positionAttributeLocation = gl.getAttribLocation(shaderProgram, 'aVertexPosition');
    gl.enableVertexAttribArray(positionAttributeLocation);
    gl.vertexAttribPointer(positionAttributeLocation, 2, gl.FLOAT, false, 0, 0);

    const timeUniformLocation = gl.getUniformLocation(shaderProgram, 'u_time');
    const timeValue = ${time ? time : '0.0'};
    gl.uniform1f(timeUniformLocation, timeValue);

    const resolutionUniformLocation = gl.getUniformLocation(shaderProgram, 'u_resolution');
    gl.uniform2f(resolutionUniformLocation, canvas.width, canvas.height);

    gl.clear(gl.COLOR_BUFFER_BIT);
    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);

    window.renderComplete = true;
  </script>
</body>
</html>
`;

    // Write the HTML content to a temporary file.
    fs.writeFileSync(htmlFilePath, htmlContent);

    const startTime = Date.now();

    // Open a new browser page.
    page = await browser.newPage();
    await page.goto(`file://${htmlFilePath}`);

    // Wait for the shader to render.
    await new Promise(resolve => setTimeout(resolve, 3000));

    // Take a screenshot of the rendered shader.
    const screenshotBuffer = await page.screenshot({ encoding: 'binary' });
    const endTime = Date.now();

    // Calculate a hash of the screenshot.
    const hash = crypto.createHash('sha256').update(screenshotBuffer).digest('hex');

    // Return shader execution details.
    res.json({
      hash,
      startTime,
      endTime,
      renderingTime: endTime - startTime,
    });
  } catch (error) {
    console.error('Error executing shader:', error);
    if (!res.headersSent) {
      res.status(500).json({ error: 'Failed to execute shader.' });
    }
  } finally {
    // Ensure the browser page is closed if it was opened.
    if (page) {
      try {
        await page.close();
      } catch (e) {
        console.error('Error closing browser page:', e);
      }
    }

    // Remove the temporary HTML file if it exists.
    if (fs.existsSync(htmlFilePath)) {
      try {
        fs.unlinkSync(htmlFilePath);
      } catch (e) {
        console.error('Error deleting temporary file:', e);
      }
    }
  }
}


// Start the server
app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});