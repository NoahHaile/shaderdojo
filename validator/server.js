const express = require('express');
const puppeteer = require('puppeteer');
const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

const PORT = parseInt(process.env.PORT || '3000', 10);
const VALIDATOR_KEY = process.env.VALIDATOR_KEY;
const MAX_CONCURRENT_RENDERS = parseInt(process.env.MAX_CONCURRENT_RENDERS || '2', 10);
const QUEUE_WAIT_TIMEOUT_MS = parseInt(process.env.QUEUE_WAIT_TIMEOUT_MS || '8000', 10);
const RENDER_TIMEOUT_MS = parseInt(process.env.RENDER_TIMEOUT_MS || '5000', 10);
const RENDER_SETTLE_MS = parseInt(process.env.RENDER_SETTLE_MS || '150', 10);
const MAX_SHADER_BYTES = parseInt(process.env.MAX_SHADER_BYTES || (32 * 1024).toString(), 10);
const BODY_LIMIT = `${Math.max(64, Math.ceil((MAX_SHADER_BYTES * 2) / 1024)) + 4}kb`;

// Bundled lesson texture. Bound to texture unit 0 on every render as `u_image`.
// Must be byte-identical to frontend-app/public/textures/lesson-image.png so
// the student preview and the hashed render see the same pixels.
const LESSON_IMAGE_PATH = path.join(__dirname, 'textures', 'lesson-image.png');
let LESSON_IMAGE_DATA_URL = null;
let LESSON_IMAGE_W = 0;
let LESSON_IMAGE_H = 0;
try {
    const buf = fs.readFileSync(LESSON_IMAGE_PATH);
    // PNG IHDR sits at bytes 16..24 (4-byte width, 4-byte height, big-endian).
    LESSON_IMAGE_W = buf.readUInt32BE(16);
    LESSON_IMAGE_H = buf.readUInt32BE(20);
    LESSON_IMAGE_DATA_URL = 'data:image/png;base64,' + buf.toString('base64');
    console.log(`Loaded lesson texture: ${LESSON_IMAGE_W}x${LESSON_IMAGE_H}, ${buf.length} bytes`);
} catch (e) {
    console.error('FATAL: failed to load lesson texture from ' + LESSON_IMAGE_PATH + ': ' + e.message);
    process.exit(1);
}

if (!VALIDATOR_KEY) {
    console.error('FATAL: VALIDATOR_KEY env var is required');
    process.exit(1);
}

const app = express();
app.use(express.json({ limit: BODY_LIMIT }));

app.get('/health', (_req, res) => res.json({ ok: true }));

app.use((req, res, next) => {
    const provided = req.get('X-Validator-Key') || '';
    const a = Buffer.from(provided);
    const b = Buffer.from(VALIDATOR_KEY);
    if (a.length !== b.length || !crypto.timingSafeEqual(a, b)) {
        return res.status(401).json({ error: 'Unauthorized' });
    }
    next();
});

let browserPromise = null;
async function getBrowser() {
    if (browserPromise) {
        try {
            const b = await browserPromise;
            if (b && b.connected !== false) return b;
        } catch { /* fall through and relaunch */ }
        browserPromise = null;
    }
    // --no-sandbox / --disable-setuid-sandbox: Ubuntu 22.04+ on most cloud hosts
    // (incl. DigitalOcean droplets) locks down unprivileged user namespaces via
    // AppArmor, so Chromium's own sandbox can't initialize. The validator is
    // already isolated inside a Docker container running as the non-root
    // `pptruser`, with no network access to the DB or any other service, which
    // is the effective sandbox boundary. See:
    //   https://chromium.googlesource.com/chromium/src/+/main/docs/security/apparmor-userns-restrictions.md
    browserPromise = puppeteer.launch({
        headless: 'new',
        args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage'],
    });
    const b = await browserPromise;
    b.on('disconnected', () => { browserPromise = null; });
    return b;
}

let activeRenders = 0;
const waiters = [];
function acquireSlot() {
    return new Promise((resolve, reject) => {
        if (activeRenders < MAX_CONCURRENT_RENDERS) {
            activeRenders++;
            return resolve();
        }
        const entry = { resolve, reject };
        entry.timer = setTimeout(() => {
            const i = waiters.indexOf(entry);
            if (i >= 0) waiters.splice(i, 1);
            reject(new Error('queue-timeout'));
        }, QUEUE_WAIT_TIMEOUT_MS);
        waiters.push(entry);
    });
}
function releaseSlot() {
    activeRenders--;
    if (activeRenders < 0) activeRenders = 0;
    const next = waiters.shift();
    if (next) {
        clearTimeout(next.timer);
        activeRenders++;
        next.resolve();
    }
}

const RENDER_PAGE_HTML = `<!DOCTYPE html><html><head><meta charset="utf-8"><title>r</title>
<style>body{margin:0}canvas{display:block}</style></head>
<body><canvas id="glcanvas" width="400" height="400"></canvas></body></html>`;

// Evaluated INSIDE the Puppeteer page. Arguments are JSON-serialized by Puppeteer,
// so user-supplied shader source can never escape into JS context.
async function runShaderInPage(vsSource, fsSource, timeValue, imageDataUrl, imageW, imageH) {
    const canvas = document.getElementById('glcanvas');
    const gl = canvas.getContext('webgl', { preserveDrawingBuffer: true });
    if (!gl) return { ok: false, error: 'WebGL not supported' };

    function compile(type, src) {
        const s = gl.createShader(type);
        gl.shaderSource(s, src);
        gl.compileShader(s);
        if (!gl.getShaderParameter(s, gl.COMPILE_STATUS)) {
            const log = gl.getShaderInfoLog(s) || 'unknown';
            gl.deleteShader(s);
            return { error: log };
        }
        return { shader: s };
    }

    const vs = compile(gl.VERTEX_SHADER, vsSource);
    if (vs.error) return { ok: false, error: 'vertex: ' + vs.error };
    const fs = compile(gl.FRAGMENT_SHADER, fsSource);
    if (fs.error) return { ok: false, error: 'fragment: ' + fs.error };

    const prog = gl.createProgram();
    gl.attachShader(prog, vs.shader);
    gl.attachShader(prog, fs.shader);
    gl.linkProgram(prog);
    if (!gl.getProgramParameter(prog, gl.LINK_STATUS)) {
        return { ok: false, error: 'link: ' + (gl.getProgramInfoLog(prog) || 'unknown') };
    }
    gl.useProgram(prog);

    const buf = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, buf);
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1, -1, 1, -1, -1, 1, 1, 1]), gl.STATIC_DRAW);

    const posLoc = gl.getAttribLocation(prog, 'aVertexPosition');
    if (posLoc >= 0) {
        gl.enableVertexAttribArray(posLoc);
        gl.vertexAttribPointer(posLoc, 2, gl.FLOAT, false, 0, 0);
    }
    const tLoc = gl.getUniformLocation(prog, 'u_time');
    if (tLoc) gl.uniform1f(tLoc, timeValue);
    const rLoc = gl.getUniformLocation(prog, 'u_resolution');
    if (rLoc) gl.uniform2f(rLoc, canvas.width, canvas.height);

    // Decode and upload the lesson texture before drawing. UNPACK_FLIP_Y_WEBGL
    // matches GLSL's bottom-left UV origin so texture2D(u_image, uv) reads
    // right-side-up when uv = gl_FragCoord.xy / u_resolution.xy.
    try {
        const img = new Image();
        img.src = imageDataUrl;
        await img.decode();

        const tex = gl.createTexture();
        gl.activeTexture(gl.TEXTURE0);
        gl.bindTexture(gl.TEXTURE_2D, tex);
        gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, true);
        gl.pixelStorei(gl.UNPACK_PREMULTIPLY_ALPHA_WEBGL, false);
        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, img);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);

        const iLoc = gl.getUniformLocation(prog, 'u_image');
        if (iLoc) gl.uniform1i(iLoc, 0);
        const irLoc = gl.getUniformLocation(prog, 'u_image_resolution');
        if (irLoc) gl.uniform2f(irLoc, imageW, imageH);
    } catch (err) {
        return { ok: false, error: 'texture: ' + (err && err.message || String(err)) };
    }

    gl.viewport(0, 0, canvas.width, canvas.height);
    gl.clearColor(0, 0, 0, 1);
    gl.clear(gl.COLOR_BUFFER_BIT);
    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
    gl.finish();
    return { ok: true };
}

async function renderShader({ vertexShader, fragmentShader, time }) {
    const browser = await getBrowser();
    const page = await browser.newPage();
    let timeoutHandle;
    try {
        page.setDefaultTimeout(RENDER_TIMEOUT_MS);
        page.setDefaultNavigationTimeout(RENDER_TIMEOUT_MS);
        await page.setViewport({ width: 400, height: 400, deviceScaleFactor: 1 });
        await page.setContent(RENDER_PAGE_HTML, { waitUntil: 'load' });

        const evalPromise = page.evaluate(
            runShaderInPage,
            vertexShader,
            fragmentShader,
            Number.isFinite(time) ? time : 0,
            LESSON_IMAGE_DATA_URL,
            LESSON_IMAGE_W,
            LESSON_IMAGE_H,
        );
        const timeoutPromise = new Promise((_, reject) => {
            timeoutHandle = setTimeout(() => reject(new Error('render-timeout')), RENDER_TIMEOUT_MS);
        });
        const result = await Promise.race([evalPromise, timeoutPromise]);
        if (!result || !result.ok) {
            const err = new Error('compile-failed: ' + (result && result.error ? result.error : 'unknown'));
            err.code = 'COMPILE_FAILED';
            throw err;
        }

        if (RENDER_SETTLE_MS > 0) {
            await new Promise(r => setTimeout(r, RENDER_SETTLE_MS));
        }
        return await page.screenshot({ type: 'png', omitBackground: false });
    } finally {
        if (timeoutHandle) clearTimeout(timeoutHandle);
        try { await page.close({ runBeforeUnload: false }); } catch { /* page already gone */ }
    }
}

app.post('/execute-shader', async (req, res) => {
    const { vertexShader, fragmentShader, time } = req.body || {};
    if (typeof vertexShader !== 'string' || typeof fragmentShader !== 'string') {
        return res.status(400).json({ error: 'vertexShader and fragmentShader are required.' });
    }
    if (vertexShader.length > MAX_SHADER_BYTES || fragmentShader.length > MAX_SHADER_BYTES) {
        return res.status(413).json({ error: 'Shader source too large.' });
    }
    const numericTime = typeof time === 'number' ? time : parseFloat(time);

    try {
        await acquireSlot();
    } catch (e) {
        return res.status(429).json({ error: 'Validator busy; please retry.' });
    }

    try {
        const pngBuffer = await renderShader({ vertexShader, fragmentShader, time: numericTime });
        const imageHash = crypto.createHash('sha256').update(pngBuffer).digest('hex');
        return res.json({ imageHash, byteLength: pngBuffer.length });
    } catch (e) {
        if (e && e.code === 'COMPILE_FAILED') {
            return res.status(400).json({ error: e.message });
        }
        if (e && e.message === 'render-timeout') {
            return res.status(504).json({ error: 'Shader render timed out.' });
        }
        console.error('Render error:', e && e.stack || e);
        return res.status(500).json({ error: 'Render failed.' });
    } finally {
        releaseSlot();
    }
});

const server = app.listen(PORT, () => {
    console.log(`Validator listening on :${PORT} (max concurrent renders: ${MAX_CONCURRENT_RENDERS})`);
});

async function shutdown() {
    server.close();
    try {
        if (browserPromise) {
            const b = await browserPromise;
            await b.close();
        }
    } catch { /* best effort */ }
    process.exit(0);
}
process.on('SIGTERM', shutdown);
process.on('SIGINT', shutdown);
