\c shader_dojo;

-- Family B — Color (3 courses, 12 lessons)
-- Same lecture-style rules as Foundations: explicit recipes, hand-holding TODOs.

INSERT INTO lesson (course_id, slug, display_order, title, description, starter_fragment_shader, canonical_fragment_shader) VALUES

-- ===== Course: hsv-color =====
((SELECT id FROM course WHERE slug = 'hsv-color'), 'p60fmIlW-3M', 0,
 'Hue wheel along x',
 '<p><strong>Goal.</strong> Meet HSV — the color space where "color" and "brightness" are two separate knobs.</p><p><strong>The three knobs.</strong></p><ul><li><strong>Hue</strong> (0..1) — which color: 0 red, 0.33 green, 0.67 blue, back to red at 1.</li><li><strong>Saturation</strong> (0..1) — how strong: 0 is gray, 1 is full color.</li><li><strong>Value</strong> (0..1) — how bright: 0 is black, 1 is the brightest the channel will go.</li></ul><p><strong>The recipe.</strong> The starter ships a 4-line <code>hsv2rgb</code> helper — paste-once, use everywhere. Feed it <code>vec3(uv.x, 1.0, 1.0)</code>: hue runs left-to-right, saturation and value pinned to max. Result: the full hue spectrum sweeping across the canvas.</p><p>Reference: <a href="https://thebookofshaders.com/06/" target="_blank" rel="noreferrer">Book of Shaders — Colors (HSB section)</a>.</p>',
 'vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: hue from uv.x, saturation and value at 1.0.
    // vec3 c = hsv2rgb(vec3(uv.x, 1.0, 1.0));
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
 '<p><strong>Goal.</strong> Drive hue by direction instead of by x. The result is the classic color wheel.</p><p><strong>The recipe.</strong></p><ol><li>Get the polar angle of the centered position: <code>atan(p.y, p.x)</code> returns radians in <code>[-π, π]</code>.</li><li>Divide by <code>2π</code> to get <code>[-0.5, 0.5]</code>.</li><li>Add <code>0.5</code> so the range becomes <code>[0, 1]</code> — exactly what HSV wants for hue.</li><li>Feed that into <code>hsv2rgb(vec3(h, 1.0, 1.0))</code>.</li></ol><p>Pure red points right, green points up-left, blue points down-left — the standard color wheel orientation.</p><p>Reference: <a href="https://thebookofshaders.com/06/" target="_blank" rel="noreferrer">Book of Shaders — Colors</a>.</p>',
 'vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    // TODO: hue = atan(p.y, p.x) / (2π) + 0.5.
    // float h = atan(p.y, p.x) / (2.0 * 3.14159) + 0.5;
    // vec3 c = hsv2rgb(vec3(h, 1.0, 1.0));
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
 '<p><strong>Goal.</strong> Lock the hue to one value, drive saturation by distance from the center.</p><p><strong>The setup.</strong> Hue <code>0.07</code> is a salmon-orange. Saturation goes from 0 at the center (gray) to 1 at radius ≥ 0.5 (fully saturated).</p><p><strong>The recipe.</strong></p><ol><li>Centered, aspect-corrected position <code>p</code>.</li><li><code>s = clamp(length(p) * 2.0, 0.0, 1.0)</code> — multiply by 2 so saturation reaches 1 at radius 0.5; clamp so points beyond the disc stay at 1.</li><li><code>hsv2rgb(vec3(0.07, s, 1.0))</code>.</li></ol><p>You''ll see a salmon disc that fades to white at its center.</p><p>Reference: <a href="https://thebookofshaders.com/06/" target="_blank" rel="noreferrer">Book of Shaders — Colors</a>.</p>',
 'vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    // TODO: saturation = clamp(length(p) * 2.0, 0.0, 1.0).
    // float s = clamp(length(p) * 2.0, 0.0, 1.0);
    // vec3 c = hsv2rgb(vec3(0.07, s, 1.0));
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
 '<p><strong>Goal.</strong> Pin hue and saturation, drive value with the time oscillator from Family A.</p><p><strong>Why this matters.</strong> Unlike RGB, HSV lets you change "brightness" without changing "color." Drop <code>v = 0.5 + 0.5 * sin(u_time)</code> into the value slot and the canvas pulses dark↔bright without the hue drifting.</p><p>This is one of the practical wins of HSV: animate brightness independently of color.</p><p>Reference: <a href="https://thebookofshaders.com/06/" target="_blank" rel="noreferrer">Book of Shaders — Colors</a>.</p>',
 'vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
void main() {
    // TODO: v = 0.5 + 0.5 * sin(u_time); plug into hsv2rgb.
    // float v = 0.5 + 0.5 * sin(u_time);
    // vec3 c = hsv2rgb(vec3(0.55, 1.0, v));
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
 '<p><strong>Goal.</strong> Build an infinitely-tunable palette generator from one cosine and four vectors.</p><p><strong>The formula (Inigo Quilez).</strong> <code>color(t) = a + b · cos(2π · (c · t + d))</code>. Each input is a <code>vec3</code> (one channel each); <code>t</code> is the position along the palette.</p><ul><li><code>a</code> — the average color (DC bias).</li><li><code>b</code> — how much each channel varies (amplitude).</li><li><code>c</code> — how many cycles each channel makes over the range (frequency).</li><li><code>d</code> — where each channel''s cycle starts (phase).</li></ul><p><strong>The default rainbow.</strong> <code>a = b = vec3(0.5)</code>, <code>c = vec3(1.0)</code>, <code>d = vec3(0.00, 0.33, 0.67)</code>. Feed <code>uv.x</code> as <code>t</code> — every hue appears across the canvas.</p><p>Reference: <a href="https://iquilezles.org/articles/palettes/" target="_blank" rel="noreferrer">IQ — Palettes</a>.</p>',
 'vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
    return a + b * cos(6.28318 * (c * t + d));
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: classic rainbow palette indexed by uv.x.
    // vec3 c = palette(uv.x, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.00, 0.33, 0.67));
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
 '<p><strong>Goal.</strong> Replace the spatial <code>t</code> with a temporal one. The whole canvas becomes a single color that cycles through every shade of the palette.</p><p><strong>The change.</strong> Pass <code>u_time * 0.2</code> as <code>t</code> instead of <code>uv.x</code>. The <code>0.2</code> slows the cycle to about one full sweep every 5 seconds.</p><p>Reference: <a href="https://iquilezles.org/articles/palettes/" target="_blank" rel="noreferrer">IQ — Palettes</a>.</p>',
 'vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
    return a + b * cos(6.28318 * (c * t + d));
}
void main() {
    // TODO: t = u_time * 0.2 (slow cycle).
    // vec3 c = palette(u_time * 0.2, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.00, 0.33, 0.67));
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
 '<p><strong>Goal.</strong> Use distance-from-center as <code>t</code> and the palette wraps into concentric rings.</p><p><strong>The recipe.</strong> Centered, aspect-corrected <code>p</code>, then <code>r = length(p)</code>, then <code>palette(r, ...)</code>. Because <code>r</code> grows from 0 outward but the palette cycles at <code>t = 1, 2, 3, ...</code>, the canvas reveals rings of color as <code>r</code> crosses each integer.</p><p>Reference: <a href="https://iquilezles.org/articles/palettes/" target="_blank" rel="noreferrer">IQ — Palettes</a>.</p>',
 'vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
    return a + b * cos(6.28318 * (c * t + d));
}
void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    // TODO: r = length(p); palette indexed by r.
    // float r = length(p);
    // vec3 c = palette(r, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.00, 0.33, 0.67));
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
 '<p><strong>Goal.</strong> Pick four new vectors to build a palette of your own.</p><p><strong>What each vector controls (recap).</strong> <code>a</code> is bias, <code>b</code> is contrast, <code>c</code> is per-channel frequency, <code>d</code> is per-channel phase. By dropping <code>c</code> below 1 you keep more of the cycle off-screen, biasing toward a partial color range — exactly what a sunset is.</p><p><strong>The palette.</strong> <code>a=(0.66, 0.50, 0.40)</code>, <code>b=(0.50, 0.40, 0.20)</code>, <code>c=(0.8, 0.6, 0.5)</code>, <code>d=(0.00, 0.20, 0.50)</code>. Index by <code>uv.y</code> so warmth rises toward the top.</p><p>Reference: <a href="https://iquilezles.org/articles/palettes/" target="_blank" rel="noreferrer">IQ — Palettes</a>.</p>',
 'vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
    return a + b * cos(6.28318 * (c * t + d));
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: sunset palette indexed by uv.y.
    // vec3 c = palette(uv.y, vec3(0.66, 0.50, 0.40), vec3(0.50, 0.40, 0.20), vec3(0.8, 0.6, 0.5), vec3(0.00, 0.20, 0.50));
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
 '<p><strong>Goal.</strong> Fix the "everything looks too dark" problem on real monitors.</p><p><strong>What''s happening.</strong> Pixel values that <em>look</em> like a linear gradient on the screen are actually nonlinear — monitors apply about a <code>2.2</code> exponent when displaying. A linear ramp in code looks crushed in the dark half.</p><p><strong>The fix.</strong> At the very end of your shader, raise the color to the <code>1.0 / 2.2</code> power: <code>pow(color, vec3(1.0 / 2.2))</code>. This is the inverse of what the monitor does, so the on-screen ramp is finally linear to the eye.</p><p><strong>Compare.</strong> Run the starter with the gamma fix commented out and you''ll see a dark gradient; uncomment it and the midpoint shifts up to ~0.5 brightness, as it should.</p><p>Reference: <a href="https://iquilezles.org/articles/gamma/" target="_blank" rel="noreferrer">IQ — Gamma correct blurring</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 c = vec3(uv.x);
    // TODO: apply gamma to the final color.
    // c = pow(c, vec3(1.0 / 2.2));
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
 '<p><strong>Goal.</strong> Darken the corners of the frame so the eye is drawn to the center.</p><p><strong>The recipe.</strong> Same distance-then-smoothstep pattern from Family A:</p><ol><li>Centered position <code>p</code>.</li><li>Smoothstep the radius: <code>smoothstep(0.4, 0.75, length(p))</code> is 0 inside radius 0.4, 1 outside radius 0.75. Subtract from 1 to get a bright disc that fades to 0 at the corners.</li><li>Multiply your color by that mask.</li></ol><p>Tweak the smoothstep edges to taste — narrower gap is a more aggressive vignette.</p><p>Reference: <a href="https://iquilezles.org/articles/outdoorslighting/" target="_blank" rel="noreferrer">IQ — Outdoors lighting</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 c = vec3(0.95, 0.81, 0.36);
    // TODO: build the vignette mask, multiply into c.
    // float v = 1.0 - smoothstep(0.4, 0.75, length(p));
    // c *= v;
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
 '<p><strong>Goal.</strong> Squash out-of-range color values back into the visible <code>[0, 1]</code> band — also known as tone mapping.</p><p><strong>Why you need it.</strong> Real shaders generate HDR values that go above 1 (a sun, a glowing palette, a bloom pass). If you just clamp, the brightest highlights become flat white blobs.</p><p><strong>The Reinhard formula.</strong> <code>c / (c + 1.0)</code>. Component-wise: values near 0 stay near 0, values near 1 land near 0.5, values way above 1 asymptote to 1. The result preserves detail in highlights.</p><p>The starter builds a deliberately over-bright color (<code>uv.x * 4</code> and <code>uv.y * 2</code>) so you can see Reinhard pulling those highlights down.</p><p>Reference: <a href="https://iquilezles.org/articles/outdoorslighting/" target="_blank" rel="noreferrer">IQ — Outdoors lighting</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 c = vec3(uv.x * 4.0, uv.y * 2.0, 1.0);
    // TODO: Reinhard tone map.
    // c = c / (c + 1.0);
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
 '<p><strong>Goal.</strong> Use the same family of tone-mapping idea, but with a film-like curve that compresses highlights more gracefully than Reinhard.</p><p><strong>The fit (Krzysztof Narkowicz).</strong> <code>(c · (2.51c + 0.03)) / (c · (2.43c + 0.59) + 0.14)</code>, clamped to <code>[0, 1]</code>. It''s a rational approximation to the ACES filmic curve used in film and games.</p><p><strong>What changes visually.</strong> Same starter color as the Reinhard lesson, but now the highlights bend toward a warm, photographic roll-off instead of asymptoting toward gray.</p><p>Reference: <a href="https://iquilezles.org/articles/outdoorslighting/" target="_blank" rel="noreferrer">IQ — Outdoors lighting</a>.</p>',
 'vec3 aces(vec3 x) {
    return clamp((x * (2.51 * x + 0.03)) / (x * (2.43 * x + 0.59) + 0.14), 0.0, 1.0);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 c = vec3(uv.x * 4.0, uv.y * 2.0, 1.0);
    // TODO: ACES tone map.
    // c = aces(c);
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
