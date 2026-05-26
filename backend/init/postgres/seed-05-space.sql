\c shader_dojo;

-- Family D — Space transforms (4 courses, 16 lessons)

INSERT INTO lesson (course_id, slug, display_order, title, description, starter_fragment_shader, canonical_fragment_shader) VALUES

-- ===== Course: rotations-2d =====
((SELECT id FROM course WHERE slug = 'rotations-2d'), '5ExBUOXv5sk', 0,
 'Rotate around origin',
 '<p>A 2D rotation is a <code>mat2</code> built from one angle: <code>mat2(c, -s, s, c)</code> where <code>c = cos(angle)</code> and <code>s = sin(angle)</code>. Multiply your centered uv by that matrix and the whole plane spins around the origin.</p><p>Rotate the centered uv by <code>π/6</code>, then draw a centered box of half-size <code>(0.2, 0.1)</code>.</p><p>Reference: <a href="https://thebookofshaders.com/08/" target="_blank" rel="noreferrer">Book of Shaders — Matrices</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float a = 3.14159 / 6.0;
    float c = cos(a), s = sin(a);
    // TODO: p = mat2(c, -s, s, c) * p;
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
 '<p>Rotation matrices only spin around the origin. To rotate around any other point, translate so the pivot becomes the origin, rotate, then translate back: <code>p = R * (p - pivot) + pivot</code>.</p><p>Rotate the same centered box by <code>π/4</code> around the pivot <code>(0.2, 0.0)</code>.</p><p>Reference: <a href="https://thebookofshaders.com/08/" target="_blank" rel="noreferrer">Book of Shaders — Matrices</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec2 pivot = vec2(0.2, 0.0);
    float a = 3.14159 / 4.0;
    float c = cos(a), s = sin(a);
    // TODO: p = mat2(c, -s, s, c) * (p - pivot) + pivot;
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
 '<p>Make the rotation angle a function of time. The shape stays the same; the coordinate frame underneath it spins, so the box appears to rotate continuously.</p><p>Reference: <a href="https://thebookofshaders.com/08/" target="_blank" rel="noreferrer">Book of Shaders — Matrices</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    // TODO: rotate p by u_time * 0.3 using mat2(c, -s, s, c).
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
 '<p>Compose transforms by stacking them on the uv. Scaling the coordinate by <code>k</code> makes the drawn shape appear <code>1/k</code> times as large — counterintuitive but consistent with the rest of the family.</p><p>Rotate by <code>π/4</code>, then scale uv by <code>1.5</code>, then draw a box <code>(0.25, 0.15)</code>.</p><p>Reference: <a href="https://thebookofshaders.com/08/" target="_blank" rel="noreferrer">Book of Shaders — Matrices</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float a = 3.14159 / 4.0;
    float c = cos(a), s = sin(a);
    p = mat2(c, -s, s, c) * p;
    // TODO: p *= 1.5;
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
 '<p>Polar coordinates rewrite a 2D position as <code>(r, a)</code>: <code>r = length(p)</code> is distance from the origin, <code>a = atan(p.y, p.x)</code> is angle. Output <code>r</code> on all three channels and the canvas darkens at the center, brightens outward.</p><p>Reference: <a href="https://thebookofshaders.com/07/" target="_blank" rel="noreferrer">Book of Shaders — Shapes (polar section)</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    // TODO: r = length(p); output vec3(r).
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
 '<p>Take the polar angle, normalize it to <code>[0, 1]</code> by dividing by <code>2π</code>, then multiply by the number of wedges. <code>fract</code> wraps the result inside each slice; <code>step(0.5, ...)</code> turns each slice into a binary wedge.</p><p>Reference: <a href="https://thebookofshaders.com/07/" target="_blank" rel="noreferrer">Book of Shaders — Shapes (polar section)</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float a = atan(p.y, p.x);
    // TODO: m = step(0.5, fract(a / 6.28318 * 6.0));
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
 '<p>A rose curve has radius that depends on angle: <code>R = k * cos(n * a)</code> gives <code>n</code> petals when <code>n</code> is odd. Build the target radius for every angle, then mask all pixels whose actual radius is less than the target — that fills in the petals.</p><p>Reference: <a href="https://thebookofshaders.com/07/" target="_blank" rel="noreferrer">Book of Shaders — Shapes (polar section)</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float a = atan(p.y, p.x);
    float R = 0.4 * cos(5.0 * a);
    // TODO: m = smoothstep(0.01, -0.01, length(p) - R);
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
 '<p>Mix radius and angle inside one <code>fract</code> to get a spiral. Stepping radius alone gives rings; stepping angle alone gives wedges; stepping their weighted sum twists the rings into a spiral arm.</p><p>Reference: <a href="https://thebookofshaders.com/07/" target="_blank" rel="noreferrer">Book of Shaders — Shapes (polar section)</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float a = atan(p.y, p.x);
    float r = length(p);
    // TODO: m = step(0.5, fract(r * 8.0 + a / 6.28318 * 3.0));
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
 '<p>To repeat a pattern, scale the uv up so one tile spans <code>[0, 1]</code>, then take <code>fract</code> to get the local coordinate inside each tile. Subtract <code>0.5</code> so each cell is centered on its own origin, and you can draw a shape that appears in every cell.</p><p>References: <a href="https://thebookofshaders.com/09/" target="_blank" rel="noreferrer">BoS — Patterns</a>, <a href="https://iquilezles.org/articles/sdfrepetition/" target="_blank" rel="noreferrer">IQ — Domain repetition</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 6.0;
    // TODO: f = fract(uv) - 0.5; m = smoothstep(0.005, -0.005, length(f) - 0.3);
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
 '<p>Once you have the integer cell index from <code>floor(uv)</code>, a checkerboard is just <code>mod(cell.x + cell.y, 2.0)</code> — alternating 0 and 1 along both axes.</p><p>References: <a href="https://thebookofshaders.com/09/" target="_blank" rel="noreferrer">BoS — Patterns</a>, <a href="https://iquilezles.org/articles/sdfrepetition/" target="_blank" rel="noreferrer">IQ — Domain repetition</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 8.0;
    vec2 cell = floor(uv);
    // TODO: m = mod(cell.x + cell.y, 2.0);
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
 '<p>The cell index is constant inside one tile, so any function of it produces a flat color per cell. The classic 1D hash <code>fract(sin(dot(cell, vec2(12.9898, 78.233))) * 43758.5453)</code> turns the cell index into a pseudo-random scalar — use it as a grayscale value to color every cell differently.</p><p>References: <a href="https://thebookofshaders.com/09/" target="_blank" rel="noreferrer">BoS — Patterns</a>, <a href="https://iquilezles.org/articles/sdfrepetition/" target="_blank" rel="noreferrer">IQ — Domain repetition</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 5.0;
    vec2 cell = floor(uv);
    // TODO: h = fract(sin(dot(cell, vec2(12.9898, 78.233))) * 43758.5453);
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
 '<p>A brick pattern shifts every other row by half a tile. Compute the integer row index first, decide if it''s odd, and shift <code>uv.x</code> by <code>0.5</code> before taking <code>fract</code>. The local tile coordinate is otherwise unchanged.</p><p>References: <a href="https://thebookofshaders.com/09/" target="_blank" rel="noreferrer">BoS — Patterns</a>, <a href="https://iquilezles.org/articles/sdfrepetition/" target="_blank" rel="noreferrer">IQ — Domain repetition</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 6.0;
    float row = floor(uv.y);
    // TODO: if (mod(row, 2.0) == 1.0) uv.x += 0.5;
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
 '<p>Taking <code>abs</code> of a centered coordinate folds the plane into the top-right quadrant: every pixel reads the same value as its mirror image across both axes. Place one off-center shape and it appears reflected into all four quadrants automatically.</p><p>References: <a href="https://thebookofshaders.com/09/" target="_blank" rel="noreferrer">BoS — Patterns (mirror)</a>, <a href="https://mercury.sexy/hg_sdf/" target="_blank" rel="noreferrer">hg_sdf — domain ops</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    // TODO: p = abs(p);
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
 '<p>One <code>abs</code> gives you 4 quadrants of symmetry. Rotate by <code>π/4</code> and <code>abs</code> a second time and you fold once more along the diagonals — the result is 8-fold symmetry.</p><p>References: <a href="https://thebookofshaders.com/09/" target="_blank" rel="noreferrer">BoS — Patterns (mirror)</a>, <a href="https://mercury.sexy/hg_sdf/" target="_blank" rel="noreferrer">hg_sdf — domain ops</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    p = abs(p);
    float a = 3.14159 / 4.0;
    float c = cos(a), s = sin(a);
    p = mat2(c, -s, s, c) * p;
    // TODO: p = abs(p);
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
 '<p>For N-fold rotational symmetry, convert to polar, wrap the angle into a single slice of width <code>2π/N</code>, recenter that slice on zero, and convert back. Anything you draw in the slice appears N times around the origin.</p><p>References: <a href="https://thebookofshaders.com/09/" target="_blank" rel="noreferrer">BoS — Patterns (mirror)</a>, <a href="https://mercury.sexy/hg_sdf/" target="_blank" rel="noreferrer">hg_sdf — domain ops</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float a = atan(p.y, p.x);
    float r = length(p);
    float N = 6.0;
    // TODO: a = mod(a, 6.28318 / N) - 3.14159 / N; p = r * vec2(cos(a), sin(a));
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
 '<p>The fold itself stays a fixed N=6, but rotate the coordinate by <code>u_time * 0.2</code> <em>before</em> folding. The shape doesn''t move; the symmetry frame spins under it, so the whole kaleidoscope appears to rotate.</p><p>References: <a href="https://thebookofshaders.com/09/" target="_blank" rel="noreferrer">BoS — Patterns (mirror)</a>, <a href="https://mercury.sexy/hg_sdf/" target="_blank" rel="noreferrer">hg_sdf — domain ops</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    // TODO: rotate p by u_time * 0.2 before the polar fold.
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
