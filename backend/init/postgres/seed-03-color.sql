\c shader_dojo;

-- Family B — Color (3 courses, 12 lessons)

INSERT INTO lesson (course_id, slug, display_order, title, description, starter_fragment_shader, canonical_fragment_shader) VALUES

-- ===== Course: hsv-color =====
((SELECT id FROM course WHERE slug = 'hsv-color'), 'p60fmIlW-3M', 0,
 'Hue wheel along x',
 '<p>The HSV color space lets you set a hue once and walk it through every color at maximum saturation and value. Build the standard <code>hsv2rgb</code> helper, then feed in <code>vec3(uv.x, 1.0, 1.0)</code> so the canvas sweeps every hue from left to right.</p><p>Reference: <a href="https://thebookofshaders.com/06/" target="_blank" rel="noreferrer">Book of Shaders — Colors (HSB section)</a>.</p>',
 'vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: c = hsv2rgb(vec3(uv.x, 1.0, 1.0));
    vec3 c = vec3(0.5);
    gl_FragColor = vec4(c, 1.0);
}',
 'vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 c = hsv2rgb(vec3(uv.x, 1.0, 1.0));
    gl_FragColor = vec4(c, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'hsv-color'), '2RCHfX2ZA7s', 1,
 'Hue from polar angle',
 '<p>Feed the polar angle into hue instead of x. The result is a true color wheel: pure red at <code>0°</code>, cycling all the way around to red again.</p><p>Reference: <a href="https://thebookofshaders.com/06/" target="_blank" rel="noreferrer">Book of Shaders — Colors</a>.</p>',
 'vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    // TODO: h = atan(p.y, p.x) / (2.0 * 3.14159) + 0.5;  then hsv2rgb(vec3(h, 1.0, 1.0))
    vec3 c = vec3(0.5);
    gl_FragColor = vec4(c, 1.0);
}',
 'vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float h = atan(p.y, p.x) / (2.0 * 3.14159) + 0.5;
    vec3 c = hsv2rgb(vec3(h, 1.0, 1.0));
    gl_FragColor = vec4(c, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'hsv-color'), '_XPXs6awl8U', 2,
 'Saturation by radius',
 '<p>Fix the hue, drive saturation by radius. Centers are gray (no color), edges are fully saturated. Clamp the radius so it stays in <code>[0, 1]</code>.</p><p>Reference: <a href="https://thebookofshaders.com/06/" target="_blank" rel="noreferrer">Book of Shaders — Colors</a>.</p>',
 'vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    // TODO: s = clamp(length(p) * 2.0, 0.0, 1.0); then hsv2rgb(vec3(0.07, s, 1.0))
    vec3 c = vec3(1.0);
    gl_FragColor = vec4(c, 1.0);
}',
 'vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float s = clamp(length(p) * 2.0, 0.0, 1.0);
    vec3 c = hsv2rgb(vec3(0.07, s, 1.0));
    gl_FragColor = vec4(c, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'hsv-color'), 'uQitrBNNf48', 3,
 'Value pulse on time',
 '<p>Lock hue and saturation, drive value with a time oscillator. The canvas pulses brighter and darker without changing color.</p><p>Reference: <a href="https://thebookofshaders.com/06/" target="_blank" rel="noreferrer">Book of Shaders — Colors</a>.</p>',
 'vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
void main() {
    // TODO: v = 0.5 + 0.5 * sin(u_time); then hsv2rgb(vec3(0.55, 1.0, v))
    vec3 c = hsv2rgb(vec3(0.55, 1.0, 1.0));
    gl_FragColor = vec4(c, 1.0);
}',
 'vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
void main() {
    float v = 0.5 + 0.5 * sin(u_time);
    vec3 c = hsv2rgb(vec3(0.55, 1.0, v));
    gl_FragColor = vec4(c, 1.0);
}'),

-- ===== Course: cosine-palettes =====
((SELECT id FROM course WHERE slug = 'cosine-palettes'), 'lUI79_46ook', 0,
 'Static cosine palette',
 '<p>Inigo Quilez''s palette generator is four vectors and one cosine: <code>a + b * cos(2π * (c * t + d))</code>. The classic default <code>a = b = vec3(0.5)</code>, <code>c = vec3(1.0)</code>, <code>d = vec3(0.00, 0.33, 0.67)</code> sweeps through every hue. Feed <code>uv.x</code> as <code>t</code>.</p><p>Reference: <a href="https://iquilezles.org/articles/palettes/" target="_blank" rel="noreferrer">IQ — Palettes</a>.</p>',
 'vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
    return a + b * cos(6.28318 * (c * t + d));
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: c = palette(uv.x, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.00, 0.33, 0.67));
    vec3 c = vec3(0.5);
    gl_FragColor = vec4(c, 1.0);
}',
 'vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
    return a + b * cos(6.28318 * (c * t + d));
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 c = palette(uv.x, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.00, 0.33, 0.67));
    gl_FragColor = vec4(c, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'cosine-palettes'), 'a1X-bvkK6Nw', 1,
 'Animated palette',
 '<p>The same palette, but <code>t</code> drifts with time. The whole canvas becomes one color that cycles through the palette.</p><p>Reference: <a href="https://iquilezles.org/articles/palettes/" target="_blank" rel="noreferrer">IQ — Palettes</a>.</p>',
 'vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
    return a + b * cos(6.28318 * (c * t + d));
}
void main() {
    // TODO: c = palette(u_time * 0.2, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.00, 0.33, 0.67));
    vec3 c = vec3(0.5);
    gl_FragColor = vec4(c, 1.0);
}',
 'vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
    return a + b * cos(6.28318 * (c * t + d));
}
void main() {
    vec3 c = palette(u_time * 0.2, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.00, 0.33, 0.67));
    gl_FragColor = vec4(c, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'cosine-palettes'), 'G2adWB1gqbk', 2,
 'Radial palette',
 '<p>Use the distance from the center as palette <code>t</code> instead of <code>uv.x</code>. The palette wraps into concentric rings.</p><p>Reference: <a href="https://iquilezles.org/articles/palettes/" target="_blank" rel="noreferrer">IQ — Palettes</a>.</p>',
 'vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
    return a + b * cos(6.28318 * (c * t + d));
}
void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    // TODO: r = length(p); c = palette(r, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.00, 0.33, 0.67));
    vec3 c = vec3(0.5);
    gl_FragColor = vec4(c, 1.0);
}',
 'vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
    return a + b * cos(6.28318 * (c * t + d));
}
void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float r = length(p);
    vec3 c = palette(r, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.00, 0.33, 0.67));
    gl_FragColor = vec4(c, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'cosine-palettes'), 'JIh3Pj3mAuw', 3,
 'Custom sunset palette',
 '<p>Swap the four vectors to build a palette of your own. These values shift the bias, contrast, frequency, and phase of each channel to produce warm sunset tones.</p><p>Reference: <a href="https://iquilezles.org/articles/palettes/" target="_blank" rel="noreferrer">IQ — Palettes</a>.</p>',
 'vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
    return a + b * cos(6.28318 * (c * t + d));
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: c = palette(uv.y, vec3(0.66, 0.50, 0.40), vec3(0.50, 0.40, 0.20), vec3(0.8, 0.6, 0.5), vec3(0.00, 0.20, 0.50));
    vec3 c = vec3(0.5);
    gl_FragColor = vec4(c, 1.0);
}',
 'vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
    return a + b * cos(6.28318 * (c * t + d));
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 c = palette(uv.y, vec3(0.66, 0.50, 0.40), vec3(0.50, 0.40, 0.20), vec3(0.8, 0.6, 0.5), vec3(0.00, 0.20, 0.50));
    gl_FragColor = vec4(c, 1.0);
}'),

-- ===== Course: tone-vignette-gamma =====
((SELECT id FROM course WHERE slug = 'tone-vignette-gamma'), 'hK5QJQ86oMc', 0,
 'Gamma correction',
 '<p>Raw linear-light values look too dark on the screen because monitors apply a nonlinear (gamma ~2.2) response. The standard fix at the end of a shader: <code>pow(color, vec3(1.0/2.2))</code>. Render a linear gradient before and apply gamma to see the difference.</p><p>Reference: <a href="https://iquilezles.org/articles/gamma/" target="_blank" rel="noreferrer">IQ — Gamma correct blurring</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 c = vec3(uv.x);
    // TODO: c = pow(c, vec3(1.0/2.2));
    gl_FragColor = vec4(c, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 c = vec3(uv.x);
    c = pow(c, vec3(1.0/2.2));
    gl_FragColor = vec4(c, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'tone-vignette-gamma'), 'BPmLthBAT2s', 1,
 'Radial vignette',
 '<p>A vignette darkens the corners of the frame. Smoothstep the radius from the center: full brightness inside a disc, darkening to zero at the edges. Multiply your color by the vignette mask.</p><p>Reference: <a href="https://iquilezles.org/articles/outdoorslighting/" target="_blank" rel="noreferrer">IQ — Outdoors lighting</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 c = vec3(0.95, 0.81, 0.36);
    // TODO: v = 1.0 - smoothstep(0.4, 0.75, length(p)); c *= v;
    gl_FragColor = vec4(c, 1.0);
}',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 c = vec3(0.95, 0.81, 0.36);
    float v = 1.0 - smoothstep(0.4, 0.75, length(p));
    c *= v;
    gl_FragColor = vec4(c, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'tone-vignette-gamma'), 'B9_W_mw16Gc', 2,
 'Reinhard tone map',
 '<p>HDR colors can exceed 1.0; tone mapping squashes them into the visible <code>[0, 1]</code> range. Reinhard is the simplest: <code>c / (c + 1.0)</code>. Multiply your gradient up to "blow it out", then Reinhard-map it.</p><p>Reference: <a href="https://iquilezles.org/articles/outdoorslighting/" target="_blank" rel="noreferrer">IQ — Outdoors lighting</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 c = vec3(uv.x * 4.0, uv.y * 2.0, 1.0);
    // TODO: c = c / (c + 1.0);
    gl_FragColor = vec4(c, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 c = vec3(uv.x * 4.0, uv.y * 2.0, 1.0);
    c = c / (c + 1.0);
    gl_FragColor = vec4(c, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'tone-vignette-gamma'), 'Ae7sCWNcjgw', 3,
 'ACES tone map approximation',
 '<p>Krzysztof Narkowicz''s ACES fit packs the filmic tone curve into one expression: <code>(c*(a*c+b))/(c*(c*c+d)+e)</code> with <code>a=2.51, b=0.03, c=2.43, d=0.59, e=0.14</code>. It compresses highlights more gracefully than Reinhard.</p><p>Reference: <a href="https://iquilezles.org/articles/outdoorslighting/" target="_blank" rel="noreferrer">IQ — Outdoors lighting</a>.</p>',
 'vec3 aces(vec3 x) {
    return clamp((x * (2.51 * x + 0.03)) / (x * (2.43 * x + 0.59) + 0.14), 0.0, 1.0);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 c = vec3(uv.x * 4.0, uv.y * 2.0, 1.0);
    // TODO: c = aces(c);
    gl_FragColor = vec4(c, 1.0);
}',
 'vec3 aces(vec3 x) {
    return clamp((x * (2.51 * x + 0.03)) / (x * (2.43 * x + 0.59) + 0.14), 0.0, 1.0);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 c = vec3(uv.x * 4.0, uv.y * 2.0, 1.0);
    c = aces(c);
    gl_FragColor = vec4(c, 1.0);
}');
