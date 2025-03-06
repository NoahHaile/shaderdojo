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

// Endpoint to execute shader code
app.post('/execute-shader', async (req, res) => {
    const { vertexShader, fragmentShader, time } = req.body;

    if (!vertexShader || !fragmentShader) {
        return res.status(400).json({ error: 'Vertex and fragment shaders are required.' });
    }

    // Generate unique file names
    const randomId = crypto.randomBytes(8).toString('hex'); // Random ID for this request
    const htmlFileName = `shader_${randomId}.html`;
    const htmlFilePath = path.join(__dirname, 'temp', htmlFileName);

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
            canvas { display: block; }
          </style>
        </head>
        <body>
          <canvas id="glcanvas"></canvas>
          <script>
            const canvas = document.getElementById('glcanvas');
            const gl = canvas.getContext('webgl');
      
            // Vertex Shader
            const vsSource = \`${vertexShader}\`;
      
            // Fragment Shader
            const fsSource = \`${fragmentShader}\`;
      
            // Compile Shader
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
      
            const vertexShader = compileShader(gl, vsSource, gl.VERTEX_SHADER);
            const fragmentShader = compileShader(gl, fsSource, gl.FRAGMENT_SHADER);
      
            // Create Program
            const shaderProgram = gl.createProgram();
            gl.attachShader(shaderProgram, vertexShader);
            gl.attachShader(shaderProgram, fragmentShader);
            gl.linkProgram(shaderProgram);
            if (!gl.getProgramParameter(shaderProgram, gl.LINK_STATUS)) {
              console.error('Program linking error:', gl.getProgramInfoLog(shaderProgram));
            }
      
            gl.useProgram(shaderProgram);
      
            // Set Up Geometry
            const positionBuffer = gl.createBuffer();
            gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);
            const positions = [
              -1.0, -1.0,
               1.0, -1.0,
              -1.0,  1.0,
               1.0,  1.0,
            ];
            gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(positions), gl.STATIC_DRAW);
      
            const positionAttributeLocation = gl.getAttribLocation(shaderProgram, 'aVertexPosition');
            gl.enableVertexAttribArray(positionAttributeLocation);
            gl.vertexAttribPointer(positionAttributeLocation, 2, gl.FLOAT, false, 0, 0);
      
            // Uniforms
            const timeUniformLocation = gl.getUniformLocation(shaderProgram, 'uTime');
      
            // Render at the exact time
            const time = ${time ? time : '0.0'};
            gl.uniform1f(timeUniformLocation, time);
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

        // Wait for rendering
        await new Promise(resolve => setTimeout(resolve, 6000));

        // Capture screenshot to a buffer
        const screenshotBuffer = await page.screenshot({ encoding: 'binary' });

        // Track rendering end time
        const endTime = Date.now();

        await page.close();

        // Hash the buffer
        const hash = crypto.createHash('sha256').update(screenshotBuffer).digest('hex');

        // Clean up the HTML file
        fs.unlinkSync(htmlFilePath);

        // Send the response
        res.json({
            hash,
            startTime,
            endTime,
            renderingTime: endTime - startTime, // Time taken to render (in milliseconds)
        });
    } catch (error) {
        console.error('Error executing shader:', error);
        res.status(500).json({ error: 'Failed to execute shader.' });

        // Clean up temporary files in case of an error
        if (fs.existsSync(htmlFilePath)) fs.unlinkSync(htmlFilePath);
    }
});

// Start the server
app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
});