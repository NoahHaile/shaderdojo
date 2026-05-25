\c shader_dojo;

-- Family A — Foundations (5 courses, 20 lessons)
-- starter_vertex_shader is left NULL: the validator and frontend use the canonical passthrough.

INSERT INTO lesson (id, course_id, slug, display_order, title, description, starter_fragment_shader, canonical_fragment_shader) VALUES

-- ===== Course: uv-coordinates =====
('c0000001-0001-0000-0000-000000000000', 'c0000001-0000-0000-0000-000000000000', 'Y9NUVKnImBU', 0,
 'UV as RG color',
 '<p>Every fragment shader needs a coordinate system. Divide <code>gl_FragCoord.xy</code> by <code>u_resolution.xy</code> to get UV in <code>[0, 1]</code>.</p><p>Output that UV as the red and green channels — red rises with x, green with y, blue stays at 0.</p><p>Reference: <a href="https://thebookofshaders.com/03/" target="_blank" rel="noreferrer">Book of Shaders — Uniforms</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: output uv as the red and green channels (blue = 0, alpha = 1).
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    gl_FragColor = vec4(uv, 0.0, 1.0);
}'),

('c0000001-0002-0000-0000-000000000000', 'c0000001-0000-0000-0000-000000000000', 'u0ntUSvRPHI', 1,
 'Centered UV',
 '<p>Subtract <code>0.5</code> from each component to put the origin at the canvas center. Taking the absolute value of a centered UV gives concentric rectangles radiating from the middle.</p><p>Reference: <a href="https://thebookofshaders.com/03/" target="_blank" rel="noreferrer">Book of Shaders — Uniforms</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: re-center uv so (0, 0) is the canvas middle, then output abs(uv) * 2.0 in RG.
    gl_FragColor = vec4(uv, 0.0, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy - 0.5;
    gl_FragColor = vec4(abs(uv) * 2.0, 0.0, 1.0);
}'),

('c0000001-0003-0000-0000-000000000000', 'c0000001-0000-0000-0000-000000000000', 'ISrgvAd5SMg', 2,
 'Aspect-corrected UV',
 '<p>If the canvas is non-square, a raw UV stretches every shape. Divide the centered pixel offset by <code>u_resolution.y</code> (the shorter side, conventionally) so a unit of UV is a unit of pixel — circles stay circular.</p><p>Reference: <a href="https://thebookofshaders.com/03/" target="_blank" rel="noreferrer">Book of Shaders — Uniforms</a>.</p>',
 'void main() {
    // TODO: build aspect-corrected uv = (gl_FragCoord.xy - 0.5*u_resolution.xy) / u_resolution.y
    vec2 uv = gl_FragCoord.xy / u_resolution.xy - 0.5;
    float d = length(uv);
    gl_FragColor = vec4(vec3(step(d, 0.3)), 1.0);
}',
 'void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d = length(uv);
    gl_FragColor = vec4(vec3(step(d, 0.3)), 1.0);
}'),

('c0000001-0004-0000-0000-000000000000', 'c0000001-0000-0000-0000-000000000000', 'RmYF8JiNb5A', 3,
 'Polar coordinates',
 '<p>Convert a centered UV into polar: <code>r = length(p)</code> is distance from origin, <code>a = atan(p.y, p.x)</code> is angle in <code>[-π, π]</code>. Output <code>r</code> as red and the normalized angle as green to see the polar grid.</p><p>Reference: <a href="https://thebookofshaders.com/07/" target="_blank" rel="noreferrer">Book of Shaders — Shapes (polar section)</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    // TODO: compute r = length(p) and a = atan(p.y, p.x), then output (r, a/3.14159, 0, 1).
    gl_FragColor = vec4(p, 0.0, 1.0);
}',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float r = length(p);
    float a = atan(p.y, p.x);
    gl_FragColor = vec4(r, a / 3.14159265, 0.0, 1.0);
}'),

-- ===== Course: time-oscillation =====
('c0000002-0001-0000-0000-000000000000', 'c0000002-0000-0000-0000-000000000000', 'RysomZQB5N8', 0,
 'Sine brightness',
 '<p>The signature time animation: <code>0.5 + 0.5 * sin(u_time)</code> gives a value that smoothly oscillates between 0 and 1. Use it as a grayscale brightness so the whole canvas pulses.</p><p>References: <a href="https://thebookofshaders.com/03/" target="_blank" rel="noreferrer">BoS — Uniforms</a>, <a href="https://iquilezles.org/articles/trigfunctions/" target="_blank" rel="noreferrer">IQ — Trig functions</a>.</p>',
 'void main() {
    // TODO: set v to 0.5 + 0.5 * sin(u_time), then output it on all three channels.
    float v = 1.0;
    gl_FragColor = vec4(vec3(v), 1.0);
}',
 'void main() {
    float v = 0.5 + 0.5 * sin(u_time);
    gl_FragColor = vec4(vec3(v), 1.0);
}'),

('c0000002-0002-0000-0000-000000000000', 'c0000002-0000-0000-0000-000000000000', 'Rh5lJolvCpE', 1,
 'Two-color crossfade',
 '<p>Feed a time oscillation into <code>mix()</code> to blend between two fixed colors. The 0..1 oscillator becomes the <code>t</code> of the mix.</p><p>Reference: <a href="https://thebookofshaders.com/06/" target="_blank" rel="noreferrer">Book of Shaders — Colors</a>.</p>',
 'void main() {
    float t = 0.5 + 0.5 * sin(u_time);
    // TODO: mix between (0.96, 0.62, 0.51) and (0.95, 0.81, 0.36) by t.
    vec3 c = vec3(1.0);
    gl_FragColor = vec4(c, 1.0);
}',
 'void main() {
    float t = 0.5 + 0.5 * sin(u_time);
    vec3 c = mix(vec3(0.96, 0.62, 0.51), vec3(0.95, 0.81, 0.36), t);
    gl_FragColor = vec4(c, 1.0);
}'),

('c0000002-0003-0000-0000-000000000000', 'c0000002-0000-0000-0000-000000000000', '5Wv1Wxu93pY', 2,
 'Phase-offset RGB',
 '<p>Each channel gets its own phase by adding a different offset inside the <code>cos()</code>. The three vec3 offsets <code>(0, 2π/3, 4π/3)</code> evenly space the RGB channels around the cycle.</p><p>Reference: <a href="https://iquilezles.org/articles/trigfunctions/" target="_blank" rel="noreferrer">IQ — Trig functions</a>.</p>',
 'void main() {
    // TODO: c = 0.5 + 0.5 * cos(u_time + vec3(0.0, 2.094, 4.189));
    vec3 c = vec3(0.5);
    gl_FragColor = vec4(c, 1.0);
}',
 'void main() {
    vec3 c = 0.5 + 0.5 * cos(u_time + vec3(0.0, 2.094, 4.189));
    gl_FragColor = vec4(c, 1.0);
}'),

('c0000002-0004-0000-0000-000000000000', 'c0000002-0000-0000-0000-000000000000', '8LOHoVrvY5s', 3,
 'Per-axis frequency',
 '<p>The oscillation can take a position too. <code>sin(uv.x * k + u_time)</code> produces vertical stripes that scroll over time — frequency <code>k</code> sets how many stripes fit across the canvas.</p><p>Reference: <a href="https://thebookofshaders.com/05/" target="_blank" rel="noreferrer">Book of Shaders — Shaping functions</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: v = 0.5 + 0.5 * sin(uv.x * 12.566 + u_time);
    float v = 1.0;
    gl_FragColor = vec4(vec3(v), 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float v = 0.5 + 0.5 * sin(uv.x * 12.566 + u_time);
    gl_FragColor = vec4(vec3(v), 1.0);
}'),

-- ===== Course: step-smoothstep =====
('c0000003-0001-0000-0000-000000000000', 'c0000003-0000-0000-0000-000000000000', 'p0O1Dv3P-vA', 0,
 'step() half-plane',
 '<p><code>step(edge, x)</code> returns 0 when <code>x &lt; edge</code> and 1 otherwise — a hard binary mask. Split the canvas vertically into a black and white half.</p><p>References: <a href="https://thebookofshaders.com/05/" target="_blank" rel="noreferrer">BoS — Shaping functions</a>, <a href="https://iquilezles.org/articles/functions/" target="_blank" rel="noreferrer">IQ — Useful little functions</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: m = step(0.5, uv.x);
    float m = 0.0;
    gl_FragColor = vec4(vec3(m), 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float m = step(0.5, uv.x);
    gl_FragColor = vec4(vec3(m), 1.0);
}'),

('c0000003-0002-0000-0000-000000000000', 'c0000003-0000-0000-0000-000000000000', 'ANep5l9KXQA', 1,
 'smoothstep() antialiased edge',
 '<p><code>smoothstep(a, b, x)</code> ramps from 0 to 1 with a smooth Hermite curve. Use it with a small range around 0.5 to get an antialiased version of the previous lesson.</p><p>References: <a href="https://thebookofshaders.com/05/" target="_blank" rel="noreferrer">BoS — Shaping functions</a>, <a href="https://iquilezles.org/articles/smoothsteps/" target="_blank" rel="noreferrer">IQ — Smoothsteps</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: replace step(0.5, ...) with smoothstep(0.48, 0.52, uv.x).
    float m = step(0.5, uv.x);
    gl_FragColor = vec4(vec3(m), 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float m = smoothstep(0.48, 0.52, uv.x);
    gl_FragColor = vec4(vec3(m), 1.0);
}'),

('c0000003-0003-0000-0000-000000000000', 'c0000003-0000-0000-0000-000000000000', 'DMpqeHFWXBM', 2,
 'Stripe via two smoothsteps',
 '<p>Subtracting one smoothstep from another carves a band: rises at the first edge, falls at the second. Use this to draw a soft white stripe between <code>0.3</code> and <code>0.7</code>.</p><p>Reference: <a href="https://iquilezles.org/articles/smoothsteps/" target="_blank" rel="noreferrer">IQ — Smoothsteps</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: m = smoothstep(0.30, 0.32, uv.x) - smoothstep(0.68, 0.70, uv.x);
    float m = 0.0;
    gl_FragColor = vec4(vec3(m), 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float m = smoothstep(0.30, 0.32, uv.x) - smoothstep(0.68, 0.70, uv.x);
    gl_FragColor = vec4(vec3(m), 1.0);
}'),

('c0000003-0004-0000-0000-000000000000', 'c0000003-0000-0000-0000-000000000000', 'J0cVn8u2KQM', 3,
 'Signed-threshold band',
 '<p>Take the absolute distance from a center value, then smoothstep on that. Result: a band that fades out symmetrically away from the chosen line.</p><p>Reference: <a href="https://iquilezles.org/articles/functions/" target="_blank" rel="noreferrer">IQ — Useful little functions</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: d = abs(uv.x - 0.5); m = 1.0 - smoothstep(0.18, 0.22, d);
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
('c0000004-0001-0000-0000-000000000000', 'c0000004-0000-0000-0000-000000000000', 'C9NOPPTcO8c', 0,
 'Horizontal two-color',
 '<p><code>mix(a, b, t)</code> is component-wise linear interpolation. Pass <code>uv.x</code> as <code>t</code> to blend smoothly from color A on the left to color B on the right.</p><p>Reference: <a href="https://thebookofshaders.com/06/" target="_blank" rel="noreferrer">Book of Shaders — Colors</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: c = mix(vec3(0.96, 0.62, 0.51), vec3(0.95, 0.81, 0.36), uv.x);
    vec3 c = vec3(0.5);
    gl_FragColor = vec4(c, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 c = mix(vec3(0.96, 0.62, 0.51), vec3(0.95, 0.81, 0.36), uv.x);
    gl_FragColor = vec4(c, 1.0);
}'),

('c0000004-0002-0000-0000-000000000000', 'c0000004-0000-0000-0000-000000000000', '5U6D3uvCGzQ', 1,
 'Diagonal gradient',
 '<p>Build the blend factor from a combination of both axes — here <code>(uv.x + uv.y) * 0.5</code> — to get a diagonal gradient that runs from corner to corner.</p><p>Reference: <a href="https://thebookofshaders.com/06/" target="_blank" rel="noreferrer">Book of Shaders — Colors</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: t = (uv.x + uv.y) * 0.5; then mix two colors by t.
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

('c0000004-0003-0000-0000-000000000000', 'c0000004-0000-0000-0000-000000000000', 'VyyQdFs8C0s', 2,
 'Three-stop nested mix',
 '<p>A three-color gradient is two mixes glued at the midpoint. Below 0.5, blend A→B; above 0.5, blend B→C. Rescale <code>uv.x</code> so each half runs 0..1.</p><p>Reference: <a href="https://thebookofshaders.com/06/" target="_blank" rel="noreferrer">Book of Shaders — Colors</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 a = vec3(0.10, 0.15, 0.35);
    vec3 b = vec3(0.96, 0.62, 0.51);
    vec3 c = vec3(0.95, 0.81, 0.36);
    // TODO: col = uv.x < 0.5 ? mix(a, b, uv.x*2.0) : mix(b, c, (uv.x-0.5)*2.0);
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

('c0000004-0004-0000-0000-000000000000', 'c0000004-0000-0000-0000-000000000000', 'RmXFv-4OZwk', 3,
 'Radial gradient',
 '<p>Drive the mix by distance from the center instead of one of the axes. Use <code>smoothstep</code> on the radius so the falloff is soft.</p><p>Reference: <a href="https://thebookofshaders.com/06/" target="_blank" rel="noreferrer">Book of Shaders — Colors</a>.</p>',
 'void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    // TODO: r = length(uv); t = smoothstep(0.0, 0.6, r); mix two colors by t.
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
('c0000005-0001-0000-0000-000000000000', 'c0000005-0000-0000-0000-000000000000', 'c3su8EDPRds', 0,
 'Plot y = x',
 '<p>To plot a curve <code>y = f(x)</code>, compute the vertical distance from every pixel to the curve, then draw a thin band wherever that distance is small. Start with the simplest curve, <code>y = x</code>.</p><p>Reference: <a href="https://thebookofshaders.com/05/" target="_blank" rel="noreferrer">Book of Shaders — Shaping functions (plot section)</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: d = abs(uv.y - uv.x); m = 1.0 - smoothstep(0.005, 0.015, d);
    float m = 0.0;
    gl_FragColor = vec4(vec3(m), 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float d = abs(uv.y - uv.x);
    float m = 1.0 - smoothstep(0.005, 0.015, d);
    gl_FragColor = vec4(vec3(m), 1.0);
}'),

('c0000005-0002-0000-0000-000000000000', 'c0000005-0000-0000-0000-000000000000', 'w60pXClCffU', 1,
 'Plot y = sin(x)',
 '<p>Same plot recipe, swap in a sine. Remap <code>uv</code> to <code>[-1, 1]</code> first so the curve sits centered, then scale the argument to fit one period across the canvas.</p><p>Reference: <a href="https://thebookofshaders.com/05/" target="_blank" rel="noreferrer">Book of Shaders — Shaping functions (plot section)</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 2.0 - 1.0;
    // TODO: y = 0.5 * sin(uv.x * 6.28318); d = abs(uv.y - y); m = 1.0 - smoothstep(0.01, 0.03, d);
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

('c0000005-0003-0000-0000-000000000000', 'c0000005-0000-0000-0000-000000000000', 'A97U3mk9yUE', 2,
 'Curve thickness',
 '<p>The smoothstep edges <code>(a, b)</code> control how thick and how soft the plotted curve is. Widen the band to draw a chunkier cosine plot.</p><p>Reference: <a href="https://iquilezles.org/articles/smoothsteps/" target="_blank" rel="noreferrer">IQ — Smoothsteps</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 2.0 - 1.0;
    // TODO: y = 0.5 * cos(uv.x * 3.14159); m = 1.0 - smoothstep(0.05, 0.08, abs(uv.y - y));
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

('c0000005-0004-0000-0000-000000000000', 'c0000005-0000-0000-0000-000000000000', 'J57FduwRbQ8', 3,
 'Animated phase',
 '<p>Add <code>u_time</code> to the sine argument and the curve scrolls. The plot recipe is unchanged — only the input function moves.</p><p>Reference: <a href="https://thebookofshaders.com/05/" target="_blank" rel="noreferrer">Book of Shaders — Shaping functions</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 2.0 - 1.0;
    // TODO: y = 0.5 * sin(uv.x * 6.28318 + u_time);
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
}');
