\c shader_dojo;

-- Family D — Space transforms (4 courses, 16 lessons)
-- Same lecture-style rules: explicit recipes, hand-holding TODOs.

INSERT INTO lesson (course_id, slug, display_order, title, description, starter_fragment_shader, canonical_fragment_shader) VALUES

-- ===== Course: rotations-2d =====
((SELECT id FROM course WHERE slug = 'rotations-2d'), '5ExBUOXv5sk', 0,
 'Rotate around origin',
 '<p><strong>Goal.</strong> Build the 2×2 rotation matrix and use it to spin the entire coordinate plane.</p><p><strong>The matrix.</strong> Given an angle <code>a</code>, define <code>c = cos(a)</code> and <code>s = sin(a)</code>. The rotation matrix is <code>mat2(c, -s, s, c)</code>. In GLSL, <code>mat2(col0x, col0y, col1x, col1y)</code> takes <em>column-major</em> arguments — so <code>(c, -s, s, c)</code> is the matrix whose first column is <code>(c, -s)</code> and second column is <code>(s, c)</code>. That is the standard CCW rotation.</p><p><strong>The recipe.</strong> Multiply the centered position by the matrix: <code>p = mat2(c, -s, s, c) * p;</code>. The whole world spins under whatever shape you draw. Here we rotate by <code>π/6</code> (30°) and draw a horizontal box.</p><p>Reference: <a href="https://thebookofshaders.com/08/" target="_blank" rel="noreferrer">Book of Shaders — Matrices</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float a = 3.14159 / 6.0;
    float c = cos(a), s = sin(a);
    // TODO: rotate p before drawing.
    // p = mat2(c, -s, s, c) * p;
    vec2 bSize = vec2(0.2, 0.1);
    vec2 d = abs(p) - bSize;
    float box = length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
    float m = smoothstep(0.005, -0.005, box);
    vec3 col = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(col, 1.0);
}',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float a = 3.14159 / 6.0;
    float c = cos(a), s = sin(a);
    p = mat2(c, -s, s, c) * p;
    vec2 bSize = vec2(0.2, 0.1);
    vec2 d = abs(p) - bSize;
    float box = length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
    float m = smoothstep(0.005, -0.005, box);
    vec3 col = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'rotations-2d'), 'HtfS1vZ20Qw', 1,
 'Rotate around pivot',
 '<p><strong>Goal.</strong> Rotate around a point that isn''t the origin.</p><p><strong>Why it''s not free.</strong> The matrix <code>mat2(c, -s, s, c)</code> always rotates around <code>(0, 0)</code>. To rotate around any other point, do the standard three-step dance: translate so the pivot becomes the origin, rotate, translate back.</p><p><strong>The formula.</strong> <code>p = mat2(c, -s, s, c) * (p - pivot) + pivot;</code>. Read it left to right: subtract pivot, rotate, add pivot back.</p><p>Pick <code>pivot = (0.2, 0.0)</code> and the box swings around a point on the right of the canvas — clearly not the origin.</p><p>Reference: <a href="https://thebookofshaders.com/08/" target="_blank" rel="noreferrer">Book of Shaders — Matrices</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec2 pivot = vec2(0.2, 0.0);
    float a = 3.14159 / 4.0;
    float c = cos(a), s = sin(a);
    // TODO: translate-rotate-translate.
    // p = mat2(c, -s, s, c) * (p - pivot) + pivot;
    vec2 bSize = vec2(0.2, 0.1);
    vec2 d = abs(p) - bSize;
    float box = length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
    float m = smoothstep(0.005, -0.005, box);
    vec3 col = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(col, 1.0);
}',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec2 pivot = vec2(0.2, 0.0);
    float a = 3.14159 / 4.0;
    float c = cos(a), s = sin(a);
    p = mat2(c, -s, s, c) * (p - pivot) + pivot;
    vec2 bSize = vec2(0.2, 0.1);
    vec2 d = abs(p) - bSize;
    float box = length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
    float m = smoothstep(0.005, -0.005, box);
    vec3 col = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'rotations-2d'), '6UFPwfI6hSQ', 2,
 'Time-rotated square',
 '<p><strong>Goal.</strong> Let the rotation angle depend on <code>u_time</code> so the shape spins continuously.</p><p><strong>The change.</strong> Replace the fixed angle with <code>a = u_time * 0.3</code>. The <code>0.3</code> slows the rotation so it''s about one revolution every 21 seconds (<code>2π / 0.3</code>) — pleasant rather than dizzying.</p><p>Important framing: the shape doesn''t move. The <em>coordinate frame</em> rotates under it, which looks identical from the outside.</p><p>Reference: <a href="https://thebookofshaders.com/08/" target="_blank" rel="noreferrer">Book of Shaders — Matrices</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    // TODO: a = u_time * 0.3; rotate p.
    // float a = u_time * 0.3;
    float a = 0.0;
    float c = cos(a), s = sin(a);
    p = mat2(c, -s, s, c) * p;
    vec2 bSize = vec2(0.2, 0.2);
    vec2 d = abs(p) - bSize;
    float box = length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
    float m = smoothstep(0.005, -0.005, box);
    vec3 col = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(col, 1.0);
}',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float a = u_time * 0.3;
    float c = cos(a), s = sin(a);
    p = mat2(c, -s, s, c) * p;
    vec2 bSize = vec2(0.2, 0.2);
    vec2 d = abs(p) - bSize;
    float box = length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
    float m = smoothstep(0.005, -0.005, box);
    vec3 col = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'rotations-2d'), 'aoAJ9kNJJlk', 3,
 'Rotate + scale',
 '<p><strong>Goal.</strong> Compose two coordinate transforms on the same <code>p</code>.</p><p><strong>The counterintuitive part.</strong> Scaling <em>up</em> the coordinate (<code>p *= 1.5</code>) makes the shape appear <em>smaller</em>. Why? Because we''re asking "what shape value does this stretched coordinate land in?" — a pixel that used to sit at the box''s edge now sits well outside the box''s edge.</p><p><strong>The order matters.</strong> Rotate first, scale second. If you reversed it the result would still look the same here (uniform scale commutes with rotation), but for non-uniform scales it would differ — keep the rotate-then-scale habit.</p><p>Reference: <a href="https://thebookofshaders.com/08/" target="_blank" rel="noreferrer">Book of Shaders — Matrices</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float a = 3.14159 / 4.0;
    float c = cos(a), s = sin(a);
    p = mat2(c, -s, s, c) * p;
    // TODO: scale uv after rotating.
    // p *= 1.5;
    vec2 bSize = vec2(0.25, 0.15);
    vec2 d = abs(p) - bSize;
    float box = length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
    float m = smoothstep(0.005, -0.005, box);
    vec3 col = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(col, 1.0);
}',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float a = 3.14159 / 4.0;
    float c = cos(a), s = sin(a);
    p = mat2(c, -s, s, c) * p;
    p *= 1.5;
    vec2 bSize = vec2(0.25, 0.15);
    vec2 d = abs(p) - bSize;
    float box = length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
    float m = smoothstep(0.005, -0.005, box);
    vec3 col = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(col, 1.0);
}'),

-- ===== Course: polar-coordinates =====
((SELECT id FROM course WHERE slug = 'polar-coordinates'), 'JTciASn_Qvk', 0,
 'Radial gradient',
 '<p><strong>Goal.</strong> Re-meet polar coordinates as a drawing tool, not just a debug visualization.</p><p><strong>The recipe.</strong> <code>r = length(p)</code> is distance from the canvas center. Output <code>vec3(r)</code> on all channels: the canvas is black at the origin and brightens outward. (At the canvas corners, <code>r &gt; 1</code>, so RGB clamps to 1 — pure white.)</p><p>This is the foundation for everything in this course: every radial pattern is just some function of <code>r</code> and the polar angle.</p><p>Reference: <a href="https://thebookofshaders.com/07/" target="_blank" rel="noreferrer">Book of Shaders — Shapes (polar section)</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    // TODO: r = length(p); output as gray.
    // float r = length(p);
    // gl_FragColor = vec4(vec3(r), 1.0);
    float r = 0.0;
    gl_FragColor = vec4(vec3(r), 1.0);
}',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float r = length(p);
    gl_FragColor = vec4(vec3(r), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'polar-coordinates'), '145rHTT59o8', 1,
 'Angular wedges',
 '<p><strong>Goal.</strong> Slice the canvas into <em>N</em> alternating wedges around the center.</p><p><strong>The recipe (every wedge pattern uses this).</strong></p><ol><li><code>a = atan(p.y, p.x)</code> — angle in <code>[-π, π]</code>.</li><li><code>a / (2π)</code> — normalize to <code>[-0.5, 0.5]</code>.</li><li>Multiply by <code>N</code> (the wedge count) — each integer step now covers one full wedge.</li><li><code>fract(...)</code> — wrap to <code>[0, 1)</code> inside each wedge.</li><li><code>step(0.5, ...)</code> — first half of each wedge is dark, second half is bright.</li></ol><p>With <code>N = 6</code> you get six wedges: three light, three dark, like a beach umbrella.</p><p>Reference: <a href="https://thebookofshaders.com/07/" target="_blank" rel="noreferrer">Book of Shaders — Shapes (polar section)</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float a = atan(p.y, p.x);
    // TODO: 6-wedge binary mask.
    // float m = step(0.5, fract(a / 6.28318 * 6.0));
    float m = 0.0;
    gl_FragColor = vec4(vec3(m), 1.0);
}',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float a = atan(p.y, p.x);
    float m = step(0.5, fract(a / 6.28318 * 6.0));
    gl_FragColor = vec4(vec3(m), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'polar-coordinates'), '4JZ6EAZk1G0', 2,
 'Rose curve',
 '<p><strong>Goal.</strong> Draw a flower with <code>n</code> petals using polar coordinates.</p><p><strong>The math.</strong> A rose curve has the polar equation <code>R(a) = k · cos(n · a)</code>. For each angle, that''s the radius at which the curve passes. Pixels whose <code>length(p)</code> is less than <code>R</code> are inside a petal; pixels outside are not.</p><p><strong>The recipe.</strong> <code>R = 0.4 * cos(5.0 * a)</code> gives a 5-petal rose of size 0.4. Then <code>m = smoothstep(0.01, -0.01, length(p) - R)</code> fills pixels where <code>length(p) &lt; R</code> with a soft edge.</p><p>Notes: <code>R</code> can go negative for certain <code>a</code>, and that''s fine — the negative side never satisfies <code>length(p) &lt; R</code>, so those wedges stay empty.</p><p>Reference: <a href="https://thebookofshaders.com/07/" target="_blank" rel="noreferrer">Book of Shaders — Shapes (polar section)</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float a = atan(p.y, p.x);
    float R = 0.4 * cos(5.0 * a);
    // TODO: fill where length(p) < R.
    // float m = smoothstep(0.01, -0.01, length(p) - R);
    float m = 0.0;
    gl_FragColor = vec4(vec3(m), 1.0);
}',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float a = atan(p.y, p.x);
    float R = 0.4 * cos(5.0 * a);
    float m = smoothstep(0.01, -0.01, length(p) - R);
    gl_FragColor = vec4(vec3(m), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'polar-coordinates'), 'q22hPP6Lpek', 3,
 'Spiral',
 '<p><strong>Goal.</strong> Combine radius and angle inside the <code>fract</code> step to twist rings into a spiral.</p><p><strong>What''s happening.</strong></p><ul><li><code>fract(r * 8.0)</code> alone would draw 8 concentric rings.</li><li><code>fract(a / 6.28318 * 3.0)</code> alone would draw 3 alternating wedges.</li><li>Their <em>sum</em> inside one <code>fract</code> shears the rings so each one rotates as it expands — a spiral.</li></ul><p>Tweak the coefficients (<code>8.0</code> and <code>3.0</code>) to get more rings or more arms.</p><p>Reference: <a href="https://thebookofshaders.com/07/" target="_blank" rel="noreferrer">Book of Shaders — Shapes (polar section)</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float a = atan(p.y, p.x);
    float r = length(p);
    // TODO: spiral mask.
    // float m = step(0.5, fract(r * 8.0 + a / 6.28318 * 3.0));
    float m = 0.0;
    gl_FragColor = vec4(vec3(m), 1.0);
}',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float a = atan(p.y, p.x);
    float r = length(p);
    float m = step(0.5, fract(r * 8.0 + a / 6.28318 * 3.0));
    gl_FragColor = vec4(vec3(m), 1.0);
}'),

-- ===== Course: tiling-repetition =====
((SELECT id FROM course WHERE slug = 'tiling-repetition'), 'TPzOO365lwg', 0,
 'Grid via fract',
 '<p><strong>Goal.</strong> Tile one shape into a grid by reusing a small piece of the canvas in every cell.</p><p><strong>The recipe.</strong></p><ol><li>Scale <code>uv</code> up so a "1.0" worth of UV covers one tile, not the whole canvas: <code>uv * 6.0</code> = 6 tiles across.</li><li><code>fract(uv)</code> = the local coordinate inside each tile, always in <code>[0, 1)</code>.</li><li>Subtract <code>0.5</code> = each cell is now centered on <code>(0, 0)</code>.</li><li>Draw a centered disc in those local coordinates and it appears in every cell.</li></ol><p>You''ve turned one shape into 36.</p><p>References: <a href="https://thebookofshaders.com/09/" target="_blank" rel="noreferrer">BoS — Patterns</a>, <a href="https://iquilezles.org/articles/sdfrepetition/" target="_blank" rel="noreferrer">IQ — Domain repetition</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 6.0;
    // TODO: per-cell coordinate; draw a centered disc.
    // vec2 f = fract(uv) - 0.5;
    // float m = smoothstep(0.005, -0.005, length(f) - 0.3);
    vec2 f = vec2(0.0);
    float m = 0.0;
    vec3 col = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(col, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 6.0;
    vec2 f = fract(uv) - 0.5;
    float m = smoothstep(0.005, -0.005, length(f) - 0.3);
    vec3 col = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'tiling-repetition'), '0MdvjwkSEKw', 1,
 'Checker via mod',
 '<p><strong>Goal.</strong> Use the <em>integer cell index</em> instead of the per-cell coordinate.</p><p><strong>The recipe.</strong> <code>floor(uv)</code> gives the integer index of the cell each pixel is in. For a checkerboard: <code>mod(cell.x + cell.y, 2.0)</code> alternates between 0 and 1 across both axes — that''s the classic checker pattern.</p><p>Cell index is constant inside one tile, so anything you compute from it is constant inside the tile too. That''s the gateway to per-tile randomization (next lesson) and brick offsets (the one after).</p><p>References: <a href="https://thebookofshaders.com/09/" target="_blank" rel="noreferrer">BoS — Patterns</a>, <a href="https://iquilezles.org/articles/sdfrepetition/" target="_blank" rel="noreferrer">IQ — Domain repetition</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 8.0;
    vec2 cell = floor(uv);
    // TODO: checker mask from cell index.
    // float m = mod(cell.x + cell.y, 2.0);
    float m = 0.0;
    gl_FragColor = vec4(vec3(m), 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 8.0;
    vec2 cell = floor(uv);
    float m = mod(cell.x + cell.y, 2.0);
    gl_FragColor = vec4(vec3(m), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'tiling-repetition'), 'AEABJnlCrik', 2,
 'Per-cell index color',
 '<p><strong>Goal.</strong> Color every tile differently — at random — using only the cell index.</p><p><strong>The hash (preview of Family E).</strong> <code>fract(sin(dot(cell, vec2(12.9898, 78.233))) * 43758.5453)</code> is a deterministic but uncorrelated function of the cell index. Same cell → same value. Nearby cells → totally different values.</p><p><strong>The recipe.</strong> Compute that hash per cell, output it as grayscale. Result: a regular grid of cells, each a different shade.</p><p>This is the cornerstone of all procedural per-cell randomness: noise, Voronoi, sprite atlases, you name it.</p><p>References: <a href="https://thebookofshaders.com/09/" target="_blank" rel="noreferrer">BoS — Patterns</a>, <a href="https://iquilezles.org/articles/sdfrepetition/" target="_blank" rel="noreferrer">IQ — Domain repetition</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 5.0;
    vec2 cell = floor(uv);
    // TODO: hash the cell index.
    // float h = fract(sin(dot(cell, vec2(12.9898, 78.233))) * 43758.5453);
    float h = 0.0;
    gl_FragColor = vec4(vec3(h), 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 5.0;
    vec2 cell = floor(uv);
    float h = fract(sin(dot(cell, vec2(12.9898, 78.233))) * 43758.5453);
    gl_FragColor = vec4(vec3(h), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'tiling-repetition'), 'K_oducynqa4', 3,
 'Offset every other row',
 '<p><strong>Goal.</strong> Stagger alternate rows by half a tile — the classic brick pattern.</p><p><strong>The recipe.</strong></p><ol><li><code>row = floor(uv.y)</code> — integer row index.</li><li>If <code>row</code> is odd, shift <code>uv.x</code> by <code>0.5</code> before taking <code>fract</code>. (<code>mod(row, 2.0) == 1.0</code> tests odd.)</li><li>Same per-cell drawing as Lesson 0.</li></ol><p>The shift moves every other row so the disc centers no longer line up vertically — you get the hexagonal-looking offset arrangement bricks use.</p><p>References: <a href="https://thebookofshaders.com/09/" target="_blank" rel="noreferrer">BoS — Patterns</a>, <a href="https://iquilezles.org/articles/sdfrepetition/" target="_blank" rel="noreferrer">IQ — Domain repetition</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 6.0;
    float row = floor(uv.y);
    // TODO: shift every odd row by half a tile.
    // if (mod(row, 2.0) == 1.0) uv.x += 0.5;
    vec2 f = fract(uv) - 0.5;
    float m = smoothstep(0.005, -0.005, length(f) - 0.25);
    vec3 col = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(col, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 6.0;
    float row = floor(uv.y);
    if (mod(row, 2.0) == 1.0) uv.x += 0.5;
    vec2 f = fract(uv) - 0.5;
    float m = smoothstep(0.005, -0.005, length(f) - 0.25);
    vec3 col = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(col, 1.0);
}'),

-- ===== Course: kaleidoscope-mirror =====
((SELECT id FROM course WHERE slug = 'kaleidoscope-mirror'), 'hsOckH--ZvE', 0,
 'abs() mirror',
 '<p><strong>Goal.</strong> Mirror the canvas with a single line.</p><p><strong>The trick.</strong> <code>abs(p)</code> folds the entire plane into the top-right quadrant — every pixel ends up reading the same value as its three mirror images. Anything you draw at, say, <code>(0.3, 0.2)</code> appears reflected into all four quadrants for free.</p><p>Same draw code, but starting with <code>p = abs(p)</code>: a single off-center disc becomes four discs.</p><p>References: <a href="https://thebookofshaders.com/09/" target="_blank" rel="noreferrer">BoS — Patterns (mirror)</a>, <a href="https://mercury.sexy/hg_sdf/" target="_blank" rel="noreferrer">hg_sdf — domain ops</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    // TODO: fold into one quadrant.
    // p = abs(p);
    float m = smoothstep(0.005, -0.005, length(p - vec2(0.3, 0.2)) - 0.12);
    vec3 col = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(col, 1.0);
}',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    p = abs(p);
    float m = smoothstep(0.005, -0.005, length(p - vec2(0.3, 0.2)) - 0.12);
    vec3 col = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'kaleidoscope-mirror'), 'WVHtVoEQXe8', 1,
 '4-fold via two abs',
 '<p><strong>Goal.</strong> Double the symmetry: first fold along the axes, then fold along the diagonals.</p><p><strong>The recipe.</strong></p><ol><li><code>p = abs(p)</code> — fold into the top-right quadrant.</li><li>Rotate by <code>π/4</code> — diagonals are now axes.</li><li><code>p = abs(p)</code> — fold again, along the new axes (which were the original diagonals).</li></ol><p>One shape drawn after step 3 appears 8 times around the canvas — full 8-fold dihedral symmetry.</p><p>References: <a href="https://thebookofshaders.com/09/" target="_blank" rel="noreferrer">BoS — Patterns (mirror)</a>, <a href="https://mercury.sexy/hg_sdf/" target="_blank" rel="noreferrer">hg_sdf — domain ops</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    p = abs(p);
    float a = 3.14159 / 4.0;
    float c = cos(a), s = sin(a);
    p = mat2(c, -s, s, c) * p;
    // TODO: fold again after rotating.
    // p = abs(p);
    float m = smoothstep(0.005, -0.005, length(p - vec2(0.3, 0.05)) - 0.08);
    vec3 col = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(col, 1.0);
}',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    p = abs(p);
    float a = 3.14159 / 4.0;
    float c = cos(a), s = sin(a);
    p = mat2(c, -s, s, c) * p;
    p = abs(p);
    float m = smoothstep(0.005, -0.005, length(p - vec2(0.3, 0.05)) - 0.08);
    vec3 col = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'kaleidoscope-mirror'), 'QPMSbvodbW8', 2,
 'N-fold polar fold',
 '<p><strong>Goal.</strong> Get any <code>N</code>-fold rotational symmetry, not just powers of two.</p><p><strong>The recipe (the polar fold).</strong></p><ol><li>Convert to polar: <code>a = atan(p.y, p.x)</code>, <code>r = length(p)</code>.</li><li>Wrap the angle into a single slice of width <code>2π / N</code>: <code>a = mod(a, 2π / N) - π / N</code>. The subtraction recenters the slice on <code>a = 0</code>.</li><li>Convert back to Cartesian: <code>p = r * vec2(cos(a), sin(a))</code>.</li></ol><p>Now anything you draw inside the slice — here a disc to the right of the origin — appears <code>N</code> times around the canvas. With <code>N = 6</code> you get a hex flower.</p><p>References: <a href="https://thebookofshaders.com/09/" target="_blank" rel="noreferrer">BoS — Patterns (mirror)</a>, <a href="https://mercury.sexy/hg_sdf/" target="_blank" rel="noreferrer">hg_sdf — domain ops</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float a = atan(p.y, p.x);
    float r = length(p);
    float N = 6.0;
    // TODO: wrap angle into one slice, convert back.
    // a = mod(a, 6.28318 / N) - 3.14159 / N;
    // p = r * vec2(cos(a), sin(a));
    float m = smoothstep(0.005, -0.005, length(p - vec2(0.35, 0.0)) - 0.1);
    vec3 col = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(col, 1.0);
}',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float a = atan(p.y, p.x);
    float r = length(p);
    float N = 6.0;
    a = mod(a, 6.28318 / N) - 3.14159 / N;
    p = r * vec2(cos(a), sin(a));
    float m = smoothstep(0.005, -0.005, length(p - vec2(0.35, 0.0)) - 0.1);
    vec3 col = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'kaleidoscope-mirror'), 'M6JS_7Y-RyU', 3,
 'Animated kaleidoscope',
 '<p><strong>Goal.</strong> Spin the symmetry frame so the kaleidoscope rotates.</p><p><strong>The recipe.</strong> Rotate <code>p</code> by <code>u_time * 0.2</code> <em>before</em> entering the polar fold. The fold''s <code>N = 6</code> stays constant; only the coordinate frame underneath spins, so the entire 6-fold pattern revolves while keeping its symmetry.</p><p>Same image as the previous lesson at <code>u_time = 0</code>; it just won''t hold still.</p><p>References: <a href="https://thebookofshaders.com/09/" target="_blank" rel="noreferrer">BoS — Patterns (mirror)</a>, <a href="https://mercury.sexy/hg_sdf/" target="_blank" rel="noreferrer">hg_sdf — domain ops</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    // TODO: rotate p by u_time*0.2 before the polar fold.
    // float rot = u_time * 0.2;
    float rot = 0.0;
    float cr = cos(rot), sr = sin(rot);
    p = mat2(cr, -sr, sr, cr) * p;
    float a = atan(p.y, p.x);
    float r = length(p);
    float N = 6.0;
    a = mod(a, 6.28318 / N) - 3.14159 / N;
    p = r * vec2(cos(a), sin(a));
    float m = smoothstep(0.005, -0.005, length(p - vec2(0.35, 0.0)) - 0.1);
    vec3 col = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(col, 1.0);
}',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float rot = u_time * 0.2;
    float cr = cos(rot), sr = sin(rot);
    p = mat2(cr, -sr, sr, cr) * p;
    float a = atan(p.y, p.x);
    float r = length(p);
    float N = 6.0;
    a = mod(a, 6.28318 / N) - 3.14159 / N;
    p = r * vec2(cos(a), sin(a));
    float m = smoothstep(0.005, -0.005, length(p - vec2(0.35, 0.0)) - 0.1);
    vec3 col = mix(vec3(0.10, 0.15, 0.35), vec3(0.95, 0.81, 0.36), m);
    gl_FragColor = vec4(col, 1.0);
}');
