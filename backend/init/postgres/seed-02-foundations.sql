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
 '<p><strong>Goal.</strong> Give every pixel a coordinate, then turn that coordinate into a color so we can <em>see</em> it.</p><p><strong>The recipe.</strong> <code>gl_FragCoord.xy</code> is the pixel''s screen position in pixels (so <code>(0, 0)</code> is the bottom-left corner, <code>(width, height)</code> is the top-right). Divide by the screen size <code>u_resolution.xy</code> and you get <code>uv</code>, a 2D coordinate that runs from <code>(0, 0)</code> to <code>(1, 1)</code> across the canvas. Output <code>uv.x</code> on the red channel and <code>uv.y</code> on the green channel.</p><p><strong>What you''ll see.</strong> A smooth two-axis gradient: black bottom-left, red bottom-right, green top-left, yellow top-right. This single image is the canvas of every later lesson — UV is the address you stamp on every pixel.</p><p>Reference: <a href="https://thebookofshaders.com/03/" target="_blank" rel="noreferrer">Book of Shaders — Uniforms</a>.</p>',
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
 '<p><strong>Goal.</strong> Move the origin from the corner to the center, then visualize the move by flipping the sign.</p><p><strong>Why.</strong> Most shapes (circles, stars, kaleidoscopes) are easier to draw around a center than around a corner. If you subtract <code>0.5</code> from each component of <code>uv</code>, the coordinate now runs from <code>(-0.5, -0.5)</code> at the bottom-left to <code>(+0.5, +0.5)</code> at the top-right — zero at the canvas center.</p><p><strong>The reveal.</strong> Centered UVs can go negative, so we can''t output them directly. Take <code>abs(uv)</code> to make negatives positive and multiply by 2 to fill the full <code>[0, 1]</code> range. The result is a pair of concentric squares of brightness: dark at the center, bright at the corners.</p><p>Reference: <a href="https://thebookofshaders.com/03/" target="_blank" rel="noreferrer">Book of Shaders — Uniforms</a>.</p>',
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
 '<p><strong>Goal.</strong> Make one unit of UV equal one unit of pixel so circles stay circular on a wide canvas.</p><p><strong>The problem.</strong> The naive <code>uv = gl_FragCoord.xy / u_resolution.xy</code> stretches: on a 1600×900 canvas, an x-unit is 1600 pixels but a y-unit is only 900. Anything you draw stretches with it.</p><p><strong>The fix.</strong> Subtract half the resolution to recenter, then divide both components by the <em>same</em> number — conventionally <code>u_resolution.y</code> (the height). Now x and y use the same scale: a unit is always a height. The starter draws a centered disc; with the wrong UV it''s an ellipse, with the right UV it''s a circle.</p><p>Reference: <a href="https://thebookofshaders.com/03/" target="_blank" rel="noreferrer">Book of Shaders — Uniforms</a>.</p>',
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
 '<p><strong>Goal.</strong> Describe a pixel by how far it is from the center and which way it points, instead of by (x, y).</p><p><strong>The recipe.</strong> Given a centered, aspect-corrected position <code>p</code>:</p><ul><li><code>r = length(p)</code> — distance from the origin. Zero at the center, larger at the edges.</li><li><code>a = atan(p.y, p.x)</code> — angle in radians, range <code>[-π, π]</code>. <code>0</code> points right, <code>π/2</code> up, <code>π</code> left.</li></ul><p><strong>What you''ll see.</strong> Output <code>r</code> as red and the normalized angle <code>a/π</code> as green. Red brightens radially; green sweeps from dark on the right, through bright at the top, to half-bright on the left. This is the polar grid laid bare.</p><p>Reference: <a href="https://thebookofshaders.com/07/" target="_blank" rel="noreferrer">Book of Shaders — Shapes (polar section)</a>.</p>',
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
 '<p><strong>Goal.</strong> Make the canvas pulse using the <code>u_time</code> uniform — the elapsed seconds since the shader started.</p><p><strong>The trick.</strong> Plain <code>sin(u_time)</code> oscillates between <code>-1</code> and <code>+1</code>, but pixel brightness must live in <code>[0, 1]</code>. The standard remap is <code>0.5 + 0.5 * sin(u_time)</code>: halve the amplitude (now <code>[-0.5, 0.5]</code>), then shift up by 0.5 (now <code>[0, 1]</code>). You''ll use this exact pattern hundreds of times.</p><p><strong>What you''ll see.</strong> The whole canvas breathes from black to white once per ~6.28 seconds (one <code>2π</code> cycle).</p><p>References: <a href="https://thebookofshaders.com/03/" target="_blank" rel="noreferrer">BoS — Uniforms</a>, <a href="https://iquilezles.org/articles/trigfunctions/" target="_blank" rel="noreferrer">IQ — Trig functions</a>.</p>',
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
 '<p><strong>Goal.</strong> Use the previous lesson''s oscillator as the blend factor of <code>mix()</code>.</p><p><strong>Background.</strong> <code>mix(a, b, t)</code> means "give me <code>a</code> when <code>t = 0</code>, give me <code>b</code> when <code>t = 1</code>, and linearly interpolate in between." Because our 0..1 oscillator already lives in that range, we can drop it straight in as <code>t</code>.</p><p><strong>The recipe.</strong> Take the salmon color <code>(0.96, 0.62, 0.51)</code> as <code>a</code>, the yellow <code>(0.95, 0.81, 0.36)</code> as <code>b</code>, and mix by the time oscillator. The whole canvas eases between the two hues.</p><p>Reference: <a href="https://thebookofshaders.com/06/" target="_blank" rel="noreferrer">Book of Shaders — Colors</a>.</p>',
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
 '<p><strong>Goal.</strong> Make every color channel oscillate on its own clock so the canvas hue-cycles instead of fading to gray.</p><p><strong>How.</strong> GLSL lets you call <code>cos</code> on a <code>vec3</code> — it cosines each component independently. So <code>cos(u_time + vec3(0.0, 2.094, 4.189))</code> gives three cosines, each <em>phase-shifted</em> by a different amount. The offsets <code>0</code>, <code>2π/3 ≈ 2.094</code>, and <code>4π/3 ≈ 4.189</code> space the three channels evenly around the cycle.</p><p><strong>The math.</strong> Same <code>0.5 + 0.5 * (...)</code> remap as before, but now the inside is a vec3. The result: a smooth rainbow cycle.</p><p>Reference: <a href="https://iquilezles.org/articles/trigfunctions/" target="_blank" rel="noreferrer">IQ — Trig functions</a>.</p>',
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
 '<p><strong>Goal.</strong> Mix space and time inside one <code>sin</code>: a phase that depends on both <code>uv.x</code> and <code>u_time</code>.</p><p><strong>How it works.</strong> Inside <code>sin(uv.x * k + u_time)</code>:</p><ul><li>The <code>uv.x * k</code> part makes the wave depend on horizontal position — at any frozen moment the canvas has <code>k / (2π)</code> stripes.</li><li>The <code>+ u_time</code> part shifts the entire wave each frame, so the stripes scroll.</li></ul><p>We pick <code>k = 12.566 ≈ 4π</code>, giving two full bright/dark cycles across the canvas.</p><p>Reference: <a href="https://thebookofshaders.com/05/" target="_blank" rel="noreferrer">Book of Shaders — Shaping functions</a>.</p>',
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
 '<p><strong>Goal.</strong> Meet the function that turns any expression into a clean binary mask.</p><p><strong>What step does.</strong> <code>step(edge, x)</code> returns <code>0.0</code> when <code>x &lt; edge</code> and <code>1.0</code> otherwise. There is no gradient — the transition happens in zero pixels. Think of it as a yes/no question evaluated at every pixel.</p><p><strong>The recipe.</strong> Ask "is this pixel to the right of <code>uv.x = 0.5</code>?" with <code>step(0.5, uv.x)</code>. Output the result on all three channels. Left half is black, right half is white. The edge is jagged because <code>step</code> has no anti-aliasing — that''s the next lesson''s problem.</p><p>References: <a href="https://thebookofshaders.com/05/" target="_blank" rel="noreferrer">BoS — Shaping functions</a>, <a href="https://iquilezles.org/articles/functions/" target="_blank" rel="noreferrer">IQ — Useful little functions</a>.</p>',
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
 '<p><strong>Goal.</strong> Replace the jagged <code>step</code> edge with a smooth one.</p><p><strong>What smoothstep does.</strong> <code>smoothstep(a, b, x)</code> is <code>0</code> below <code>a</code>, <code>1</code> above <code>b</code>, and a smooth Hermite curve in between. The wider the gap between <code>a</code> and <code>b</code>, the softer the transition.</p><p><strong>The recipe.</strong> Pick a narrow band around <code>0.5</code>: <code>smoothstep(0.48, 0.52, uv.x)</code>. From <code>uv.x = 0.48</code> to <code>uv.x = 0.52</code> the output ramps from 0 to 1 — about 4% of the canvas wide. Same image as before, but the edge is now a clean gradient pixel-wide, not a staircase.</p><p>References: <a href="https://thebookofshaders.com/05/" target="_blank" rel="noreferrer">BoS — Shaping functions</a>, <a href="https://iquilezles.org/articles/smoothsteps/" target="_blank" rel="noreferrer">IQ — Smoothsteps</a>.</p>',
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
 '<p><strong>Goal.</strong> Build a stripe — bright in the middle, dark on both sides — by subtracting one smoothstep from another.</p><p><strong>Why this works.</strong> The first <code>smoothstep(0.30, 0.32, uv.x)</code> rises from 0 to 1 around <code>uv.x = 0.31</code>. The second <code>smoothstep(0.68, 0.70, uv.x)</code> rises from 0 to 1 around <code>uv.x = 0.69</code>. Subtract them: the result is <code>0</code> outside both, <code>1</code> in the middle, with soft edges on both sides.</p><p><strong>The pattern.</strong> "Rising edge minus rising edge = a band." You will use this same recipe to draw every stripe, ring, ribbon, and wedge.</p><p>Reference: <a href="https://iquilezles.org/articles/smoothsteps/" target="_blank" rel="noreferrer">IQ — Smoothsteps</a>.</p>',
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
 '<p><strong>Goal.</strong> Build the same band with one smoothstep and a symmetric distance, instead of two stacked smoothsteps.</p><p><strong>The trick.</strong> <code>abs(uv.x - 0.5)</code> is the distance from the vertical center line. It''s <code>0</code> on the center, <code>0.5</code> at either edge. Use it as the input to smoothstep, and then <em>invert</em> the result (<code>1.0 -</code>) so the inside of the band is bright.</p><p><strong>Compare.</strong> This pattern — distance, then threshold, then invert — generalizes far better than rising-edge subtraction. You''ll see it in every SDF lesson that comes later: distance from a shape, smoothed threshold, inversion to fill the inside.</p><p>Reference: <a href="https://iquilezles.org/articles/functions/" target="_blank" rel="noreferrer">IQ — Useful little functions</a>.</p>',
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
 '<p><strong>Goal.</strong> Blend smoothly from one color on the left to another on the right.</p><p><strong>The function.</strong> <code>mix(a, b, t)</code> is component-wise linear interpolation: <code>a * (1 - t) + b * t</code>. When <code>t = 0</code> you get <code>a</code>; when <code>t = 1</code> you get <code>b</code>; halfway is the average.</p><p><strong>The recipe.</strong> Use <code>uv.x</code> as <code>t</code>. The salmon color appears on the left (where <code>uv.x ≈ 0</code>), yellow on the right (where <code>uv.x ≈ 1</code>), and every shade between is along the way.</p><p>Reference: <a href="https://thebookofshaders.com/06/" target="_blank" rel="noreferrer">Book of Shaders — Colors</a>.</p>',
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
 '<p><strong>Goal.</strong> Rotate the gradient direction by 45° using <em>both</em> axes inside the blend factor.</p><p><strong>The trick.</strong> Instead of <code>t = uv.x</code>, build <code>t</code> as the average of both axes: <code>t = (uv.x + uv.y) * 0.5</code>. Now <code>t</code> is <code>0</code> at the bottom-left corner, <code>0.5</code> along the anti-diagonal, and <code>1</code> at the top-right corner.</p><p><strong>What changes.</strong> Same <code>mix</code> as before; only <code>t</code> is different. The gradient now runs corner to corner.</p><p>Reference: <a href="https://thebookofshaders.com/06/" target="_blank" rel="noreferrer">Book of Shaders — Colors</a>.</p>',
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
 '<p><strong>Goal.</strong> Insert a middle color into the gradient by splitting it at the halfway point.</p><p><strong>The plan.</strong> Below <code>uv.x = 0.5</code>, blend <code>a → b</code>; above, blend <code>b → c</code>. The seam at <code>uv.x = 0.5</code> is exactly <code>b</code> so the join is invisible.</p><p><strong>Remapping.</strong> Each half needs its own 0..1 ramp:</p><ul><li>Left half: <code>uv.x ∈ [0, 0.5]</code> becomes <code>t = uv.x * 2.0</code>.</li><li>Right half: <code>uv.x ∈ [0.5, 1]</code> becomes <code>t = (uv.x - 0.5) * 2.0</code>.</li></ul><p>Pick with a ternary <code>uv.x &lt; 0.5 ? leftMix : rightMix</code>.</p><p>Reference: <a href="https://thebookofshaders.com/06/" target="_blank" rel="noreferrer">Book of Shaders — Colors</a>.</p>',
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
 '<p><strong>Goal.</strong> Drive the blend by distance from the canvas center instead of by an axis.</p><p><strong>The recipe.</strong></p><ul><li>Use the aspect-corrected, centered position <code>uv</code> from lesson C of Family A.</li><li><code>r = length(uv)</code> is distance from center.</li><li>Push <code>r</code> through smoothstep with falloff range <code>[0, 0.6]</code> so <code>t</code> goes from 0 at the center to 1 at radius 0.6+.</li><li><code>mix</code> the bright yellow center color with a dark blue outer color by <code>t</code>.</li></ul><p>You''ve just drawn your first spotlight.</p><p>Reference: <a href="https://thebookofshaders.com/06/" target="_blank" rel="noreferrer">Book of Shaders — Colors</a>.</p>',
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
 '<p><strong>Goal.</strong> Draw the line <code>y = x</code> inside the canvas — the simplest possible plot.</p><p><strong>The recipe (works for any curve).</strong></p><ol><li>Compute <code>d = abs(uv.y - f(uv.x))</code> — the vertical distance from this pixel to the curve.</li><li>Push <code>d</code> through a narrow smoothstep so pixels close to the curve get <code>1</code>, pixels far away get <code>0</code>. Invert with <code>1.0 -</code> to draw a bright curve on dark.</li></ol><p>For <code>y = x</code>, <code>f(uv.x) = uv.x</code>, so <code>d = abs(uv.y - uv.x)</code>. Smoothstep with edges <code>(0.005, 0.015)</code> gives a clean diagonal.</p><p>Reference: <a href="https://thebookofshaders.com/05/" target="_blank" rel="noreferrer">Book of Shaders — Shaping functions (plot section)</a>.</p>',
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
 '<p><strong>Goal.</strong> Use the same plot recipe with a non-trivial curve.</p><p><strong>Coordinate change.</strong> A sine looks better centered, so we remap <code>uv</code> from <code>[0, 1]</code> to <code>[-1, 1]</code> first (<code>* 2.0 - 1.0</code>). Then <code>uv.y = 0</code> is the middle of the canvas, exactly where the sine baseline should be.</p><p><strong>Frequency.</strong> <code>sin(uv.x * 6.28318)</code> = one full period from left to right (<code>2π ≈ 6.28318</code>). Multiply the sine by <code>0.5</code> so the peaks land at <code>uv.y = ±0.5</code> instead of spilling off the top.</p><p>Same plot pattern: distance, smoothstep, invert.</p><p>Reference: <a href="https://thebookofshaders.com/05/" target="_blank" rel="noreferrer">Book of Shaders — Shaping functions (plot section)</a>.</p>',
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
 '<p><strong>Goal.</strong> Realize that the smoothstep edges <code>(a, b)</code> in the plot recipe are exactly the thickness controls.</p><p><strong>Why.</strong> <code>1.0 - smoothstep(a, b, d)</code> is <code>1</code> when <code>d &lt; a</code>, drops to <code>0</code> when <code>d &gt; b</code>. So pixels closer than <code>a</code> are solid; pixels between <code>a</code> and <code>b</code> are the soft edge; pixels farther than <code>b</code> are nothing. Move <code>a</code> outward → thicker curve. Spread <code>b - a</code> → softer edges.</p><p><strong>The recipe.</strong> Same as Lesson 1, but with thicker edges: <code>smoothstep(0.05, 0.08, d)</code>. The cosine plot here also uses half-period frequency (<code>π</code> instead of <code>2π</code>) so the curve is gentler.</p><p>Reference: <a href="https://iquilezles.org/articles/smoothsteps/" target="_blank" rel="noreferrer">IQ — Smoothsteps</a>.</p>',
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
 '<p><strong>Goal.</strong> Add <code>u_time</code> to the sine''s phase to make the curve scroll horizontally.</p><p><strong>The change.</strong> Replace <code>sin(uv.x * 6.28318)</code> with <code>sin(uv.x * 6.28318 + u_time)</code>. Everything else stays the same — the plot recipe doesn''t care that the curve''s shape is changing every frame.</p><p><strong>Why this matters.</strong> Adding time to an argument shifts the curve. Adding time to <em>everything</em> wouldn''t change anything visible (you''d just relabel the axes). The pattern <code>f(space + time)</code> is how almost every animated procedural pattern in this curriculum gets its motion.</p><p>Reference: <a href="https://thebookofshaders.com/05/" target="_blank" rel="noreferrer">Book of Shaders — Shaping functions</a>.</p>',
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
 '<p><strong>Goal.</strong> Use a <code>for</code> loop with <code>break</code> for the first time, and turn the iteration count into a visible image.</p><p><strong>GLSL''s loop rule.</strong> The bound has to be a constant the compiler can see — <code>for (int i = 0; i &lt; 32; i++)</code> is fine; <code>for (int i = 0; i &lt; userInput; i++)</code> is not. That''s the one big rule.</p><p><strong>The recipe.</strong> Walk a counter <code>v</code> from <code>0</code> in steps of <code>0.05</code>. On each iteration: if <code>v</code> already passed <code>uv.x</code>, stop. Otherwise increment <code>steps</code>. The pixel''s gray value is <code>steps / 32</code>, so brighter pixels are the ones whose <code>uv.x</code> took more iterations to reach — a discrete horizontal gradient.</p><p>Reference: <a href="https://registry.khronos.org/OpenGL/specs/es/2.0/GLSL_ES_Specification_1.00.pdf" target="_blank" rel="noreferrer">Khronos — GLSL ES 1.0 spec</a>.</p>',
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
 '<p><strong>Goal.</strong> Use a loop as a per-pixel search.</p><p><strong>The hash function.</strong> <code>fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453)</code> is the classic one-liner pseudo-random function on GPUs. Identical <code>p</code> always returns the same value; nearby <code>p</code>s look uncorrelated. Treat it as a black box for now — Family E (noise) explains why those constants.</p><p><strong>The recipe.</strong> Loop 32 times. At each iteration, hash <code>uv * float(i + 1)</code> — different <code>i</code> gives a different value at the same pixel. The first time that value exceeds <code>0.7</code>, break. Record <code>i</code> in <code>it</code>. The image is grainy because each pixel''s "hit iteration" is essentially random.</p><p>Reference: <a href="https://iquilezles.org/articles/gpuconditionals/" target="_blank" rel="noreferrer">IQ — GPU conditionals</a>.</p>',
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
 '<p><strong>Goal.</strong> Use a loop as a <em>reduction</em>: collapse many values into one by always keeping the largest.</p><p><strong>The recipe.</strong> Start with <code>m = -1.0</code> (lower than anything <code>sin</code> can produce). For <code>i</code> from 0 to 15, compute <code>sin(uv.x * float(i))</code> and keep the bigger of the old <code>m</code> and the new value. The result is the upper envelope of a fan of sines at different frequencies.</p><p><strong>Reading the picture.</strong> Frequencies overlap, so the running max is almost always <code>1</code> except for narrow valleys. The output ends up bright with thin dark seams — the visual signature of "I asked many questions, but only the loudest one shows."</p><p>Reference: <a href="https://registry.khronos.org/OpenGL/specs/es/2.0/GLSL_ES_Specification_1.00.pdf" target="_blank" rel="noreferrer">Khronos — GLSL ES 1.0 spec</a>.</p>',
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
 '<p><strong>Goal.</strong> Swap <code>max</code> for sum and you have an accumulator. This pattern is the engine of everything from blur to fractal noise.</p><p><strong>The recipe.</strong> Start <code>s = 0</code>. For 16 iterations, add <code>sin(uv.x * float(i) * 0.5)</code> to <code>s</code>. The result is a sum of 16 sine waves at increasing frequencies — a discrete Fourier-series sketch.</p><p><strong>Scaling.</strong> The sum can reach <code>±16</code>, way outside the visible range. The output remap <code>0.5 + 0.05 * s</code> rescales it back to gray-ish territory. (<code>0.05</code> is roughly <code>1/16</code>, so each sine contributes about <code>1/16</code> of the brightness.)</p><p>Reference: <a href="https://registry.khronos.org/OpenGL/specs/es/2.0/GLSL_ES_Specification_1.00.pdf" target="_blank" rel="noreferrer">Khronos — GLSL ES 1.0 spec</a>.</p>',
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
