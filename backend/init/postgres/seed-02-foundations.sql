\c shader_dojo;

-- Family A — Foundations (6 courses, 24 lessons)
-- starter_vertex_shader is left NULL: the validator and frontend use the canonical passthrough.
--
-- Foundations are written as a lecture, not a challenge. Every lesson description spells
-- out what to do, why it works, and what you'll see. Every TODO names the exact lines to
-- write — the learner is here to read code that runs, not to invent it.

INSERT INTO lesson (course_id, slug, display_order, title, description, starter_fragment_shader, canonical_fragment_shader) VALUES

-- ===== Course: uv-coordinates =====
((SELECT id FROM course WHERE slug = 'uv-coordinates'), 'Y9NUVKnImBU', 0,
 'UV as RG color',
 '<p>You will give every pixel an address. You will turn that address into a color so you can see it.</p><p><code>gl_FragCoord.xy</code> is the pixel''s spot on the screen in pixels. <code>(0, 0)</code> is the bottom-left. Divide it by <code>u_resolution.xy</code> to get <code>uv</code>. Now the value runs from <code>0</code> to <code>1</code> across the canvas. Put <code>uv.x</code> on red and <code>uv.y</code> on green.</p><p>You will see a smooth gradient. Black is in the bottom-left. Red is on the right. Green is on top. Yellow is in the top-right.</p><p>Reference: <a href="https://thebookofshaders.com/03/" target="_blank" rel="noreferrer">Book of Shaders — Uniforms</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: replace the black with uv on the red/green channels.
    // gl_FragColor = vec4(uv, 0.0, 1.0);
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    gl_FragColor = vec4(uv, 0.0, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'uv-coordinates'), 'u0ntUSvRPHI', 1,
 'Centered UV',
 '<p>You will move the zero point from the corner to the middle.</p><p>Circles and stars are easier to draw from the middle. Subtract <code>0.5</code> from <code>uv</code>. Now the value runs from <code>-0.5</code> in the bottom-left to <code>+0.5</code> in the top-right. Zero is in the middle.</p><p>Centered values can be negative. You cannot show negative colors. Use <code>abs(uv)</code> to flip negatives to positives. Then times by <code>2</code> to fill the <code>0</code> to <code>1</code> range. You will see a dark middle and bright corners.</p><p>Reference: <a href="https://thebookofshaders.com/03/" target="_blank" rel="noreferrer">Book of Shaders — Uniforms</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: shift origin to the center.
    // uv = uv - 0.5;
    // gl_FragColor = vec4(abs(uv) * 2.0, 0.0, 1.0);
    gl_FragColor = vec4(uv, 0.0, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy - 0.5;
    gl_FragColor = vec4(abs(uv) * 2.0, 0.0, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'uv-coordinates'), 'ISrgvAd5SMg', 2,
 'Aspect-corrected UV',
 '<p>You will fix a stretch problem. You want circles to look like circles.</p><p>The plain <code>uv = gl_FragCoord.xy / u_resolution.xy</code> stretches the picture. On a wide canvas, x is wider than y. Shapes get squished.</p><p>To fix it, subtract half the size to center it. Then divide both x and y by the same number. Use <code>u_resolution.y</code>, the height. Now x and y use the same scale. The starter draws a disc. With the bad <code>uv</code> it is an oval. With the good <code>uv</code> it is a circle.</p><p>Reference: <a href="https://thebookofshaders.com/03/" target="_blank" rel="noreferrer">Book of Shaders — Uniforms</a>.</p>',
 'void main() {
    // TODO: aspect-correct uv. Both axes must use u_resolution.y.
    // vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec2 uv = gl_FragCoord.xy / u_resolution.xy - 0.5;
    float d = length(uv);
    gl_FragColor = vec4(vec3(step(d, 0.3)), 1.0);
}',
 'void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d = length(uv);
    gl_FragColor = vec4(vec3(step(d, 0.3)), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'uv-coordinates'), 'RmYF8JiNb5A', 3,
 'Polar coordinates',
 '<p>You will name a pixel by two new numbers. One is how far it is from the middle. The other is which way it points.</p><p>Start with a centered position <code>p</code>. Then:</p><ul><li><code>r = length(p)</code> is the distance from the middle. It is <code>0</code> in the middle and bigger at the edges.</li><li><code>a = atan(p.y, p.x)</code> is the angle. It runs from <code>-π</code> to <code>π</code>. <code>0</code> points right. <code>π/2</code> points up.</li></ul><p>Put <code>r</code> on red. Put <code>a/π</code> on green. Red gets brighter going out from the middle. Green sweeps around the canvas.</p><p>Reference: <a href="https://thebookofshaders.com/07/" target="_blank" rel="noreferrer">Book of Shaders — Shapes (polar section)</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    // TODO: compute polar coordinates and visualize them.
    // float r = length(p);
    // float a = atan(p.y, p.x);
    // gl_FragColor = vec4(r, a / 3.14159265, 0.0, 1.0);
    gl_FragColor = vec4(p, 0.0, 1.0);
}',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float r = length(p);
    float a = atan(p.y, p.x);
    gl_FragColor = vec4(r, a / 3.14159265, 0.0, 1.0);
}'),

-- ===== Course: time-oscillation =====
((SELECT id FROM course WHERE slug = 'time-oscillation'), 'RysomZQB5N8', 0,
 'Sine brightness',
 '<p>You will make the canvas pulse with <code>u_time</code>. <code>u_time</code> is the seconds since the shader started.</p><p>Plain <code>sin(u_time)</code> goes from <code>-1</code> to <code>+1</code>. Brightness must be from <code>0</code> to <code>1</code>. Use <code>0.5 + 0.5 * sin(u_time)</code>. Times by <code>0.5</code> to shrink the swing. Add <code>0.5</code> to shift it up. Now the value is from <code>0</code> to <code>1</code>. You will use this same trick a lot.</p><p>The canvas will breathe from black to white. One full pulse takes about <code>6.28</code> seconds.</p><p>References: <a href="https://thebookofshaders.com/03/" target="_blank" rel="noreferrer">BoS — Uniforms</a>, <a href="https://iquilezles.org/articles/trigfunctions/" target="_blank" rel="noreferrer">IQ — Trig functions</a>.</p>',
 'void main() {
    // TODO: oscillate v between 0 and 1.
    // float v = 0.5 + 0.5 * sin(u_time);
    float v = 1.0;
    gl_FragColor = vec4(vec3(v), 1.0);
}',
 'void main() {
    float v = 0.5 + 0.5 * sin(u_time);
    gl_FragColor = vec4(vec3(v), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'time-oscillation'), 'Rh5lJolvCpE', 1,
 'Two-color crossfade',
 '<p>You will use the last lesson''s pulse to fade between two colors.</p><p><code>mix(a, b, t)</code> gives you <code>a</code> when <code>t</code> is <code>0</code>. It gives you <code>b</code> when <code>t</code> is <code>1</code>. In between, it blends them. The pulse from last lesson goes from <code>0</code> to <code>1</code>. You can plug it right in as <code>t</code>.</p><p>Use salmon <code>(0.96, 0.62, 0.51)</code> for <code>a</code>. Use yellow <code>(0.95, 0.81, 0.36)</code> for <code>b</code>. The canvas will fade between the two colors.</p><p>Reference: <a href="https://thebookofshaders.com/06/" target="_blank" rel="noreferrer">Book of Shaders — Colors</a>.</p>',
 'void main() {
    float t = 0.5 + 0.5 * sin(u_time);
    // TODO: mix the two colors by t.
    // vec3 c = mix(vec3(0.96, 0.62, 0.51), vec3(0.95, 0.81, 0.36), t);
    vec3 c = vec3(1.0);
    gl_FragColor = vec4(c, 1.0);
}',
 'void main() {
    float t = 0.5 + 0.5 * sin(u_time);
    vec3 c = mix(vec3(0.96, 0.62, 0.51), vec3(0.95, 0.81, 0.36), t);
    gl_FragColor = vec4(c, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'time-oscillation'), '5Wv1Wxu93pY', 2,
 'Phase-offset RGB',
 '<p>You will pulse each color channel on its own clock. The canvas will cycle through colors.</p><p>GLSL lets you call <code>cos</code> on a <code>vec3</code>. It runs <code>cos</code> on each part on its own. So <code>cos(u_time + vec3(0.0, 2.094, 4.189))</code> gives three cosines. Each one starts at a different time. The offsets <code>0</code>, <code>2.094</code>, and <code>4.189</code> are <code>2π/3</code> apart. That spaces the three colors out around the cycle.</p><p>Use the same <code>0.5 + 0.5 * (...)</code> trick as before. But now the inside is a <code>vec3</code>. You will see a smooth rainbow cycle.</p><p>Reference: <a href="https://iquilezles.org/articles/trigfunctions/" target="_blank" rel="noreferrer">IQ — Trig functions</a>.</p>',
 'void main() {
    // TODO: phase-offset RGB.
    // vec3 c = 0.5 + 0.5 * cos(u_time + vec3(0.0, 2.094, 4.189));
    vec3 c = vec3(0.5);
    gl_FragColor = vec4(c, 1.0);
}',
 'void main() {
    vec3 c = 0.5 + 0.5 * cos(u_time + vec3(0.0, 2.094, 4.189));
    gl_FragColor = vec4(c, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'time-oscillation'), '8LOHoVrvY5s', 3,
 'Per-axis frequency',
 '<p>You will mix space and time inside one <code>sin</code>. The wave will depend on both <code>uv.x</code> and <code>u_time</code>.</p><p>Look at <code>sin(uv.x * k + u_time)</code>:</p><ul><li>The <code>uv.x * k</code> part makes the wave change across the canvas. You see <code>k / (2π)</code> stripes at any moment.</li><li>The <code>+ u_time</code> part slides the wave each frame. The stripes scroll.</li></ul><p>Pick <code>k = 12.566</code>, which is about <code>4π</code>. That gives two full bright and dark cycles across the canvas.</p><p>Reference: <a href="https://thebookofshaders.com/05/" target="_blank" rel="noreferrer">Book of Shaders — Shaping functions</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: scrolling vertical stripes.
    // float v = 0.5 + 0.5 * sin(uv.x * 12.566 + u_time);
    float v = 1.0;
    gl_FragColor = vec4(vec3(v), 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float v = 0.5 + 0.5 * sin(uv.x * 12.566 + u_time);
    gl_FragColor = vec4(vec3(v), 1.0);
}'),

-- ===== Course: step-smoothstep =====
((SELECT id FROM course WHERE slug = 'step-smoothstep'), 'p0O1Dv3P-vA', 0,
 'step() half-plane',
 '<p>You will meet a function that gives a yes-or-no answer for each pixel.</p><p><code>step(edge, x)</code> gives <code>0.0</code> when <code>x</code> is less than <code>edge</code>. It gives <code>1.0</code> otherwise. There is no blend. The change happens in zero pixels. It is a yes-or-no question at every pixel.</p><p>Ask "is this pixel past <code>uv.x = 0.5</code>?" with <code>step(0.5, uv.x)</code>. Put the answer on all three color channels. The left half is black. The right half is white. The edge looks jagged. <code>step</code> has no smoothing. You will fix that in the next lesson.</p><p>References: <a href="https://thebookofshaders.com/05/" target="_blank" rel="noreferrer">BoS — Shaping functions</a>, <a href="https://iquilezles.org/articles/functions/" target="_blank" rel="noreferrer">IQ — Useful little functions</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: split the canvas with a hard edge at uv.x = 0.5.
    // float m = step(0.5, uv.x);
    float m = 0.0;
    gl_FragColor = vec4(vec3(m), 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float m = step(0.5, uv.x);
    gl_FragColor = vec4(vec3(m), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'step-smoothstep'), 'ANep5l9KXQA', 1,
 'smoothstep() antialiased edge',
 '<p>You will swap the jagged edge for a smooth one.</p><p><code>smoothstep(a, b, x)</code> is <code>0</code> below <code>a</code>. It is <code>1</code> above <code>b</code>. In between, it makes a smooth curve. A wider gap between <code>a</code> and <code>b</code> gives a softer edge.</p><p>Pick a thin band around <code>0.5</code>. Use <code>smoothstep(0.48, 0.52, uv.x)</code>. From <code>uv.x = 0.48</code> to <code>uv.x = 0.52</code> the value goes from <code>0</code> to <code>1</code>. That is about <code>4%</code> of the canvas. The picture looks the same. But the edge is smooth, not jagged.</p><p>References: <a href="https://thebookofshaders.com/05/" target="_blank" rel="noreferrer">BoS — Shaping functions</a>, <a href="https://iquilezles.org/articles/smoothsteps/" target="_blank" rel="noreferrer">IQ — Smoothsteps</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: replace step with a narrow smoothstep.
    // float m = smoothstep(0.48, 0.52, uv.x);
    float m = step(0.5, uv.x);
    gl_FragColor = vec4(vec3(m), 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float m = smoothstep(0.48, 0.52, uv.x);
    gl_FragColor = vec4(vec3(m), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'step-smoothstep'), 'DMpqeHFWXBM', 2,
 'Stripe via two smoothsteps',
 '<p>You will draw a bright stripe in the middle. You will do this by subtracting one smoothstep from another.</p><p>The first one, <code>smoothstep(0.30, 0.32, uv.x)</code>, goes from <code>0</code> to <code>1</code> near <code>uv.x = 0.31</code>. The second one, <code>smoothstep(0.68, 0.70, uv.x)</code>, goes from <code>0</code> to <code>1</code> near <code>uv.x = 0.69</code>. Subtract them. The result is <code>0</code> on the sides. It is <code>1</code> in the middle. The edges are soft.</p><p>Rising edge minus rising edge gives a band. You will use this same pattern to draw stripes and rings and ribbons later.</p><p>Reference: <a href="https://iquilezles.org/articles/smoothsteps/" target="_blank" rel="noreferrer">IQ — Smoothsteps</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: subtract two smoothsteps to carve a stripe.
    // float m = smoothstep(0.30, 0.32, uv.x) - smoothstep(0.68, 0.70, uv.x);
    float m = 0.0;
    gl_FragColor = vec4(vec3(m), 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float m = smoothstep(0.30, 0.32, uv.x) - smoothstep(0.68, 0.70, uv.x);
    gl_FragColor = vec4(vec3(m), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'step-smoothstep'), 'J0cVn8u2KQM', 3,
 'Signed-threshold band',
 '<p>You will draw the same band a new way. You will use one smoothstep and a distance.</p><p><code>abs(uv.x - 0.5)</code> is the distance from the middle line. It is <code>0</code> at the middle. It is <code>0.5</code> at the edges. Put it into smoothstep. Then flip the result with <code>1.0 -</code>. Now the inside of the band is bright.</p><p>This pattern is distance, then smoothstep, then flip. It works for more shapes than the last lesson. You will see it again in every SDF lesson. Find the distance from a shape. Smooth it. Flip to fill the inside.</p><p>Reference: <a href="https://iquilezles.org/articles/functions/" target="_blank" rel="noreferrer">IQ — Useful little functions</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: distance from the centerline, smoothstep, invert.
    // float d = abs(uv.x - 0.5);
    // float m = 1.0 - smoothstep(0.18, 0.22, d);
    float m = 0.0;
    gl_FragColor = vec4(vec3(m), 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float d = abs(uv.x - 0.5);
    float m = 1.0 - smoothstep(0.18, 0.22, d);
    gl_FragColor = vec4(vec3(m), 1.0);
}'),

-- ===== Course: mix-gradients =====
((SELECT id FROM course WHERE slug = 'mix-gradients'), 'C9NOPPTcO8c', 0,
 'Horizontal two-color',
 '<p>You will blend from one color on the left to another on the right.</p><p><code>mix(a, b, t)</code> does the math <code>a * (1 - t) + b * t</code> on each part. When <code>t</code> is <code>0</code>, you get <code>a</code>. When <code>t</code> is <code>1</code>, you get <code>b</code>. Halfway gives the average.</p><p>Use <code>uv.x</code> as <code>t</code>. Salmon shows on the left where <code>uv.x</code> is near <code>0</code>. Yellow shows on the right where <code>uv.x</code> is near <code>1</code>. Every shade is in between.</p><p>Reference: <a href="https://thebookofshaders.com/06/" target="_blank" rel="noreferrer">Book of Shaders — Colors</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: linear horizontal blend.
    // vec3 c = mix(vec3(0.96, 0.62, 0.51), vec3(0.95, 0.81, 0.36), uv.x);
    vec3 c = vec3(0.5);
    gl_FragColor = vec4(c, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 c = mix(vec3(0.96, 0.62, 0.51), vec3(0.95, 0.81, 0.36), uv.x);
    gl_FragColor = vec4(c, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'mix-gradients'), '5U6D3uvCGzQ', 1,
 'Diagonal gradient',
 '<p>You will turn the gradient by <code>45°</code>. You will use both axes for the blend.</p><p>Last time you used <code>t = uv.x</code>. This time, average the two axes. Use <code>t = (uv.x + uv.y) * 0.5</code>. Now <code>t</code> is <code>0</code> at the bottom-left. It is <code>0.5</code> along the diagonal. It is <code>1</code> at the top-right.</p><p>The <code>mix</code> stays the same. Only <code>t</code> changes. The gradient now runs corner to corner.</p><p>Reference: <a href="https://thebookofshaders.com/06/" target="_blank" rel="noreferrer">Book of Shaders — Colors</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: combine both axes into t.
    // float t = (uv.x + uv.y) * 0.5;
    float t = uv.x;
    vec3 c = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), t);
    gl_FragColor = vec4(c, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float t = (uv.x + uv.y) * 0.5;
    vec3 c = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), t);
    gl_FragColor = vec4(c, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'mix-gradients'), 'VyyQdFs8C0s', 2,
 'Three-stop nested mix',
 '<p>You will add a third color in the middle. You will split the gradient in half.</p><p>Below <code>uv.x = 0.5</code>, blend <code>a</code> to <code>b</code>. Above it, blend <code>b</code> to <code>c</code>. At <code>uv.x = 0.5</code> the color is <code>b</code> on both sides. The join is hidden.</p><p>Each half needs its own <code>0</code> to <code>1</code> ramp:</p><ul><li>Left half: <code>uv.x</code> from <code>0</code> to <code>0.5</code> becomes <code>t = uv.x * 2.0</code>.</li><li>Right half: <code>uv.x</code> from <code>0.5</code> to <code>1</code> becomes <code>t = (uv.x - 0.5) * 2.0</code>.</li></ul><p>Pick the right one with <code>uv.x &lt; 0.5 ? leftMix : rightMix</code>.</p><p>Reference: <a href="https://thebookofshaders.com/06/" target="_blank" rel="noreferrer">Book of Shaders — Colors</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 a = vec3(0.10, 0.15, 0.35);
    vec3 b = vec3(0.96, 0.62, 0.51);
    vec3 c = vec3(0.95, 0.81, 0.36);
    // TODO: split at uv.x = 0.5, mix each half on its own 0..1 ramp.
    // vec3 col = uv.x < 0.5 ? mix(a, b, uv.x * 2.0) : mix(b, c, (uv.x - 0.5) * 2.0);
    vec3 col = a;
    gl_FragColor = vec4(col, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 a = vec3(0.10, 0.15, 0.35);
    vec3 b = vec3(0.96, 0.62, 0.51);
    vec3 c = vec3(0.95, 0.81, 0.36);
    vec3 col = uv.x < 0.5 ? mix(a, b, uv.x * 2.0) : mix(b, c, (uv.x - 0.5) * 2.0);
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'mix-gradients'), 'RmXFv-4OZwk', 3,
 'Radial gradient',
 '<p>You will blend by distance from the middle, not by an axis.</p><p>The recipe:</p><ul><li>Use the centered, aspect-fixed <code>uv</code> from earlier.</li><li><code>r = length(uv)</code> is the distance from the middle.</li><li>Put <code>r</code> through <code>smoothstep(0.0, 0.6, r)</code>. Now <code>t</code> is <code>0</code> at the middle and <code>1</code> past radius <code>0.6</code>.</li><li><code>mix</code> the bright yellow middle with a dark blue outside by <code>t</code>.</li></ul><p>You just drew your first spotlight.</p><p>Reference: <a href="https://thebookofshaders.com/06/" target="_blank" rel="noreferrer">Book of Shaders — Colors</a>.</p>',
 'void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    // TODO: blend by radius from center.
    // float r = length(uv);
    // vec3 c = mix(vec3(0.95, 0.81, 0.36), vec3(0.10, 0.15, 0.35), smoothstep(0.0, 0.6, r));
    float r = 0.0;
    vec3 c = vec3(0.95, 0.81, 0.36);
    gl_FragColor = vec4(c, 1.0);
}',
 'void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float r = length(uv);
    vec3 c = mix(vec3(0.95, 0.81, 0.36), vec3(0.10, 0.15, 0.35), smoothstep(0.0, 0.6, r));
    gl_FragColor = vec4(c, 1.0);
}'),

-- ===== Course: plotting-curves =====
((SELECT id FROM course WHERE slug = 'plotting-curves'), 'c3su8EDPRds', 0,
 'Plot y = x',
 '<p>You will draw the line <code>y = x</code>. This is the simplest plot.</p><p>The recipe works for any curve:</p><ol><li>Find <code>d = abs(uv.y - f(uv.x))</code>. That is the up-down distance from the pixel to the curve.</li><li>Put <code>d</code> through a thin smoothstep. Pixels close to the curve get <code>1</code>. Pixels far away get <code>0</code>. Flip with <code>1.0 -</code> to draw a bright line on dark.</li></ol><p>For <code>y = x</code>, <code>f(uv.x) = uv.x</code>. So <code>d = abs(uv.y - uv.x)</code>. Use <code>smoothstep(0.005, 0.015, d)</code> for a clean diagonal.</p><p>Reference: <a href="https://thebookofshaders.com/05/" target="_blank" rel="noreferrer">Book of Shaders — Shaping functions (plot section)</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: draw y = x with a smoothstep distance band.
    // float d = abs(uv.y - uv.x);
    // float m = 1.0 - smoothstep(0.005, 0.015, d);
    float m = 0.0;
    gl_FragColor = vec4(vec3(m), 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float d = abs(uv.y - uv.x);
    float m = 1.0 - smoothstep(0.005, 0.015, d);
    gl_FragColor = vec4(vec3(m), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'plotting-curves'), 'w60pXClCffU', 1,
 'Plot y = sin(x)',
 '<p>You will use the same plot recipe on a real curve.</p><p>A sine looks better centered. Remap <code>uv</code> from <code>0</code>-to-<code>1</code> to <code>-1</code>-to-<code>1</code> first. Use <code>* 2.0 - 1.0</code>. Now <code>uv.y = 0</code> is the middle of the canvas. That is where the sine baseline goes.</p><p><code>sin(uv.x * 6.28318)</code> is one full wave from left to right. <code>6.28318</code> is about <code>2π</code>. Times the sine by <code>0.5</code>. Now the peaks land at <code>uv.y = ±0.5</code>, not off the top.</p><p>Same plot pattern: distance, smoothstep, flip.</p><p>Reference: <a href="https://thebookofshaders.com/05/" target="_blank" rel="noreferrer">Book of Shaders — Shaping functions (plot section)</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 2.0 - 1.0;
    // TODO: y = 0.5 * sin(uv.x * 6.28318); same distance-band recipe.
    // float y = 0.5 * sin(uv.x * 6.28318);
    // float d = abs(uv.y - y);
    // float m = 1.0 - smoothstep(0.01, 0.03, d);
    float m = 0.0;
    gl_FragColor = vec4(vec3(m), 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 2.0 - 1.0;
    float y = 0.5 * sin(uv.x * 6.28318);
    float d = abs(uv.y - y);
    float m = 1.0 - smoothstep(0.01, 0.03, d);
    gl_FragColor = vec4(vec3(m), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'plotting-curves'), 'A97U3mk9yUE', 2,
 'Curve thickness',
 '<p>You will see that the smoothstep edges <code>(a, b)</code> set the curve thickness.</p><p>Look at <code>1.0 - smoothstep(a, b, d)</code>. It is <code>1</code> when <code>d</code> is less than <code>a</code>. It drops to <code>0</code> when <code>d</code> is more than <code>b</code>. So pixels closer than <code>a</code> are solid. Pixels between <code>a</code> and <code>b</code> are the soft edge. Pixels past <code>b</code> are dark. Push <code>a</code> out to make the curve thicker. Spread <code>b - a</code> to make the edges softer.</p><p>The recipe is the same as the last lesson. Use thicker edges: <code>smoothstep(0.05, 0.08, d)</code>. The cosine here uses <code>π</code>, not <code>2π</code>. That makes the curve gentler.</p><p>Reference: <a href="https://iquilezles.org/articles/smoothsteps/" target="_blank" rel="noreferrer">IQ — Smoothsteps</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 2.0 - 1.0;
    // TODO: thicker plot of y = 0.5 * cos(uv.x * pi).
    // float y = 0.5 * cos(uv.x * 3.14159);
    // float d = abs(uv.y - y);
    // float m = 1.0 - smoothstep(0.05, 0.08, d);
    float m = 0.0;
    gl_FragColor = vec4(vec3(m), 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 2.0 - 1.0;
    float y = 0.5 * cos(uv.x * 3.14159);
    float d = abs(uv.y - y);
    float m = 1.0 - smoothstep(0.05, 0.08, d);
    gl_FragColor = vec4(vec3(m), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'plotting-curves'), 'J57FduwRbQ8', 3,
 'Animated phase',
 '<p>You will add <code>u_time</code> to the sine. The curve will scroll across the canvas.</p><p>Swap <code>sin(uv.x * 6.28318)</code> for <code>sin(uv.x * 6.28318 + u_time)</code>. Nothing else changes. The plot recipe does not care that the curve moves each frame.</p><p>Adding time to the inside of the sine slides the curve. Adding time to everything would not change the picture. The pattern <code>f(space + time)</code> is how almost every moving pattern in this course gets its motion.</p><p>Reference: <a href="https://thebookofshaders.com/05/" target="_blank" rel="noreferrer">Book of Shaders — Shaping functions</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 2.0 - 1.0;
    // TODO: scroll by adding u_time to the sine phase.
    // float y = 0.5 * sin(uv.x * 6.28318 + u_time);
    float y = 0.5 * sin(uv.x * 6.28318);
    float d = abs(uv.y - y);
    float m = 1.0 - smoothstep(0.01, 0.03, d);
    gl_FragColor = vec4(vec3(m), 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 2.0 - 1.0;
    float y = 0.5 * sin(uv.x * 6.28318 + u_time);
    float d = abs(uv.y - y);
    float m = 1.0 - smoothstep(0.01, 0.03, d);
    gl_FragColor = vec4(vec3(m), 1.0);
}'),

-- ===== Course: loop-fundamentals =====
-- Moved here from Family J. Lessons stay simple and visual on purpose: this is the
-- one course where the learner sees `for`, `break`, and per-pixel reductions for the
-- first time. After this, the noise/voronoi/raymarch families are safe to enter.

((SELECT id FROM course WHERE slug = 'loop-fundamentals'), 'WWkoco-M-vA', 0,
 'Count steps to threshold',
 '<p>You will write your first loop. You will turn the loop count into a picture.</p><p>GLSL has one big rule for loops. The number of times must be a fixed number the compiler can see. <code>for (int i = 0; i &lt; 32; i++)</code> works. <code>for (int i = 0; i &lt; n; i++)</code> does not, if <code>n</code> is a uniform.</p><p>Walk a counter <code>v</code> from <code>0</code> in steps of <code>0.05</code>. Each time: if <code>v</code> is past <code>uv.x</code>, stop. Otherwise add <code>1</code> to <code>steps</code>. The pixel''s gray value is <code>steps / 32</code>. Brighter pixels are the ones that took more steps. You get a stepped horizontal gradient.</p><p>Reference: <a href="https://registry.khronos.org/OpenGL/specs/es/2.0/GLSL_ES_Specification_1.00.pdf" target="_blank" rel="noreferrer">Khronos — GLSL ES 1.0 spec</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    int steps = 0;
    // TODO: walk v in 32 steps of 0.05; break when v > uv.x.
    // float v = 0.0;
    // for (int i = 0; i < 32; i++) {
    //     v += 0.05;
    //     if (v > uv.x) break;
    //     steps++;
    // }
    gl_FragColor = vec4(vec3(float(steps) / 32.0), 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    int steps = 0;
    float v = 0.0;
    for (int i = 0; i < 32; i++) {
        v += 0.05;
        if (v > uv.x) break;
        steps++;
    }
    gl_FragColor = vec4(vec3(float(steps) / 32.0), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'loop-fundamentals'), '0VcH_tOJHZw', 1,
 'Break on first hit',
 '<p>You will use a loop to search at each pixel.</p><p>The function <code>fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453)</code> is a fake-random hash. The same <code>p</code> always gives the same number. Two nearby <code>p</code> values look unrelated. Treat it as a black box for now. The noise family will explain those numbers.</p><p>Loop 32 times. Each time, hash <code>uv * float(i + 1)</code>. A different <code>i</code> gives a different number at the same pixel. The first time the value goes past <code>0.7</code>, break. Save <code>i</code> in <code>it</code>. The picture looks grainy. Each pixel stops at a random step.</p><p>Reference: <a href="https://iquilezles.org/articles/gpuconditionals/" target="_blank" rel="noreferrer">IQ — GPU conditionals</a>.</p>',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    int it = 0;
    // TODO: stop the first time hash(uv * float(i+1)) crosses 0.7.
    // for (int i = 0; i < 32; i++) {
    //     if (hash(uv * float(i + 1)) > 0.7) break;
    //     it = i;
    // }
    gl_FragColor = vec4(vec3(float(it) / 32.0), 1.0);
}',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    int it = 0;
    for (int i = 0; i < 32; i++) {
        if (hash(uv * float(i + 1)) > 0.7) break;
        it = i;
    }
    gl_FragColor = vec4(vec3(float(it) / 32.0), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'loop-fundamentals'), 'WxfbsGl4W28', 2,
 'Running maximum',
 '<p>You will use a loop to keep only the biggest value out of many.</p><p>Start with <code>m = -1.0</code>. That is below anything <code>sin</code> can give. For <code>i</code> from <code>0</code> to <code>15</code>, work out <code>sin(uv.x * float(i))</code>. Keep the bigger of the old <code>m</code> and the new value. The result is the top edge of many sines at different speeds.</p><p>The waves overlap. So the running max stays near <code>1</code> most of the time. You will see a bright canvas with thin dark seams.</p><p>Reference: <a href="https://registry.khronos.org/OpenGL/specs/es/2.0/GLSL_ES_Specification_1.00.pdf" target="_blank" rel="noreferrer">Khronos — GLSL ES 1.0 spec</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: m = -1.0; loop 16 times taking max of sin(uv.x * float(i)).
    // float m = -1.0;
    // for (int i = 0; i < 16; i++) {
    //     m = max(m, sin(uv.x * float(i)));
    // }
    float m = 0.0;
    gl_FragColor = vec4(vec3(0.5 + 0.5 * m), 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float m = -1.0;
    for (int i = 0; i < 16; i++) {
        m = max(m, sin(uv.x * float(i)));
    }
    gl_FragColor = vec4(vec3(0.5 + 0.5 * m), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'loop-fundamentals'), '_8epBwGjScc', 3,
 'Running average',
 '<p>You will swap <code>max</code> for sum. Now the loop adds things up. You will use this for blur and noise later.</p><p>Start <code>s = 0</code>. Loop 16 times. Each time, add <code>sin(uv.x * float(i) * 0.5)</code> to <code>s</code>. The result is the sum of 16 sine waves at different speeds.</p><p>The sum can reach <code>±16</code>. That is far outside the visible range. The output uses <code>0.5 + 0.05 * s</code> to bring it back to gray. <code>0.05</code> is about <code>1/16</code>. So each sine adds about <code>1/16</code> of the brightness.</p><p>Reference: <a href="https://registry.khronos.org/OpenGL/specs/es/2.0/GLSL_ES_Specification_1.00.pdf" target="_blank" rel="noreferrer">Khronos — GLSL ES 1.0 spec</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: s = 0.0; loop 16 times adding sin(uv.x * float(i) * 0.5).
    // float s = 0.0;
    // for (int i = 0; i < 16; i++) {
    //     s += sin(uv.x * float(i) * 0.5);
    // }
    float s = 0.0;
    gl_FragColor = vec4(vec3(0.5 + 0.05 * s), 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float s = 0.0;
    for (int i = 0; i < 16; i++) {
        s += sin(uv.x * float(i) * 0.5);
    }
    gl_FragColor = vec4(vec3(0.5 + 0.05 * s), 1.0);
}');
