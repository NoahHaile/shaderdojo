\c shader_dojo;

-- Family D — Space transforms (4 courses, 16 lessons)
-- Same lecture-style rules: explicit recipes, hand-holding TODOs.

INSERT INTO lesson (course_id, slug, display_order, title, description, starter_fragment_shader, canonical_fragment_shader) VALUES

-- ===== Course: rotations-2d =====
((SELECT id FROM course WHERE slug = 'rotations-2d'), '5ExBUOXv5sk', 0,
 'Rotate around origin',
 '<p>You will spin the whole coordinate plane. To turn pixels, you use a 2x2 matrix. That is a small box of 4 numbers that twists coordinates.</p><p>Pick an angle <code>a</code>. Set <code>c = cos(a)</code> and <code>s = sin(a)</code>. The matrix is <code>mat2(c, -s, s, c)</code>. GLSL fills the matrix one column at a time. So the first column is <code>(c, -s)</code> and the second is <code>(s, c)</code>.</p><p>Try this: set <code>a</code> to <code>π/6</code> (30 degrees). Then write <code>p = mat2(c, -s, s, c) * p;</code>. The box you draw will tilt. Read more at <a href="https://thebookofshaders.com/08/" target="_blank" rel="noreferrer">Book of Shaders, Matrices</a>.</p>',
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
 '<p>You will spin a shape around a point that is not the center. The matrix <code>mat2(c, -s, s, c)</code> always spins around <code>(0, 0)</code>. So you need three steps.</p><p>First, move so the pivot sits at the origin. Subtract <code>pivot</code> from <code>p</code>. Second, spin with the matrix. Third, add <code>pivot</code> back. The whole line is <code>p = mat2(c, -s, s, c) * (p - pivot) + pivot;</code>.</p><p>Try this: set <code>pivot</code> to <code>(0.2, 0.0)</code>. The box will swing around that point on the right side. Read more at <a href="https://thebookofshaders.com/08/" target="_blank" rel="noreferrer">Book of Shaders, Matrices</a>.</p>',
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
 '<p>You will make the box spin all the time. Tie the angle to <code>u_time</code>. That uniform grows every frame.</p><p>Set <code>a = u_time * 0.3</code>. The <code>0.3</code> makes the spin slow. One full turn takes about 21 seconds. The shape itself does not move. The coordinate frame turns under it. From outside, that looks the same.</p><p>Try this: replace the fixed angle with <code>u_time * 0.3</code>. The box will keep spinning. Read more at <a href="https://thebookofshaders.com/08/" target="_blank" rel="noreferrer">Book of Shaders, Matrices</a>.</p>',
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
 '<p>You will stack two coordinate changes on the same <code>p</code>. First spin <code>p</code>. Then scale it.</p><p>Here is the odd part. Scaling <code>p</code> up makes the shape look smaller. <code>p *= 1.5</code> grows the coordinate. A pixel that used to sit on the edge of the box now sits past the edge. So fewer pixels land inside.</p><p>Try this: after rotating, write <code>p *= 1.5</code>. The box will appear smaller and tilted. Always rotate first, then scale. Read more at <a href="https://thebookofshaders.com/08/" target="_blank" rel="noreferrer">Book of Shaders, Matrices</a>.</p>',
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
 '<p>You will draw with polar coordinates. Polar means you use distance and angle in place of x and y. Distance from the center is called the radius.</p><p>Set <code>r = length(p)</code>. That is how far the pixel is from the center. Output <code>vec3(r)</code> on all three channels. The middle is black. The outside gets brighter. The corners go past 1, so they clamp to white.</p><p>Try this: compute <code>r</code> and put it in the color. Every polar pattern after this will build on <code>r</code> and the angle. Read more at <a href="https://thebookofshaders.com/07/" target="_blank" rel="noreferrer">Book of Shaders, Shapes (polar section)</a>.</p>',
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
 '<p>You will cut the canvas into N wedges around the center. Like slices of a pie.</p><p>Five small steps build the mask. <code>a = atan(p.y, p.x)</code> gives the angle. It runs from <code>-π</code> to <code>π</code>. Divide by <code>2π</code> to get a value from <code>-0.5</code> to <code>0.5</code>. Multiply by <code>N</code> so each whole step covers one wedge. Wrap with <code>fract</code> to land in <code>[0, 1)</code>. Then use <code>step(0.5, ...)</code> to flip half of each wedge dark and half bright.</p><p>Try this: set <code>N = 6</code> and write <code>m = step(0.5, fract(a / 6.28318 * 6.0))</code>. You will see six wedges, like a beach umbrella. Read more at <a href="https://thebookofshaders.com/07/" target="_blank" rel="noreferrer">Book of Shaders, Shapes (polar section)</a>.</p>',
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
 '<p>You will draw a flower with n petals using polar coordinates. The shape is called a rose curve.</p><p>A rose curve uses the formula <code>R(a) = k * cos(n * a)</code>. For each angle, <code>R</code> tells you the petal''s reach. A pixel is inside a petal when <code>length(p)</code> is less than <code>R</code>. When <code>R</code> goes below zero for some angles, no pixel can match, so those wedges stay empty.</p><p>Try this: set <code>R = 0.4 * cos(5.0 * a)</code>. Then write <code>m = smoothstep(0.01, -0.01, length(p) - R)</code>. You will see a 5-petal rose. Read more at <a href="https://thebookofshaders.com/07/" target="_blank" rel="noreferrer">Book of Shaders, Shapes (polar section)</a>.</p>',
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
 '<p>You will mix radius and angle inside one <code>fract</code> to twist rings into a spiral.</p><p>By itself, <code>fract(r * 8.0)</code> draws 8 rings around the center. By itself, <code>fract(a / 6.28318 * 3.0)</code> draws 3 wedges. When you add them inside one <code>fract</code>, the rings shift around as they grow. That shift turns rings into a spiral.</p><p>Try this: write <code>m = step(0.5, fract(r * 8.0 + a / 6.28318 * 3.0))</code>. Change the <code>8.0</code> for more rings. Change the <code>3.0</code> for more arms. Read more at <a href="https://thebookofshaders.com/07/" target="_blank" rel="noreferrer">Book of Shaders, Shapes (polar section)</a>.</p>',
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
 '<p>You will tile one shape into a grid. Tiling uses <code>fract</code> to repeat a small picture in every cell.</p><p>First, scale <code>uv</code> so one unit covers one tile. <code>uv * 6.0</code> gives 6 tiles across. Then <code>fract(uv)</code> gives the local spot inside each cell. That value always sits in <code>[0, 1)</code>. Subtract <code>0.5</code> so each cell is centered on <code>(0, 0)</code>. Now any shape you draw at the center shows up in every cell.</p><p>Try this: write <code>vec2 f = fract(uv) - 0.5;</code> then <code>m = smoothstep(0.005, -0.005, length(f) - 0.3);</code>. One disc becomes 36. Read more at <a href="https://thebookofshaders.com/09/" target="_blank" rel="noreferrer">Book of Shaders, Patterns</a>, and <a href="https://iquilezles.org/articles/sdfrepetition/" target="_blank" rel="noreferrer">IQ, Domain repetition</a>.</p>',
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
 '<p>You will use the cell number instead of the spot inside the cell. <code>floor(uv)</code> gives the cell number for the pixel.</p><p>For a checkerboard, write <code>mod(cell.x + cell.y, 2.0)</code>. That value flips between 0 and 1 across both axes. The cell number is the same for every pixel in one tile. So anything you build from it is also the same inside that tile.</p><p>Try this: set <code>cell = floor(uv)</code> and <code>m = mod(cell.x + cell.y, 2.0)</code>. You will see a checker grid. The next lessons use the same trick for per-cell random and brick offsets. Read more at <a href="https://thebookofshaders.com/09/" target="_blank" rel="noreferrer">Book of Shaders, Patterns</a>, and <a href="https://iquilezles.org/articles/sdfrepetition/" target="_blank" rel="noreferrer">IQ, Domain repetition</a>.</p>',
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
 '<p>You will give every cell its own random shade. You only need the cell number.</p><p>Use a hash. A hash takes a number and returns a steady-but-scrambled value. Same input gives the same output. Nearby inputs give very different outputs. The line is <code>fract(sin(dot(cell, vec2(12.9898, 78.233))) * 43758.5453)</code>. The big numbers scramble the bits inside <code>sin</code> and <code>fract</code>.</p><p>Try this: compute the hash from <code>cell</code> and output it as gray. You will see a grid where each cell has its own shade. This is the base for noise, Voronoi, and per-cell color. Read more at <a href="https://thebookofshaders.com/09/" target="_blank" rel="noreferrer">Book of Shaders, Patterns</a>, and <a href="https://iquilezles.org/articles/sdfrepetition/" target="_blank" rel="noreferrer">IQ, Domain repetition</a>.</p>',
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
 '<p>You will offset every other row by half a tile. That gives the brick pattern.</p><p>First, get the row number with <code>row = floor(uv.y)</code>. Then check if the row is odd. The test <code>mod(row, 2.0) == 1.0</code> is true on odd rows. On those rows, add <code>0.5</code> to <code>uv.x</code> before taking <code>fract</code>. The rest of the cell drawing stays the same as before.</p><p>Try this: shift odd rows by <code>0.5</code> and draw a disc per cell. The discs no longer line up in columns. You get the bricklayer''s pattern. Read more at <a href="https://thebookofshaders.com/09/" target="_blank" rel="noreferrer">Book of Shaders, Patterns</a>, and <a href="https://iquilezles.org/articles/sdfrepetition/" target="_blank" rel="noreferrer">IQ, Domain repetition</a>.</p>',
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
 '<p>You will mirror the whole canvas with one line. <code>abs(p)</code> folds the plane into the top-right corner. <code>abs</code> means take the size and drop the minus sign.</p><p>Every pixel now reads the same value as its three mirror twins. So one disc drawn at <code>(0.3, 0.2)</code> shows up in all four corners.</p><p>Try this: write <code>p = abs(p);</code> before you draw. One off-center disc becomes four. Read more at <a href="https://thebookofshaders.com/09/" target="_blank" rel="noreferrer">Book of Shaders, Patterns (mirror)</a>, and <a href="https://mercury.sexy/hg_sdf/" target="_blank" rel="noreferrer">hg_sdf, domain ops</a>.</p>',
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
 '<p>You will double the mirror. First fold the axes. Then fold the diagonals.</p><p>The recipe has three steps. Write <code>p = abs(p)</code> to fold into the top-right quadrant. Then rotate by <code>π/4</code> so the diagonals turn into axes. Write <code>p = abs(p)</code> again to fold along those new axes.</p><p>Try this: do the second <code>abs</code> after the rotation. One shape drawn after step 3 shows up 8 times around the canvas. Read more at <a href="https://thebookofshaders.com/09/" target="_blank" rel="noreferrer">Book of Shaders, Patterns (mirror)</a>, and <a href="https://mercury.sexy/hg_sdf/" target="_blank" rel="noreferrer">hg_sdf, domain ops</a>.</p>',
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
 '<p>You will fold the plane into N copies. This works for any N, not just 2, 4, or 8.</p><p>Three steps make the polar fold. First, switch to polar: <code>a = atan(p.y, p.x)</code> and <code>r = length(p)</code>. Second, wrap the angle into one slice of width <code>2π / N</code>: <code>a = mod(a, 6.28318 / N) - 3.14159 / N</code>. The minus part recenters the slice on <code>a = 0</code>. Third, switch back to x and y: <code>p = r * vec2(cos(a), sin(a))</code>.</p><p>Try this: set <code>N = 6</code> and draw a disc to the right of the origin. It will appear 6 times around the canvas, like a hex flower. Read more at <a href="https://thebookofshaders.com/09/" target="_blank" rel="noreferrer">Book of Shaders, Patterns (mirror)</a>, and <a href="https://mercury.sexy/hg_sdf/" target="_blank" rel="noreferrer">hg_sdf, domain ops</a>.</p>',
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
 '<p>You will spin the kaleidoscope. The folds stay, but the whole frame turns over time.</p><p>Rotate <code>p</code> by <code>u_time * 0.2</code> before the polar fold runs. The fold still uses <code>N = 6</code>. Only the coordinate frame moves under it. So the 6-fold pattern keeps its symmetry while it revolves.</p><p>Try this: set <code>rot = u_time * 0.2</code> and rotate <code>p</code> with it. At <code>u_time = 0</code> the image matches the last lesson. After that, it keeps spinning. Read more at <a href="https://thebookofshaders.com/09/" target="_blank" rel="noreferrer">Book of Shaders, Patterns (mirror)</a>, and <a href="https://mercury.sexy/hg_sdf/" target="_blank" rel="noreferrer">hg_sdf, domain ops</a>.</p>',
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
