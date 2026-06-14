\c shader_dojo;

-- Family A, Foundations (6 courses, 24 lessons)
-- starter_vertex_shader is left NULL: the validator and frontend use the canonical passthrough.
--
-- Code style: the description teaches. The starter is a near-empty shader,
-- the canonical is the full working answer. No didactic comments inside the
-- code, the learner writes meaningful lines from a recipe in the description.
-- Each lesson's canonical includes ideas from the prior lesson, so progression
-- is visible just by reading the code.

INSERT INTO lesson (course_id, slug, display_order, title, description, starter_fragment_shader, canonical_fragment_shader) VALUES

-- ===== Course: uv-coordinates =====
((SELECT id FROM course WHERE slug = 'uv-coordinates'), 'Y9NUVKnImBU', 0,
 'UV as RG color',
 '<p>You will give every pixel an address. Then you will turn that address into a color so you can see it.</p><p><code>gl_FragCoord.xy</code> is the pixel''s spot on the canvas, in pixels. <code>(0, 0)</code> is the bottom-left pixel. The count grows right and up.</p><p><code>u_resolution</code> is a <strong>uniform</strong>. A uniform is a value the app hands the shader once per frame. It is the same for every pixel. <code>u_resolution</code> is a <code>vec2</code> that holds the canvas size in pixels. <code>u_resolution.x</code> is the width. <code>u_resolution.y</code> is the height. The real canvas size can change. So never type the size as a plain number in your code. Always read this uniform.</p><p>Divide the pixel''s spot by the canvas size:</p><p><code>vec2 uv = gl_FragCoord.xy / u_resolution.xy;</code></p><p>This new value runs from <code>0</code> to <code>1</code> across the canvas, no matter what the pixel count is. Put <code>uv.x</code> on red and <code>uv.y</code> on green.</p><p>You will see a smooth gradient. Black is in the bottom-left. Red is on the right. Green is on top. Yellow is in the top-right.</p><p>Reference: <a href="https://thebookofshaders.com/03/" target="_blank" rel="noreferrer">Book of Shaders, Uniforms</a>.</p>',
 'void main() {
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    gl_FragColor = vec4(uv, 0.0, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'uv-coordinates'), 'u0ntUSvRPHI', 1,
 'Centered UV',
 '<p>You will move the zero point from the corner to the middle.</p><p>Circles and stars are easier to draw from the middle. Subtract <code>0.5</code> from <code>uv</code>. Now the value runs from <code>-0.5</code> in the bottom-left to <code>+0.5</code> in the top-right. Zero is in the middle.</p><p>Centered values can be negative. You cannot show a negative color. <code>abs()</code> is a built-in GLSL function. It returns a number with the minus sign taken off. So <code>abs(-0.3)</code> is <code>0.3</code>. Give it a <code>vec2</code> and it does this to each part. Use <code>abs(uv)</code> to turn the negatives positive. Then times by <code>2</code> to fill the <code>0</code> to <code>1</code> range. You will see a dark middle and bright corners.</p><p>Want another way of seeing why the middle goes dark and the corners go bright? Ask the <strong>Concierge</strong> below. It can trace a single pixel through this code for you.</p><p>Reference: <a href="https://thebookofshaders.com/03/" target="_blank" rel="noreferrer">Book of Shaders, Uniforms</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    gl_FragColor = vec4(uv, 0.0, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy - 0.5;
    gl_FragColor = vec4(abs(uv) * 2.0, 0.0, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'uv-coordinates'), 'ISrgvAd5SMg', 2,
 'Aspect-corrected UV',
 '<p>The starter already draws a filled disc for you. Do not worry about <em>how</em> it is drawn. That is the <code>length</code> and <code>step</code> code. We will cover making shapes in a bit. For now, just look at the shape.</p><p>Notice it is not round. It comes out as a squished oval. That is the problem you will fix in this lesson.</p><p>The cause is the canvas <strong>aspect ratio</strong>. The aspect ratio is the width compared to the height. The canvas is usually wider than it is tall. The plain <code>uv = gl_FragCoord.xy / u_resolution.xy</code> divides x by the width and y by the height. Those are different numbers. So one step sideways covers a different distance than one step up. A shape that should be round gets stretched sideways into an oval.</p><p>To <strong>normalize</strong> here means to put x and y on one shared scale. One step in either direction must cover the same distance. Do it in two parts:</p><ul><li>Center first: <code>gl_FragCoord.xy - 0.5 * u_resolution.xy</code> moves <code>(0, 0)</code> to the middle of the canvas.</li><li>Then divide <em>both</em> x and y by the same number, the height: <code>u_resolution.y</code>.</li></ul><p>So <code>uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y</code>. Now both axes share one scale. The oval snaps back into a round circle.</p><p>This is a real mental step. Take it slowly. Open the <strong>Concierge</strong> below and ask it to walk you through the new <code>uv</code> line one piece at a time. It is happy to go gently.</p><p>Reference: <a href="https://thebookofshaders.com/03/" target="_blank" rel="noreferrer">Book of Shaders, Uniforms</a>.</p>',
 'void main() {
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
 '<p>You will name a pixel by two new numbers instead of x and y. One is how far the pixel is from the middle. The other is which way it points. Together these are <strong>polar coordinates</strong>.</p><p>The starter already gives you <code>p</code>. That is the centered, aspect-corrected position from the last lesson, with <code>(0, 0)</code> in the middle. You only need to read two things off it.</p><p><code>length()</code> is a built-in GLSL function. It returns how long a vector is. That is the straight line from <code>(0, 0)</code> to the point. Because <code>p</code> is centered, <code>r = length(p)</code> is the distance from the middle. It is <code>0</code> at the center and grows toward the edges.</p><p><code>atan()</code> is built in too. Called with two arguments as <code>atan(p.y, p.x)</code>, it gives the angle the point makes. The angle is read from the right side of the canvas, going counter-clockwise. It runs from <code>-π</code> to <code>π</code>. <code>0</code> points right. <code>π/2</code> points up.</p><p>GLSL has no built-in name for π, so spell the value out yourself: <code>float PI = 3.14159265;</code>. Then put <code>r</code> on red and <code>a / PI</code> on green. Dividing by π squeezes the angle into the <code>-1</code> to <code>1</code> range. Red brightens going out from the middle. Green sweeps around the canvas.</p><p>Reference: <a href="https://thebookofshaders.com/07/" target="_blank" rel="noreferrer">Book of Shaders, Shapes (polar section)</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float PI = 3.14159265;
    float r = length(p);
    float a = atan(p.y, p.x);
    gl_FragColor = vec4(r, a / PI, 0.0, 1.0);
}'),

-- ===== Course: time-oscillation =====
((SELECT id FROM course WHERE slug = 'time-oscillation'), 'RysomZQB5N8', 0,
 'Sine brightness',
 '<p>You will make the canvas pulse with <code>u_time</code>. <code>u_time</code> is a <code>float</code>. It counts the seconds since the shader started.</p><p>Plain <code>sin(u_time)</code> swings from <code>-1</code> to <code>+1</code>. Brightness must be from <code>0</code> to <code>1</code>. Reshape the swing with the same two steps you used in Orientation:</p><ul><li>Times by <code>0.5</code> to shrink the swing.</li><li>Add <code>0.5</code> to shift it up.</li></ul><p>So <code>0.5 + 0.5 * sin(u_time)</code> swings between <code>0</code> and <code>1</code>. Store it in a <code>float</code> named <code>v</code>:</p><p><code>float v = 0.5 + 0.5 * sin(u_time);</code></p><p>Then put <code>v</code> on all three color channels. <code>vec3(v)</code> builds a <code>vec3</code> where x, y, and z all equal <code>v</code>. Wrap it in a <code>vec4</code> with alpha <code>1.0</code>:</p><p><code>gl_FragColor = vec4(vec3(v), 1.0);</code></p><p>The canvas will breathe from black to white. One full pulse takes about <code>6.28</code> seconds.</p><p>References: <a href="https://thebookofshaders.com/03/" target="_blank" rel="noreferrer">BoS, Uniforms</a>, <a href="https://iquilezles.org/articles/trigfunctions/" target="_blank" rel="noreferrer">IQ, Trig functions</a>.</p>',
 'void main() {
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
 'void main() {
    float v = 0.5 + 0.5 * sin(u_time);
    gl_FragColor = vec4(vec3(v), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'time-oscillation'), 'Rh5lJolvCpE', 1,
 'Two-color crossfade',
 '<p>You will use the last lesson''s pulse to fade between two colors.</p><p><code>mix(a, b, t)</code> is a built-in function that blends two values. It mixes them with this exact recipe:</p><p><code>mix(a, b, t) = a * (1.0 - t) + b * t</code></p><p>Read it like a slider. When <code>t</code> is <code>0</code>, you get pure <code>a</code>. When <code>t</code> is <code>1</code>, you get pure <code>b</code>. At <code>0.5</code>, you get the halfway color. So <code>t</code> picks where you are between the two.</p><p>Your <code>t</code> from last lesson already swings smoothly from <code>0</code> to <code>1</code>. Plug it right in.</p><p>Use salmon <code>(0.96, 0.62, 0.51)</code> for <code>a</code> and yellow <code>(0.95, 0.81, 0.36)</code> for <code>b</code>:</p><p><code>vec3 c = mix(vec3(0.96, 0.62, 0.51), vec3(0.95, 0.81, 0.36), t);</code></p><p>The canvas will fade between the two colors.</p><p>Reference: <a href="https://thebookofshaders.com/06/" target="_blank" rel="noreferrer">Book of Shaders, Colors</a>.</p>',
 'void main() {
    float t = 0.5 + 0.5 * sin(u_time);
    gl_FragColor = vec4(vec3(t), 1.0);
}',
 'void main() {
    float t = 0.5 + 0.5 * sin(u_time);
    vec3 c = mix(vec3(0.96, 0.62, 0.51), vec3(0.95, 0.81, 0.36), t);
    gl_FragColor = vec4(c, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'time-oscillation'), '5Wv1Wxu93pY', 2,
 'Phase-offset RGB',
 '<p>You will pulse each color channel on its own clock. The canvas will cycle through colors.</p><p>The starter already has a <code>vec3 col</code> set to a gray pulse. All three channels are tied to the same <code>sin(u_time)</code>, so they rise and fall together.</p><p>To get color motion, the three channels need to be out of sync. Replace the line with this:</p><p><code>vec3 col = 0.5 + 0.5 * cos(u_time + vec3(0.0, 2.094, 4.189));</code></p><p>Two things changed.</p><p><strong>Why cos instead of sin?</strong> Either one swings between <code>-1</code> and <code>+1</code>. They are the same wave, just shifted. Cosine is the convention here. The same formula returns in the cosine palettes lesson later, and matching the convention now will make it feel familiar then.</p><p><strong>Why a vec3 offset?</strong> GLSL lets you call <code>cos</code> on a <code>vec3</code>. It runs <code>cos</code> on each part on its own. So <code>cos(u_time + vec3(0.0, 2.094, 4.189))</code> gives three cosines. Each one starts at a different time. The offsets <code>0</code>, <code>2.094</code>, and <code>4.189</code> are <code>2π/3</code> apart. That spaces the three colors evenly around the cycle, so the canvas glides through red, green, and blue instead of pulsing gray.</p><p>Reference: <a href="https://iquilezles.org/articles/trigfunctions/" target="_blank" rel="noreferrer">IQ, Trig functions</a>.</p>',
 'void main() {
    vec3 col = vec3(0.5 + 0.5 * sin(u_time));
    gl_FragColor = vec4(col, 1.0);
}',
 'void main() {
    vec3 col = 0.5 + 0.5 * cos(u_time + vec3(0.0, 2.094, 4.189));
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'time-oscillation'), '8LOHoVrvY5s', 3,
 'Per-axis frequency',
 '<p>You will mix space and time inside one <code>sin</code>. The wave will depend on both <code>uv.x</code> and <code>u_time</code>.</p><p>The starter already gives you <code>uv = gl_FragCoord.xy / u_resolution.xy</code>. You have seen this line before in Orientation and in the UV course. It gives every pixel a spot from <code>0</code> to <code>1</code> across the canvas.</p><p>The line you will write is:</p><p><code>float v = 0.5 + 0.5 * sin(uv.x * k + u_time);</code></p><p>The <code>0.5 + 0.5 * (...)</code> wrapper is the same trick you have been using. It matters here for a special reason. Plain <code>sin</code> dips below <code>0</code> for half its swing, and a negative color value just shows up as black. Without the wrapper, big stripes of the canvas would be flat black with no shape. The wrapper lifts the swing into the <code>0</code> to <code>1</code> range so every pixel gets a real brightness.</p><p>Now look at what is inside the <code>sin</code>:</p><ul><li><code>uv.x * k</code> makes the wave repeat across the canvas. <code>k</code> controls how fast that repeat happens. A bigger <code>k</code> packs more bright and dark cycles into the same width.</li><li><code>+ u_time</code> slides the whole wave each frame. The stripes scroll.</li></ul><p>Pick <code>k = 12.566</code>. That is about <code>4π</code>. It gives two full bright and dark cycles across the canvas.</p><p>Reference: <a href="https://thebookofshaders.com/05/" target="_blank" rel="noreferrer">Book of Shaders, Shaping functions</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float v = 0.5 + 0.5 * sin(uv.x * 12.566 + u_time);
    gl_FragColor = vec4(vec3(v), 1.0);
}'),

-- ===== Course: step-smoothstep =====
((SELECT id FROM course WHERE slug = 'step-smoothstep'), 'p0O1Dv3P-vA', 0,
 'step() half-plane',
 '<p>You will meet a function that gives a yes-or-no answer for each pixel.</p><p><code>step(edge, x)</code> gives <code>0.0</code> when <code>x</code> is less than <code>edge</code>. It gives <code>1.0</code> otherwise. There is no blend. The change happens in zero pixels. It is a yes-or-no question at every pixel.</p><p>The starter gives you <code>uv = gl_FragCoord.xy / u_resolution.xy</code>. Ask "is this pixel past <code>uv.x = 0.5</code>?" with <code>step(0.5, uv.x)</code>. Put the answer on all three color channels. The left half is black. The right half is white. The edge looks jagged. <code>step</code> has no smoothing. You will fix that in the next lesson.</p><p>References: <a href="https://thebookofshaders.com/05/" target="_blank" rel="noreferrer">BoS, Shaping functions</a>, <a href="https://iquilezles.org/articles/functions/" target="_blank" rel="noreferrer">IQ, Useful little functions</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float m = step(0.5, uv.x);
    gl_FragColor = vec4(vec3(m), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'step-smoothstep'), 'ANep5l9KXQA', 1,
 'smoothstep() antialiased edge',
 '<p>You will swap the jagged edge for a smooth one.</p><p><code>smoothstep(a, b, x)</code> is <code>0</code> below <code>a</code>. It is <code>1</code> above <code>b</code>. In between, it makes a smooth curve. A wider gap between <code>a</code> and <code>b</code> gives a softer edge.</p><p>Pick a thin band around <code>0.5</code>. Use <code>smoothstep(0.48, 0.52, uv.x)</code>. From <code>uv.x = 0.48</code> to <code>uv.x = 0.52</code> the value goes from <code>0</code> to <code>1</code>. That is about <code>4%</code> of the canvas. The picture looks the same. But the edge is smooth, not jagged.</p><p>References: <a href="https://thebookofshaders.com/05/" target="_blank" rel="noreferrer">BoS, Shaping functions</a>, <a href="https://iquilezles.org/articles/smoothsteps/" target="_blank" rel="noreferrer">IQ, Smoothsteps</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
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
 '<p>You will draw a bright stripe in the middle. You will do this by subtracting one smoothstep from another.</p><p>The starter gives you <code>uv = gl_FragCoord.xy / u_resolution.xy</code>. The first smoothstep, <code>smoothstep(0.30, 0.32, uv.x)</code>, goes from <code>0</code> to <code>1</code> near <code>uv.x = 0.31</code>. The second, <code>smoothstep(0.68, 0.70, uv.x)</code>, goes from <code>0</code> to <code>1</code> near <code>uv.x = 0.69</code>. Subtract them. The result is <code>0</code> on the sides. It is <code>1</code> in the middle. The edges are soft.</p><p>Rising edge minus rising edge gives a band. You will use this same pattern to draw stripes and rings and ribbons later.</p><p>Reference: <a href="https://iquilezles.org/articles/smoothsteps/" target="_blank" rel="noreferrer">IQ, Smoothsteps</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float m = smoothstep(0.30, 0.32, uv.x) - smoothstep(0.68, 0.70, uv.x);
    gl_FragColor = vec4(vec3(m), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'step-smoothstep'), 'J0cVn8u2KQM', 3,
 'Reversed smoothstep',
 '<p>You will flip a smoothstep. You will see that swapping the first two arguments turns a rising edge into a falling edge.</p><p>The starter has a rising edge: <code>smoothstep(0.3, 0.7, uv.x)</code>. The canvas is dark on the left and bright on the right. The smooth transition happens between <code>uv.x = 0.3</code> and <code>uv.x = 0.7</code>.</p><p>Now swap the first two arguments: <code>smoothstep(0.7, 0.3, uv.x)</code>. Same numbers. Same x. Just flipped.</p><p>Run it. The canvas flips. It is now bright on the left and dark on the right. The transition still sits between <code>0.3</code> and <code>0.7</code>, but the direction is reversed.</p><p><strong>Why it works.</strong> Inside, smoothstep computes <code>(x - edge0) / (edge1 - edge0)</code>. Swap edge0 and edge1 and that fraction flips sign. The whole curve flips with it. You get the same shape, mirrored.</p><p>This is a clean way to make a falling edge. It saves you from writing <code>1.0 - smoothstep(...)</code> every time.</p><p>Reference: <a href="https://iquilezles.org/articles/smoothsteps/" target="_blank" rel="noreferrer">IQ, Smoothsteps</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float m = smoothstep(0.3, 0.7, uv.x);
    gl_FragColor = vec4(vec3(m), 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float m = smoothstep(0.7, 0.3, uv.x);
    gl_FragColor = vec4(vec3(m), 1.0);
}'),

-- ===== Course: mix-gradients =====
((SELECT id FROM course WHERE slug = 'mix-gradients'), 'C9NOPPTcO8c', 0,
 'Horizontal two-color',
 '<p>You will blend from salmon on the left to yellow on the right.</p><p><code>mix(a, b, t)</code> is the GLSL built-in for blending. It does the math <code>a * (1 - t) + b * t</code> on each part. When <code>t</code> is <code>0</code>, you get <code>a</code>. When <code>t</code> is <code>1</code>, you get <code>b</code>. Halfway gives the average.</p><p>The starter shows a flat salmon canvas. Now mix it with yellow as the pixel moves across the canvas. Store <code>uv.x</code> in a <code>float</code> named <code>t</code>:</p><p><code>float t = uv.x;</code></p><p>Then pass it as the third argument of <code>mix</code>:</p><p><code>vec3 c = mix(vec3(0.96, 0.62, 0.51), vec3(0.95, 0.81, 0.36), t);</code></p><p>Salmon shows on the left where <code>t</code> is near <code>0</code>. Yellow shows on the right where <code>t</code> is near <code>1</code>. Every shade is in between.</p><p>Reference: <a href="https://thebookofshaders.com/06/" target="_blank" rel="noreferrer">Book of Shaders, Colors</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 c = vec3(0.96, 0.62, 0.51);
    gl_FragColor = vec4(c, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float t = uv.x;
    vec3 c = mix(vec3(0.96, 0.62, 0.51), vec3(0.95, 0.81, 0.36), t);
    gl_FragColor = vec4(c, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'mix-gradients'), '5U6D3uvCGzQ', 1,
 'Diagonal gradient',
 '<p>You will turn the gradient by <code>45°</code>. You will use both axes for the blend.</p><p>The starter has <code>float t = uv.x;</code> from last lesson. Change that one line to average both axes:</p><p><code>float t = (uv.x + uv.y) * 0.5;</code></p><p>Now <code>t</code> is <code>0</code> at the bottom-left, <code>0.5</code> along the diagonal, and <code>1</code> at the top-right. The <code>mix</code> stays the same: salmon <code>(0.96, 0.62, 0.51)</code> on one side, yellow <code>(0.95, 0.81, 0.36)</code> on the other. Only <code>t</code> changes. The gradient now runs corner to corner.</p><p>Reference: <a href="https://thebookofshaders.com/06/" target="_blank" rel="noreferrer">Book of Shaders, Colors</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float t = uv.x;
    vec3 c = mix(vec3(0.96, 0.62, 0.51), vec3(0.95, 0.81, 0.36), t);
    gl_FragColor = vec4(c, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float t = (uv.x + uv.y) * 0.5;
    vec3 c = mix(vec3(0.96, 0.62, 0.51), vec3(0.95, 0.81, 0.36), t);
    gl_FragColor = vec4(c, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'mix-gradients'), 'VyyQdFs8C0s', 2,
 'Three-stop nested mix',
 '<p>You will add a third color so the gradient has three stops instead of two. The trick: at the middle, both halves must arrive at the same color.</p>
<p>The starter ships the diagonal salmon-to-yellow gradient from last lesson. Add a third color, navy, that takes over on the left. Declare all three as named vectors:</p>
<p><code>vec3 navy   = vec3(0.10, 0.15, 0.35);<br>vec3 salmon = vec3(0.96, 0.62, 0.51);<br>vec3 yellow = vec3(0.95, 0.81, 0.36);</code></p>
<p>Each half of the canvas needs its own <code>0</code>-to-<code>1</code> ramp:</p>
<ul><li>Left half: <code>uv.x</code> from <code>0</code> to <code>0.5</code> becomes <code>uv.x * 2.0</code>. Use this to blend navy to salmon.</li>
<li>Right half: <code>uv.x</code> from <code>0.5</code> to <code>1</code> becomes <code>(uv.x - 0.5) * 2.0</code>. Use this to blend salmon to yellow.</li></ul>
<p>Compute both mixes and store each in its own variable:</p>
<p><code>vec3 leftMix  = mix(navy, salmon, uv.x * 2.0);<br>vec3 rightMix = mix(salmon, yellow, (uv.x - 0.5) * 2.0);</code></p>
<p>Now pick whichever applies to the current pixel. The <strong>ternary operator</strong> <code>condition ? a : b</code> is a one-line if/else. It returns <code>a</code> when the condition is true, <code>b</code> when it is false. Use <code>uv.x &lt; 0.5</code> as the condition so the left half draws <code>leftMix</code> and the right half draws <code>rightMix</code>:</p>
<p><code>vec3 col = uv.x &lt; 0.5 ? leftMix : rightMix;</code></p>
<p>At <code>uv.x = 0.5</code> exactly, both <code>leftMix</code> and <code>rightMix</code> evaluate to pure salmon. So the join is invisible: the colors meet seamlessly in the middle.</p>
<p>Reference: <a href="https://thebookofshaders.com/06/" target="_blank" rel="noreferrer">Book of Shaders, Colors</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float t = (uv.x + uv.y) * 0.5;
    vec3 c = mix(vec3(0.96, 0.62, 0.51), vec3(0.95, 0.81, 0.36), t);
    gl_FragColor = vec4(c, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 navy   = vec3(0.10, 0.15, 0.35);
    vec3 salmon = vec3(0.96, 0.62, 0.51);
    vec3 yellow = vec3(0.95, 0.81, 0.36);
    vec3 leftMix  = mix(navy, salmon, uv.x * 2.0);
    vec3 rightMix = mix(salmon, yellow, (uv.x - 0.5) * 2.0);
    vec3 col = uv.x < 0.5 ? leftMix : rightMix;
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'mix-gradients'), 'RmXFv-4OZwk', 3,
 'Radial gradient',
 '<p>You will blend by distance from the middle, not by an axis.</p>
<p>The starter ships the centered, aspect-fixed <code>p</code> from the polar lesson. The recipe:</p>
<ul><li>Get the distance to the middle with <code>float r = length(p);</code>.</li>
<li>Put <code>r</code> through <code>smoothstep(0.0, 0.6, r)</code> and store it in a <code>float</code> named <code>t</code>. Now <code>t</code> is <code>0</code> at the middle and <code>1</code> past radius <code>0.6</code>.</li>
<li><code>mix</code> bright yellow <code>(0.95, 0.81, 0.36)</code> in the middle with dark navy <code>(0.10, 0.15, 0.35)</code> outside, using <code>t</code> as the blend factor:</li></ul>
<p><code>vec3 col = mix(vec3(0.95, 0.81, 0.36), vec3(0.10, 0.15, 0.35), t);</code></p>
<p>You just drew your first spotlight.</p>
<p>Reference: <a href="https://thebookofshaders.com/06/" target="_blank" rel="noreferrer">Book of Shaders, Colors</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float r = length(p);
    float t = smoothstep(0.0, 0.6, r);
    vec3 col = mix(vec3(0.95, 0.81, 0.36), vec3(0.10, 0.15, 0.35), t);
    gl_FragColor = vec4(col, 1.0);
}'),

-- ===== Course: plotting-curves =====
((SELECT id FROM course WHERE slug = 'plotting-curves'), 'c3su8EDPRds', 0,
 'Plot y = x',
 '<p>You will draw the line <code>y = x</code>. This is the simplest plot.</p>
<p>Each pixel sits at <code>(uv.x, uv.y)</code>. On the line <code>y = x</code>, the vertical position equals the horizontal position. So at column <code>uv.x</code>, the line sits at vertical position <code>uv.x</code> too. The up-down distance from a pixel to the line is the gap between <code>uv.y</code> and that target:</p>
<p><code>float d = abs(uv.y - uv.x);</code></p>
<p>Now turn that distance into brightness. Use <code>smoothstep</code> with two close edges so only pixels very near the line stay bright. Flip the result with <code>1.0 -</code> so close pixels become <code>1</code> and far pixels become <code>0</code>:</p>
<p><code>float m = 1.0 - smoothstep(0.005, 0.015, d);</code></p>
<p>The starter ships <code>uv</code> ready. You write the two lines above and put <code>vec3(m)</code> into <code>gl_FragColor</code>.</p>
<p>The pattern <code>abs(uv.y - [vertical position at uv.x])</code> is the whole plot recipe. The next lesson swaps in a sine for that vertical position, and everything else stays the same.</p>
<p>Reference: <a href="https://thebookofshaders.com/05/" target="_blank" rel="noreferrer">Book of Shaders, Shaping functions (plot section)</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float d = abs(uv.y - uv.x);
    float m = 1.0 - smoothstep(0.005, 0.015, d);
    gl_FragColor = vec4(vec3(m), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'plotting-curves'), 'w60pXClCffU', 1,
 'Plot y = sin(x)',
 '<p>You will use the same plot recipe on a real curve.</p><p>A sine looks better centered. Remap <code>uv</code> from <code>0</code>-to-<code>1</code> to <code>-1</code>-to-<code>1</code> first. Change the starter''s <code>uv</code> line to:</p><p><code>vec2 uv = gl_FragCoord.xy / u_resolution.xy * 2.0 - 1.0;</code></p><p>Now <code>uv.y = 0</code> is the middle of the canvas. That is where the sine baseline goes.</p><p><code>sin(uv.x * 6.28318)</code> is one full wave from left to right. <code>6.28318</code> is about <code>2π</code>. Times the sine by <code>0.5</code> so the peaks land at <code>uv.y = ±0.5</code>, not off the top. Store the result in a <code>float</code> named <code>y</code>:</p><p><code>float y = 0.5 * sin(uv.x * 6.28318);</code></p><p>Then the plot recipe is the same as last lesson, but with <code>y</code> in place of <code>uv.x</code>:</p><p><code>float d = abs(uv.y - y);<br>float m = 1.0 - smoothstep(0.01, 0.03, d);</code></p><p>Reference: <a href="https://thebookofshaders.com/05/" target="_blank" rel="noreferrer">Book of Shaders, Shaping functions (plot section)</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float d = abs(uv.y - uv.x);
    float m = 1.0 - smoothstep(0.005, 0.015, d);
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
 '<p>You will see that the smoothstep edges <code>(a, b)</code> set the curve thickness.</p><p>Look at <code>1.0 - smoothstep(a, b, d)</code>. It is <code>1</code> when <code>d</code> is less than <code>a</code>. It drops to <code>0</code> when <code>d</code> is more than <code>b</code>. So pixels closer than <code>a</code> are solid. Pixels between <code>a</code> and <code>b</code> are the soft edge. Pixels past <code>b</code> are dark. Push <code>a</code> out to make the curve thicker. Spread <code>b - a</code> to make the edges softer.</p><p>Everything else from last lesson stays the same. Only change the smoothstep edges. Use <code>smoothstep(0.05, 0.08, d)</code> for a curve that is about three times as thick, with the same soft falloff.</p><p>Reference: <a href="https://iquilezles.org/articles/smoothsteps/" target="_blank" rel="noreferrer">IQ, Smoothsteps</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 2.0 - 1.0;
    float y = 0.5 * sin(uv.x * 6.28318);
    float d = abs(uv.y - y);
    float m = 1.0 - smoothstep(0.01, 0.03, d);
    gl_FragColor = vec4(vec3(m), 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 2.0 - 1.0;
    float y = 0.5 * sin(uv.x * 6.28318);
    float d = abs(uv.y - y);
    float m = 1.0 - smoothstep(0.05, 0.08, d);
    gl_FragColor = vec4(vec3(m), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'plotting-curves'), 'J57FduwRbQ8', 3,
 'Animated phase',
 '<p>You will add <code>u_time</code> to the sine. The curve will scroll across the canvas.</p><p>Swap <code>sin(uv.x * 6.28318)</code> for <code>sin(uv.x * 6.28318 + u_time)</code>. Nothing else changes. The plot recipe does not care that the curve moves each frame.</p><p>Adding time to the inside of the sine slides the curve. Adding time to everything would not change the picture. The pattern <code>f(space + time)</code> is how almost every moving pattern in this course gets its motion.</p><p>Reference: <a href="https://thebookofshaders.com/05/" target="_blank" rel="noreferrer">Book of Shaders, Shaping functions</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 2.0 - 1.0;
    float y = 0.5 * sin(uv.x * 6.28318);
    float d = abs(uv.y - y);
    float m = 1.0 - smoothstep(0.05, 0.08, d);
    gl_FragColor = vec4(vec3(m), 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 2.0 - 1.0;
    float y = 0.5 * sin(uv.x * 6.28318 + u_time);
    float d = abs(uv.y - y);
    float m = 1.0 - smoothstep(0.05, 0.08, d);
    gl_FragColor = vec4(vec3(m), 1.0);
}'),

-- ===== Course: loop-fundamentals =====
-- Moved here from Family J. Lessons stay simple and visual on purpose: this is the
-- one course where the learner sees `for`, `break`, and per-pixel reductions for the
-- first time. After this, the noise/voronoi/raymarch families are safe to enter.

((SELECT id FROM course WHERE slug = 'loop-fundamentals'), 'WWkoco-M-vA', 0,
 'Count steps to threshold',
 '<p>You will write your first loop. You will turn the loop count into a picture.</p><p>GLSL has one big rule for loops. The number of times must be a fixed number the compiler can see. <code>for (int i = 0; i &lt; 32; i++)</code> works. <code>for (int i = 0; i &lt; n; i++)</code> does not, if <code>n</code> is a uniform.</p><p>The starter ships <code>uv</code>, <code>steps</code>, and <code>v</code> ready, plus the final <code>gl_FragColor</code> that turns <code>steps</code> into gray. All you write is the loop.</p><p>The loop walks <code>v</code> up by <code>0.05</code> at each step. If <code>v</code> goes past <code>uv.x</code>, <code>break</code>. Otherwise add <code>1</code> to <code>steps</code>:</p><p><code>for (int i = 0; i &lt; 32; i++) {<br>&nbsp;&nbsp;&nbsp;&nbsp;v += 0.05;<br>&nbsp;&nbsp;&nbsp;&nbsp;if (v &gt; uv.x) break;<br>&nbsp;&nbsp;&nbsp;&nbsp;steps++;<br>}</code></p><p>Brighter pixels are the ones that took more steps. You get a stepped horizontal gradient.</p><p>Reference: <a href="https://registry.khronos.org/OpenGL/specs/es/2.0/GLSL_ES_Specification_1.00.pdf" target="_blank" rel="noreferrer">Khronos, GLSL ES 1.0 spec</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    int steps = 0;
    float v = 0.0;
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
 '<p>You will use a loop to search at each pixel.</p><p>The helper <code>hash(p)</code> returns <code>fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453)</code>. It is a fake-random function. The same <code>p</code> always gives the same number. Two nearby <code>p</code> values look unrelated. Treat it as a black box for now. The noise family will explain those numbers.</p><p>The starter ships <code>uv</code>, <code>it</code>, and the final <code>gl_FragColor</code> that turns <code>it</code> into gray. All you write is the loop.</p><p>Loop 32 times. At step <code>i</code>, hash <code>uv * float(i + 1)</code>. A different <code>i</code> gives a different number at the same pixel. The first time the value goes past <code>0.7</code>, <code>break</code>. Otherwise save <code>i</code> in <code>it</code>:</p><p><code>for (int i = 0; i &lt; 32; i++) {<br>&nbsp;&nbsp;&nbsp;&nbsp;if (hash(uv * float(i + 1)) &gt; 0.7) break;<br>&nbsp;&nbsp;&nbsp;&nbsp;it = i;<br>}</code></p><p>The picture looks grainy. Each pixel stops at a random step.</p><p>Reference: <a href="https://iquilezles.org/articles/gpuconditionals/" target="_blank" rel="noreferrer">IQ, GPU conditionals</a>.</p>',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    int it = 0;
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
 '<p>You will use a loop to keep only the biggest value out of many.</p><p>The starter ships <code>uv</code>, <code>m</code> set to <code>-1.0</code>, and the final <code>gl_FragColor</code> that maps <code>m</code> from <code>-1</code>-to-<code>1</code> into a gray value. <code>-1.0</code> is the right starting point because it sits below anything <code>sin</code> can give. The first comparison will always lift <code>m</code> up.</p><p>All you write is the loop. For <code>i</code> from <code>0</code> to <code>15</code>, work out <code>sin(uv.x * float(i))</code>. Keep the bigger of the old <code>m</code> and the new value:</p><p><code>for (int i = 0; i &lt; 16; i++) {<br>&nbsp;&nbsp;&nbsp;&nbsp;m = max(m, sin(uv.x * float(i)));<br>}</code></p><p>The result is the top edge of 16 sines at different speeds. The waves overlap, so the running max stays near <code>1</code> most of the time. You will see a bright canvas with thin dark seams.</p><p>Reference: <a href="https://registry.khronos.org/OpenGL/specs/es/2.0/GLSL_ES_Specification_1.00.pdf" target="_blank" rel="noreferrer">Khronos, GLSL ES 1.0 spec</a>.</p>',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float m = -1.0;
    gl_FragColor = vec4(vec3(0.5 + 0.5 * m), 1.0);
}',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float m = -1.0;
    for (int i = 0; i < 16; i++) {
        m = max(m, sin(uv.x * float(i)));
    }
    gl_FragColor = vec4(vec3(0.5 + 0.5 * m), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'loop-fundamentals'), '_8epBwGjScc', 3,
 'Running average',
 '<p>You will swap <code>max</code> for sum. Now the loop adds things up. You will use this for blur and noise later.</p><p>Start <code>s = 0</code>. Loop 16 times. Each time, add <code>sin(uv.x * float(i) * 0.5)</code> to <code>s</code>. The result is the sum of 16 sine waves at different speeds.</p><p>The sum can reach <code>±16</code>. That is far outside the visible range. The output uses <code>0.5 + 0.05 * s</code> to bring it back to gray. <code>0.05</code> is about <code>1/16</code>. So each sine adds about <code>1/16</code> of the brightness.</p><p>Reference: <a href="https://registry.khronos.org/OpenGL/specs/es/2.0/GLSL_ES_Specification_1.00.pdf" target="_blank" rel="noreferrer">Khronos, GLSL ES 1.0 spec</a>.</p>',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float m = -1.0;
    for (int i = 0; i < 16; i++) {
        m = max(m, sin(uv.x * float(i)));
    }
    gl_FragColor = vec4(vec3(0.5 + 0.5 * m), 1.0);
}',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float s = 0.0;
    for (int i = 0; i < 16; i++) {
        s += sin(uv.x * float(i) * 0.5);
    }
    gl_FragColor = vec4(vec3(0.5 + 0.05 * s), 1.0);
}');

-- Per-lesson Concierge guidance: the aspect-corrected UV lesson is the first hard
-- mental step for a brand-new learner, so soften the tutor for this one lesson.
UPDATE lesson SET concierge_hint =
 'This learner is just starting out and is on the hardest step so far: correcting the canvas aspect ratio so a circle stops looking like an oval. Go especially gentle. Take it one small piece at a time and check they follow before moving on. Do not assume they know what gl_FragCoord, u_resolution, centering, or dividing by the height do, explain each plainly. Be warm and encouraging. Never paste the whole corrected uv line at once; build it up with them.'
WHERE slug = 'ISrgvAd5SMg'
  AND course_id = (SELECT id FROM course WHERE slug = 'uv-coordinates');
