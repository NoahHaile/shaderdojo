\c shader_dojo;

-- Family C — 2D distance fields (4 courses, 16 lessons)
-- Code style: the description teaches. The starter is a near-empty shader or
-- the prior lesson's canonical. The canonical is the full working answer. No
-- didactic comments inside the code — the learner writes meaningful lines from
-- the recipe in the description.

INSERT INTO lesson (course_id, slug, display_order, title, description, starter_fragment_shader, canonical_fragment_shader) VALUES

-- ===== Course: sdf-2d-primitives =====
((SELECT id FROM course WHERE slug = 'sdf-2d-primitives'), 'JzbSl6hZIn0', 0,
 'Circle SDF',
 '<p>An SDF is a function. You give it a point. It tells you the distance to the nearest edge of a shape. The number is negative inside the shape and positive outside.</p><p>For a circle of radius <code>r</code> at the center, the SDF is <code>length(p) - r</code>. It is 0 on the edge. It is negative inside. It is positive outside.</p><p>Now fill the inside. <code>step(0.0, d)</code> gives 1 outside and 0 inside. Flip it with <code>1.0 - step(0.0, d)</code>. Then <code>mix(bg, fg, m)</code> paints the inside with <code>fg</code> on top of <code>bg</code>.</p><p>Reference: <a href="https://iquilezles.org/articles/distfunctions2d/" target="_blank" rel="noreferrer">IQ — 2D distance functions</a>.</p>',
 'void main() {
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
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
 '<p>A box needs two parts. Outside the box, the distance is how far past the nearest side you are. Inside the box, the distance is how deep in you are. The formula adds both parts.</p><p>Given half-sizes <code>b</code>, first do <code>vec2 d = abs(p) - b</code>. This folds <code>p</code> into one corner and subtracts the half-size. A negative number means you are inside on that axis.</p><p>The outside part is <code>length(max(d, 0.0))</code>. Only positive parts count. The inside part is <code>min(max(d.x, d.y), 0.0)</code>. It only fires when both axes are inside. Add them. Fill the inside like you did for the circle.</p><p>Reference: <a href="https://iquilezles.org/articles/distfunctions2d/" target="_blank" rel="noreferrer">IQ — 2D distance functions</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d = length(p) - 0.3;
    float m = 1.0 - step(0.0, d);
    vec3 c = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
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
 '<p>A line segment has two ends. You want the distance from a point <code>p</code> to the segment from <code>a</code> to <code>b</code>. This is the building block for lines, arrows, and strokes.</p><p>First take <code>pa = p - a</code> and <code>ba = b - a</code>. Then find <code>h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0)</code>. That projects <code>p</code> onto the line and keeps it between the two ends. Return <code>length(pa - ba * h)</code>. That is the distance from <code>p</code> to the closest point on the segment.</p><p>A segment has no inside. The distance is always positive or zero. Draw it as a stroke with a smoothstep band of width <code>0.03</code>.</p><p>Reference: <a href="https://iquilezles.org/articles/distfunctions2d/" target="_blank" rel="noreferrer">IQ — 2D distance functions</a>.</p>',
 'float sdSegment(vec2 p, vec2 a, vec2 b) {
    vec2 pa = p - a;
    vec2 ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h);
}
void main() {
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
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
 '<p>You can color the inside and outside of a shape using just the sign of the SDF. You do not need the full distance.</p><p><code>sign(d)</code> returns <code>-1</code> inside, <code>+1</code> outside, and <code>0</code> on the edge. Then <code>step(sign(d), 0.0)</code> gives 1 when the sign is less than or equal to 0. That is your inside mask.</p><p>You will use the same circle of radius 0.3 and the same colors. The sign alone tells you which side you are on.</p><p>Reference: <a href="https://thebookofshaders.com/07/" target="_blank" rel="noreferrer">Book of Shaders — Shapes</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d = length(p) - 0.3;
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
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
 '<p>You can join two shapes into one. A point is inside the union if it is inside either shape. The rule is <code>min(d1, d2)</code>. If either distance is negative, the min is negative, so that pixel is filled.</p><p>Place two circles 0.2 units left and right of the center. Find each SDF. Then take <code>d = min(d1, d2)</code> and fill where <code>d &lt; 0</code>.</p><p>The two circles will look like one peanut shape.</p><p>Reference: <a href="https://iquilezles.org/articles/distfunctions2d/" target="_blank" rel="noreferrer">IQ — 2D distance functions</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d1 = length(p - vec2(-0.2, 0.0)) - 0.25;
    float d2 = length(p - vec2( 0.2, 0.0)) - 0.25;
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
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
 '<p>You can keep only the part where two shapes overlap. A point is inside the intersection only if it is inside both shapes. The rule is <code>max(d1, d2)</code>.</p><p>If either SDF is positive, the max is positive. So a pixel is only inside when both distances are negative.</p><p>Use the same two circles as before. You will see a lens shape where they overlap.</p><p>Reference: <a href="https://iquilezles.org/articles/distfunctions2d/" target="_blank" rel="noreferrer">IQ — 2D distance functions</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d1 = length(p - vec2(-0.2, 0.0)) - 0.25;
    float d2 = length(p - vec2( 0.2, 0.0)) - 0.25;
    float d = min(d1, d2);
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
 '<p>You can punch one shape out of another. A point is inside the result if it is inside <code>A</code> but outside <code>B</code>. The rule is <code>max(A, -B)</code>.</p><p>Multiplying an SDF by <code>-1</code> flips inside and outside. So <code>-B</code> is the shape that fills everything except <code>B</code>. Then you intersect that with <code>A</code>.</p><p>Place a big circle of radius 0.4 at the center and a small circle of radius 0.25 to the right. Take <code>d = max(large, -small)</code>. You will see a crescent moon.</p><p>Reference: <a href="https://iquilezles.org/articles/distfunctions2d/" target="_blank" rel="noreferrer">IQ — 2D distance functions</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float large = length(p) - 0.4;
    float small = length(p - vec2(0.15, 0.0)) - 0.25;
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
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
 '<p>You can make a ring with the same subtraction rule. Put both circles at the center. The outer one has radius 0.4. The inner one has radius 0.3.</p><p>Take <code>d = max(outer, -inner)</code>. You get everything inside the big circle but outside the small one. The result is a ring 0.1 units wide.</p><p>The formula is the same as the last lesson. Only the positions changed.</p><p>Reference: <a href="https://mercury.sexy/hg_sdf/" target="_blank" rel="noreferrer">hg_sdf — distance field operations</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float large = length(p) - 0.4;
    float small = length(p - vec2(0.15, 0.0)) - 0.25;
    float d = max(large, -small);
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
 '<p><code>min(d1, d2)</code> makes a hard kink where two shapes meet. <code>smin</code> is a smooth min. It acts like <code>min</code> when the two distances are far apart. It blends them softly when they get close.</p><p>The starter ships the 4-line smin from Iñigo Quilez. The <code>k</code> parameter sets the blend width. A bigger <code>k</code> means a wider, more merged blend. <code>k = 0.1</code> is gentle.</p><p>Use the same two circles as the union lesson. Just swap <code>min</code> for <code>smin(d1, d2, 0.1)</code>. The two circles will look like one blob.</p><p>Reference: <a href="https://iquilezles.org/articles/smin/" target="_blank" rel="noreferrer">IQ — Smooth minimum</a>.</p>',
 'float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5*(b-a)/k, 0.0, 1.0);
    return mix(b, a, h) - k*h*(1.0-h);
}
void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d1 = length(p - vec2(-0.18, 0.0)) - 0.2;
    float d2 = length(p - vec2( 0.18, 0.0)) - 0.2;
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
 '<p>You can pull two shapes together even when they do not touch. Place two circles 0.5 units apart. With plain <code>min</code> they stay apart.</p><p>Use <code>smin(d1, d2, 0.2)</code>. The bigger <code>k</code> reaches across the gap and grows a smooth bridge between them. The result looks like a dumbbell.</p><p>Think about other <code>k</code> values. At <code>k = 0.05</code> the bridge would not reach. At <code>k = 0.5</code> the shape would flatten out. For this spacing, <code>0.2</code> is just right.</p><p>Reference: <a href="https://iquilezles.org/articles/smin/" target="_blank" rel="noreferrer">IQ — Smooth minimum</a>.</p>',
 'float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5*(b-a)/k, 0.0, 1.0);
    return mix(b, a, h) - k*h*(1.0-h);
}
void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d1 = length(p - vec2(-0.25, 0.0)) - 0.2;
    float d2 = length(p - vec2( 0.25, 0.0)) - 0.2;
    float d = smin(d1, d2, 0.1);
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
 '<p>You can merge more than two shapes by nesting <code>smin</code> calls. Place three circles in a small triangle. Find their SDFs as <code>d1</code>, <code>d2</code>, and <code>d3</code>.</p><p>Combine them with <code>smin(smin(d1, d2, 0.12), d3, 0.12)</code>. The order of merges does not change the look.</p><p>You will see three lobes pulled into one blob, like a thick clover.</p><p>Reference: <a href="https://iquilezles.org/articles/smin/" target="_blank" rel="noreferrer">IQ — Smooth minimum</a>.</p>',
 'float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5*(b-a)/k, 0.0, 1.0);
    return mix(b, a, h) - k*h*(1.0-h);
}
void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d1 = length(p - vec2(-0.3, 0.0)) - 0.18;
    float d2 = length(p - vec2( 0.0, 0.15)) - 0.18;
    float d3 = length(p - vec2( 0.3, 0.0)) - 0.18;
    float d = smin(d1, d2, 0.12);
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
 '<p><code>smin</code> does not care what shapes you merge. It only looks at the distances. Put a circle on the left and a box on the right.</p><p>The starter ships an <code>sdBox</code> helper. It uses the same formula as the box lesson. Combine the two shapes with <code>smin(dc, db, 0.1)</code>.</p><p>The merge looks just as smooth as it did with two circles.</p><p>Reference: <a href="https://iquilezles.org/articles/smin/" target="_blank" rel="noreferrer">IQ — Smooth minimum</a>.</p>',
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
 '<p><code>step(0.0, d)</code> gives a hard, jagged edge. You can soften it with <code>smoothstep</code>.</p><p>Use a small range around zero: <code>smoothstep(0.005, -0.005, d)</code>. As <code>d</code> moves from <code>+0.005</code> down to <code>-0.005</code>, the value ramps from 0 to 1. So you get 0 outside, 1 inside, and a soft band a pixel or two wide at the edge.</p><p>Note the argument order. A bigger first edge and a smaller second edge flips the ramp. You want 1 inside, where <code>d</code> is negative, so the edges are flipped.</p><p>Reference: <a href="https://iquilezles.org/articles/distance/" target="_blank" rel="noreferrer">IQ — Distance functions</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d = length(p) - 0.3;
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
 '<p>You want the soft edge to be one pixel wide every time. The last lesson hard-coded <code>0.005</code>. That looks good at one size, blurry at 4K, and jagged at small sizes.</p><p><code>fwidth(d)</code> measures how fast <code>d</code> changes between this pixel and its neighbors. In plain words, it tells you how many world units one pixel covers. Use that as the smoothstep width and the edge stays one pixel wide at any size.</p><p>The recipe is two lines: <code>w = fwidth(d); m = smoothstep(w, -w, d);</code>.</p><p>Reference: <a href="https://iquilezles.org/articles/filterableprocedurals/" target="_blank" rel="noreferrer">IQ — Filterable procedurals</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d = length(p) - 0.3;
    float m = smoothstep(0.005, -0.005, d);
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
 '<p>You can draw just the outline of a shape with no fill. <code>abs(d)</code> is the distance from the edge with no sign. Pixels near the edge have a small <code>abs(d)</code>. Pixels far away have a big one.</p><p>Take <code>e = abs(d) - 0.01</code>. That makes a new SDF for a thin wall around the edge. Its inside is the band you want to draw.</p><p>Now use the same fwidth AA from the last lesson on <code>e</code>. <code>w = fwidth(e); m = smoothstep(w, -w, e);</code>.</p><p>Reference: <a href="https://iquilezles.org/articles/distance/" target="_blank" rel="noreferrer">IQ — Distance functions</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d = length(p) - 0.3;
    float w = fwidth(d);
    float m = smoothstep(w, -w, d);
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
 '<p>You can draw a fill and a stroke in one image. Start with a box SDF <code>d</code> and a pixel width <code>w = fwidth(d)</code>.</p><p>Build two masks. <code>fill = smoothstep(w, -w, d)</code> is the inside of the box. <code>stroke = smoothstep(w, -w, abs(d) - 0.01)</code> is a thin band around the edge.</p><p>Combine them with <code>m = max(fill, stroke)</code>. Wherever either mask is on, you draw the foreground color. This is the building block for UI elements in a shader.</p><p>Reference: <a href="https://iquilezles.org/articles/distance/" target="_blank" rel="noreferrer">IQ — Distance functions</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec2 q = abs(p) - vec2(0.3, 0.2);
    float d = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0);
    float w = fwidth(d);
    float fill = smoothstep(w, -w, d);
    vec3 c = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), fill);
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
