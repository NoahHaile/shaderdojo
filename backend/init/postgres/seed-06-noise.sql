\c shader_dojo;

-- Family E, Noise (6 courses, 24 lessons)

INSERT INTO lesson (course_id, slug, display_order, title, description, starter_fragment_shader, canonical_fragment_shader) VALUES

-- ===== Course: hash-random =====
((SELECT id FROM course WHERE slug = 'hash-random'), '9C0KRy8EXPw', 0,
 'fract-sin hash',
 '<p>A hash takes a position in and gives a number out. The same position always gives the same number. Different positions give different numbers. The line <code>fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453)</code> turns any 2D point into a number from 0 up to 1. It looks random.</p><p>Try this: send each pixel''s <code>uv</code> through the hash. Put the result in all three color channels. The canvas fills with white noise.</p><p>Read more at <a href="https://thebookofshaders.com/10/" target="_blank" rel="noreferrer">Book of Shaders, Random</a>.</p>',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float v = hash(uv);
    gl_FragColor = vec4(vec3(v), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'hash-random'), 'sP81PGpNsDc', 1,
 'Random per cell',
 '<p>Snap <code>uv</code> to a grid first. Use <code>floor()</code> to round it down. Every pixel inside the same cell gets the same hash input. So every pixel in a cell gets the same gray.</p><p>The canvas turns into flat blocks of gray. Not speckle this time.</p><p>Read more at <a href="https://thebookofshaders.com/10/" target="_blank" rel="noreferrer">Book of Shaders, Random</a>.</p>',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float v = hash(uv);
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

((SELECT id FROM course WHERE slug = 'hash-random'), 'gwTmpCj_ML8', 2,
 'Random colored cells',
 '<p>One hash call gives one number. You need three for color: red, green, and blue. Call the hash three times. Each call uses a different offset so you get three different numbers.</p><p>Pack them into a <code>vec3</code>. Each cell gets its own color.</p><p>Read more at <a href="https://iquilezles.org/articles/sfrand/" target="_blank" rel="noreferrer">IQ, sfrand</a>.</p>',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 8.0;
    vec2 cell = floor(uv);
    float v = hash(cell);
    gl_FragColor = vec4(vec3(v), 1.0);
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

((SELECT id FROM course WHERE slug = 'hash-random'), '5-EoiI-KZPg', 3,
 'Static-noise field',
 '<p>Hash the raw pixel position <code>gl_FragCoord.xy</code>. Every pixel gets a different number. Then use <code>step(0.5, v)</code>. That gives 0 if the number is below 0.5 and 1 if it is above.</p><p>Each pixel becomes black or white. You get a salt-and-pepper static screen.</p><p>Read more at <a href="https://thebookofshaders.com/10/" target="_blank" rel="noreferrer">Book of Shaders, Random</a>.</p>',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
void main() {
    float v = hash(gl_FragCoord.xy);
    gl_FragColor = vec4(vec3(step(0.5, v)), 1.0);
}'),

-- ===== Course: value-noise =====
((SELECT id FROM course WHERE slug = 'value-noise'), 'k5Xi7xvA2qU', 0,
 'Bilinear value noise',
 '<p>Value noise is a grid of random numbers, smoothly blended between the corners. Each cell has four corners. You hash each corner. Then you blend the four numbers based on where your pixel sits inside the cell.</p><p>A smoothstep curve on the blend weights stops the joins from looking sharp. Sample at <code>uv * 6.0</code> to fit a few cells across the screen. You get soft gray blobs.</p><p>Read more at <a href="https://thebookofshaders.com/11/" target="_blank" rel="noreferrer">Book of Shaders, Noise</a>.</p>',
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
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
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

((SELECT id FROM course WHERE slug = 'value-noise'), 'ZvRqVRXNQSM', 1,
 'Tilt and rotate noise',
 '<p>The input position does not have to map straight onto the noise grid. Multiply <code>uv</code> by a small 2x2 rotation matrix before you sample. Pick an angle like <code>0.7</code> radians. Build <code>mat2(c, -s, s, c)</code> with <code>c = cos(0.7)</code> and <code>s = sin(0.7)</code>.</p><p>Then scale the result by <code>1.4</code> for a zoom tweak. You get the same value noise field, but tilted on its side and a touch closer up.</p><p>Read more at <a href="https://thebookofshaders.com/08/" target="_blank" rel="noreferrer">Book of Shaders, Matrices</a>.</p>',
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
    float c = cos(0.7), s = sin(0.7);
    uv = mat2(c, -s, s, c) * uv * 1.4;
    float v = vnoise(uv);
    gl_FragColor = vec4(vec3(v), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'value-noise'), 'htcWkJzE_ps', 2,
 'Grayscale heightmap',
 '<p>Use the noise number as a height. Low spots are valleys. High spots are peaks. Run that height through <code>mix()</code> between two colors.</p><p>Pick a dark blue for low and a warm sand for high. The flat gray field turns into a small landscape.</p><p>Read more at <a href="https://iquilezles.org/articles/morenoise/" target="_blank" rel="noreferrer">IQ, Value noise derivatives</a>.</p>',
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
    gl_FragColor = vec4(vec3(h), 1.0);
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

((SELECT id FROM course WHERE slug = 'value-noise'), 'aU1wXmUb_bM', 3,
 'Thresholded mask',
 '<p>Take the smooth noise and cut it in half. Use <code>step(0.5, vnoise(p))</code>. Pixels below 0.5 turn black. Pixels above turn white.</p><p>The line between black and white follows the noise at value 0.5. You get organic blobs with wavy edges.</p><p>Read more at <a href="https://thebookofshaders.com/11/" target="_blank" rel="noreferrer">Book of Shaders, Noise</a>.</p>',
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
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 5.0;
    float m = step(0.5, vnoise(uv));
    gl_FragColor = vec4(vec3(m), 1.0);
}'),

-- ===== Course: gradient-noise =====
((SELECT id FROM course WHERE slug = 'gradient-noise'), '6I4Ck7-RJP0', 0,
 'Gradient noise field',
 '<p>Gradient noise is a grid of random directions, blended between the corners. At each corner you place a random 2D arrow. You take the dot product of that arrow with the offset from the corner to your pixel. Then you blend the four corner results with smoothstep weights.</p><p>It looks smoother than value noise. Sample <code>gnoise(uv * 5.0)</code> and output it as gray.</p><p>Read more at <a href="https://iquilezles.org/articles/gradientnoise/" target="_blank" rel="noreferrer">IQ, Gradient noise</a>.</p>',
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
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
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

((SELECT id FROM course WHERE slug = 'gradient-noise'), 'U2mTaGqvPfM', 1,
 'Value vs gradient',
 '<p>Show both kinds of noise side by side. Check <code>uv.x &lt; 0.5</code>. On the left, draw value noise. On the right, draw gradient noise.</p><p>Value noise looks blocky and quilted. Gradient noise looks more like clouds with soft diagonal lines.</p><p>Read more at <a href="https://thebookofshaders.com/11/" target="_blank" rel="noreferrer">Book of Shaders, Noise</a>.</p>',
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
    float v = gnoise(uv * 5.0);
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

((SELECT id FROM course WHERE slug = 'gradient-noise'), '2Z-7PN_Q4WE', 2,
 'Two-octave gradient noise',
 '<p>One noise layer is smooth but plain. Add a second layer at twice the frequency and half the amplitude: <code>gnoise(uv) + 0.5 * gnoise(uv * 2.0)</code>. The coarse layer gives the big shape. The finer layer adds little bumps inside it.</p><p>Divide by <code>1.5</code> to bring the total back into the 0 to 1 range. The result has visibly more detail than plain gradient noise. This is a tiny preview of fbm, where you stack many octaves.</p><p>Read more at <a href="https://thebookofshaders.com/13/" target="_blank" rel="noreferrer">Book of Shaders, Fractal Brownian Motion</a>.</p>',
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
    float v = gnoise(uv) + 0.5 * gnoise(uv * 2.0);
    v = v / 1.5;
    gl_FragColor = vec4(vec3(v), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'gradient-noise'), 'T2NF7k2xjr4', 3,
 'Ridge: 1 - abs(noise)',
 '<p>The noise gives a number from 0 to 1. Move it to -1 to 1 with <code>2.0 * g - 1.0</code>. Take the absolute value. Subtract from 1.</p><p>Now the high spots and low spots both flip up. Every peak and valley becomes a sharp bright ridge. This is the start of ridged terrain.</p><p>Read more at <a href="https://iquilezles.org/articles/gradientnoise/" target="_blank" rel="noreferrer">IQ, Gradient noise</a>.</p>',
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
    gl_FragColor = vec4(vec3(g), 1.0);
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
((SELECT id FROM course WHERE slug = 'voronoi'), '1pa9tbcxn-w', 0,
 'F1 distance field',
 '<p>Voronoi noise scatters one point inside each grid cell. For each pixel, you find the closest point. The output is the distance to that point.</p><p>Your pixel could be near a point in any of the nine cells around it. So check the 3 by 3 block of cells and keep the smallest distance. Output that distance as gray. You get cracked-mud cells with dark centers and bright edges.</p><p>Read more at <a href="https://thebookofshaders.com/12/" target="_blank" rel="noreferrer">Book of Shaders, Cellular noise</a>.</p>',
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
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
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

((SELECT id FROM course WHERE slug = 'voronoi'), 'Dxt9A_WAVoI', 1,
 'Per-cell color',
 '<p>Keep track of which cell had the closest point. Save its id while you loop. Then hash that id to make a color.</p><p>Every cell gets one solid color. The same cell always gets the same color. The screen looks like a stained glass window.</p><p>Read more at <a href="https://thebookofshaders.com/12/" target="_blank" rel="noreferrer">Book of Shaders, Cellular noise</a>.</p>',
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
    return vec3(sqrt(minD));
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

((SELECT id FROM course WHERE slug = 'voronoi'), 'NGgJ1nctUsM', 2,
 'Cell borders',
 '<p>The Voronoi distance is only near zero right at a point. Anywhere else in the cell it is bigger. Use <code>smoothstep(0.0, 0.05, voronoi(uv))</code> to push small distances to 0 and the rest to 1.</p><p>Cell insides go bright. Only the small spot around each point goes dark. The dark spots mark where the seed points sit.</p><p>Read more at <a href="https://iquilezles.org/articles/voronoilines/" target="_blank" rel="noreferrer">IQ, Voronoi edges</a>.</p>',
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

((SELECT id FROM course WHERE slug = 'voronoi'), 'bd3TXMUCGPI', 3,
 'Animated cell centers',
 '<p>The offset <code>o</code> tells you where the point sits inside its cell. Right now it is fixed. Make it move with time.</p><p>Use <code>0.5 + 0.5 * sin(u_time + hash(cell) * 6.28318)</code> for x and y. Each point now wiggles in place. The whole Voronoi pattern squirms.</p><p>Read more at <a href="https://iquilezles.org/articles/voronoilines/" target="_blank" rel="noreferrer">IQ, Voronoi edges</a>.</p>',
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
((SELECT id FROM course WHERE slug = 'fbm'), 'YVVANHjaPpc', 0,
 'Four-octave fbm',
 '<p>fbm stacks noise at smaller scales. The first layer gives the big shape. Each next layer adds smaller detail. Each step doubles the frequency and halves the amplitude.</p><p>Four layers is a common choice. It is cheap and looks like clouds. Sample <code>fbm(uv * 3.0)</code> and output it as gray.</p><p>Read more at <a href="https://thebookofshaders.com/13/" target="_blank" rel="noreferrer">Book of Shaders, Fractal Brownian Motion</a>.</p>',
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
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
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

((SELECT id FROM course WHERE slug = 'fbm'), 'bN_4zO2yfu8', 1,
 'Terrain bands',
 '<p>Round the fbm output to 8 steps. Use <code>floor(fbm(uv) * 8.0) / 8.0</code>. The smooth field turns into flat bands of gray.</p><p>The bands look like contour lines on a topo map.</p><p>Read more at <a href="https://iquilezles.org/articles/fbm/" target="_blank" rel="noreferrer">IQ, fBM</a>.</p>',
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

((SELECT id FROM course WHERE slug = 'fbm'), 'GRU-ulHpUeA', 2,
 'Turbulence (abs)',
 '<p>Turbulence is fbm with a small change. In each layer, replace <code>vnoise(p)</code> with <code>abs(2.0 * vnoise(p) - 1.0)</code>.</p><p>That folds the noise so both peaks and valleys point up. The folds make sharp creases at every layer. The result looks like puffs of smoke.</p><p>Read more at <a href="https://iquilezles.org/articles/fbm/" target="_blank" rel="noreferrer">IQ, fBM</a>.</p>',
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

((SELECT id FROM course WHERE slug = 'fbm'), 'kP4ECqQABEI', 3,
 'Animated drift',
 '<p>Add <code>vec2(0.0, u_time * 0.15)</code> to the fbm input. All four layers share the same offset, so they all move together.</p><p>The big shapes and the small detail drift as one. It looks like slow weather.</p><p>Read more at <a href="https://iquilezles.org/articles/fbm/" target="_blank" rel="noreferrer">IQ, fBM</a>.</p>',
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
((SELECT id FROM course WHERE slug = 'domain-warping'), 'JsuBv4re3dI', 0,
 'Warp by noise vec',
 '<p>Domain warping moves the input position with noise before you sample more noise. Build a 2D offset <code>q = vec2(fbm(uv), fbm(uv + 5.2))</code>. Then sample <code>fbm(uv + 0.8 * q)</code>.</p><p>The two fbm calls use different inputs, so x and y move on their own. The smooth field starts to bend and swirl.</p><p>Read more at <a href="https://iquilezles.org/articles/warp/" target="_blank" rel="noreferrer">IQ, Domain warping</a>.</p>',
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

((SELECT id FROM course WHERE slug = 'domain-warping'), 'B7Uax6BPwGQ', 1,
 'Warped fbm',
 '<p>Same warp as before. Compute <code>q</code> first, then sample fbm at the warped position. This time, color the output instead of using gray.</p><p>Mix from a dark blue at the lows to a warm sand at the highs. The swirly marbled structure stands out.</p><p>Read more at <a href="https://iquilezles.org/articles/warp/" target="_blank" rel="noreferrer">IQ, Domain warping</a>.</p>',
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

((SELECT id FROM course WHERE slug = 'domain-warping'), 'Wt23ZTB3KJw', 2,
 'Two-level warp',
 '<p>Chain two warps for a richer marble. First compute <code>q</code> from <code>uv</code>. Then compute <code>r</code> from <code>uv + q</code> with new offsets. Finally sample <code>fbm(uv + r)</code>.</p><p>The first warp shapes the input. The second warp shapes that. You get deep swirls inside swirls. This is IQ''s two-level warp.</p><p>Read more at <a href="https://iquilezles.org/articles/warp/" target="_blank" rel="noreferrer">IQ, Domain warping</a>.</p>',
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

((SELECT id FROM course WHERE slug = 'domain-warping'), 'yc3PaZZSqcM', 3,
 'Two-level warp (warp the warp)',
 '<p>You can warp the warp. First compute <code>q</code> with two fbm samples, just like before. Then build a second offset <code>r</code> whose inputs already include <code>4.0 * q</code>. Each component of <code>r</code> uses its own constant offset so the two coordinates stay independent.</p><p>Finally sample <code>fbm(uv + 4.0 * r)</code>. Each warp bends the input that feeds the next one. The distortions compound and the field grows deep, twisted, marble-like swirls. This is the classic two-level pattern from IQ''s warp article.</p><p>Read more at <a href="https://iquilezles.org/articles/warp/" target="_blank" rel="noreferrer">IQ, Domain warping</a>.</p>',
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
    vec2 q = vec2(fbm(uv + vec2(0.0, 0.0)), fbm(uv + vec2(5.2, 1.3)));
    vec2 r = vec2(fbm(uv + 4.0 * q + vec2(1.7, 9.2)), fbm(uv + 4.0 * q + vec2(8.3, 2.8)));
    float v = fbm(uv + 4.0 * r);
    gl_FragColor = vec4(vec3(v), 1.0);
}');
