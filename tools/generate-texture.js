// Generates a 256x256 deterministic PNG for sampler2D demos.
// Writes the same bytes to both frontend-app/public/textures/ and validator/textures/
// so the frontend preview and the validator render see identical pixels.
//
// Run: node tools/generate-texture.js

const fs = require('fs');
const zlib = require('zlib');
const path = require('path');

const W = 256, H = 256;

// HSV gradient (hue across x, brightness from top to bottom) with a bright
// circle and a dark square overlaid. Plenty of smooth gradient + hard edges
// to demonstrate color, blur, edge, and convolution kernels.
function pixelAt(x, y) {
    const u = x / W;
    const v = y / H;

    const hue = u;
    const sat = 0.75;
    const val = 0.30 + 0.65 * v;

    let r, g, b;
    {
        const h = hue * 6;
        const i = Math.floor(h);
        const f = h - i;
        const p = val * (1 - sat);
        const q = val * (1 - f * sat);
        const t = val * (1 - (1 - f) * sat);
        switch (i % 6) {
            case 0: r = val; g = t;   b = p;   break;
            case 1: r = q;   g = val; b = p;   break;
            case 2: r = p;   g = val; b = t;   break;
            case 3: r = p;   g = q;   b = val; break;
            case 4: r = t;   g = p;   b = val; break;
            default: r = val; g = p;  b = q;   break;
        }
    }

    // White-ish circle at (0.30, 0.40), radius 0.11
    const dx1 = u - 0.30, dy1 = v - 0.40;
    const d1 = Math.sqrt(dx1 * dx1 + dy1 * dy1);
    if (d1 < 0.105) { r = g = b = 0.97; }

    // Dark square at (0.70, 0.70), half-side 0.085
    if (Math.abs(u - 0.70) < 0.085 && Math.abs(v - 0.70) < 0.085) {
        r = g = b = 0.05;
    }

    return [
        Math.max(0, Math.min(255, Math.round(r * 255))),
        Math.max(0, Math.min(255, Math.round(g * 255))),
        Math.max(0, Math.min(255, Math.round(b * 255))),
    ];
}

// Filtered raw stream: 1 filter byte (None=0) per row + RGB triples.
const raw = Buffer.alloc(H * (W * 3 + 1));
let p = 0;
for (let y = 0; y < H; y++) {
    raw[p++] = 0;
    for (let x = 0; x < W; x++) {
        const rgb = pixelAt(x, y);
        raw[p++] = rgb[0];
        raw[p++] = rgb[1];
        raw[p++] = rgb[2];
    }
}

const idat = zlib.deflateSync(raw, { level: 9 });

function crc32(buf) {
    let c = 0xffffffff;
    for (let i = 0; i < buf.length; i++) {
        c ^= buf[i];
        for (let k = 0; k < 8; k++) c = (c >>> 1) ^ (0xedb88320 & -(c & 1));
    }
    return (c ^ 0xffffffff) >>> 0;
}
function chunk(type, data) {
    const len = Buffer.alloc(4); len.writeUInt32BE(data.length, 0);
    const typ = Buffer.from(type, 'ascii');
    const body = Buffer.concat([typ, data]);
    const crc = Buffer.alloc(4); crc.writeUInt32BE(crc32(body), 0);
    return Buffer.concat([len, body, crc]);
}

const SIG = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);
const ihdr = Buffer.alloc(13);
ihdr.writeUInt32BE(W, 0);
ihdr.writeUInt32BE(H, 4);
ihdr[8] = 8;   // 8-bit depth
ihdr[9] = 2;   // colour type: truecolour (RGB)
ihdr[10] = 0;  // compression: deflate
ihdr[11] = 0;  // filter method: 0
ihdr[12] = 0;  // interlace: none

const png = Buffer.concat([
    SIG,
    chunk('IHDR', ihdr),
    chunk('IDAT', idat),
    chunk('IEND', Buffer.alloc(0)),
]);

const repoRoot = path.join(__dirname, '..');
const targets = [
    path.join(repoRoot, 'frontend-app', 'public', 'textures', 'lesson-image.png'),
    path.join(repoRoot, 'validator',     'textures',          'lesson-image.png'),
];
for (const t of targets) {
    fs.mkdirSync(path.dirname(t), { recursive: true });
    fs.writeFileSync(t, png);
    console.log(`wrote ${t} (${png.length} bytes)`);
}
