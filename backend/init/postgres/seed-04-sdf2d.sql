\c shader_dojo;

-- Family C — 2D distance fields (4 courses, 16 lessons)
-- Same lecture-style rules: explicit recipes, hand-holding TODOs, "what you'll see".

INSERT INTO lesson (course_id, slug, display_order, title, description, starter_fragment_shader, canonical_fragment_shader) VALUES

-- ===== Course: sdf-2d-primitives =====
((SELECT id FROM course WHERE slug = 'sdf-2d-primitives'), 'JzbSl6hZIn0', 0,
 'Circle SDF',
 '<p><strong>Goal.</strong> Meet the signed distance field (SDF) — the most powerful idea in this entire curriculum.</p><p><strong>What an SDF is.</strong> A function that, given a point, returns:</p><ul><li><strong>How far</strong> the point is from a shape''s edge.</li><li><strong>Which side</strong>: negative if inside, positive if outside.</li></ul><p><strong>Circle SDF.</strong> The distance from <code>p</code> to a circle of radius <code>r</code> at the origin is just <code>length(p) - r</code>. At the circle''s edge it''s 0; inside it''s negative; outside it''s positive.</p><p><strong>Filling the inside.</strong> <code>step(0.0, d)</code> is 1 outside, 0 inside. <code>1.0 - step(0.0, d)</code> flips that — 1 inside, 0 outside. <code>mix(bg, fg, m)</code> paints the inside <code>fg</code> on a <code>bg</code> backdrop.</p><p>Reference: <a href="https://iquilezles.org/articles/distfunctions2d/" target="_blank" rel="noreferrer">IQ — 2D distance functions</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d = length(p) - 0.3;
    // TODO: fill where d < 0.
    // float m = 1.0 - step(0.0, d);
    // vec3 c = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
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
 '<p><strong>Goal.</strong> The standard axis-aligned box SDF — uglier formula than the circle, but instructive.</p><p><strong>Why it''s a two-part formula.</strong> A circle has one piece (distance from center). A box has two cases: outside the box, distance is "how far past the nearest face"; inside, distance is "how deep in." The formula combines them.</p><p><strong>The formula.</strong> Given half-extents <code>b</code>:</p><ol><li><code>vec2 d = abs(p) - b</code> — fold <code>p</code> into the first quadrant, subtract half-size. Negative components mean "inside on this axis."</li><li><strong>Outside part:</strong> <code>length(max(d, 0.0))</code> — only the positive components contribute; this is the Euclidean distance to the nearest face if you''re outside.</li><li><strong>Inside part:</strong> <code>min(max(d.x, d.y), 0.0)</code> — only fires when both <code>d.x</code> and <code>d.y</code> are negative; gives a negative depth-inside value.</li></ol><p>Sum them. Fill the inside the same way as the circle.</p><p>Reference: <a href="https://iquilezles.org/articles/distfunctions2d/" target="_blank" rel="noreferrer">IQ — 2D distance functions</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec2 d = abs(p) - vec2(0.3, 0.2);
    // TODO: combine outside + inside parts; fill where dist < 0.
    // float dist = length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
    // float m = 1.0 - step(0.0, dist);
    // vec3 c = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
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
 '<p><strong>Goal.</strong> Distance from a point to a line segment — the building block for every line, arrow, and stroke.</p><p><strong>The recipe.</strong> Given a segment from <code>a</code> to <code>b</code> and query point <code>p</code>:</p><ol><li><code>pa = p - a</code> (point relative to start).</li><li><code>ba = b - a</code> (segment direction).</li><li><code>h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0)</code> — project <code>pa</code> onto <code>ba</code>, clamp to <code>[0, 1]</code> so we stay on the segment.</li><li>Return <code>length(pa - ba * h)</code> — the perpendicular distance from <code>p</code> to the closest point on the segment.</li></ol><p>Unlike the closed shapes above, a segment has no "inside" — distance is always positive. Draw the stroke with a smoothstep band of width <code>0.03</code>.</p><p>Reference: <a href="https://iquilezles.org/articles/distfunctions2d/" target="_blank" rel="noreferrer">IQ — 2D distance functions</a>.</p>',
 'float sdSegment(vec2 p, vec2 a, vec2 b) {
    vec2 pa = p - a;
    vec2 ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h);
}
void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d = sdSegment(p, vec2(-0.4, -0.3), vec2(0.4, 0.3));
    // TODO: stroke = 1.0 - smoothstep(0.0, 0.03, d); mix bg/fg.
    // float m = 1.0 - smoothstep(0.0, 0.03, d);
    // vec3 c = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
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
 '<p><strong>Goal.</strong> Use the <em>sign</em> of the SDF (not just its magnitude) to color the two sides of a shape differently.</p><p><strong>The trick.</strong> <code>sign(d)</code> returns <code>-1</code> inside, <code>+1</code> outside, <code>0</code> exactly on the edge. <code>step(sign(d), 0.0)</code> returns <code>1</code> when <code>sign(d) ≤ 0</code> (inside) and <code>0</code> otherwise. That''s your fill mask — and you didn''t need the absolute distance at all.</p><p>Same circle of radius 0.3, same color palette. The point is: the sign carries everything you need to know about "which side."</p><p>Reference: <a href="https://thebookofshaders.com/07/" target="_blank" rel="noreferrer">Book of Shaders — Shapes</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d = length(p) - 0.3;
    // TODO: fill mask from sign.
    // float m = step(sign(d), 0.0);
    // vec3 c = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
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
 '<p><strong>Goal.</strong> Combine two SDFs into one shape.</p><p><strong>The rule.</strong> The union of two shapes — "inside if inside either" — is the pointwise <code>min</code> of their SDFs. If either distance is negative, the min is negative, so the union is filled there.</p><p><strong>The recipe.</strong> Two circles offset left and right by 0.2 from the center. Compute each SDF; <code>d = min(d1, d2)</code>; fill where <code>d &lt; 0</code>. The two circles read as one peanut-shaped region.</p><p>Reference: <a href="https://iquilezles.org/articles/distfunctions2d/" target="_blank" rel="noreferrer">IQ — 2D distance functions</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d1 = length(p - vec2(-0.2, 0.0)) - 0.25;
    float d2 = length(p - vec2( 0.2, 0.0)) - 0.25;
    // TODO: union = min(d1, d2).
    // float d = min(d1, d2);
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
 '<p><strong>Goal.</strong> Keep only the overlap.</p><p><strong>The rule.</strong> "Inside only if inside both" is the pointwise <code>max</code>. A pixel''s distance to the intersection is the larger of the two — if either SDF is positive (outside), the max is positive (outside).</p><p><strong>What you''ll see.</strong> Same two circles. The result is the lens-shaped overlap region between them.</p><p>Reference: <a href="https://iquilezles.org/articles/distfunctions2d/" target="_blank" rel="noreferrer">IQ — 2D distance functions</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d1 = length(p - vec2(-0.2, 0.0)) - 0.25;
    float d2 = length(p - vec2( 0.2, 0.0)) - 0.25;
    // TODO: intersection = max(d1, d2).
    // float d = max(d1, d2);
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
 '<p><strong>Goal.</strong> Punch <code>B</code> out of <code>A</code>.</p><p><strong>The rule.</strong> Subtraction is "inside <code>A</code> but outside <code>B</code>." Inverting an SDF (multiplying by <code>-1</code>) swaps inside and outside, so "outside <code>B</code>" becomes "inside <code>-B</code>." Then it''s an intersection: <code>max(A, -B)</code>.</p><p><strong>The recipe.</strong> A big circle of radius 0.4 at the center; a small circle of radius 0.25 offset to the right. <code>d = max(large, -small)</code> gives the large circle minus the small one — a crescent moon.</p><p>Reference: <a href="https://iquilezles.org/articles/distfunctions2d/" target="_blank" rel="noreferrer">IQ — 2D distance functions</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float large = length(p) - 0.4;
    float small = length(p - vec2(0.15, 0.0)) - 0.25;
    // TODO: subtract small from large.
    // float d = max(large, -small);
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
 '<p><strong>Goal.</strong> Apply the subtraction trick with two concentric circles — and you get a ring.</p><p>Same recipe as the last lesson. Both circles are at the origin: outer radius 0.4, inner radius 0.3. <code>d = max(outer, -inner)</code> keeps everything inside the outer circle but outside the inner — a 0.1-unit-wide ring.</p><p>This is a great litmus test for understanding subtraction: the formula is identical, only the positions changed.</p><p>Reference: <a href="https://mercury.sexy/hg_sdf/" target="_blank" rel="noreferrer">hg_sdf — distance field operations</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float outer = length(p) - 0.4;
    float inner = length(p) - 0.3;
    // TODO: ring = max(outer, -inner).
    // float d = max(outer, -inner);
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
 '<p><strong>Goal.</strong> Replace the harsh kink that <code>min(d1, d2)</code> creates at the junction of two shapes with a smooth, blobby join.</p><p><strong>The smin function.</strong> Iñigo Quilez''s polynomial smin (4 lines, ships in the starter): it acts like <code>min</code> when the two distances are far apart but blends them smoothly when they''re close.</p><p><strong>The <code>k</code> parameter.</strong> Bigger <code>k</code> = wider blend, more "merged" look. <code>k = 0.1</code> is gentle — you can still see the two circles but their seam dissolves.</p><p><strong>The recipe.</strong> Same two circles as the union lesson, but use <code>smin(d1, d2, 0.1)</code> instead of <code>min</code>. The result reads as one organic blob.</p><p>Reference: <a href="https://iquilezles.org/articles/smin/" target="_blank" rel="noreferrer">IQ — Smooth minimum</a>.</p>',
 'float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5*(b-a)/k, 0.0, 1.0);
    return mix(b, a, h) - k*h*(1.0-h);
}
void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d1 = length(p - vec2(-0.18, 0.0)) - 0.2;
    float d2 = length(p - vec2( 0.18, 0.0)) - 0.2;
    // TODO: smooth union with k = 0.1.
    // float d = smin(d1, d2, 0.1);
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
 '<p><strong>Goal.</strong> See <code>k</code> in action: pull two shapes that don''t even touch into a single blob.</p><p><strong>The setup.</strong> Two circles separated by 0.5 units — clearly disjoint with normal <code>min</code>. With a generous <code>k = 0.2</code>, <code>smin</code> still pulls them together through a smooth bridge of material — the "neck" of the dumbbell.</p><p>Try other <code>k</code> values in your head: <code>k = 0.05</code> wouldn''t reach across the gap, <code>k = 0.5</code> would create a near-flat slab. <code>0.2</code> is the sweet spot for this spacing.</p><p>Reference: <a href="https://iquilezles.org/articles/smin/" target="_blank" rel="noreferrer">IQ — Smooth minimum</a>.</p>',
 'float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5*(b-a)/k, 0.0, 1.0);
    return mix(b, a, h) - k*h*(1.0-h);
}
void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d1 = length(p - vec2(-0.25, 0.0)) - 0.2;
    float d2 = length(p - vec2( 0.25, 0.0)) - 0.2;
    // TODO: smin with bigger k = 0.2 to bridge the gap.
    // float d = smin(d1, d2, 0.2);
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
 '<p><strong>Goal.</strong> Nest <code>smin</code> calls to merge more than two shapes.</p><p><strong>The recipe.</strong> Three circles arranged in a small triangle. Compute their SDFs as <code>d1</code>, <code>d2</code>, <code>d3</code>. Combine: <code>smin(smin(d1, d2, 0.12), d3, 0.12)</code>. The smin is associative enough in practice — the order of merges doesn''t matter visually.</p><p>You''ll see three lobes pulled into one tri-armed blob, like a thick clover.</p><p>Reference: <a href="https://iquilezles.org/articles/smin/" target="_blank" rel="noreferrer">IQ — Smooth minimum</a>.</p>',
 'float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5*(b-a)/k, 0.0, 1.0);
    return mix(b, a, h) - k*h*(1.0-h);
}
void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d1 = length(p - vec2(-0.3, 0.0)) - 0.18;
    float d2 = length(p - vec2( 0.0, 0.15)) - 0.18;
    float d3 = length(p - vec2( 0.3, 0.0)) - 0.18;
    // TODO: chain two smins.
    // float d = smin(smin(d1, d2, 0.12), d3, 0.12);
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
 '<p><strong>Goal.</strong> Show that <code>smin</code> doesn''t care what kind of SDFs it merges.</p><p><strong>The setup.</strong> A circle on the left, an axis-aligned box on the right. The starter ships a <code>sdBox</code> helper (same formula as the box lesson). Combine them with <code>smin(dc, db, 0.1)</code>.</p><p>The merge looks the same as two circles — smooth, blobby — because <code>smin</code> operates only on the distances, not on what shapes produced them.</p><p>Reference: <a href="https://iquilezles.org/articles/smin/" target="_blank" rel="noreferrer">IQ — Smooth minimum</a>.</p>',
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
    // TODO: smin circle + box.
    // float d = smin(dc, db, 0.1);
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
 '<p><strong>Goal.</strong> Replace the staircase you got from <code>step(0.0, d)</code> with a soft, antialiased edge.</p><p><strong>The recipe.</strong> Use <code>smoothstep</code> with a small range straddling zero: <code>smoothstep(0.005, -0.005, d)</code>. Read it as "ramp from 0 to 1 as <code>d</code> moves from <code>+0.005</code> down through <code>-0.005</code>." The result is 0 outside the shape, 1 inside, and a one-or-two-pixel-wide soft transition at the edge.</p><p><strong>Argument-order note.</strong> Passing a larger first argument and a smaller second argument inverts smoothstep''s direction. We want <code>1</code> inside (where <code>d</code> is negative), so we flip the edges.</p><p>Reference: <a href="https://iquilezles.org/articles/distance/" target="_blank" rel="noreferrer">IQ — Distance functions</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d = length(p) - 0.3;
    // TODO: m = smoothstep(0.005, -0.005, d).
    // float m = smoothstep(0.005, -0.005, d);
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
 '<p><strong>Goal.</strong> Make the soft edge exactly one pixel wide, no matter the canvas size or shape size.</p><p><strong>Why a fixed width fails.</strong> The previous lesson hard-coded <code>0.005</code>. That looks good at 1080p but blurry at 4K (multiple pixels) and aliased at 320p (sub-pixel).</p><p><strong>Enter fwidth.</strong> <code>fwidth(d)</code> measures how fast <code>d</code> changes between this pixel and its neighbors — i.e. how many world-units one pixel covers along the SDF''s gradient. Use that as the smoothstep width and the edge is always pixel-perfect.</p><p><strong>The recipe.</strong> <code>w = fwidth(d); m = smoothstep(w, -w, d);</code>.</p><p>Reference: <a href="https://iquilezles.org/articles/filterableprocedurals/" target="_blank" rel="noreferrer">IQ — Filterable procedurals</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d = length(p) - 0.3;
    // TODO: pixel-wide AA from fwidth.
    // float w = fwidth(d);
    // float m = smoothstep(w, -w, d);
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
 '<p><strong>Goal.</strong> Draw only the outline of a shape — no fill.</p><p><strong>The trick.</strong> <code>abs(d)</code> is the unsigned distance from the edge. Pixels near the edge (on either side) have small <code>abs(d)</code>; pixels far away have large. Threshold <code>abs(d) - halfWidth</code> through smoothstep to draw a band exactly around the edge.</p><p><strong>The recipe.</strong> <code>e = abs(d) - 0.01;</code> turns the SDF into a new SDF whose zero-set is two parallel curves — the inside and outside walls of a half-pixel-thick wall. Same fwidth AA as the previous lesson, applied to <code>e</code>.</p><p>Reference: <a href="https://iquilezles.org/articles/distance/" target="_blank" rel="noreferrer">IQ — Distance functions</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d = length(p) - 0.3;
    float e = abs(d) - 0.01;
    // TODO: pixel AA on the outline.
    // float w = fwidth(e);
    // float m = smoothstep(w, -w, e);
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
 '<p><strong>Goal.</strong> Combine fill and stroke into a single image.</p><p><strong>The recipe.</strong></p><ol><li>Box SDF <code>d</code>, with a pre-computed pixel width <code>w</code>.</li><li><code>fill = smoothstep(w, -w, d)</code> — pixel-perfect fill mask.</li><li><code>stroke = smoothstep(w, -w, abs(d) - 0.01)</code> — pixel-perfect outline mask.</li><li><code>m = max(fill, stroke)</code> — wherever either is nonzero, draw the foreground color. (The stroke "wins" because it''s anchored on the edge where fill is already at its soft transition.)</li></ol><p>This is the building block of every UI element you''d ever draw in a shader.</p><p>Reference: <a href="https://iquilezles.org/articles/distance/" target="_blank" rel="noreferrer">IQ — Distance functions</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec2 q = abs(p) - vec2(0.3, 0.2);
    float d = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0);
    float w = fwidth(d);
    float fill = smoothstep(w, -w, d);
    float stroke = smoothstep(w, -w, abs(d) - 0.01);
    // TODO: combine fill and stroke.
    // float m = max(fill, stroke);
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
