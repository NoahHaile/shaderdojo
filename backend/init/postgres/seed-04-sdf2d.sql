\c shader_dojo;

-- Family C — 2D distance fields (4 courses, 16 lessons)

INSERT INTO lesson (course_id, slug, display_order, title, description, starter_fragment_shader, canonical_fragment_shader) VALUES

-- ===== Course: sdf-2d-primitives =====
((SELECT id FROM course WHERE slug = 'sdf-2d-primitives'), 'JzbSl6hZIn0', 0,
 'Circle SDF',
 '<p>A 2D signed distance field returns, at every point, the signed distance to the nearest edge of a shape — negative inside, positive outside. For a circle of radius <code>r</code> centered at the origin, the SDF is simply <code>length(p) - r</code>.</p><p>Build an aspect-corrected position, compute the circle distance, then fill where <code>d &lt; 0</code> using <code>step</code>.</p><p>Reference: <a href="https://iquilezles.org/articles/distfunctions2d/" target="_blank" rel="noreferrer">IQ — 2D distance functions</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d = length(p) - 0.3;
    // TODO: m = 1.0 - step(0.0, d);  then mix bg and fg by m.
    vec3 c = vec3(0.10, 0.15, 0.35);
    gl_FragColor = vec4(c, 1.0);
}',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d = length(p) - 0.3;
    float m = 1.0 - step(0.0, d);
    vec3 c = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(c, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'sdf-2d-primitives'), 'yVz-hRs9GSw', 1,
 'Box SDF',
 '<p>The axis-aligned box SDF folds the point into the first quadrant with <code>abs(p)</code>, subtracts the half-extents, and combines the outside and inside cases: <code>length(max(d, 0.0)) + min(max(d.x, d.y), 0.0)</code>.</p><p>Fill the interior of a box with half-size <code>(0.3, 0.2)</code>.</p><p>Reference: <a href="https://iquilezles.org/articles/distfunctions2d/" target="_blank" rel="noreferrer">IQ — 2D distance functions</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec2 d = abs(p) - vec2(0.3, 0.2);
    // TODO: dist = length(max(d, 0.0)) + min(max(d.x, d.y), 0.0); fill where dist < 0.
    vec3 c = vec3(0.10, 0.15, 0.35);
    gl_FragColor = vec4(c, 1.0);
}',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec2 d = abs(p) - vec2(0.3, 0.2);
    float dist = length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
    float m = 1.0 - step(0.0, dist);
    vec3 c = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(c, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'sdf-2d-primitives'), '0D--l4GMMvc', 2,
 'Segment SDF',
 '<p>Distance from a point <code>p</code> to a segment <code>ab</code> is the length of the perpendicular drop, clamped to the segment endpoints: project <code>p - a</code> onto <code>b - a</code>, clamp the parameter to <code>[0, 1]</code>, then measure.</p><p>Draw the segment between <code>(-0.4, -0.3)</code> and <code>(0.4, 0.3)</code> with a smoothstep edge of width <code>0.03</code>.</p><p>Reference: <a href="https://iquilezles.org/articles/distfunctions2d/" target="_blank" rel="noreferrer">IQ — 2D distance functions</a>.</p>',
 'float sdSegment(vec2 p, vec2 a, vec2 b) {
    vec2 pa = p - a;
    vec2 ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h);
}
void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d = sdSegment(p, vec2(-0.4, -0.3), vec2(0.4, 0.3));
    // TODO: m = 1.0 - smoothstep(0.0, 0.03, d); mix bg and fg by m.
    vec3 c = vec3(0.10, 0.15, 0.35);
    gl_FragColor = vec4(c, 1.0);
}',
 'float sdSegment(vec2 p, vec2 a, vec2 b) {
    vec2 pa = p - a;
    vec2 ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h);
}
void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d = sdSegment(p, vec2(-0.4, -0.3), vec2(0.4, 0.3));
    float m = 1.0 - smoothstep(0.0, 0.03, d);
    vec3 c = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(c, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'sdf-2d-primitives'), 'zLNN7LoEyh8', 3,
 'Inside/outside color',
 '<p>Because an SDF is signed, the sign alone tells you which side of the shape a pixel is on. Use <code>sign(d)</code> with <code>step</code> to flip between two colors: warm inside, cool outside.</p><p>Reference: <a href="https://thebookofshaders.com/07/" target="_blank" rel="noreferrer">Book of Shaders — Shapes</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d = length(p) - 0.3;
    // TODO: m = step(sign(d), 0.0);  // 1 when sign(d) < 0, 0 otherwise. mix bg/fg by m.
    vec3 c = vec3(0.10, 0.15, 0.35);
    gl_FragColor = vec4(c, 1.0);
}',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d = length(p) - 0.3;
    float m = step(sign(d), 0.0);
    vec3 c = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(c, 1.0);
}'),

-- ===== Course: sdf-booleans =====
((SELECT id FROM course WHERE slug = 'sdf-booleans'), '7V63dWypRrA', 0,
 'Union (min)',
 '<p>The union of two SDFs is the pointwise minimum: a pixel is inside the union if it is inside either shape. Combine two circles into one connected region.</p><p>Reference: <a href="https://iquilezles.org/articles/distfunctions2d/" target="_blank" rel="noreferrer">IQ — 2D distance functions</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d1 = length(p - vec2(-0.2, 0.0)) - 0.25;
    float d2 = length(p - vec2( 0.2, 0.0)) - 0.25;
    // TODO: d = min(d1, d2); fill where d < 0.
    float d = d1;
    float m = 1.0 - step(0.0, d);
    vec3 c = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(c, 1.0);
}',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d1 = length(p - vec2(-0.2, 0.0)) - 0.25;
    float d2 = length(p - vec2( 0.2, 0.0)) - 0.25;
    float d = min(d1, d2);
    float m = 1.0 - step(0.0, d);
    vec3 c = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(c, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'sdf-booleans'), 'Q7M7KLKlWzg', 1,
 'Intersection (max)',
 '<p>The intersection of two SDFs is the pointwise maximum: a pixel is inside only when it is inside both shapes. With two overlapping circles you get the lens-shaped overlap.</p><p>Reference: <a href="https://iquilezles.org/articles/distfunctions2d/" target="_blank" rel="noreferrer">IQ — 2D distance functions</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d1 = length(p - vec2(-0.2, 0.0)) - 0.25;
    float d2 = length(p - vec2( 0.2, 0.0)) - 0.25;
    // TODO: d = max(d1, d2); fill where d < 0.
    float d = d1;
    float m = 1.0 - step(0.0, d);
    vec3 c = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(c, 1.0);
}',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d1 = length(p - vec2(-0.2, 0.0)) - 0.25;
    float d2 = length(p - vec2( 0.2, 0.0)) - 0.25;
    float d = max(d1, d2);
    float m = 1.0 - step(0.0, d);
    vec3 c = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(c, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'sdf-booleans'), 'aijhF2MIni0', 2,
 'Subtraction',
 '<p>Subtraction of <code>B</code> from <code>A</code> is <code>max(A, -B)</code> — keep everything inside <code>A</code>, but punch out the region inside <code>B</code>. Carve a small circle out of a larger one.</p><p>Reference: <a href="https://iquilezles.org/articles/distfunctions2d/" target="_blank" rel="noreferrer">IQ — 2D distance functions</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float large = length(p) - 0.4;
    float small = length(p - vec2(0.15, 0.0)) - 0.25;
    // TODO: d = max(large, -small); fill where d < 0.
    float d = large;
    float m = 1.0 - step(0.0, d);
    vec3 c = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(c, 1.0);
}',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float large = length(p) - 0.4;
    float small = length(p - vec2(0.15, 0.0)) - 0.25;
    float d = max(large, -small);
    float m = 1.0 - step(0.0, d);
    vec3 c = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(c, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'sdf-booleans'), 'n1n-VAcZRq8', 3,
 'Annulus',
 '<p>An annulus (ring) is a disc minus a smaller concentric disc — exactly the subtraction pattern, with both circles at the same center. Same recipe, different radii.</p><p>Reference: <a href="https://mercury.sexy/hg_sdf/" target="_blank" rel="noreferrer">hg_sdf — distance field operations</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float outer = length(p) - 0.4;
    float inner = length(p) - 0.3;
    // TODO: d = max(outer, -inner); fill where d < 0.
    float d = outer;
    float m = 1.0 - step(0.0, d);
    vec3 c = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(c, 1.0);
}',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float outer = length(p) - 0.4;
    float inner = length(p) - 0.3;
    float d = max(outer, -inner);
    float m = 1.0 - step(0.0, d);
    vec3 c = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(c, 1.0);
}'),

-- ===== Course: smooth-min =====
((SELECT id FROM course WHERE slug = 'smooth-min'), 'lyoV6wQmTbc', 0,
 'Two-circle smin blob',
 '<p>The hard <code>min</code> of two SDFs creates a kink where the shapes meet. Inigo Quilez''s smooth minimum (<code>smin</code>) blends the union with a small parameter <code>k</code> that controls the merge radius — perfect for organic, blobby joins.</p><p>Use <code>smin(d1, d2, 0.1)</code> on two circles and fill where the result is negative.</p><p>Reference: <a href="https://iquilezles.org/articles/smin/" target="_blank" rel="noreferrer">IQ — Smooth minimum</a>.</p>',
 'float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5*(b-a)/k, 0.0, 1.0);
    return mix(b, a, h) - k*h*(1.0-h);
}
void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d1 = length(p - vec2(-0.18, 0.0)) - 0.2;
    float d2 = length(p - vec2( 0.18, 0.0)) - 0.2;
    // TODO: d = smin(d1, d2, 0.1); fill where d < 0.
    float d = min(d1, d2);
    float m = 1.0 - step(0.0, d);
    vec3 c = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(c, 1.0);
}',
 'float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5*(b-a)/k, 0.0, 1.0);
    return mix(b, a, h) - k*h*(1.0-h);
}
void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d1 = length(p - vec2(-0.18, 0.0)) - 0.2;
    float d2 = length(p - vec2( 0.18, 0.0)) - 0.2;
    float d = smin(d1, d2, 0.1);
    float m = 1.0 - step(0.0, d);
    vec3 c = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(c, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'smooth-min'), 'qNvmKsPb46w', 1,
 'Tune k parameter',
 '<p>The <code>k</code> in <code>smin</code> is the merge radius. With circles that no longer overlap, a larger <code>k</code> still pulls them together through a smooth bridge. Try <code>k = 0.2</code> on two circles spaced apart and watch the connecting "neck" appear.</p><p>Reference: <a href="https://iquilezles.org/articles/smin/" target="_blank" rel="noreferrer">IQ — Smooth minimum</a>.</p>',
 'float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5*(b-a)/k, 0.0, 1.0);
    return mix(b, a, h) - k*h*(1.0-h);
}
void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d1 = length(p - vec2(-0.25, 0.0)) - 0.2;
    float d2 = length(p - vec2( 0.25, 0.0)) - 0.2;
    // TODO: d = smin(d1, d2, 0.2); fill where d < 0.
    float d = min(d1, d2);
    float m = 1.0 - step(0.0, d);
    vec3 c = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(c, 1.0);
}',
 'float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5*(b-a)/k, 0.0, 1.0);
    return mix(b, a, h) - k*h*(1.0-h);
}
void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d1 = length(p - vec2(-0.25, 0.0)) - 0.2;
    float d2 = length(p - vec2( 0.25, 0.0)) - 0.2;
    float d = smin(d1, d2, 0.2);
    float m = 1.0 - step(0.0, d);
    vec3 c = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(c, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'smooth-min'), 'xICP11ymFw4', 2,
 'Smin chain (3 circles)',
 '<p><code>smin</code> chains: <code>smin(smin(a, b, k), c, k)</code> blends three SDFs in sequence. Three circles arranged in a triangle become a smooth tri-lobed blob.</p><p>Reference: <a href="https://iquilezles.org/articles/smin/" target="_blank" rel="noreferrer">IQ — Smooth minimum</a>.</p>',
 'float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5*(b-a)/k, 0.0, 1.0);
    return mix(b, a, h) - k*h*(1.0-h);
}
void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d1 = length(p - vec2(-0.3, 0.0)) - 0.18;
    float d2 = length(p - vec2( 0.0, 0.15)) - 0.18;
    float d3 = length(p - vec2( 0.3, 0.0)) - 0.18;
    // TODO: d = smin(smin(d1, d2, 0.12), d3, 0.12); fill where d < 0.
    float d = min(min(d1, d2), d3);
    float m = 1.0 - step(0.0, d);
    vec3 c = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(c, 1.0);
}',
 'float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5*(b-a)/k, 0.0, 1.0);
    return mix(b, a, h) - k*h*(1.0-h);
}
void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d1 = length(p - vec2(-0.3, 0.0)) - 0.18;
    float d2 = length(p - vec2( 0.0, 0.15)) - 0.18;
    float d3 = length(p - vec2( 0.3, 0.0)) - 0.18;
    float d = smin(smin(d1, d2, 0.12), d3, 0.12);
    float m = 1.0 - step(0.0, d);
    vec3 c = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(c, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'smooth-min'), 'F3GWrhv1Ex4', 3,
 'Smin circle + box',
 '<p>The smooth minimum doesn''t care what kind of SDFs it merges. Blend a circle with a box and the join is just as smooth as two circles — the merge radius <code>k</code> is what matters.</p><p>Reference: <a href="https://iquilezles.org/articles/smin/" target="_blank" rel="noreferrer">IQ — Smooth minimum</a>.</p>',
 'float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5*(b-a)/k, 0.0, 1.0);
    return mix(b, a, h) - k*h*(1.0-h);
}
float sdBox(vec2 p, vec2 b) {
    vec2 d = abs(p) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}
void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float dc = length(p - vec2(-0.15, 0.0)) - 0.2;
    float db = sdBox(p - vec2(0.15, 0.0), vec2(0.18, 0.15));
    // TODO: d = smin(dc, db, 0.1); fill where d < 0.
    float d = min(dc, db);
    float m = 1.0 - step(0.0, d);
    vec3 c = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(c, 1.0);
}',
 'float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5*(b-a)/k, 0.0, 1.0);
    return mix(b, a, h) - k*h*(1.0-h);
}
float sdBox(vec2 p, vec2 b) {
    vec2 d = abs(p) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}
void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float dc = length(p - vec2(-0.15, 0.0)) - 0.2;
    float db = sdBox(p - vec2(0.15, 0.0), vec2(0.18, 0.15));
    float d = smin(dc, db, 0.1);
    float m = 1.0 - step(0.0, d);
    vec3 c = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(c, 1.0);
}'),

-- ===== Course: sdf-antialiasing =====
((SELECT id FROM course WHERE slug = 'sdf-antialiasing'), 'ktiILxFLfgo', 0,
 'smoothstep AA',
 '<p>A raw <code>step(0.0, d)</code> mask gives a jagged staircase along the edge of an SDF. <code>smoothstep</code> with a small range around zero gives one or two pixels of soft transition — much easier on the eyes.</p><p>Note the argument order: <code>smoothstep(0.005, -0.005, d)</code> ramps from 1 inside to 0 outside.</p><p>Reference: <a href="https://iquilezles.org/articles/distance/" target="_blank" rel="noreferrer">IQ — Distance functions</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d = length(p) - 0.3;
    // TODO: m = smoothstep(0.005, -0.005, d);
    float m = 1.0 - step(0.0, d);
    vec3 c = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(c, 1.0);
}',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d = length(p) - 0.3;
    float m = smoothstep(0.005, -0.005, d);
    vec3 c = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(c, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'sdf-antialiasing'), 'A5hFLYmvSI8', 1,
 'fwidth pixel-width AA',
 '<p>A fixed-width smoothstep band looks different at different resolutions. <code>fwidth(d)</code> measures how fast the SDF changes across one pixel, so using it as the smoothstep width gives a resolution-independent edge that stays exactly one pixel wide.</p><p>Reference: <a href="https://iquilezles.org/articles/filterableprocedurals/" target="_blank" rel="noreferrer">IQ — Filterable procedurals</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d = length(p) - 0.3;
    // TODO: w = fwidth(d); m = smoothstep(w, -w, d);
    float m = 1.0 - step(0.0, d);
    vec3 c = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(c, 1.0);
}',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d = length(p) - 0.3;
    float w = fwidth(d);
    float m = smoothstep(w, -w, d);
    vec3 c = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(c, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'sdf-antialiasing'), '2w-7co6sg70', 2,
 'Outlined ring',
 '<p>To draw just the outline of an SDF shape, take <code>abs(d)</code> — distance from the edge regardless of side — and threshold it. Combined with <code>fwidth</code>-based AA, it produces a crisp hollow ring.</p><p>Reference: <a href="https://iquilezles.org/articles/distance/" target="_blank" rel="noreferrer">IQ — Distance functions</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d = length(p) - 0.3;
    float e = abs(d) - 0.01;
    // TODO: w = fwidth(e); m = smoothstep(w, -w, e);
    float m = 0.0;
    vec3 c = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(c, 1.0);
}',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d = length(p) - 0.3;
    float e = abs(d) - 0.01;
    float w = fwidth(e);
    float m = smoothstep(w, -w, e);
    vec3 c = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(c, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'sdf-antialiasing'), 'bbAtaXDM5eM', 3,
 'Filled shape with stroke',
 '<p>Combine a filled interior with an outline: compute a fill mask from <code>d</code> and a stroke mask from <code>abs(d) - halfWidth</code>, then take the <code>max</code> of the two so the stroke sits on top.</p><p>Reference: <a href="https://iquilezles.org/articles/distance/" target="_blank" rel="noreferrer">IQ — Distance functions</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec2 q = abs(p) - vec2(0.3, 0.2);
    float d = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0);
    float w = fwidth(d);
    float fill = smoothstep(w, -w, d);
    float stroke = smoothstep(w, -w, abs(d) - 0.01);
    // TODO: m = max(fill, stroke);
    float m = fill;
    vec3 c = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(c, 1.0);
}',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec2 q = abs(p) - vec2(0.3, 0.2);
    float d = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0);
    float w = fwidth(d);
    float fill = smoothstep(w, -w, d);
    float stroke = smoothstep(w, -w, abs(d) - 0.01);
    float m = max(fill, stroke);
    vec3 c = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(c, 1.0);
}');
