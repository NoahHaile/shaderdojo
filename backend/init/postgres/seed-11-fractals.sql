\c shader_dojo;

-- Family J — Iteration & fractals (6 courses, 24 lessons).
-- loop-fundamentals moved to Foundations (seed-02) — it's a prerequisite for noise & raymarching.

INSERT INTO lesson (course_id, slug, display_order, title, description, starter_fragment_shader, canonical_fragment_shader) VALUES

-- ===== Course: accumulation-loops =====
((SELECT id FROM course WHERE slug = 'accumulation-loops'), 'CAixj7DUkss', 0,
 'N-tap blur on image',
 '<p>A box blur is a loop that accumulates neighbor samples and divides by the count. With a constant 5×5 kernel that''s 25 fixed taps — perfect for GLSL ES 1.0.</p><p>Use a pixel step <code>px = 0.005</code> and sum <code>texture2D(u_image, uv + vec2(x, y) * px)</code> for every <code>(x, y)</code> in the kernel, then divide by 25.</p><p>Reference: <a href="https://thebookofshaders.com/13/" target="_blank" rel="noreferrer">Book of Shaders — Fractal Brownian Motion</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float px = 0.005;
    // TODO: sum 5x5 = 25 samples from u_image at offsets x,y in [-2,2] * px, then divide by 25.
    vec4 sum = texture2D(u_image, uv);
    gl_FragColor = sum;
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float px = 0.005;
    vec4 sum = vec4(0.0);
    for (int x = -2; x <= 2; x++) {
        for (int y = -2; y <= 2; y++) {
            sum += texture2D(u_image, uv + vec2(float(x), float(y)) * px);
        }
    }
    gl_FragColor = sum / 25.0;
}'),

((SELECT id FROM course WHERE slug = 'accumulation-loops'), 'xMi5t4GFZuo', 1,
 'Jitter-sampled AA',
 '<p>Instead of a grid of taps, sample at random offsets — the kind of noisy supersampling antialiasing schemes use. Eight taps, each at a hash-jittered position, averaged.</p><p>For iteration <code>i</code>, build a two-component jitter from two different hash inputs, scale by a few pixels, and accumulate <code>u_image</code> samples.</p><p>Reference: <a href="https://thebookofshaders.com/13/" target="_blank" rel="noreferrer">Book of Shaders — Fractal Brownian Motion</a>.</p>',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: average 8 hash-jittered samples from u_image.
    vec4 sum = texture2D(u_image, uv);
    gl_FragColor = sum;
}',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec4 sum = vec4(0.0);
    for (int i = 0; i < 8; i++) {
        vec2 j = vec2(hash(uv + float(i)), hash(uv - float(i))) - 0.5;
        sum += texture2D(u_image, uv + j * 0.01);
    }
    gl_FragColor = sum / 8.0;
}'),

((SELECT id FROM course WHERE slug = 'accumulation-loops'), 'Y3cAQQcOcxE', 2,
 'Motion blur',
 '<p>Motion blur is a one-axis stretch of the box blur. Accumulate eight samples along a vertical streak and average — the image smears in the y direction.</p><p>For each iteration <code>i</code>, sample at <code>uv + vec2(0.0, float(i) * 0.005)</code> and divide by 8 at the end.</p><p>Reference: <a href="https://thebookofshaders.com/13/" target="_blank" rel="noreferrer">Book of Shaders — Fractal Brownian Motion</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: 8 samples at uv + vec2(0.0, float(i)*0.005), average.
    vec4 sum = texture2D(u_image, uv);
    gl_FragColor = sum;
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec4 sum = vec4(0.0);
    for (int i = 0; i < 8; i++) {
        sum += texture2D(u_image, uv + vec2(0.0, float(i) * 0.005));
    }
    gl_FragColor = sum / 8.0;
}'),

((SELECT id FROM course WHERE slug = 'accumulation-loops'), 'wpWMZoP8VUU', 3,
 'Re-derive fbm',
 '<p>Fractal Brownian motion is the canonical accumulation loop: sum value-noise octaves with shrinking amplitude and growing frequency. Five iterations, halving amplitude and doubling frequency, give you the texture you''d recognize from cloud and terrain shaders.</p><p>Start from a hash, build a smoothed value noise, then loop: <code>v += a * vnoise(p); p *= 2.0; a *= 0.5;</code>.</p><p>Reference: <a href="https://thebookofshaders.com/13/" target="_blank" rel="noreferrer">Book of Shaders — Fractal Brownian Motion</a>.</p>',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 p = uv * 4.0;
    // TODO: accumulate 5 octaves: v += a * vnoise(p); p *= 2.0; a *= 0.5;
    float v = vnoise(p);
    gl_FragColor = vec4(vec3(v), 1.0);
}',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 p = uv * 4.0;
    float v = 0.0;
    float a = 1.0;
    for (int i = 0; i < 5; i++) {
        v += a * vnoise(p);
        p *= 2.0;
        a *= 0.5;
    }
    gl_FragColor = vec4(vec3(v), 1.0);
}'),

-- ===== Course: mandelbrot =====
((SELECT id FROM course WHERE slug = 'mandelbrot'), 'WWTQAiyd_H8', 0,
 'Binary in-set mask',
 '<p>The Mandelbrot set is the set of complex numbers <code>c</code> for which <code>z = z² + c</code> stays bounded starting from <code>z = 0</code>. A pixel renders that map when its position becomes <code>c</code>.</p><p>Iterate 64 times. If <code>|z|</code> ever exceeds 2 (we check <code>dot(z, z) &gt; 4.0</code>) the point escapes — render it white. If it survives all 64 iterations, it''s in the set — render it black.</p><p>Reference: <a href="https://iquilezles.org/articles/arquimedes/" target="_blank" rel="noreferrer">IQ — Mandelbrot intro</a>.</p>',
 'void main() {
    vec2 c = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0 - vec2(0.5, 0.0);
    vec2 z = vec2(0.0);
    // TODO: iterate z = z^2 + c 64 times; if dot(z,z) > 4.0 escape (white), else in-set (black).
    float m = 0.0;
    gl_FragColor = vec4(vec3(m), 1.0);
}',
 'void main() {
    vec2 c = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0 - vec2(0.5, 0.0);
    vec2 z = vec2(0.0);
    float m = 0.0;
    for (int i = 0; i < 64; i++) {
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        if (dot(z, z) > 4.0) { m = 1.0; break; }
    }
    gl_FragColor = vec4(vec3(m), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'mandelbrot'), 'N2Abg_Mu-aY', 1,
 'Iter count gray',
 '<p>Record <em>when</em> the point escapes, not just whether. The iteration index at escape is a discrete proxy for the distance from the set.</p><p>Iterate up to 64; the moment <code>dot(z, z) &gt; 4.0</code>, save <code>it = i</code> and break. Output <code>vec3(float(it) / 64.0)</code> for stepped grayscale bands.</p><p>Reference: <a href="https://iquilezles.org/articles/arquimedes/" target="_blank" rel="noreferrer">IQ — Mandelbrot intro</a>.</p>',
 'void main() {
    vec2 c = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0 - vec2(0.5, 0.0);
    vec2 z = vec2(0.0);
    // TODO: record the iteration index at escape; output float(it)/64.0 as gray.
    int it = 0;
    gl_FragColor = vec4(vec3(float(it) / 64.0), 1.0);
}',
 'void main() {
    vec2 c = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0 - vec2(0.5, 0.0);
    vec2 z = vec2(0.0);
    int it = 0;
    for (int i = 0; i < 64; i++) {
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        if (dot(z, z) > 4.0) break;
        it = i;
    }
    gl_FragColor = vec4(vec3(float(it) / 64.0), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'mandelbrot'), 'B3-FzWCpiMc', 2,
 'Smooth iter count',
 '<p>Integer iteration counts produce visible banding. The continuous version subtracts <code>log2(log2(|z|²))</code> from the integer count, giving a smooth fractional value that crosses bands without seams.</p><p>The starter already runs the iteration and tracks <code>escaped</code> (otherwise <code>log2</code> on the in-set leftover would produce NaN). Your only job is to fill in <code>n = float(it) - log2(log2(dot(z, z)))</code> and force <code>n = 0.0</code> when the point never escaped.</p><p>Reference: <a href="https://iquilezles.org/articles/msetsmooth/" target="_blank" rel="noreferrer">IQ — Continuous iteration count</a>.</p>',
 'void main() {
    vec2 c = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0 - vec2(0.5, 0.0);
    vec2 z = vec2(0.0);
    int it = 0;
    bool escaped = false;
    for (int i = 0; i < 64; i++) {
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        if (dot(z, z) > 4.0) { escaped = true; break; }
        it = i;
    }
    // TODO: n = float(it) - log2(log2(dot(z, z)));
    // TODO: if (!escaped) n = 0.0;  // avoid NaN inside the set
    float n = 0.0;
    gl_FragColor = vec4(vec3(n / 64.0), 1.0);
}',
 'void main() {
    vec2 c = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0 - vec2(0.5, 0.0);
    vec2 z = vec2(0.0);
    int it = 0;
    bool escaped = false;
    for (int i = 0; i < 64; i++) {
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        if (dot(z, z) > 4.0) { escaped = true; break; }
        it = i;
    }
    float n = float(it) - log2(log2(dot(z, z)));
    if (!escaped) n = 0.0;
    gl_FragColor = vec4(vec3(n / 64.0), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'mandelbrot'), 'Bas0UtXRa0Y', 3,
 'Palette colorize',
 '<p>The smooth iteration count is just a scalar — feed it to a cosine palette and the Mandelbrot blooms into color.</p><p>The iteration loop and the smooth count are already wired up. Set <code>col</code> to the IQ palette evaluated at <code>n * 0.05</code> when the point escaped; keep it black inside the set.</p><p>Reference: <a href="https://iquilezles.org/articles/distancefractals/" target="_blank" rel="noreferrer">IQ — Distance fractals</a>.</p>',
 'vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
    return a + b * cos(6.28318 * (c * t + d));
}
void main() {
    vec2 c = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0 - vec2(0.5, 0.0);
    vec2 z = vec2(0.0);
    int it = 0;
    bool escaped = false;
    for (int i = 0; i < 64; i++) {
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        if (dot(z, z) > 4.0) { escaped = true; break; }
        it = i;
    }
    float n = float(it) - log2(log2(dot(z, z)));
    // TODO: col = escaped ? palette(n*0.05, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.0, 0.33, 0.67)) : vec3(0.0);
    vec3 col = vec3(0.0);
    gl_FragColor = vec4(col, 1.0);
}',
 'vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
    return a + b * cos(6.28318 * (c * t + d));
}
void main() {
    vec2 c = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0 - vec2(0.5, 0.0);
    vec2 z = vec2(0.0);
    int it = 0;
    bool escaped = false;
    for (int i = 0; i < 64; i++) {
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        if (dot(z, z) > 4.0) { escaped = true; break; }
        it = i;
    }
    float n = float(it) - log2(log2(dot(z, z)));
    vec3 col = escaped
        ? palette(n * 0.05, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.0, 0.33, 0.67))
        : vec3(0.0);
    gl_FragColor = vec4(col, 1.0);
}'),

-- ===== Course: julia-sets =====
((SELECT id FROM course WHERE slug = 'julia-sets'), 'JjgP_PFlzqw', 0,
 'Static Julia',
 '<p>A Julia set flips the Mandelbrot loop: <code>c</code> is fixed, the per-pixel position becomes the starting <code>z</code>. Different <code>c</code> produces a different filled-Julia shape.</p><p>The complex-square step <code>z = (z.x²−z.y², 2·z.x·z.y) + c</code> is the same as in Mandelbrot — only the meaning of <code>z</code> and <code>c</code> swapped. Fill in the loop and the NaN guard.</p><p>Reference: <a href="https://iquilezles.org/articles/juliasets3d/" target="_blank" rel="noreferrer">IQ — 3D Julia sets</a>.</p>',
 'void main() {
    vec2 z = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0;
    vec2 c = vec2(-0.7, 0.27);
    int it = 0;
    bool escaped = false;
    // TODO: for (int i = 0; i < 64; i++) { z = vec2(z.x*z.x - z.y*z.y, 2.0*z.x*z.y) + c;
    //         if (dot(z, z) > 4.0) { escaped = true; break; } it = i; }
    float n = float(it) - log2(log2(dot(z, z)));
    if (!escaped) n = 0.0;
    gl_FragColor = vec4(vec3(n / 64.0), 1.0);
}',
 'void main() {
    vec2 z = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0;
    vec2 c = vec2(-0.7, 0.27);
    int it = 0;
    bool escaped = false;
    for (int i = 0; i < 64; i++) {
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        if (dot(z, z) > 4.0) { escaped = true; break; }
        it = i;
    }
    float n = float(it) - log2(log2(dot(z, z)));
    if (!escaped) n = 0.0;
    gl_FragColor = vec4(vec3(n / 64.0), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'julia-sets'), 'GUqs2ifF4zc', 1,
 'Animate c on circle',
 '<p>Slide <code>c</code> around a circle in the complex plane and the whole Julia shape morphs through its family. The radius and speed control how dramatic the deformation is.</p><p>Same iteration as before — only <code>c</code> is now a moving target. Replace the fixed assignment with the moving one.</p><p>Reference: <a href="https://iquilezles.org/articles/juliasets3d/" target="_blank" rel="noreferrer">IQ — 3D Julia sets</a>.</p>',
 'void main() {
    vec2 z = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0;
    // TODO: c = 0.7 * vec2(cos(u_time*0.3), sin(u_time*0.3));
    vec2 c = vec2(-0.7, 0.27);
    int it = 0;
    bool escaped = false;
    for (int i = 0; i < 64; i++) {
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        if (dot(z, z) > 4.0) { escaped = true; break; }
        it = i;
    }
    float n = float(it) - log2(log2(dot(z, z)));
    if (!escaped) n = 0.0;
    gl_FragColor = vec4(vec3(n / 64.0), 1.0);
}',
 'void main() {
    vec2 z = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0;
    vec2 c = 0.7 * vec2(cos(u_time * 0.3), sin(u_time * 0.3));
    int it = 0;
    bool escaped = false;
    for (int i = 0; i < 64; i++) {
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        if (dot(z, z) > 4.0) { escaped = true; break; }
        it = i;
    }
    float n = float(it) - log2(log2(dot(z, z)));
    if (!escaped) n = 0.0;
    gl_FragColor = vec4(vec3(n / 64.0), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'julia-sets'), 'z_aQg0oSmGQ', 2,
 'Zoom into feature',
 '<p>Julia sets are self-similar — zooming into the boundary reveals miniature copies of the whole. A linear remap of <code>z</code> before iteration zooms the camera.</p><p>Pre-transform <code>z = z * 0.4 + vec2(-0.1, 0.6)</code>, which zooms in by 2.5× and recenters near an interesting boundary feature. Keep <code>c</code> fixed at <code>(-0.7, 0.27)</code>.</p><p>Reference: <a href="https://iquilezles.org/articles/juliasets3d/" target="_blank" rel="noreferrer">IQ — 3D Julia sets</a>.</p>',
 'void main() {
    vec2 z = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0;
    // TODO: z = z * 0.4 + vec2(-0.1, 0.6);
    vec2 c = vec2(-0.7, 0.27);
    int it = 0;
    bool escaped = false;
    for (int i = 0; i < 64; i++) {
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        if (dot(z, z) > 4.0) { escaped = true; break; }
        it = i;
    }
    float n = float(it) - log2(log2(dot(z, z)));
    if (!escaped) n = 0.0;
    gl_FragColor = vec4(vec3(n / 64.0), 1.0);
}',
 'void main() {
    vec2 z = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0;
    z = z * 0.4 + vec2(-0.1, 0.6);
    vec2 c = vec2(-0.7, 0.27);
    int it = 0;
    bool escaped = false;
    for (int i = 0; i < 64; i++) {
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        if (dot(z, z) > 4.0) { escaped = true; break; }
        it = i;
    }
    float n = float(it) - log2(log2(dot(z, z)));
    if (!escaped) n = 0.0;
    gl_FragColor = vec4(vec3(n / 64.0), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'julia-sets'), 'd3Imp0svQQk', 3,
 'Two-Julia crossfade',
 '<p>Run two Julia iterations with different <code>c</code> values from the same starting <code>z</code>, then crossfade their outputs. The result is a temporal blend between two distinct fractal shapes.</p><p>Both iterations share one fixed loop bound — track an <code>escaped</code> flag for each so a finished iteration stops updating its iteration count. Mix the smooth counts with <code>0.5 + 0.5 * sin(u_time * 0.3)</code>.</p><p>Reference: <a href="https://iquilezles.org/articles/juliasets3d/" target="_blank" rel="noreferrer">IQ — 3D Julia sets</a>.</p>',
 'void main() {
    vec2 z0 = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0;
    vec2 c1 = vec2(-0.7, 0.27);
    vec2 c2 = vec2(0.285, 0.01);
    vec2 za = z0;
    vec2 zb = z0;
    int ita = 0;
    int itb = 0;
    bool ea = false;
    bool eb = false;
    for (int i = 0; i < 64; i++) {
        if (!ea) {
            za = vec2(za.x * za.x - za.y * za.y, 2.0 * za.x * za.y) + c1;
            if (dot(za, za) > 4.0) ea = true; else ita = i;
        }
        if (!eb) {
            zb = vec2(zb.x * zb.x - zb.y * zb.y, 2.0 * zb.x * zb.y) + c2;
            if (dot(zb, zb) > 4.0) eb = true; else itb = i;
        }
    }
    // TODO: na = ea ? (float(ita) - log2(log2(dot(za, za)))) : 0.0;
    // TODO: nb = eb ? (float(itb) - log2(log2(dot(zb, zb)))) : 0.0;
    // TODO: t = 0.5 + 0.5 * sin(u_time * 0.3);
    // TODO: n = mix(na, nb, t);
    float n = 0.0;
    gl_FragColor = vec4(vec3(n / 64.0), 1.0);
}',
 'void main() {
    vec2 z0 = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0;
    vec2 c1 = vec2(-0.7, 0.27);
    vec2 c2 = vec2(0.285, 0.01);
    vec2 za = z0;
    vec2 zb = z0;
    int ita = 0;
    int itb = 0;
    bool ea = false;
    bool eb = false;
    for (int i = 0; i < 64; i++) {
        if (!ea) {
            za = vec2(za.x * za.x - za.y * za.y, 2.0 * za.x * za.y) + c1;
            if (dot(za, za) > 4.0) ea = true; else ita = i;
        }
        if (!eb) {
            zb = vec2(zb.x * zb.x - zb.y * zb.y, 2.0 * zb.x * zb.y) + c2;
            if (dot(zb, zb) > 4.0) eb = true; else itb = i;
        }
    }
    float na = ea ? (float(ita) - log2(log2(dot(za, za)))) : 0.0;
    float nb = eb ? (float(itb) - log2(log2(dot(zb, zb)))) : 0.0;
    float t = 0.5 + 0.5 * sin(u_time * 0.3);
    float n = mix(na, nb, t);
    gl_FragColor = vec4(vec3(n / 64.0), 1.0);
}'),

-- ===== Course: orbit-traps =====
((SELECT id FROM course WHERE slug = 'orbit-traps'), 'cbG-2ccChv8', 0,
 'Point trap (Mandelbrot)',
 '<p>An orbit trap records the closest approach the iteration ever made to some geometry. For a point trap, that''s the minimum of <code>length(z - p)</code> across all iterations.</p><p>Iterate the Mandelbrot map and track <code>trap = min(trap, length(z - vec2(0.0, 1.0)))</code>. Output the trap as grayscale to see new structure carved by the trap point.</p><p>Reference: <a href="https://iquilezles.org/articles/ftrapsprocedural/" target="_blank" rel="noreferrer">IQ — Procedural orbit traps</a>.</p>',
 'void main() {
    vec2 c = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0 - vec2(0.5, 0.0);
    vec2 z = vec2(0.0);
    float trap = 1e10;
    // TODO: iterate 64 times; track trap = min(trap, length(z - vec2(0.0, 1.0))).
    gl_FragColor = vec4(vec3(trap), 1.0);
}',
 'void main() {
    vec2 c = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0 - vec2(0.5, 0.0);
    vec2 z = vec2(0.0);
    float trap = 1e10;
    for (int i = 0; i < 64; i++) {
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        trap = min(trap, length(z - vec2(0.0, 1.0)));
        if (dot(z, z) > 4.0) break;
    }
    gl_FragColor = vec4(vec3(trap), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'orbit-traps'), 'Z0mmaXwERaU', 1,
 'Line trap (Julia)',
 '<p>Swap the trap geometry to a line and the fractal grows ribbons. The distance from <code>z</code> to the y-axis is just <code>abs(z.x)</code>.</p><p>Run a Julia iteration with <code>c = (-0.7, 0.27)</code> and track <code>trap = min(trap, abs(z.x))</code>.</p><p>Reference: <a href="https://iquilezles.org/articles/ftrapsgeometric/" target="_blank" rel="noreferrer">IQ — Geometric orbit traps</a>.</p>',
 'void main() {
    vec2 z = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0;
    vec2 c = vec2(-0.7, 0.27);
    float trap = 1e10;
    // TODO: iterate 64 times; track trap = min(trap, abs(z.x)).
    gl_FragColor = vec4(vec3(trap), 1.0);
}',
 'void main() {
    vec2 z = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0;
    vec2 c = vec2(-0.7, 0.27);
    float trap = 1e10;
    for (int i = 0; i < 64; i++) {
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        trap = min(trap, abs(z.x));
        if (dot(z, z) > 4.0) break;
    }
    gl_FragColor = vec4(vec3(trap), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'orbit-traps'), 'YAohKdAMs-4', 2,
 'Multi-trap min',
 '<p>Combine multiple trap shapes by taking the minimum distance over all of them. You get features from every trap superimposed on the fractal.</p><p>Use Julia with <code>c = (-0.7, 0.27)</code> and track <code>trap = min(trap, min(length(z), abs(z.y - 0.5)))</code> — a point at origin and a horizontal line.</p><p>Reference: <a href="https://iquilezles.org/articles/ftrapsbitmap/" target="_blank" rel="noreferrer">IQ — Bitmap orbit traps</a>.</p>',
 'void main() {
    vec2 z = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0;
    vec2 c = vec2(-0.7, 0.27);
    float trap = 1e10;
    // TODO: trap = min(trap, min(length(z), abs(z.y - 0.5)));
    gl_FragColor = vec4(vec3(trap), 1.0);
}',
 'void main() {
    vec2 z = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0;
    vec2 c = vec2(-0.7, 0.27);
    float trap = 1e10;
    for (int i = 0; i < 64; i++) {
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        trap = min(trap, min(length(z), abs(z.y - 0.5)));
        if (dot(z, z) > 4.0) break;
    }
    gl_FragColor = vec4(vec3(trap), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'orbit-traps'), 'E2g3RC2CD2U', 3,
 'Animated trap',
 '<p>Move the trap point on a circle over time. Same fractal, same iteration count, but the trap geometry rotates — and the inner structure swirls with it.</p><p>Trap point = <code>0.5 * vec2(cos(u_time * 0.3), sin(u_time * 0.3))</code>. Track <code>trap = min(trap, length(z - p))</code>.</p><p>Reference: <a href="https://iquilezles.org/articles/ftrapsprocedural/" target="_blank" rel="noreferrer">IQ — Procedural orbit traps</a>.</p>',
 'void main() {
    vec2 z = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0;
    vec2 c = vec2(-0.7, 0.27);
    float trap = 1e10;
    // TODO: p = 0.5*vec2(cos(u_time*0.3), sin(u_time*0.3)); trap = min(trap, length(z - p)).
    gl_FragColor = vec4(vec3(trap), 1.0);
}',
 'void main() {
    vec2 z = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0;
    vec2 c = vec2(-0.7, 0.27);
    vec2 p = 0.5 * vec2(cos(u_time * 0.3), sin(u_time * 0.3));
    float trap = 1e10;
    for (int i = 0; i < 64; i++) {
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        trap = min(trap, length(z - p));
        if (dot(z, z) > 4.0) break;
    }
    gl_FragColor = vec4(vec3(trap), 1.0);
}'),

-- ===== Course: ifs-folding =====
((SELECT id FROM course WHERE slug = 'ifs-folding'), 'uP3HCxq4Tco', 0,
 '2D Sierpinski',
 '<p>An iterated function system folds and scales space — every iteration brings detail closer to the origin. The Sierpinski fold is three lines: take <code>abs</code>, reflect when the sum exceeds 1, then scale by 2 and shift.</p><p>Apply six iterations of the fold to a centered <code>p</code> and use <code>step(length(p), 1.0)</code> as the mask.</p><p>Reference: <a href="https://iquilezles.org/articles/ifsfractals/" target="_blank" rel="noreferrer">IQ — IFS fractals</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 p = (uv - 0.5) * 2.0;
    // TODO: 6 iterations of: p=abs(p); if (p.x+p.y>1.0) p=vec2(1.0)-p.yx; p=p*2.0-vec2(1.0);
    float m = step(length(p), 1.0);
    gl_FragColor = vec4(vec3(m), 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 p = (uv - 0.5) * 2.0;
    for (int i = 0; i < 6; i++) {
        p = abs(p);
        if (p.x + p.y > 1.0) p = vec2(1.0) - p.yx;
        p = p * 2.0 - vec2(1.0);
    }
    float m = step(length(p), 1.0);
    gl_FragColor = vec4(vec3(m), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'ifs-folding'), '_LDkavCZ2fs', 1,
 'Koch detail',
 '<p>Different folds give different fractals. Combine <code>abs</code>, a rotation, and a scale, and you start picking up Koch-like spiky boundaries.</p><p>Six iterations of: take <code>abs</code>, rotate <code>p</code> by a constant matrix, and scale by 2 then offset.</p><p>Reference: <a href="https://iquilezles.org/articles/ifsfractals/" target="_blank" rel="noreferrer">IQ — IFS fractals</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 p = (uv - 0.5) * 2.0;
    float a = 0.5;
    mat2 R = mat2(cos(a), -sin(a), sin(a), cos(a));
    // TODO: 6 iterations of: p = abs(p); p = R * p; p = p * 2.0 - vec2(1.0);
    float m = step(length(p), 1.0);
    gl_FragColor = vec4(vec3(m), 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 p = (uv - 0.5) * 2.0;
    float a = 0.5;
    mat2 R = mat2(cos(a), -sin(a), sin(a), cos(a));
    for (int i = 0; i < 6; i++) {
        p = abs(p);
        p = R * p;
        p = p * 2.0 - vec2(1.0);
    }
    float m = step(length(p), 1.0);
    gl_FragColor = vec4(vec3(m), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'ifs-folding'), 'DbJr87pcKpo', 2,
 'Fewer folds',
 '<p>Iteration depth controls detail. Run the same Sierpinski fold for only 4 iterations instead of 6 and the result is chunkier — fewer self-similar levels carved into space.</p><p>Use a constant <code>4</code> bound on the loop (variable bounds aren''t allowed in GLSL ES 1.0).</p><p>Reference: <a href="https://iquilezles.org/articles/ifsfractals/" target="_blank" rel="noreferrer">IQ — IFS fractals</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 p = (uv - 0.5) * 2.0;
    // TODO: same Sierpinski fold but i < 4.
    float m = step(length(p), 1.0);
    gl_FragColor = vec4(vec3(m), 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 p = (uv - 0.5) * 2.0;
    for (int i = 0; i < 4; i++) {
        p = abs(p);
        if (p.x + p.y > 1.0) p = vec2(1.0) - p.yx;
        p = p * 2.0 - vec2(1.0);
    }
    float m = step(length(p), 1.0);
    gl_FragColor = vec4(vec3(m), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'ifs-folding'), 'w_yMH23pxjg', 3,
 'Animated fold param',
 '<p>The loop bound must be constant, but the values inside the loop don''t have to be. Animate the scale factor instead of the iteration count.</p><p>Use a fixed 6-iteration Sierpinski loop, but replace the <code>p * 2.0</code> step with <code>p * s</code> where <code>s = 1.95 + 0.1 * sin(u_time * 0.3)</code>. The fractal pulses without restructuring the loop.</p><p>Reference: <a href="https://iquilezles.org/articles/ifsfractals/" target="_blank" rel="noreferrer">IQ — IFS fractals</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 p = (uv - 0.5) * 2.0;
    float s = 1.95 + 0.1 * sin(u_time * 0.3);
    // TODO: 6 iterations of fold with scale s inside the fixed-bound loop.
    float m = step(length(p), 1.0);
    gl_FragColor = vec4(vec3(m), 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 p = (uv - 0.5) * 2.0;
    float s = 1.95 + 0.1 * sin(u_time * 0.3);
    for (int i = 0; i < 6; i++) {
        p = abs(p);
        if (p.x + p.y > 1.0) p = vec2(1.0) - p.yx;
        p = p * s - vec2(1.0);
    }
    float m = step(length(p), 1.0);
    gl_FragColor = vec4(vec3(m), 1.0);
}'),

-- ===== Course: kifs-raymarched =====
((SELECT id FROM course WHERE slug = 'kifs-raymarched'), '2R5iMV8viwM', 0,
 'Simple fold + raymarch',
 '<p>A Kaleidoscopic IFS (KIFS) is a folded scene with a real SDF. Each fold step also accumulates a scale factor so the distance estimate stays correct.</p><p>Inside <code>scene(p)</code>, fold six times with <code>abs</code> and sorted-swap; multiply <code>p</code> by 1.5 and <code>s</code> by 1.5 each iteration. Return <code>(length(p) - 2.0) / s</code> as the distance, then raymarch from a fixed camera.</p><p>Reference: <a href="https://iquilezles.org/articles/menger/" target="_blank" rel="noreferrer">IQ — Menger fractal</a>.</p>',
 'float scene(vec3 p) {
    float s = 1.0;
    for (int i = 0; i < 6; i++) {
        p = abs(p) - vec3(1.0);
        if (p.x < p.y) p.xy = p.yx;
        if (p.y < p.z) p.yz = p.zy;
        if (p.x < p.y) p.xy = p.yx;
        p *= 1.5;
        s *= 1.5;
    }
    return (length(p) - 2.0) / s;
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 4.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    // TODO: raymarch up to 64 steps; if hit, white; else sky vec3(0.85, 0.90, 0.95).
    vec3 col = vec3(0.85, 0.90, 0.95);
    gl_FragColor = vec4(col, 1.0);
}',
 'float scene(vec3 p) {
    float s = 1.0;
    for (int i = 0; i < 6; i++) {
        p = abs(p) - vec3(1.0);
        if (p.x < p.y) p.xy = p.yx;
        if (p.y < p.z) p.yz = p.zy;
        if (p.x < p.y) p.xy = p.yx;
        p *= 1.5;
        s *= 1.5;
    }
    return (length(p) - 2.0) / s;
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 4.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    for (int i = 0; i < 64; i++) {
        vec3 p = ro + rd * t;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        t += d;
        if (t > 20.0) break;
    }
    vec3 col = hit ? vec3(1.0) : vec3(0.85, 0.90, 0.95);
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'kifs-raymarched'), 'XrXdetTC8tQ', 1,
 'Mandelbox-lite',
 '<p>A sphere fold is the other half of the Mandelbox trick: shrink points near the origin and invert points just outside a unit sphere. The result is a 3D fractal with bubble-like cavities.</p><p>Inside the loop, compute <code>r2 = dot(p, p)</code>: if <code>r2 &lt; 0.25</code> multiply <code>p</code> by 4; else if <code>r2 &lt; 1.0</code> divide by <code>r2</code>. Combine with the standard KIFS abs-fold to get a Mandelbox-lite.</p><p>Reference: <a href="https://iquilezles.org/articles/distancefractals/" target="_blank" rel="noreferrer">IQ — Distance fractals</a>.</p>',
 'float scene(vec3 p) {
    float s = 1.0;
    for (int i = 0; i < 6; i++) {
        p = abs(p) - vec3(1.0);
        float r2 = dot(p, p);
        if (r2 < 0.25) { p *= 4.0; s *= 4.0; }
        else if (r2 < 1.0) { p /= r2; s /= r2; }
        p *= 1.5;
        s *= 1.5;
    }
    return (length(p) - 2.0) / s;
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 4.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    // TODO: raymarch with the sphere-fold scene; hit=white, miss=sky.
    vec3 col = vec3(0.85, 0.90, 0.95);
    gl_FragColor = vec4(col, 1.0);
}',
 'float scene(vec3 p) {
    float s = 1.0;
    for (int i = 0; i < 6; i++) {
        p = abs(p) - vec3(1.0);
        float r2 = dot(p, p);
        if (r2 < 0.25) { p *= 4.0; s *= 4.0; }
        else if (r2 < 1.0) { p /= r2; s /= r2; }
        p *= 1.5;
        s *= 1.5;
    }
    return (length(p) - 2.0) / s;
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 4.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    for (int i = 0; i < 64; i++) {
        vec3 p = ro + rd * t;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        t += d;
        if (t > 20.0) break;
    }
    vec3 col = hit ? vec3(1.0) : vec3(0.85, 0.90, 0.95);
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'kifs-raymarched'), 'Hk7dP6NHCus', 2,
 'Tune fold count',
 '<p>More fold iterations = more detail levels = a more intricate fractal silhouette. Push the KIFS loop from 6 to 8 iterations and rerender.</p><p>The bound has to be constant — bake the new <code>8</code> into the for-loop literal.</p><p>Reference: <a href="https://mercury.sexy/hg_sdf/" target="_blank" rel="noreferrer">hg_sdf — SDF library</a>.</p>',
 'float scene(vec3 p) {
    float s = 1.0;
    // TODO: change i < 6 to i < 8.
    for (int i = 0; i < 6; i++) {
        p = abs(p) - vec3(1.0);
        if (p.x < p.y) p.xy = p.yx;
        if (p.y < p.z) p.yz = p.zy;
        if (p.x < p.y) p.xy = p.yx;
        p *= 1.5;
        s *= 1.5;
    }
    return (length(p) - 2.0) / s;
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 4.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    for (int i = 0; i < 64; i++) {
        vec3 p = ro + rd * t;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        t += d;
        if (t > 20.0) break;
    }
    vec3 col = hit ? vec3(1.0) : vec3(0.85, 0.90, 0.95);
    gl_FragColor = vec4(col, 1.0);
}',
 'float scene(vec3 p) {
    float s = 1.0;
    for (int i = 0; i < 8; i++) {
        p = abs(p) - vec3(1.0);
        if (p.x < p.y) p.xy = p.yx;
        if (p.y < p.z) p.yz = p.zy;
        if (p.x < p.y) p.xy = p.yx;
        p *= 1.5;
        s *= 1.5;
    }
    return (length(p) - 2.0) / s;
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 4.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    for (int i = 0; i < 64; i++) {
        vec3 p = ro + rd * t;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        t += d;
        if (t > 20.0) break;
    }
    vec3 col = hit ? vec3(1.0) : vec3(0.85, 0.90, 0.95);
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'kifs-raymarched'), '-qQ7eiM9vK4', 3,
 'Orbit-trap color',
 '<p>The orbit-trap trick that colored 2D fractals also works on 3D KIFS. Track the closest approach of <code>p</code> to the origin during the fold, then run that scalar through a cosine palette.</p><p>Add a global <code>g_trap</code> that the scene function writes during iteration, then feed it to the IQ palette for the hit color.</p><p>Reference: <a href="https://iquilezles.org/articles/menger/" target="_blank" rel="noreferrer">IQ — Menger fractal</a>.</p>',
 'vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
    return a + b * cos(6.28318 * (c * t + d));
}
float g_trap;
float scene(vec3 p) {
    float s = 1.0;
    g_trap = 1e10;
    for (int i = 0; i < 6; i++) {
        p = abs(p) - vec3(1.0);
        if (p.x < p.y) p.xy = p.yx;
        if (p.y < p.z) p.yz = p.zy;
        if (p.x < p.y) p.xy = p.yx;
        p *= 1.5;
        s *= 1.5;
        g_trap = min(g_trap, length(p));
    }
    return (length(p) - 2.0) / s;
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 4.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    // TODO: raymarch; on hit, color = palette(g_trap*0.2, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.0,0.33,0.67)).
    vec3 col = vec3(0.85, 0.90, 0.95);
    gl_FragColor = vec4(col, 1.0);
}',
 'vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
    return a + b * cos(6.28318 * (c * t + d));
}
float g_trap;
float scene(vec3 p) {
    float s = 1.0;
    g_trap = 1e10;
    for (int i = 0; i < 6; i++) {
        p = abs(p) - vec3(1.0);
        if (p.x < p.y) p.xy = p.yx;
        if (p.y < p.z) p.yz = p.zy;
        if (p.x < p.y) p.xy = p.yx;
        p *= 1.5;
        s *= 1.5;
        g_trap = min(g_trap, length(p));
    }
    return (length(p) - 2.0) / s;
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 4.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    for (int i = 0; i < 64; i++) {
        vec3 p = ro + rd * t;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        t += d;
        if (t > 20.0) break;
    }
    vec3 col = hit
        ? palette(g_trap * 0.2, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.0, 0.33, 0.67))
        : vec3(0.85, 0.90, 0.95);
    gl_FragColor = vec4(col, 1.0);
}');
