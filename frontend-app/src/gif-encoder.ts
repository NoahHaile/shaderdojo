// Self-contained animated-GIF encoder. No dependencies, no web worker.
//
// Used by the lesson page's "Download GIF" action: ShaderCanvas hands back a
// list of RGBA frames read straight off the WebGL backbuffer, and encodeGif
// turns them into a looping image/gif Blob.
//
// Pipeline per call: box-downscale + vertical flip (WebGL readPixels is
// bottom-up) -> a single global 256-colour palette via median cut -> nearest-
// colour mapping with a 15-bit cache -> GIF LZW -> GIF89a assembly with a
// NETSCAPE2.0 loop block. Quality is tuned for the smooth colour fields this
// app produces; the palette is global so the loop stays visually stable.

/** One frame as read from the GL backbuffer: tightly-packed RGBA, bottom-up. */
export interface RgbaFrame {
    data: Uint8Array;
    width: number;
    height: number;
}

export interface CaptureResult {
    frames: RgbaFrame[];
    fps: number;
}

export interface EncodeOptions {
    fps: number;
    /** Longest output edge in pixels; frames are box-downscaled to fit. */
    maxSize?: number;
}

// ─── frame prep: box-average downscale + Y flip + drop alpha ──────────────
function prepFrame(rgba: Uint8Array, w: number, h: number, tw: number, th: number): Uint8Array {
    const out = new Uint8Array(tw * th * 3);
    for (let y = 0; y < th; y++) {
        const sy0 = Math.floor((y * h) / th);
        const sy1 = Math.max(sy0 + 1, Math.floor(((y + 1) * h) / th));
        for (let x = 0; x < tw; x++) {
            const sx0 = Math.floor((x * w) / tw);
            const sx1 = Math.max(sx0 + 1, Math.floor(((x + 1) * w) / tw));
            let r = 0, g = 0, b = 0, n = 0;
            for (let syy = sy0; syy < sy1 && syy < h; syy++) {
                const srcY = h - 1 - syy;            // flip: readPixels is bottom-up
                for (let sxx = sx0; sxx < sx1 && sxx < w; sxx++) {
                    const si = (srcY * w + sxx) * 4;
                    r += rgba[si]; g += rgba[si + 1]; b += rgba[si + 2]; n++;
                }
            }
            const di = (y * tw + x) * 3;
            out[di] = (r / n) | 0;
            out[di + 1] = (g / n) | 0;
            out[di + 2] = (b / n) | 0;
        }
    }
    return out;
}

// ─── median-cut quantisation -> global palette of <=256 colours ───────────
interface Box { start: number; end: number; channel: number; range: number; }

function chan(v: number, c: number): number {
    return c === 0 ? (v >> 16) & 255 : c === 1 ? (v >> 8) & 255 : v & 255;
}

function buildPalette(frames: Uint8Array[], maxColors: number): { table: Uint8Array; count: number } {
    let total = 0;
    for (const f of frames) total += f.length / 3;
    const cap = 24000;
    const step = Math.max(1, Math.floor(total / cap));

    const ptsArr: number[] = [];
    let counter = 0;
    for (const f of frames) {
        for (let p = 0; p < f.length; p += 3) {
            if (counter++ % step !== 0) continue;
            ptsArr.push((f[p] << 16) | (f[p + 1] << 8) | f[p + 2]);
        }
    }
    const table = new Uint8Array(maxColors * 3);
    if (ptsArr.length === 0) return { table, count: 1 };
    const pts = Int32Array.from(ptsArr);

    const range = (start: number, end: number): { channel: number; range: number } => {
        let rmin = 255, rmax = 0, gmin = 255, gmax = 0, bmin = 255, bmax = 0;
        for (let i = start; i < end; i++) {
            const v = pts[i];
            const r = (v >> 16) & 255, g = (v >> 8) & 255, b = v & 255;
            if (r < rmin) rmin = r; if (r > rmax) rmax = r;
            if (g < gmin) gmin = g; if (g > gmax) gmax = g;
            if (b < bmin) bmin = b; if (b > bmax) bmax = b;
        }
        const dr = rmax - rmin, dg = gmax - gmin, db = bmax - bmin;
        const m = Math.max(dr, dg, db);
        return { channel: m === dr ? 0 : m === dg ? 1 : 2, range: m };
    };
    const makeBox = (start: number, end: number): Box => ({ start, end, ...range(start, end) });

    const boxes: Box[] = [makeBox(0, pts.length)];
    while (boxes.length < maxColors) {
        let bi = -1, best = -1;
        for (let i = 0; i < boxes.length; i++) {
            const b = boxes[i];
            if (b.end - b.start >= 2 && b.range > best) { best = b.range; bi = i; }
        }
        if (bi < 0) break;
        const b = boxes[bi];
        const ch = b.channel;
        pts.subarray(b.start, b.end).sort((x, y) => chan(x, ch) - chan(y, ch));
        const mid = (b.start + b.end) >> 1;
        boxes.splice(bi, 1, makeBox(b.start, mid), makeBox(mid, b.end));
    }

    for (let i = 0; i < boxes.length; i++) {
        const b = boxes[i];
        let r = 0, g = 0, bl = 0;
        const n = b.end - b.start;
        for (let j = b.start; j < b.end; j++) {
            const v = pts[j];
            r += (v >> 16) & 255; g += (v >> 8) & 255; bl += v & 255;
        }
        table[i * 3] = Math.round(r / n);
        table[i * 3 + 1] = Math.round(g / n);
        table[i * 3 + 2] = Math.round(bl / n);
    }
    return { table, count: boxes.length };
}

function makeMapper(table: Uint8Array, count: number): (r: number, g: number, b: number) => number {
    const cache = new Int16Array(32768).fill(-1);
    return (r, g, b) => {
        const key = ((r >> 3) << 10) | ((g >> 3) << 5) | (b >> 3);
        const hit = cache[key];
        if (hit >= 0) return hit;
        let bestD = Infinity, bi = 0;
        for (let i = 0; i < count; i++) {
            const dr = r - table[i * 3], dg = g - table[i * 3 + 1], db = b - table[i * 3 + 2];
            const d = dr * dr + dg * dg + db * db;
            if (d < bestD) { bestD = d; bi = i; }
        }
        cache[key] = bi;
        return bi;
    };
}

// ─── GIF LZW (variable-width, LSB-first), one frame's index stream ────────
function lzwEncode(indices: Uint8Array, minCodeSize: number): number[] {
    const clearCode = 1 << minCodeSize;
    const eoiCode = clearCode + 1;
    let codeSize = minCodeSize + 1;
    let nextCode = eoiCode + 1;
    let dict = new Map<number, number>();

    const out: number[] = [];
    let cur = 0, curBits = 0;
    const emit = (code: number) => {
        cur |= code << curBits;
        curBits += codeSize;
        while (curBits >= 8) { out.push(cur & 0xff); cur >>= 8; curBits -= 8; }
    };

    emit(clearCode);
    let prev = indices[0];
    for (let i = 1; i < indices.length; i++) {
        const k = indices[i];
        const key = (prev << 8) | k;
        const code = dict.get(key);
        if (code !== undefined) {
            prev = code;
        } else {
            emit(prev);
            if (nextCode === 4096) {
                emit(clearCode);
                dict = new Map();
                nextCode = eoiCode + 1;
                codeSize = minCodeSize + 1;
            } else {
                if (nextCode >= (1 << codeSize)) codeSize++;
                dict.set(key, nextCode++);
            }
            prev = k;
        }
    }
    emit(prev);
    emit(eoiCode);
    if (curBits > 0) out.push(cur & 0xff);
    return out;
}

function writeSubBlocks(out: number[], bytes: number[]): void {
    let i = 0;
    while (i < bytes.length) {
        const n = Math.min(255, bytes.length - i);
        out.push(n);
        for (let j = 0; j < n; j++) out.push(bytes[i + j]);
        i += n;
    }
    out.push(0);
}

// ─── public entry point ──────────────────────────────────────────────────
export function encodeGif(frames: RgbaFrame[], opts: EncodeOptions): Blob {
    if (frames.length === 0) return new Blob([new Uint8Array([0x47, 0x49, 0x46])], { type: 'image/gif' });

    const maxSize = opts.maxSize ?? 360;
    const { width: w, height: h } = frames[0];
    const scale = Math.min(1, maxSize / Math.max(w, h));
    const tw = Math.max(1, Math.round(w * scale));
    const th = Math.max(1, Math.round(h * scale));

    const prepped = frames.map(f => prepFrame(f.data, f.width, f.height, tw, th));
    const { table, count } = buildPalette(prepped, 256);
    const map = makeMapper(table, count);
    const delay = Math.max(2, Math.round(1000 / opts.fps / 10));   // centiseconds

    const out: number[] = [];
    const u16 = (v: number) => out.push(v & 0xff, (v >> 8) & 0xff);
    const str = (s: string) => { for (let i = 0; i < s.length; i++) out.push(s.charCodeAt(i)); };

    str('GIF89a');
    u16(tw); u16(th);
    out.push(0xf7, 0x00, 0x00);                  // 256-colour global table flag, bg, aspect
    for (let i = 0; i < 768; i++) out.push(table[i]);
    out.push(0x21, 0xff, 0x0b);                  // NETSCAPE2.0 loop extension
    str('NETSCAPE2.0');
    out.push(0x03, 0x01, 0x00, 0x00, 0x00);      // loop forever

    for (const f of prepped) {
        out.push(0x21, 0xf9, 0x04, 0x00); u16(delay); out.push(0x00, 0x00);   // graphic control
        out.push(0x2c); u16(0); u16(0); u16(tw); u16(th); out.push(0x00);     // image descriptor
        const idx = new Uint8Array(tw * th);
        for (let p = 0, pi = 0; p < f.length; p += 3, pi++) idx[pi] = map(f[p], f[p + 1], f[p + 2]);
        out.push(0x08);                          // LZW minimum code size
        writeSubBlocks(out, lzwEncode(idx, 8));
    }
    out.push(0x3b);                              // trailer

    return new Blob([new Uint8Array(out)], { type: 'image/gif' });
}
