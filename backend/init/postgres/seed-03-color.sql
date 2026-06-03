\c shader_dojo;

-- Family B — Color (3 courses, 12 lessons)
-- Same lecture-style rules as Foundations: explicit recipes, hand-holding TODOs.

INSERT INTO lesson (course_id, slug, display_order, title, description, starter_fragment_shader, canonical_fragment_shader) VALUES

-- ===== Course: hsv-color =====
((SELECT id FROM course WHERE slug = 'hsv-color'), 'p60fmIlW-3M', 0,
 'Hue wheel along x',
 '<p>HSV is a color space. It splits color into three knobs. The first knob is hue. Hue picks which color you see. 0 is red, 0.33 is green, 0.67 is blue, and 1 is red again.</p><p>The second knob is saturation. 0 is gray and 1 is full color. The third knob is value. 0 is black and 1 is the brightest. The helper <code>hsv2rgb</code> turns those three numbers into red, green, and blue.</p><p>Now feed it <code>vec3(uv.x, 1.0, 1.0)</code>. Hue runs left to right. Saturation and value stay at the top. You will see every hue across the canvas.</p><p>Reference: <a href="https://thebookofshaders.com/06/" target="_blank" rel="noreferrer">Book of Shaders — Colors (HSB section)</a>.</p>',
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
 '<p>Last time hue ran left to right. Now it will spin around a center. You will get the classic color wheel.</p><p>Start with the centered position <code>p</code>. Call <code>atan(p.y, p.x)</code>. That gives the angle in radians from <code>-π</code> to <code>π</code>. Radians are just a way to measure angles. Divide by <code>2π</code> to get a range from <code>-0.5</code> to <code>0.5</code>. Add <code>0.5</code> to slide it to <code>0</code> to <code>1</code>. That is the range hue wants.</p><p>Then feed it to <code>hsv2rgb(vec3(h, 1.0, 1.0))</code>. Red points right. Green points up and left. Blue points down and left.</p><p>Reference: <a href="https://thebookofshaders.com/06/" target="_blank" rel="noreferrer">Book of Shaders — Colors</a>.</p>',
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
 '<p>This time hue stays locked. Saturation does the work. Hue <code>0.07</code> is a salmon-orange. The center will be gray. The edge will be full salmon.</p><p>Start with the centered position <code>p</code>. Get the distance from the center with <code>length(p)</code>. Multiply it by <code>2.0</code> so saturation hits <code>1</code> at radius <code>0.5</code>. Wrap that in <code>clamp(..., 0.0, 1.0)</code> so points past the disc stay at <code>1</code>. Clamp just pins a value inside a range.</p><p>Then call <code>hsv2rgb(vec3(0.07, s, 1.0))</code>. You will see a salmon disc that fades to white at the center.</p><p>Reference: <a href="https://thebookofshaders.com/06/" target="_blank" rel="noreferrer">Book of Shaders — Colors</a>.</p>',
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
 '<p>Now pin hue and saturation. Move the value knob with time. Use the same wave from Family A: <code>v = 0.5 + 0.5 * sin(u_time)</code>. That wave swings between <code>0</code> and <code>1</code>.</p><p>Drop <code>v</code> into the third slot of <code>hsv2rgb</code>. The canvas pulses dark and bright. The color stays the same.</p><p>This is what HSV is good for. You can move brightness on its own. The hue does not drift.</p><p>Reference: <a href="https://thebookofshaders.com/06/" target="_blank" rel="noreferrer">Book of Shaders — Colors</a>.</p>',
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
 '<p>You can build a palette from one cosine and four <code>vec3</code> inputs. The formula is <code>color(t) = a + b · cos(2π · (c · t + d))</code>. Inigo Quilez made it. The input <code>t</code> picks a spot along the palette.</p><p>Each <code>vec3</code> has one number per color channel. <code>a</code> is the average color. <code>b</code> is how much each channel moves. <code>c</code> is how many waves each channel makes. <code>d</code> is where each wave starts.</p><p>The rainbow uses <code>a = b = vec3(0.5)</code>, <code>c = vec3(1.0)</code>, and <code>d = vec3(0.00, 0.33, 0.67)</code>. Feed <code>uv.x</code> as <code>t</code>. Every hue shows up across the canvas.</p><p>Reference: <a href="https://iquilezles.org/articles/palettes/" target="_blank" rel="noreferrer">IQ — Palettes</a>.</p>',
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
 '<p>Last time <code>t</code> came from space. Now it will come from time. The whole canvas turns one color. That color cycles through the palette.</p><p>Swap <code>uv.x</code> for <code>u_time * 0.2</code>. The <code>0.2</code> slows the cycle. One full loop takes about five seconds.</p><p>Reference: <a href="https://iquilezles.org/articles/palettes/" target="_blank" rel="noreferrer">IQ — Palettes</a>.</p>',
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
 '<p>This time <code>t</code> comes from distance. The palette will wrap into rings around the center.</p><p>Start with the centered position <code>p</code>. Get the distance with <code>r = length(p)</code>. Call <code>palette(r, ...)</code>. The value <code>r</code> grows from <code>0</code> at the center. The palette loops every <code>1</code> unit. Each loop draws one ring.</p><p>Reference: <a href="https://iquilezles.org/articles/palettes/" target="_blank" rel="noreferrer">IQ — Palettes</a>.</p>',
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
 '<p>Now pick your own four <code>vec3</code> inputs. As a recap: <code>a</code> sets the bias, <code>b</code> sets the contrast, <code>c</code> sets the wave count, and <code>d</code> sets the wave start. If <code>c</code> drops below <code>1</code>, less of the cycle fits on screen. That gives you a small slice of colors. A sunset is one of those slices.</p><p>Try <code>a=(0.66, 0.50, 0.40)</code>, <code>b=(0.50, 0.40, 0.20)</code>, <code>c=(0.8, 0.6, 0.5)</code>, and <code>d=(0.00, 0.20, 0.50)</code>. Use <code>uv.y</code> for <code>t</code>. Warm tones rise to the top.</p><p>Reference: <a href="https://iquilezles.org/articles/palettes/" target="_blank" rel="noreferrer">IQ — Palettes</a>.</p>',
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
 '<p>Monitors do not show colors in a straight line. They use a curve. They raise each color value to about a <code>2.2</code> power. So an even ramp in code looks dark on screen. The dark half gets crushed.</p><p>The fix is to bend the color the other way. At the end of your shader, write <code>pow(color, vec3(1.0 / 2.2))</code>. The function <code>pow</code> raises one number to the power of another. This new bend cancels the monitor''s bend. The ramp looks even to your eye.</p><p>Run the starter without the fix to see the dark gradient. Then add the line. The middle moves up to about <code>0.5</code>, like it should.</p><p>Reference: <a href="https://iquilezles.org/articles/gamma/" target="_blank" rel="noreferrer">IQ — Gamma correct blurring</a>.</p>',
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
 '<p>A vignette darkens the corners of the frame. Your eye then moves to the middle. You use the same distance and smoothstep trick from Family A.</p><p>Start with the centered position <code>p</code>. Call <code>smoothstep(0.4, 0.75, length(p))</code>. That gives <code>0</code> inside radius <code>0.4</code> and <code>1</code> outside radius <code>0.75</code>. Subtract from <code>1</code> to flip it. Now you have a bright disc that fades to <code>0</code> at the corners.</p><p>Multiply your color by that mask. Move the two smoothstep edges to taste. A smaller gap makes a stronger vignette.</p><p>Reference: <a href="https://iquilezles.org/articles/outdoorslighting/" target="_blank" rel="noreferrer">IQ — Outdoors lighting</a>.</p>',
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
 '<p>Some shaders make color values above <code>1</code>. A sun, a bright palette, or a bloom pass all do this. The screen can only show <code>0</code> to <code>1</code>. If you just clamp the top, the bright spots turn into flat white blobs. Tone mapping squashes those big values back into the visible range and keeps the detail.</p><p>The Reinhard formula is <code>c / (c + 1.0)</code>. Values near <code>0</code> stay near <code>0</code>. Values near <code>1</code> land near <code>0.5</code>. Values way above <code>1</code> get close to <code>1</code> but never reach it.</p><p>The starter makes a too-bright color on purpose. It uses <code>uv.x * 4</code> and <code>uv.y * 2</code>. Add the line and watch Reinhard pull the highlights down.</p><p>Reference: <a href="https://iquilezles.org/articles/outdoorslighting/" target="_blank" rel="noreferrer">IQ — Outdoors lighting</a>.</p>',
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
 '<p>ACES is another tone map. It bends highlights in a film-like way. Films and games use it. The curve looks warmer and softer than Reinhard.</p><p>Krzysztof Narkowicz fit it to a short formula: <code>(c · (2.51c + 0.03)) / (c · (2.43c + 0.59) + 0.14)</code>, clamped to <code>[0, 1]</code>. The helper <code>aces</code> in the starter does this for you. Clamp pins the result inside the <code>0</code> to <code>1</code> range.</p><p>The starter uses the same too-bright color as the Reinhard lesson. Call <code>aces(c)</code>. The highlights now roll off warm instead of fading to gray.</p><p>Reference: <a href="https://iquilezles.org/articles/outdoorslighting/" target="_blank" rel="noreferrer">IQ — Outdoors lighting</a>.</p>',
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
