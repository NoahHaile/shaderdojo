\c shader_dojo;

-- Family E — Noise (6 courses, 24 lessons)

INSERT INTO lesson (id, course_id, slug, display_order, title, description, starter_fragment_shader, canonical_fragment_shader) VALUES

-- ===== Course: hash-random =====
('c0000017-0001-0000-0000-000000000000', 'c0000017-0000-0000-0000-000000000000', '9C0KRy8EXPw', 0,
 'fract-sin hash',
 '<p>Pseudo-random in a shader starts with a deterministic hash. The folklore one-liner <code>fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453)</code> turns any 2D coordinate into a value in <code>[0, 1)</code> that looks random.</p><p>Feed each pixel''s UV through the hash and output it on all three channels — the canvas fills with per-pixel white noise.</p><p>Reference: <a href="https://thebookofshaders.com/10/" target="_blank" rel="noreferrer">Book of Shaders — Random</a>.</p>',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: v = hash(uv); output vec3(v).
    float v = 0.0;
    gl_FragColor = vec4(vec3(v), 1.0);
}',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float v = hash(uv);
    gl_FragColor = vec4(vec3(v), 1.0);
}'),

('c0000017-0002-0000-0000-000000000000', 'c0000017-0000-0000-0000-000000000000', 'sP81PGpNsDc', 1,
 'Random per cell',
 '<p>Quantize UV first with <code>floor()</code> so every pixel inside the same grid cell gets the same hash input. The canvas becomes a coarse grid of random grays — flat blocks instead of speckle.</p><p>Reference: <a href="https://thebookofshaders.com/10/" target="_blank" rel="noreferrer">Book of Shaders — Random</a>.</p>',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 8.0;
    // TODO: cell = floor(uv); v = hash(cell); output vec3(v).
    float v = 0.0;
    gl_FragColor = vec4(vec3(v), 1.0);
}',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 8.0;
    vec2 cell = floor(uv);
    float v = hash(cell);
    gl_FragColor = vec4(vec3(v), 1.0);
}'),

('c0000017-0003-0000-0000-000000000000', 'c0000017-0000-0000-0000-000000000000', 'gwTmpCj_ML8', 2,
 'Random colored cells',
 '<p>One hash gives one channel. Call the hash three times with different offsets to get three independent randoms — pack them into RGB so each cell gets its own arbitrary color.</p><p>Reference: <a href="https://iquilezles.org/articles/sfrand/" target="_blank" rel="noreferrer">IQ — sfrand</a>.</p>',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 8.0;
    vec2 cell = floor(uv);
    // TODO: c = vec3(hash(cell), hash(cell + 17.0), hash(cell + 31.0));
    vec3 c = vec3(hash(cell));
    gl_FragColor = vec4(c, 1.0);
}',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 8.0;
    vec2 cell = floor(uv);
    vec3 c = vec3(hash(cell), hash(cell + 17.0), hash(cell + 31.0));
    gl_FragColor = vec4(c, 1.0);
}'),

('c0000017-0004-0000-0000-000000000000', 'c0000017-0000-0000-0000-000000000000', '5-EoiI-KZPg', 3,
 'Static-noise field',
 '<p>Hash the raw fragment coordinate to get a different value per pixel, then <code>step(0.5, v)</code> to threshold into a binary mask. The result is a salt-and-pepper static texture.</p><p>Reference: <a href="https://thebookofshaders.com/10/" target="_blank" rel="noreferrer">Book of Shaders — Random</a>.</p>',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
void main() {
    // TODO: v = hash(gl_FragCoord.xy); output vec3(step(0.5, v)).
    float v = 0.0;
    gl_FragColor = vec4(vec3(v), 1.0);
}',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
void main() {
    float v = hash(gl_FragCoord.xy);
    gl_FragColor = vec4(vec3(step(0.5, v)), 1.0);
}'),

-- ===== Course: value-noise =====
('c0000018-0001-0000-0000-000000000000', 'c0000018-0000-0000-0000-000000000000', 'k5Xi7xvA2qU', 0,
 'Bilinear value noise',
 '<p>Value noise smooths the per-cell hash by bilinearly interpolating between the four corner hashes of each cell, with a smoothstep curve on the weights for visual continuity.</p><p>Sample the noise at <code>uv * 6.0</code> to fit a handful of cells across the canvas — the result is a soft blobby grayscale field.</p><p>Reference: <a href="https://thebookofshaders.com/11/" target="_blank" rel="noreferrer">Book of Shaders — Noise</a>.</p>',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i),            hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 6.0;
    // TODO: v = vnoise(uv); output vec3(v).
    float v = 0.0;
    gl_FragColor = vec4(vec3(v), 1.0);
}',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i),            hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 6.0;
    float v = vnoise(uv);
    gl_FragColor = vec4(vec3(v), 1.0);
}'),

('c0000018-0002-0000-0000-000000000000', 'c0000018-0000-0000-0000-000000000000', 'ZvRqVRXNQSM', 1,
 'Sliding origin',
 '<p>Adding a time-varying offset to the noise coordinate slides the whole field. Translate in x only — the noise scrolls horizontally like a slow conveyor belt.</p><p>Reference: <a href="https://thebookofshaders.com/11/" target="_blank" rel="noreferrer">Book of Shaders — Noise</a>.</p>',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i),            hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 6.0;
    // TODO: v = vnoise(uv + vec2(u_time * 0.3, 0.0));
    float v = vnoise(uv);
    gl_FragColor = vec4(vec3(v), 1.0);
}',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i),            hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 6.0;
    float v = vnoise(uv + vec2(u_time * 0.3, 0.0));
    gl_FragColor = vec4(vec3(v), 1.0);
}'),

('c0000018-0003-0000-0000-000000000000', 'c0000018-0000-0000-0000-000000000000', 'htcWkJzE_ps', 2,
 'Grayscale heightmap',
 '<p>Treat the noise output as a height and remap it through a color ramp. Mix from a dark blue at the lowlands to a warm sand at the peaks — instant landscape vibe.</p><p>Reference: <a href="https://iquilezles.org/articles/morenoise/" target="_blank" rel="noreferrer">IQ — Value noise derivatives</a>.</p>',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i),            hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 4.0;
    float h = vnoise(uv);
    // TODO: c = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), h);
    vec3 c = vec3(h);
    gl_FragColor = vec4(c, 1.0);
}',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i),            hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 4.0;
    float h = vnoise(uv);
    vec3 c = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), h);
    gl_FragColor = vec4(c, 1.0);
}'),

('c0000018-0004-0000-0000-000000000000', 'c0000018-0000-0000-0000-000000000000', 'aU1wXmUb_bM', 3,
 'Thresholded mask',
 '<p><code>step(0.5, vnoise(p))</code> turns the smooth field into a binary mask. The boundary follows the iso-line at 0.5 — irregular organic blobs.</p><p>Reference: <a href="https://thebookofshaders.com/11/" target="_blank" rel="noreferrer">Book of Shaders — Noise</a>.</p>',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i),            hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 5.0;
    // TODO: m = step(0.5, vnoise(uv));
    float m = vnoise(uv);
    gl_FragColor = vec4(vec3(m), 1.0);
}',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i),            hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 5.0;
    float m = step(0.5, vnoise(uv));
    gl_FragColor = vec4(vec3(m), 1.0);
}'),

-- ===== Course: gradient-noise =====
('c0000019-0001-0000-0000-000000000000', 'c0000019-0000-0000-0000-000000000000', '6I4Ck7-RJP0', 0,
 'Gradient noise field',
 '<p>Perlin-style gradient noise puts a random gradient vector at each lattice corner, then dot-products it with the offset from that corner to the sample point. Smoothstep-weighted bilinear blend gives a smoother, less blocky field than value noise.</p><p>Sample <code>gnoise(uv * 5.0)</code> and render as grayscale.</p><p>Reference: <a href="https://iquilezles.org/articles/gradientnoise/" target="_blank" rel="noreferrer">IQ — Gradient noise</a>.</p>',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
vec2 grad(vec2 p) {
    float a = hash(p) * 6.28318;
    return vec2(cos(a), sin(a));
}
float gnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    float a = dot(grad(i),                 f);
    float b = dot(grad(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0));
    float c = dot(grad(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0));
    float d = dot(grad(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0));
    return 0.5 + 0.5 * mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 5.0;
    // TODO: v = gnoise(uv); output vec3(v).
    float v = 0.0;
    gl_FragColor = vec4(vec3(v), 1.0);
}',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
vec2 grad(vec2 p) {
    float a = hash(p) * 6.28318;
    return vec2(cos(a), sin(a));
}
float gnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    float a = dot(grad(i),                 f);
    float b = dot(grad(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0));
    float c = dot(grad(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0));
    float d = dot(grad(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0));
    return 0.5 + 0.5 * mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 5.0;
    float v = gnoise(uv);
    gl_FragColor = vec4(vec3(v), 1.0);
}'),

('c0000019-0002-0000-0000-000000000000', 'c0000019-0000-0000-0000-000000000000', 'U2mTaGqvPfM', 1,
 'Value vs gradient',
 '<p>Render both noises side by side: value noise on the left half (<code>uv.x &lt; 0.5</code>), gradient noise on the right. Value noise looks blocky and quilted; gradient noise looks more cloud-like with diagonal structure.</p><p>Reference: <a href="https://thebookofshaders.com/11/" target="_blank" rel="noreferrer">Book of Shaders — Noise</a>.</p>',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i),            hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}
vec2 grad(vec2 p) {
    float a = hash(p) * 6.28318;
    return vec2(cos(a), sin(a));
}
float gnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    float a = dot(grad(i),                 f);
    float b = dot(grad(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0));
    float c = dot(grad(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0));
    float d = dot(grad(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0));
    return 0.5 + 0.5 * mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: v = (uv.x < 0.5) ? vnoise(uv * 5.0) : gnoise(uv * 5.0);
    float v = 0.0;
    gl_FragColor = vec4(vec3(v), 1.0);
}',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i),            hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}
vec2 grad(vec2 p) {
    float a = hash(p) * 6.28318;
    return vec2(cos(a), sin(a));
}
float gnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    float a = dot(grad(i),                 f);
    float b = dot(grad(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0));
    float c = dot(grad(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0));
    float d = dot(grad(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0));
    return 0.5 + 0.5 * mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float v = (uv.x < 0.5) ? vnoise(uv * 5.0) : gnoise(uv * 5.0);
    gl_FragColor = vec4(vec3(v), 1.0);
}'),

('c0000019-0003-0000-0000-000000000000', 'c0000019-0000-0000-0000-000000000000', '2Z-7PN_Q4WE', 2,
 'Animated drift',
 '<p>Translate the noise input by <code>(0, u_time * 0.2)</code> so the field drifts upward. The classic recipe for slow-moving clouds or rolling fog.</p><p>Reference: <a href="https://iquilezles.org/articles/gradientnoise/" target="_blank" rel="noreferrer">IQ — Gradient noise</a>.</p>',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
vec2 grad(vec2 p) {
    float a = hash(p) * 6.28318;
    return vec2(cos(a), sin(a));
}
float gnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    float a = dot(grad(i),                 f);
    float b = dot(grad(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0));
    float c = dot(grad(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0));
    float d = dot(grad(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0));
    return 0.5 + 0.5 * mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 4.0;
    // TODO: v = gnoise(uv + vec2(0.0, u_time * 0.2));
    float v = gnoise(uv);
    gl_FragColor = vec4(vec3(v), 1.0);
}',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
vec2 grad(vec2 p) {
    float a = hash(p) * 6.28318;
    return vec2(cos(a), sin(a));
}
float gnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    float a = dot(grad(i),                 f);
    float b = dot(grad(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0));
    float c = dot(grad(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0));
    float d = dot(grad(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0));
    return 0.5 + 0.5 * mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 4.0;
    float v = gnoise(uv + vec2(0.0, u_time * 0.2));
    gl_FragColor = vec4(vec3(v), 1.0);
}'),

('c0000019-0004-0000-0000-000000000000', 'c0000019-0000-0000-0000-000000000000', 'T2NF7k2xjr4', 3,
 'Ridge: 1 - abs(noise)',
 '<p>Remap the <code>[0, 1]</code> noise back to <code>[-1, 1]</code>, take the absolute value, and subtract from 1. Peaks of the original noise (and valleys) become sharp ridges of brightness — this is the basis of "ridged multifractal" terrain.</p><p>Reference: <a href="https://iquilezles.org/articles/gradientnoise/" target="_blank" rel="noreferrer">IQ — Gradient noise</a>.</p>',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
vec2 grad(vec2 p) {
    float a = hash(p) * 6.28318;
    return vec2(cos(a), sin(a));
}
float gnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    float a = dot(grad(i),                 f);
    float b = dot(grad(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0));
    float c = dot(grad(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0));
    float d = dot(grad(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0));
    return 0.5 + 0.5 * mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 4.0;
    float g = gnoise(uv);
    // TODO: v = 1.0 - abs(2.0 * g - 1.0);
    float v = g;
    gl_FragColor = vec4(vec3(v), 1.0);
}',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
vec2 grad(vec2 p) {
    float a = hash(p) * 6.28318;
    return vec2(cos(a), sin(a));
}
float gnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    float a = dot(grad(i),                 f);
    float b = dot(grad(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0));
    float c = dot(grad(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0));
    float d = dot(grad(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0));
    return 0.5 + 0.5 * mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 4.0;
    float g = gnoise(uv);
    float v = 1.0 - abs(2.0 * g - 1.0);
    gl_FragColor = vec4(vec3(v), 1.0);
}'),

-- ===== Course: voronoi =====
('c0000020-0001-0000-0000-000000000000', 'c0000020-0000-0000-0000-000000000000', '1pa9tbcxn-w', 0,
 'F1 distance field',
 '<p>Voronoi (a.k.a. Worley) noise scatters a feature point inside every grid cell and, for each pixel, returns the distance to the nearest such point. Iterate the 3x3 neighborhood around the current cell to find that nearest point.</p><p>Render the distance directly — you get cracked-mud cells with dark centers and bright junctions.</p><p>Reference: <a href="https://thebookofshaders.com/12/" target="_blank" rel="noreferrer">Book of Shaders — Cellular noise</a>.</p>',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float voronoi(vec2 uv) {
    vec2 i = floor(uv);
    vec2 f = fract(uv);
    float minD = 8.0;
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 n = vec2(float(x), float(y));
            vec2 o = vec2(hash(i + n), hash(i + n + vec2(7.0, 13.0)));
            vec2 r = n + o - f;
            minD = min(minD, dot(r, r));
        }
    }
    return sqrt(minD);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 6.0;
    // TODO: v = voronoi(uv); output vec3(v).
    float v = 0.0;
    gl_FragColor = vec4(vec3(v), 1.0);
}',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float voronoi(vec2 uv) {
    vec2 i = floor(uv);
    vec2 f = fract(uv);
    float minD = 8.0;
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 n = vec2(float(x), float(y));
            vec2 o = vec2(hash(i + n), hash(i + n + vec2(7.0, 13.0)));
            vec2 r = n + o - f;
            minD = min(minD, dot(r, r));
        }
    }
    return sqrt(minD);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 6.0;
    float v = voronoi(uv);
    gl_FragColor = vec4(vec3(v), 1.0);
}'),

('c0000020-0002-0000-0000-000000000000', 'c0000020-0000-0000-0000-000000000000', 'Dxt9A_WAVoI', 1,
 'Per-cell color',
 '<p>Track which neighbor cell won the <code>min</code> race, not just the distance to it. Hash that closest-cell id to get a stable color per Voronoi region — every cell becomes its own solid patch.</p><p>Reference: <a href="https://thebookofshaders.com/12/" target="_blank" rel="noreferrer">Book of Shaders — Cellular noise</a>.</p>',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
vec3 voronoiColor(vec2 uv) {
    vec2 i = floor(uv);
    vec2 f = fract(uv);
    float minD = 8.0;
    vec2 closest = vec2(0.0);
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 n = vec2(float(x), float(y));
            vec2 o = vec2(hash(i + n), hash(i + n + vec2(7.0, 13.0)));
            vec2 r = n + o - f;
            float d = dot(r, r);
            if (d < minD) {
                minD = d;
                closest = i + n;
            }
        }
    }
    // TODO: return vec3(hash(closest), hash(closest + 17.0), hash(closest + 31.0));
    return vec3(0.5);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 6.0;
    gl_FragColor = vec4(voronoiColor(uv), 1.0);
}',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
vec3 voronoiColor(vec2 uv) {
    vec2 i = floor(uv);
    vec2 f = fract(uv);
    float minD = 8.0;
    vec2 closest = vec2(0.0);
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 n = vec2(float(x), float(y));
            vec2 o = vec2(hash(i + n), hash(i + n + vec2(7.0, 13.0)));
            vec2 r = n + o - f;
            float d = dot(r, r);
            if (d < minD) {
                minD = d;
                closest = i + n;
            }
        }
    }
    return vec3(hash(closest), hash(closest + 17.0), hash(closest + 31.0));
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 6.0;
    gl_FragColor = vec4(voronoiColor(uv), 1.0);
}'),

('c0000020-0003-0000-0000-000000000000', 'c0000020-0000-0000-0000-000000000000', 'NGgJ1nctUsM', 2,
 'Cell borders',
 '<p>A short distance from a feature point means we''re still inside a cell; values very close to zero only happen at the seed itself. Use <code>smoothstep(0, 0.05, voronoi(...))</code> so cell interiors are bright and only the immediate neighborhood of each seed darkens — inverted from the usual edge rendering, but the same idea.</p><p>Reference: <a href="https://iquilezles.org/articles/voronoilines/" target="_blank" rel="noreferrer">IQ — Voronoi edges</a>.</p>',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float voronoi(vec2 uv) {
    vec2 i = floor(uv);
    vec2 f = fract(uv);
    float minD = 8.0;
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 n = vec2(float(x), float(y));
            vec2 o = vec2(hash(i + n), hash(i + n + vec2(7.0, 13.0)));
            vec2 r = n + o - f;
            minD = min(minD, dot(r, r));
        }
    }
    return sqrt(minD);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 6.0;
    // TODO: v = smoothstep(0.0, 0.05, voronoi(uv));
    float v = voronoi(uv);
    gl_FragColor = vec4(vec3(v), 1.0);
}',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float voronoi(vec2 uv) {
    vec2 i = floor(uv);
    vec2 f = fract(uv);
    float minD = 8.0;
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 n = vec2(float(x), float(y));
            vec2 o = vec2(hash(i + n), hash(i + n + vec2(7.0, 13.0)));
            vec2 r = n + o - f;
            minD = min(minD, dot(r, r));
        }
    }
    return sqrt(minD);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 6.0;
    float v = smoothstep(0.0, 0.05, voronoi(uv));
    gl_FragColor = vec4(vec3(v), 1.0);
}'),

('c0000020-0004-0000-0000-000000000000', 'c0000020-0000-0000-0000-000000000000', 'bd3TXMUCGPI', 3,
 'Animated cell centers',
 '<p>The per-cell offset <code>o</code> is what places each feature point. Replace the static hash with a time-driven <code>0.5 + 0.5 * sin(u_time + cellHash * 2π)</code> so every seed orbits inside its cell — the Voronoi diagram squirms.</p><p>Reference: <a href="https://iquilezles.org/articles/voronoilines/" target="_blank" rel="noreferrer">IQ — Voronoi edges</a>.</p>',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float voronoi(vec2 uv) {
    vec2 i = floor(uv);
    vec2 f = fract(uv);
    float minD = 8.0;
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 n = vec2(float(x), float(y));
            // TODO: o = vec2(0.5 + 0.5*sin(u_time + hash(i+n)*6.28318),
            //               0.5 + 0.5*sin(u_time + hash(i+n+vec2(7.0,13.0))*6.28318));
            vec2 o = vec2(hash(i + n), hash(i + n + vec2(7.0, 13.0)));
            vec2 r = n + o - f;
            minD = min(minD, dot(r, r));
        }
    }
    return sqrt(minD);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 6.0;
    gl_FragColor = vec4(vec3(voronoi(uv)), 1.0);
}',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float voronoi(vec2 uv) {
    vec2 i = floor(uv);
    vec2 f = fract(uv);
    float minD = 8.0;
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 n = vec2(float(x), float(y));
            vec2 o = vec2(0.5 + 0.5 * sin(u_time + hash(i + n) * 6.28318),
                          0.5 + 0.5 * sin(u_time + hash(i + n + vec2(7.0, 13.0)) * 6.28318));
            vec2 r = n + o - f;
            minD = min(minD, dot(r, r));
        }
    }
    return sqrt(minD);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 6.0;
    gl_FragColor = vec4(vec3(voronoi(uv)), 1.0);
}'),

-- ===== Course: fbm =====
('c0000021-0001-0000-0000-000000000000', 'c0000021-0000-0000-0000-000000000000', 'YVVANHjaPpc', 0,
 'Four-octave fbm',
 '<p>Fractal Brownian motion sums noise at multiple frequencies, halving the amplitude and doubling the frequency at each step. Four octaves is the common default — cheap and visibly cloud-like.</p><p>Sample <code>fbm(uv * 3.0)</code> and render as grayscale.</p><p>Reference: <a href="https://thebookofshaders.com/13/" target="_blank" rel="noreferrer">Book of Shaders — Fractal Brownian Motion</a>.</p>',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i),            hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}
float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 4; i++) {
        v += a * vnoise(p);
        p *= 2.0;
        a *= 0.5;
    }
    return v;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 3.0;
    // TODO: v = fbm(uv); output vec3(v).
    float v = 0.0;
    gl_FragColor = vec4(vec3(v), 1.0);
}',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i),            hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}
float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 4; i++) {
        v += a * vnoise(p);
        p *= 2.0;
        a *= 0.5;
    }
    return v;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 3.0;
    float v = fbm(uv);
    gl_FragColor = vec4(vec3(v), 1.0);
}'),

('c0000021-0002-0000-0000-000000000000', 'c0000021-0000-0000-0000-000000000000', 'bN_4zO2yfu8', 1,
 'Terrain bands',
 '<p>Quantize the fbm output into 8 steps with <code>floor(fbm * 8.0) / 8.0</code>. The smooth field becomes contour-like terraces — the simplest topo-map trick.</p><p>Reference: <a href="https://iquilezles.org/articles/fbm/" target="_blank" rel="noreferrer">IQ — fBM</a>.</p>',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i),            hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}
float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 4; i++) {
        v += a * vnoise(p);
        p *= 2.0;
        a *= 0.5;
    }
    return v;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 3.0;
    // TODO: v = floor(fbm(uv) * 8.0) / 8.0;
    float v = fbm(uv);
    gl_FragColor = vec4(vec3(v), 1.0);
}',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i),            hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}
float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 4; i++) {
        v += a * vnoise(p);
        p *= 2.0;
        a *= 0.5;
    }
    return v;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 3.0;
    float v = floor(fbm(uv) * 8.0) / 8.0;
    gl_FragColor = vec4(vec3(v), 1.0);
}'),

('c0000021-0003-0000-0000-000000000000', 'c0000021-0000-0000-0000-000000000000', 'GRU-ulHpUeA', 2,
 'Turbulence (abs)',
 '<p>"Turbulence" is fbm with <code>abs(2 * noise - 1)</code> instead of plain noise per octave. The folded absolute value introduces creases that look like billowing smoke.</p><p>Reference: <a href="https://iquilezles.org/articles/fbm/" target="_blank" rel="noreferrer">IQ — fBM</a>.</p>',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i),            hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}
float turb(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 4; i++) {
        // TODO: v += a * abs(2.0 * vnoise(p) - 1.0);
        v += a * vnoise(p);
        p *= 2.0;
        a *= 0.5;
    }
    return v;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 3.0;
    gl_FragColor = vec4(vec3(turb(uv)), 1.0);
}',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i),            hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}
float turb(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 4; i++) {
        v += a * abs(2.0 * vnoise(p) - 1.0);
        p *= 2.0;
        a *= 0.5;
    }
    return v;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 3.0;
    gl_FragColor = vec4(vec3(turb(uv)), 1.0);
}'),

('c0000021-0004-0000-0000-000000000000', 'c0000021-0000-0000-0000-000000000000', 'kP4ECqQABEI', 3,
 'Animated drift',
 '<p>Translate the fbm input with <code>vec2(0, u_time * 0.15)</code>. Because all four octaves share the same offset, the whole multifractal field drifts coherently — looks like slow weather.</p><p>Reference: <a href="https://iquilezles.org/articles/fbm/" target="_blank" rel="noreferrer">IQ — fBM</a>.</p>',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i),            hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}
float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 4; i++) {
        v += a * vnoise(p);
        p *= 2.0;
        a *= 0.5;
    }
    return v;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 3.0;
    // TODO: v = fbm(uv + vec2(0.0, u_time * 0.15));
    float v = fbm(uv);
    gl_FragColor = vec4(vec3(v), 1.0);
}',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i),            hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}
float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 4; i++) {
        v += a * vnoise(p);
        p *= 2.0;
        a *= 0.5;
    }
    return v;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 3.0;
    float v = fbm(uv + vec2(0.0, u_time * 0.15));
    gl_FragColor = vec4(vec3(v), 1.0);
}'),

-- ===== Course: domain-warping =====
('c0000022-0001-0000-0000-000000000000', 'c0000022-0000-0000-0000-000000000000', 'JsuBv4re3dI', 0,
 'Warp by noise vec',
 '<p>Domain warping bends the coordinate space with noise itself before sampling. Build a 2D offset <code>q = (fbm(uv), fbm(uv + 5.2))</code>, then sample <code>fbm(uv + 0.8 * q)</code>. The constant offset between the two fbms decorrelates them so the warp has both x and y motion.</p><p>Reference: <a href="https://iquilezles.org/articles/warp/" target="_blank" rel="noreferrer">IQ — Domain warping</a>.</p>',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i),            hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}
float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 4; i++) {
        v += a * vnoise(p);
        p *= 2.0;
        a *= 0.5;
    }
    return v;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 2.0;
    // TODO: q = vec2(fbm(uv), fbm(uv + 5.2)); v = fbm(uv + 0.8 * q);
    float v = fbm(uv);
    gl_FragColor = vec4(vec3(v), 1.0);
}',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i),            hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}
float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 4; i++) {
        v += a * vnoise(p);
        p *= 2.0;
        a *= 0.5;
    }
    return v;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 2.0;
    vec2 q = vec2(fbm(uv), fbm(uv + 5.2));
    float v = fbm(uv + 0.8 * q);
    gl_FragColor = vec4(vec3(v), 1.0);
}'),

('c0000022-0002-0000-0000-000000000000', 'c0000022-0000-0000-0000-000000000000', 'B7Uax6BPwGQ', 1,
 'Warped fbm',
 '<p>Same recipe, framed differently: explicitly compute the warp vector <code>q</code> and then sample fbm at the warped position. Tinting the output with the warm/dark palette makes the marbled structure pop.</p><p>Reference: <a href="https://iquilezles.org/articles/warp/" target="_blank" rel="noreferrer">IQ — Domain warping</a>.</p>',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i),            hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}
float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 4; i++) {
        v += a * vnoise(p);
        p *= 2.0;
        a *= 0.5;
    }
    return v;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 2.0;
    vec2 q = vec2(fbm(uv), fbm(uv + 5.2));
    float v = fbm(uv + 0.8 * q);
    // TODO: c = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), v);
    vec3 c = vec3(v);
    gl_FragColor = vec4(c, 1.0);
}',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i),            hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}
float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 4; i++) {
        v += a * vnoise(p);
        p *= 2.0;
        a *= 0.5;
    }
    return v;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 2.0;
    vec2 q = vec2(fbm(uv), fbm(uv + 5.2));
    float v = fbm(uv + 0.8 * q);
    vec3 c = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), v);
    gl_FragColor = vec4(c, 1.0);
}'),

('c0000022-0003-0000-0000-000000000000', 'c0000022-0000-0000-0000-000000000000', 'Wt23ZTB3KJw', 2,
 'Two-level warp',
 '<p>Chain two warps for an even richer marbled look: compute <code>q</code> from uv, then compute <code>r</code> from <code>uv + q</code> with new constant offsets, then sample <code>fbm(uv + r)</code>. This is IQ''s canonical two-level warp.</p><p>Reference: <a href="https://iquilezles.org/articles/warp/" target="_blank" rel="noreferrer">IQ — Domain warping</a>.</p>',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i),            hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}
float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 4; i++) {
        v += a * vnoise(p);
        p *= 2.0;
        a *= 0.5;
    }
    return v;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 2.0;
    // TODO:
    // q = vec2(fbm(uv), fbm(uv + 5.2));
    // r = vec2(fbm(uv + q + 1.7), fbm(uv + q + 9.2));
    // v = fbm(uv + r);
    float v = fbm(uv);
    gl_FragColor = vec4(vec3(v), 1.0);
}',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i),            hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}
float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 4; i++) {
        v += a * vnoise(p);
        p *= 2.0;
        a *= 0.5;
    }
    return v;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 2.0;
    vec2 q = vec2(fbm(uv), fbm(uv + 5.2));
    vec2 r = vec2(fbm(uv + q + 1.7), fbm(uv + q + 9.2));
    float v = fbm(uv + r);
    gl_FragColor = vec4(vec3(v), 1.0);
}'),

('c0000022-0004-0000-0000-000000000000', 'c0000022-0000-0000-0000-000000000000', 'yc3PaZZSqcM', 3,
 'Animated warp offset',
 '<p>Animate the warp by sliding the q-sampling location with <code>u_time * 0.1</code>. The structure morphs over time — the canvas looks like slowly stirring marble or oil paint.</p><p>Reference: <a href="https://iquilezles.org/articles/warp/" target="_blank" rel="noreferrer">IQ — Domain warping</a>.</p>',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i),            hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}
float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 4; i++) {
        v += a * vnoise(p);
        p *= 2.0;
        a *= 0.5;
    }
    return v;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 2.0;
    // TODO: q = vec2(fbm(uv + u_time * 0.1), fbm(uv + 5.2 + u_time * 0.1));
    //       v = fbm(uv + 0.8 * q);
    vec2 q = vec2(fbm(uv), fbm(uv + 5.2));
    float v = fbm(uv + 0.8 * q);
    gl_FragColor = vec4(vec3(v), 1.0);
}',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i),            hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}
float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 4; i++) {
        v += a * vnoise(p);
        p *= 2.0;
        a *= 0.5;
    }
    return v;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 2.0;
    vec2 q = vec2(fbm(uv + u_time * 0.1), fbm(uv + 5.2 + u_time * 0.1));
    float v = fbm(uv + 0.8 * q);
    gl_FragColor = vec4(vec3(v), 1.0);
}');
