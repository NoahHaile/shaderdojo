CREATE DATABASE shader_dojo;
\c shader_dojo;

-- ---------- account ----------
CREATE TABLE account
(
    id         VARCHAR(36) PRIMARY KEY,
    username   VARCHAR(255) UNIQUE NOT NULL,
    password   VARCHAR(255) NOT NULL,
    email      VARCHAR(255),
    country    VARCHAR(128),
    bio        VARCHAR(1024),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_account_username ON account (username);

-- ---------- course ----------
-- category is freeform (admin convention), e.g. 'Fundamentals', 'Art Tutorials',
-- 'Effects', 'Math'. UI groups courses by this column.
-- difficulty is one of: 'beginner' | 'intermediate' | 'advanced'.
-- display_order sorts courses within a category.
CREATE TABLE course
(
    id            VARCHAR(36) PRIMARY KEY,
    slug          VARCHAR(128) UNIQUE NOT NULL,
    title         VARCHAR(256) NOT NULL,
    description   TEXT,
    category      VARCHAR(64) NOT NULL DEFAULT 'Fundamentals',
    difficulty    VARCHAR(16) NOT NULL DEFAULT 'beginner',
    display_order INT NOT NULL DEFAULT 0,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_course_category_order ON course (category, display_order);

-- ---------- lesson ----------
-- description is HTML (sanitized in the frontend).
-- hashed_answer NULL = exploratory or awaiting `recompute-hashes`.
CREATE TABLE lesson
(
    id                        VARCHAR(36) PRIMARY KEY,
    course_id                 VARCHAR(36) NOT NULL REFERENCES course (id) ON DELETE CASCADE,
    slug                      VARCHAR(128) NOT NULL,
    display_order             INT NOT NULL DEFAULT 0,
    title                     VARCHAR(256) NOT NULL,
    description               TEXT,
    starter_vertex_shader     TEXT,
    starter_fragment_shader   TEXT,
    canonical_fragment_shader TEXT,
    hashed_answer             VARCHAR(128),
    created_at                TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (course_id, slug)
);

CREATE INDEX idx_lesson_course ON lesson (course_id, display_order);

-- ---------- comment ----------
CREATE TABLE comment
(
    id         VARCHAR(36) PRIMARY KEY,
    code       TEXT,
    content    VARCHAR(512),
    account    VARCHAR(36) REFERENCES account (id) ON DELETE SET NULL,
    lesson     VARCHAR(36) NOT NULL REFERENCES lesson (id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_comment_lesson ON comment (lesson);

-- ---------- attempt ----------
CREATE TABLE attempt
(
    id         VARCHAR(36) PRIMARY KEY,
    status     VARCHAR(32) NOT NULL,
    account    VARCHAR(36) NOT NULL REFERENCES account (id) ON DELETE CASCADE,
    lesson     VARCHAR(36) NOT NULL REFERENCES lesson (id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_attempt_account_lesson ON attempt (account, lesson);

-- ===========================================================
-- COURSES (Book of Shaders, chapter-aligned)
-- ===========================================================
-- Each course is one BoS chapter. Lessons inside a course are a chain:
-- lesson N+1.starter_fragment_shader is byte-identical to lesson N.canonical_fragment_shader.
-- All canonicals must produce a deterministic image at u_time = 20.0.

INSERT INTO course (id, slug, title, description, category, difficulty, display_order) VALUES
    ('11111111-0001-0000-0000-000000000000',
     'ch02-hello-world',
     'Chapter 02: Hello World',
     'Three lessons. Output one solid colour. Build a feel for gl_FragColor and the 0..1 component range.',
     'Book of Shaders', 'beginner', 0),
    ('11111111-0002-0000-0000-000000000000',
     'ch03-uniforms',
     'Chapter 03: Uniforms',
     'Four lessons. Read coordinates, react to time, and end on a pulsing tinted sky.',
     'Book of Shaders', 'beginner', 1),
    ('11111111-0003-0000-0000-000000000000',
     'ch05-shaping-functions',
     'Chapter 05: Shaping Functions',
     'Five lessons. step, smoothstep, and plotting culminating in a traced sine wave.',
     'Book of Shaders', 'beginner', 2),
    ('11111111-0004-0000-0000-000000000000',
     'ch06-colors',
     'Chapter 06: Colors',
     'Five lessons. Mix, gradients, HSV, vignette. Paint a sunset by the end.',
     'Book of Shaders', 'beginner', 3),
    ('11111111-0005-0000-0000-000000000000',
     'ch07-shapes',
     'Chapter 07: Shapes',
     'Five lessons. Distance fields and SDF composition. Draw a smiley face.',
     'Book of Shaders', 'intermediate', 4),
    ('11111111-0006-0000-0000-000000000000',
     'ch08-matrices',
     'Chapter 08: Matrices',
     'Five lessons. Rotation, scale, transform order. End on a rotating mandala.',
     'Book of Shaders', 'intermediate', 5),
    ('11111111-0007-0000-0000-000000000000',
     'ch09-patterns',
     'Chapter 09: Patterns',
     'Five lessons. fract, mod, floor. Tile your way to a diamond textile.',
     'Book of Shaders', 'intermediate', 6),
    ('11111111-0008-0000-0000-000000000000',
     'ch10-random',
     'Chapter 10: Random',
     'Five lessons. Deterministic hash noise. Build a starfield over an indigo sky.',
     'Book of Shaders', 'intermediate', 7),
    ('11111111-0009-0000-0000-000000000000',
     'ch11-noise',
     'Chapter 11: Noise',
     'Five lessons. Value noise, bilinear interpolation. Render a single cumulus cloud.',
     'Book of Shaders', 'advanced', 8),
    ('11111111-0010-0000-0000-000000000000',
     'ch12-cellular-noise',
     'Chapter 12: Cellular Noise',
     'Five lessons. Voronoi cells, neighbour search, bordered tessellation. Build a stone tile.',
     'Book of Shaders', 'advanced', 9),
    ('11111111-0011-0000-0000-000000000000',
     'ch13-fbm',
     'Chapter 13: Fractional Brownian Motion',
     'Five lessons. Octave layering, turbulence, height-banded terrain.',
     'Book of Shaders', 'advanced', 10),
    ('11111111-0012-0000-0000-000000000000',
     'ch15-image-operations',
     'Chapter 15+: Image Operations',
     'Five lessons. Synthesize a procedural image and then transform it. Blends, kernels, edge detection without textures.',
     'Book of Shaders', 'advanced', 11);

-- ===========================================================
-- COURSE 1 — Chapter 02: Hello World (3 lessons)
-- Theme: light one solid colour square.
-- ===========================================================

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000001-0001-0001-0000-000000000000',
    '11111111-0001-0000-0000-000000000000',
    'output-white',
    0,
    'Output white',
    '<p>Every fragment shader must set <code>gl_FragColor</code>, a four-component vector <code>(R, G, B, A)</code> where each channel is in <code>0.0..1.0</code>.</p>
<p>Set <code>gl_FragColor</code> to opaque <strong>white</strong>: all four components at <code>1.0</code>.</p>
<p>Reference: <a href="https://thebookofshaders.com/02/" target="_blank" rel="noreferrer">The Book of Shaders &mdash; Hello World</a></p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    // TODO: set gl_FragColor to opaque white.
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
    'void main() {
    gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000001-0002-0001-0000-000000000000',
    '11111111-0001-0000-0000-000000000000',
    'tinted-salmon',
    1,
    'Tinted salmon',
    '<p>White is a fine debug colour but boring. Replace it with ShaderDojo salmon: <code>vec4(0.996, 0.494, 0.494, 1.0)</code>.</p>
<p>Every value between <code>0.0</code> and <code>1.0</code> picks a colour. Try other triples to see how the channels combine.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
}',
    'void main() {
    gl_FragColor = vec4(0.996, 0.494, 0.494, 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000001-0003-0001-0000-000000000000',
    '11111111-0001-0000-0000-000000000000',
    'dim-the-salmon',
    2,
    'Dim the salmon',
    '<p>Halve each of the RGB components to render a darker salmon. Keep alpha at <code>1.0</code>.</p>
<p>New value: <code>vec4(0.498, 0.247, 0.247, 1.0)</code>.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    gl_FragColor = vec4(0.996, 0.494, 0.494, 1.0);
}',
    'void main() {
    gl_FragColor = vec4(0.498, 0.247, 0.247, 1.0);
}'
);

-- ===========================================================
-- COURSE 2 — Chapter 03: Uniforms (4 lessons)
-- Theme: build a pulsing tinted sky from uniforms only.
-- ===========================================================

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000002-0001-0002-0000-000000000000',
    '11111111-0002-0000-0000-000000000000',
    'red-on-x',
    0,
    'Red along x',
    '<p><code>gl_FragCoord.xy</code> is the pixel position in screen space. Divide by <code>u_resolution.xy</code> to get a normalized 0..1 coordinate <code>uv</code>.</p>
<p>Render the red channel as <code>uv.x</code> so the canvas fades from black on the left to red on the right.</p>
<p>Reference: <a href="https://thebookofshaders.com/03/" target="_blank" rel="noreferrer">The Book of Shaders &mdash; Uniforms</a></p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    // TODO: compute uv and use uv.x for the red channel.
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 color = vec3(uv.x, 0.0, 0.0);
    gl_FragColor = vec4(color, 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000002-0002-0002-0000-000000000000',
    '11111111-0002-0000-0000-000000000000',
    'uv-gradient',
    1,
    'Add the green axis',
    '<p>Now do the same for green using <code>uv.y</code>. The result is the canonical UV debug view: red on x, green on y, black in the bottom-left corner, yellow in the top-right.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 color = vec3(uv.x, 0.0, 0.0);
    gl_FragColor = vec4(color, 1.0);
}',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 color = vec3(uv.x, uv.y, 0.0);
    gl_FragColor = vec4(color, 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000002-0003-0002-0000-000000000000',
    '11111111-0002-0000-0000-000000000000',
    'pulse-with-time',
    2,
    'Pulse with time',
    '<p><code>u_time</code> is a uniform float that increases every frame. The validator runs at <code>t = 20.0</code> exactly &mdash; that frame is what the lesson hash captures.</p>
<p>Compute a pulse value <code>0.5 + 0.5 * sin(u_time)</code> and multiply it into the red and green channels. At <code>t = 20</code> the gradient lands at a specific dim brightness.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 color = vec3(uv.x, uv.y, 0.0);
    gl_FragColor = vec4(color, 1.0);
}',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float pulse = 0.5 + 0.5 * sin(u_time);
    vec3 color = vec3(uv.x * pulse, uv.y * pulse, 0.0);
    gl_FragColor = vec4(color, 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000002-0004-0002-0000-000000000000',
    '11111111-0002-0000-0000-000000000000',
    'sky-tint',
    3,
    'Sky tint',
    '<p>Blend the pulsing UV gradient toward a sky-blue <code>vec3(0.4, 0.6, 0.9)</code>. Use <code>mix</code> with <code>uv.y * 0.5</code> as the blend factor &mdash; the top of the canvas gets more sky.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float pulse = 0.5 + 0.5 * sin(u_time);
    vec3 color = vec3(uv.x * pulse, uv.y * pulse, 0.0);
    gl_FragColor = vec4(color, 1.0);
}',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float pulse = 0.5 + 0.5 * sin(u_time);
    vec3 color = vec3(uv.x * pulse, uv.y * pulse, 0.0);
    vec3 sky = vec3(0.4, 0.6, 0.9);
    color = mix(color, sky, uv.y * 0.5);
    gl_FragColor = vec4(color, 1.0);
}'
);

-- ===========================================================
-- COURSE 3 — Chapter 05: Shaping Functions (5 lessons)
-- Theme: plot curves with step / smoothstep.
-- ===========================================================

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000003-0001-0003-0000-000000000000',
    '11111111-0003-0000-0000-000000000000',
    'hard-split',
    0,
    'Hard split with step()',
    '<p><code>step(edge, x)</code> returns <code>0.0</code> when <code>x &lt; edge</code> and <code>1.0</code> otherwise. Use it to make the right half of the canvas white and the left half black.</p>
<p>Reference: <a href="https://thebookofshaders.com/05/" target="_blank" rel="noreferrer">The Book of Shaders &mdash; Shaping functions</a></p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    // TODO: use step() with edge 0.5 and uv.x.
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float m = step(0.5, uv.x);
    gl_FragColor = vec4(vec3(m), 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000003-0002-0003-0000-000000000000',
    '11111111-0003-0000-0000-000000000000',
    'soft-split',
    1,
    'Soft split with smoothstep()',
    '<p><code>smoothstep(a, b, x)</code> ramps from <code>0</code> to <code>1</code> across <code>[a, b]</code> with a smooth Hermite curve.</p>
<p>Replace <code>step(0.5, uv.x)</code> with <code>smoothstep(0.4, 0.6, uv.x)</code> to get a soft vertical fade.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float m = step(0.5, uv.x);
    gl_FragColor = vec4(vec3(m), 1.0);
}',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float m = smoothstep(0.4, 0.6, uv.x);
    gl_FragColor = vec4(vec3(m), 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000003-0003-0003-0000-000000000000',
    '11111111-0003-0000-0000-000000000000',
    'horizontal-band',
    2,
    'A horizontal band',
    '<p>Stack two <code>smoothstep</code>s back-to-back to draw a thin glowing band centered at <code>y = 0.5</code>:</p>
<pre><code>m = smoothstep(0.49, 0.50, uv.y) - smoothstep(0.50, 0.51, uv.y);</code></pre>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float m = smoothstep(0.4, 0.6, uv.x);
    gl_FragColor = vec4(vec3(m), 1.0);
}',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float m = smoothstep(0.49, 0.50, uv.y) - smoothstep(0.50, 0.51, uv.y);
    gl_FragColor = vec4(vec3(m), 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000003-0004-0003-0000-000000000000',
    '11111111-0003-0000-0000-000000000000',
    'plot-parabola',
    3,
    'Plot y = x squared',
    '<p>Replace the constant <code>0.5</code> band with one that follows the curve <code>y = x * x</code>. Compute the curve value at the current <code>uv.x</code>, then use two <code>smoothstep</code>s to draw a 1-pixel line where <code>uv.y</code> equals that value.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float m = smoothstep(0.49, 0.50, uv.y) - smoothstep(0.50, 0.51, uv.y);
    gl_FragColor = vec4(vec3(m), 1.0);
}',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float y = uv.x * uv.x;
    float m = smoothstep(y - 0.01, y, uv.y) - smoothstep(y, y + 0.01, uv.y);
    gl_FragColor = vec4(vec3(m), 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000003-0005-0003-0000-000000000000',
    '11111111-0003-0000-0000-000000000000',
    'plot-sine',
    4,
    'Plot a sine wave',
    '<p>Same plotting technique, different curve. Replace <code>uv.x * uv.x</code> with a sine wave shifted into the 0..1 range:</p>
<pre><code>y = 0.5 + 0.4 * sin(uv.x * 6.2831853);</code></pre>
<p>You should see a single full sine cycle traced across the canvas.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float y = uv.x * uv.x;
    float m = smoothstep(y - 0.01, y, uv.y) - smoothstep(y, y + 0.01, uv.y);
    gl_FragColor = vec4(vec3(m), 1.0);
}',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float y = 0.5 + 0.4 * sin(uv.x * 6.2831853);
    float m = smoothstep(y - 0.01, y, uv.y) - smoothstep(y, y + 0.01, uv.y);
    gl_FragColor = vec4(vec3(m), 1.0);
}'
);

-- ===========================================================
-- COURSE 4 — Chapter 06: Colors (5 lessons)
-- Theme: paint a sunset.
-- ===========================================================

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000004-0001-0004-0000-000000000000',
    '11111111-0004-0000-0000-000000000000',
    'solid-orange',
    0,
    'Solid orange',
    '<p>Fill the canvas with a single warm orange <code>vec3(1.0, 0.5, 0.1)</code>. This is the sunset starting point.</p>
<p>Reference: <a href="https://thebookofshaders.com/06/" target="_blank" rel="noreferrer">The Book of Shaders &mdash; Colors</a></p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: render solid orange.
    vec3 color = vec3(0.0);
    gl_FragColor = vec4(color, 1.0);
}',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 color = vec3(1.0, 0.5, 0.1);
    gl_FragColor = vec4(color, 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000004-0002-0004-0000-000000000000',
    '11111111-0004-0000-0000-000000000000',
    'sky-gradient',
    1,
    'Sky gradient',
    '<p><code>mix(a, b, t)</code> blends <code>a</code> and <code>b</code> linearly: <code>t = 0</code> returns <code>a</code>, <code>t = 1</code> returns <code>b</code>.</p>
<p>Mix orange at the bottom toward purple <code>vec3(0.3, 0.1, 0.5)</code> at the top, controlled by <code>uv.y</code>.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 color = vec3(1.0, 0.5, 0.1);
    gl_FragColor = vec4(color, 1.0);
}',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 orange = vec3(1.0, 0.5, 0.1);
    vec3 purple = vec3(0.3, 0.1, 0.5);
    vec3 color = mix(orange, purple, uv.y);
    gl_FragColor = vec4(color, 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000004-0003-0004-0000-000000000000',
    '11111111-0004-0000-0000-000000000000',
    'three-color-band',
    2,
    'Pink band in the middle',
    '<p>Chain two <code>mix</code> calls to pass through three colours: orange &rarr; pink &rarr; purple. Use <code>smoothstep</code>s to control where each transition lives.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 orange = vec3(1.0, 0.5, 0.1);
    vec3 purple = vec3(0.3, 0.1, 0.5);
    vec3 color = mix(orange, purple, uv.y);
    gl_FragColor = vec4(color, 1.0);
}',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 orange = vec3(1.0, 0.5, 0.1);
    vec3 pink   = vec3(1.0, 0.4, 0.6);
    vec3 purple = vec3(0.3, 0.1, 0.5);
    vec3 c1 = mix(orange, pink, smoothstep(0.0, 0.5, uv.y));
    vec3 color = mix(c1, purple, smoothstep(0.5, 1.0, uv.y));
    gl_FragColor = vec4(color, 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000004-0004-0004-0000-000000000000',
    '11111111-0004-0000-0000-000000000000',
    'hsv-horizon',
    3,
    'HSV horizon',
    '<p><strong>HSV</strong> (hue, saturation, value) puts the rainbow on a single axis. The canonical conversion <code>hsv2rgb</code> is six lines using a packed <code>vec4</code> trick.</p>
<p>Pick hue by <code>uv.y</code> (orange at the bottom, purple at the top), saturation <code>0.7</code>, value <code>1.0</code>. The colours land in the same place but feel less hand-tuned.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 orange = vec3(1.0, 0.5, 0.1);
    vec3 pink   = vec3(1.0, 0.4, 0.6);
    vec3 purple = vec3(0.3, 0.1, 0.5);
    vec3 c1 = mix(orange, pink, smoothstep(0.0, 0.5, uv.y));
    vec3 color = mix(c1, purple, smoothstep(0.5, 1.0, uv.y));
    gl_FragColor = vec4(color, 1.0);
}',
    'vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float hue = mix(0.08, 0.75, uv.y);
    vec3 color = hsv2rgb(vec3(hue, 0.7, 1.0));
    gl_FragColor = vec4(color, 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000004-0005-0004-0000-000000000000',
    '11111111-0004-0000-0000-000000000000',
    'vignette',
    4,
    'Add a vignette',
    '<p>Darken the corners. Compute <code>length(uv - 0.5)</code>, push it through <code>smoothstep(0.3, 0.7, d)</code>, invert it, and multiply that vignette into the colour.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float hue = mix(0.08, 0.75, uv.y);
    vec3 color = hsv2rgb(vec3(hue, 0.7, 1.0));
    gl_FragColor = vec4(color, 1.0);
}',
    'vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float hue = mix(0.08, 0.75, uv.y);
    vec3 color = hsv2rgb(vec3(hue, 0.7, 1.0));
    float vig = 1.0 - smoothstep(0.3, 0.7, length(uv - 0.5));
    color *= vig;
    gl_FragColor = vec4(color, 1.0);
}'
);

-- ===========================================================
-- COURSE 5 — Chapter 07: Shapes (5 lessons)
-- Theme: draw a smiley face.
-- ===========================================================

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000005-0001-0005-0000-000000000000',
    '11111111-0005-0000-0000-000000000000',
    'one-eye',
    0,
    'A single eye',
    '<p>A <strong>distance field</strong> tells you how far each pixel is from a feature. For a circle centered at <code>c</code>, the SDF is just <code>length(uv - c)</code>.</p>
<p>Draw a small white disc centered at <code>(0.35, 0.65)</code> with radius <code>0.05</code>. Antialias the edge with <code>smoothstep</code>.</p>
<p>Reference: <a href="https://thebookofshaders.com/07/" target="_blank" rel="noreferrer">The Book of Shaders &mdash; Shapes</a></p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: draw a small white disc at (0.35, 0.65).
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float d = length(uv - vec2(0.35, 0.65));
    float m = 1.0 - smoothstep(0.04, 0.06, d);
    gl_FragColor = vec4(vec3(m), 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000005-0002-0005-0000-000000000000',
    '11111111-0005-0000-0000-000000000000',
    'two-eyes',
    1,
    'Both eyes',
    '<p>Two circles, one shape. Take the minimum of two distance fields: the closer feature wins.</p>
<p>Add a second eye at <code>(0.65, 0.65)</code>. Use <code>min(d1, d2)</code> as the combined distance.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float d = length(uv - vec2(0.35, 0.65));
    float m = 1.0 - smoothstep(0.04, 0.06, d);
    gl_FragColor = vec4(vec3(m), 1.0);
}',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float d1 = length(uv - vec2(0.35, 0.65));
    float d2 = length(uv - vec2(0.65, 0.65));
    float d = min(d1, d2);
    float m = 1.0 - smoothstep(0.04, 0.06, d);
    gl_FragColor = vec4(vec3(m), 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000005-0003-0005-0000-000000000000',
    '11111111-0005-0000-0000-000000000000',
    'add-a-smile',
    2,
    'Add a smile',
    '<p>A ring is the difference of two thresholded discs at the same center. <code>step(uv.y, 0.5)</code> keeps only the bottom half.</p>
<p>Draw a ring centered at <code>(0.5, 0.5)</code> with inner radius ~0.19 and outer radius ~0.21, then mask to the lower half. Combine with the eyes via <code>max</code>.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float d1 = length(uv - vec2(0.35, 0.65));
    float d2 = length(uv - vec2(0.65, 0.65));
    float d = min(d1, d2);
    float m = 1.0 - smoothstep(0.04, 0.06, d);
    gl_FragColor = vec4(vec3(m), 1.0);
}',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float d1 = length(uv - vec2(0.35, 0.65));
    float d2 = length(uv - vec2(0.65, 0.65));
    float eyes = 1.0 - smoothstep(0.04, 0.06, min(d1, d2));
    float dm = length(uv - vec2(0.5, 0.5));
    float ring = smoothstep(0.18, 0.19, dm) - smoothstep(0.21, 0.22, dm);
    float smile = ring * step(uv.y, 0.5);
    float m = max(eyes, smile);
    gl_FragColor = vec4(vec3(m), 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000005-0004-0005-0000-000000000000',
    '11111111-0005-0000-0000-000000000000',
    'head-outline',
    3,
    'Outline the head',
    '<p>Add one more ring &mdash; the head outline. Same technique, different radii: a thin ring centered at <code>(0.5, 0.5)</code> with inner ~0.40 and outer ~0.42.</p>
<p>Combine all three features (eyes, smile, head outline) with <code>max</code>.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float d1 = length(uv - vec2(0.35, 0.65));
    float d2 = length(uv - vec2(0.65, 0.65));
    float eyes = 1.0 - smoothstep(0.04, 0.06, min(d1, d2));
    float dm = length(uv - vec2(0.5, 0.5));
    float ring = smoothstep(0.18, 0.19, dm) - smoothstep(0.21, 0.22, dm);
    float smile = ring * step(uv.y, 0.5);
    float m = max(eyes, smile);
    gl_FragColor = vec4(vec3(m), 1.0);
}',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float d1 = length(uv - vec2(0.35, 0.65));
    float d2 = length(uv - vec2(0.65, 0.65));
    float eyes = 1.0 - smoothstep(0.04, 0.06, min(d1, d2));
    float dm = length(uv - vec2(0.5, 0.5));
    float ring = smoothstep(0.18, 0.19, dm) - smoothstep(0.21, 0.22, dm);
    float smile = ring * step(uv.y, 0.5);
    float head = smoothstep(0.39, 0.40, dm) - smoothstep(0.41, 0.42, dm);
    float m = max(max(eyes, smile), head);
    gl_FragColor = vec4(vec3(m), 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000005-0005-0005-0000-000000000000',
    '11111111-0005-0000-0000-000000000000',
    'tint-and-fill',
    4,
    'Yellow head, dark features',
    '<p>Replace the outline with a filled yellow disc. Layer the features on top in black using <code>mix</code>: background &rarr; yellow head &rarr; dark features.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float d1 = length(uv - vec2(0.35, 0.65));
    float d2 = length(uv - vec2(0.65, 0.65));
    float eyes = 1.0 - smoothstep(0.04, 0.06, min(d1, d2));
    float dm = length(uv - vec2(0.5, 0.5));
    float ring = smoothstep(0.18, 0.19, dm) - smoothstep(0.21, 0.22, dm);
    float smile = ring * step(uv.y, 0.5);
    float head = smoothstep(0.39, 0.40, dm) - smoothstep(0.41, 0.42, dm);
    float m = max(max(eyes, smile), head);
    gl_FragColor = vec4(vec3(m), 1.0);
}',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float d1 = length(uv - vec2(0.35, 0.65));
    float d2 = length(uv - vec2(0.65, 0.65));
    float eyes = 1.0 - smoothstep(0.04, 0.06, min(d1, d2));
    float dm = length(uv - vec2(0.5, 0.5));
    float ring = smoothstep(0.18, 0.19, dm) - smoothstep(0.21, 0.22, dm);
    float smile = ring * step(uv.y, 0.5);
    float head = 1.0 - smoothstep(0.39, 0.41, dm);
    float features = max(eyes, smile);
    vec3 yellow = vec3(1.0, 0.85, 0.2);
    vec3 color = mix(vec3(0.0), yellow, head);
    color = mix(color, vec3(0.0), features);
    gl_FragColor = vec4(color, 1.0);
}'
);

-- ===========================================================
-- COURSE 6 — Chapter 08: Matrices (5 lessons)
-- Theme: rotating mandala.
-- ===========================================================

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000006-0001-0006-0000-000000000000',
    '11111111-0006-0000-0000-000000000000',
    'centered-square',
    0,
    'A centered square',
    '<p>Shift coordinates so <code>(0, 0)</code> is the canvas center: <code>p = uv - 0.5</code>. Then <code>max(abs(p.x), abs(p.y))</code> is the Chebyshev distance &mdash; a square SDF.</p>
<p>Draw a filled white square of half-side <code>0.2</code> centered on the canvas.</p>
<p>Reference: <a href="https://thebookofshaders.com/08/" target="_blank" rel="noreferrer">The Book of Shaders &mdash; Matrices</a></p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: square SDF using max(abs(p.x), abs(p.y)).
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 p = uv - 0.5;
    float box = max(abs(p.x), abs(p.y));
    float m = 1.0 - step(0.2, box);
    gl_FragColor = vec4(vec3(m), 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000006-0002-0006-0000-000000000000',
    '11111111-0006-0000-0000-000000000000',
    'rotate-45',
    1,
    'Rotate 45 degrees',
    '<p>A 2D rotation matrix:</p>
<pre><code>mat2 R = mat2(cos(a), -sin(a),
              sin(a),  cos(a));</code></pre>
<p>Apply it to <code>p</code> with <code>a = 0.7853981</code> (45 degrees in radians) before computing the SDF. The square becomes a diamond.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 p = uv - 0.5;
    float box = max(abs(p.x), abs(p.y));
    float m = 1.0 - step(0.2, box);
    gl_FragColor = vec4(vec3(m), 1.0);
}',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 p = uv - 0.5;
    float a = 0.7853981;
    mat2 R = mat2(cos(a), -sin(a), sin(a), cos(a));
    p = R * p;
    float box = max(abs(p.x), abs(p.y));
    float m = 1.0 - step(0.2, box);
    gl_FragColor = vec4(vec3(m), 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000006-0003-0006-0000-000000000000',
    '11111111-0006-0000-0000-000000000000',
    'rotate-by-time',
    2,
    'Rotate by u_time',
    '<p>Drive the rotation angle from <code>u_time</code> instead of a constant. The validator hashes the frame at <code>t = 20.0</code>, which lands the square at a specific angle in the hash.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 p = uv - 0.5;
    float a = 0.7853981;
    mat2 R = mat2(cos(a), -sin(a), sin(a), cos(a));
    p = R * p;
    float box = max(abs(p.x), abs(p.y));
    float m = 1.0 - step(0.2, box);
    gl_FragColor = vec4(vec3(m), 1.0);
}',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 p = uv - 0.5;
    float a = u_time;
    mat2 R = mat2(cos(a), -sin(a), sin(a), cos(a));
    p = R * p;
    float box = max(abs(p.x), abs(p.y));
    float m = 1.0 - step(0.2, box);
    gl_FragColor = vec4(vec3(m), 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000006-0004-0006-0000-000000000000',
    '11111111-0006-0000-0000-000000000000',
    'nested-squares',
    3,
    'Nested squares (mandala)',
    '<p>Three concentric rotated rings. Loop over <code>i = 0, 1, 2</code>: each iteration uses a different angle (<code>u_time + i * 0.5236</code>) and a smaller scale. Combine the rings with <code>max</code>.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 p = uv - 0.5;
    float a = u_time;
    mat2 R = mat2(cos(a), -sin(a), sin(a), cos(a));
    p = R * p;
    float box = max(abs(p.x), abs(p.y));
    float m = 1.0 - step(0.2, box);
    gl_FragColor = vec4(vec3(m), 1.0);
}',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 p = uv - 0.5;
    float mask = 0.0;
    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        float a = u_time + fi * 0.5236;
        mat2 R = mat2(cos(a), -sin(a), sin(a), cos(a));
        vec2 q = R * p;
        float scale = 0.35 - fi * 0.10;
        float box = max(abs(q.x), abs(q.y));
        float ring = step(scale - 0.02, box) * step(box, scale);
        mask = max(mask, ring);
    }
    gl_FragColor = vec4(vec3(mask), 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000006-0005-0006-0000-000000000000',
    '11111111-0006-0000-0000-000000000000',
    'symmetric-color',
    4,
    'Colour by angle',
    '<p><code>atan(p.y, p.x)</code> returns the angle of <code>p</code> from the origin. Use it to colour each pixel based on its angular position &mdash; the classic three-cosine palette <code>0.5 + 0.5 * cos(angle + offsets)</code>.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 p = uv - 0.5;
    float mask = 0.0;
    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        float a = u_time + fi * 0.5236;
        mat2 R = mat2(cos(a), -sin(a), sin(a), cos(a));
        vec2 q = R * p;
        float scale = 0.35 - fi * 0.10;
        float box = max(abs(q.x), abs(q.y));
        float ring = step(scale - 0.02, box) * step(box, scale);
        mask = max(mask, ring);
    }
    gl_FragColor = vec4(vec3(mask), 1.0);
}',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 p = uv - 0.5;
    vec3 color = vec3(0.0);
    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        float a = u_time + fi * 0.5236;
        mat2 R = mat2(cos(a), -sin(a), sin(a), cos(a));
        vec2 q = R * p;
        float scale = 0.35 - fi * 0.10;
        float box = max(abs(q.x), abs(q.y));
        float ring = step(scale - 0.02, box) * step(box, scale);
        float ang = atan(q.y, q.x);
        vec3 c = 0.5 + 0.5 * cos(ang + vec3(0.0, 2.094, 4.188));
        color = max(color, c * ring);
    }
    gl_FragColor = vec4(color, 1.0);
}'
);

-- ===========================================================
-- COURSE 7 — Chapter 09: Patterns (5 lessons)
-- Theme: textile tiles.
-- ===========================================================

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000007-0001-0007-0000-000000000000',
    '11111111-0007-0000-0000-000000000000',
    'checkerboard',
    0,
    'Checkerboard',
    '<p><code>floor</code> and <code>mod</code> turn continuous coordinates into integer cells. The XOR of two parities is a checker pattern.</p>
<p>Render a 4&times;4 checkerboard with <code>mod(floor(uv.x * 4.0) + floor(uv.y * 4.0), 2.0)</code>.</p>
<p>Reference: <a href="https://thebookofshaders.com/09/" target="_blank" rel="noreferrer">The Book of Shaders &mdash; Patterns</a></p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: 4x4 checkerboard.
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float c = mod(floor(uv.x * 4.0) + floor(uv.y * 4.0), 2.0);
    gl_FragColor = vec4(vec3(c), 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000007-0002-0007-0000-000000000000',
    '11111111-0007-0000-0000-000000000000',
    'vertical-stripes',
    1,
    'Vertical stripes',
    '<p>Drop the <code>uv.y</code> term and use a higher frequency on <code>uv.x</code>:</p>
<pre><code>c = mod(floor(uv.x * 8.0), 2.0);</code></pre>
<p>Eight black-and-white stripes.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float c = mod(floor(uv.x * 4.0) + floor(uv.y * 4.0), 2.0);
    gl_FragColor = vec4(vec3(c), 1.0);
}',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float c = mod(floor(uv.x * 8.0), 2.0);
    gl_FragColor = vec4(vec3(c), 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000007-0003-0007-0000-000000000000',
    '11111111-0007-0000-0000-000000000000',
    'brick-offset',
    2,
    'Brick offset',
    '<p>Real bricks alternate the horizontal offset between rows. Compute the row index, add half a brick on odd rows, then use <code>fract</code> to draw mortar gaps at cell edges.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float c = mod(floor(uv.x * 8.0), 2.0);
    gl_FragColor = vec4(vec3(c), 1.0);
}',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float row = floor(uv.y * 8.0);
    float shift = mod(row, 2.0) * 0.125;
    vec2 cell = fract(vec2((uv.x + shift) * 4.0, uv.y * 8.0));
    float m = step(0.05, cell.x) * step(cell.x, 0.95) * step(0.05, cell.y) * step(cell.y, 0.95);
    gl_FragColor = vec4(vec3(m), 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000007-0004-0007-0000-000000000000',
    '11111111-0007-0000-0000-000000000000',
    'polka-dots',
    3,
    'Polka dots',
    '<p>Inside each cell, <code>fract</code> gives a local <code>(0..1, 0..1)</code> coordinate. Shift it to <code>-0.5..0.5</code> and use <code>length</code> to draw a circle in each cell.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float row = floor(uv.y * 8.0);
    float shift = mod(row, 2.0) * 0.125;
    vec2 cell = fract(vec2((uv.x + shift) * 4.0, uv.y * 8.0));
    float m = step(0.05, cell.x) * step(cell.x, 0.95) * step(0.05, cell.y) * step(cell.y, 0.95);
    gl_FragColor = vec4(vec3(m), 1.0);
}',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 cell = fract(uv * 8.0) - 0.5;
    float d = length(cell);
    float m = 1.0 - smoothstep(0.20, 0.25, d);
    gl_FragColor = vec4(vec3(m), 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000007-0005-0007-0000-000000000000',
    '11111111-0007-0000-0000-000000000000',
    'diamond-tiles',
    4,
    'Diamond tiles',
    '<p>Rotate each cell coordinate 45 degrees before computing the square SDF. The same per-cell logic now produces diamonds instead of dots.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 cell = fract(uv * 8.0) - 0.5;
    float d = length(cell);
    float m = 1.0 - smoothstep(0.20, 0.25, d);
    gl_FragColor = vec4(vec3(m), 1.0);
}',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 cell = fract(uv * 8.0) - 0.5;
    float a = 0.7853981;
    mat2 R = mat2(cos(a), -sin(a), sin(a), cos(a));
    cell = R * cell;
    float box = max(abs(cell.x), abs(cell.y));
    float m = 1.0 - smoothstep(0.30, 0.34, box);
    gl_FragColor = vec4(vec3(m), 1.0);
}'
);

-- ===========================================================
-- COURSE 8 — Chapter 10: Random (5 lessons)
-- Theme: build a starfield.
-- ===========================================================

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000008-0001-0008-0000-000000000000',
    '11111111-0008-0000-0000-000000000000',
    'tv-static',
    0,
    'TV static',
    '<p>Shaders do not have a built-in random number generator. The classic hash <code>fract(sin(dot(p, k)) * c)</code> is fast and deterministic.</p>
<p>Run it on <code>uv</code> directly to get a different value per pixel &mdash; TV static.</p>
<p>Reference: <a href="https://thebookofshaders.com/10/" target="_blank" rel="noreferrer">The Book of Shaders &mdash; Random</a></p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: hash uv with fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453).
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
    'float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float r = rand(uv);
    gl_FragColor = vec4(vec3(r), 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000008-0002-0008-0000-000000000000',
    '11111111-0008-0000-0000-000000000000',
    'per-tile-random',
    1,
    'Per-tile random',
    '<p>Hash a tile coordinate instead of a pixel coordinate: <code>floor(uv * 12.0)</code>. Same hash, different input &mdash; the result is one random value per 12&times;12 cell.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float r = rand(uv);
    gl_FragColor = vec4(vec3(r), 1.0);
}',
    'float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 tile = floor(uv * 12.0);
    float r = rand(tile);
    gl_FragColor = vec4(vec3(r), 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000008-0003-0008-0000-000000000000',
    '11111111-0008-0000-0000-000000000000',
    'sparse-stars',
    2,
    'Sparse stars',
    '<p>Threshold the random with <code>step(0.92, r)</code>: only cells whose hash is above the threshold light up. The threshold controls density.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 tile = floor(uv * 12.0);
    float r = rand(tile);
    gl_FragColor = vec4(vec3(r), 1.0);
}',
    'float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 tile = floor(uv * 12.0);
    float r = rand(tile);
    float star = step(0.92, r);
    gl_FragColor = vec4(vec3(star), 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000008-0004-0008-0000-000000000000',
    '11111111-0008-0000-0000-000000000000',
    'vary-brightness',
    3,
    'Vary the brightness',
    '<p>Stars are not all the same brightness. Hash a slightly offset coordinate (<code>tile + 1.0</code>) for a second independent random value, then multiply into the star mask.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 tile = floor(uv * 12.0);
    float r = rand(tile);
    float star = step(0.92, r);
    gl_FragColor = vec4(vec3(star), 1.0);
}',
    'float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 tile = floor(uv * 12.0);
    float r = rand(tile);
    float star = step(0.92, r);
    float brightness = rand(tile + 1.0);
    gl_FragColor = vec4(vec3(star * brightness), 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000008-0005-0008-0000-000000000000',
    '11111111-0008-0000-0000-000000000000',
    'indigo-sky',
    4,
    'Indigo sky background',
    '<p>Mix a vertical gradient from black at the horizon to indigo at the top, then add the star intensities on top. The starfield reads like a night sky now.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 tile = floor(uv * 12.0);
    float r = rand(tile);
    float star = step(0.92, r);
    float brightness = rand(tile + 1.0);
    gl_FragColor = vec4(vec3(star * brightness), 1.0);
}',
    'float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 tile = floor(uv * 12.0);
    float r = rand(tile);
    float star = step(0.92, r);
    float brightness = rand(tile + 1.0);
    vec3 sky = mix(vec3(0.0), vec3(0.15, 0.05, 0.30), uv.y);
    vec3 color = sky + vec3(star * brightness);
    gl_FragColor = vec4(color, 1.0);
}'
);

-- ===========================================================
-- COURSE 9 — Chapter 11: Noise (5 lessons)
-- Theme: build a cumulus cloud.
-- ===========================================================

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000009-0001-0009-0000-000000000000',
    '11111111-0009-0000-0000-000000000000',
    'noise-1d',
    0,
    '1D value noise',
    '<p>Per-tile random looks blocky. Value noise smooths it by interpolating between random values at integer points.</p>
<p>Sample <code>rand(floor(x))</code> and <code>rand(floor(x) + 1.0)</code>, then <code>smoothstep</code>-interpolate between them by the fractional part.</p>
<p>Reference: <a href="https://thebookofshaders.com/11/" target="_blank" rel="noreferrer">The Book of Shaders &mdash; Noise</a></p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: 1D value noise sampled across uv.x.
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
    'float rand(float x) {
    return fract(sin(x * 12.9898) * 43758.5453);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float x = uv.x * 4.0;
    float i = floor(x);
    float f = fract(x);
    f = smoothstep(0.0, 1.0, f);
    float n = mix(rand(i), rand(i + 1.0), f);
    gl_FragColor = vec4(vec3(n), 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000009-0002-0009-0000-000000000000',
    '11111111-0009-0000-0000-000000000000',
    'noise-2d',
    1,
    '2D value noise',
    '<p>Same idea, two dimensions. Hash four corner values per integer cell and bilinearly interpolate.</p>
<p>This <code>noise()</code> function is the building block for the rest of the chapter.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'float rand(float x) {
    return fract(sin(x * 12.9898) * 43758.5453);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float x = uv.x * 4.0;
    float i = floor(x);
    float f = fract(x);
    f = smoothstep(0.0, 1.0, f);
    float n = mix(rand(i), rand(i + 1.0), f);
    gl_FragColor = vec4(vec3(n), 1.0);
}',
    'float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = smoothstep(0.0, 1.0, f);
    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float n = noise(uv * 4.0);
    gl_FragColor = vec4(vec3(n), 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000009-0003-0009-0000-000000000000',
    '11111111-0009-0000-0000-000000000000',
    'threshold-blob',
    2,
    'Threshold into a blob',
    '<p>Push the noise through <code>smoothstep(0.4, 0.6, n)</code> &mdash; everything below 0.4 becomes black, everything above 0.6 becomes white, in-between smoothly fades.</p>
<p>The result is an organic blob.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = smoothstep(0.0, 1.0, f);
    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float n = noise(uv * 4.0);
    gl_FragColor = vec4(vec3(n), 1.0);
}',
    'float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = smoothstep(0.0, 1.0, f);
    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float n = noise(uv * 4.0);
    float blob = smoothstep(0.4, 0.6, n);
    gl_FragColor = vec4(vec3(blob), 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000009-0004-0009-0000-000000000000',
    '11111111-0009-0000-0000-000000000000',
    'cloud-soft-edges',
    3,
    'Soft cloud against sky',
    '<p>Drop the hard threshold. Use the raw <code>noise</code> value as the blend factor between sky blue and white. Now the blob has soft edges.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = smoothstep(0.0, 1.0, f);
    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float n = noise(uv * 4.0);
    float blob = smoothstep(0.4, 0.6, n);
    gl_FragColor = vec4(vec3(blob), 1.0);
}',
    'float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = smoothstep(0.0, 1.0, f);
    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float n = noise(uv * 4.0);
    vec3 sky = vec3(0.4, 0.6, 0.9);
    vec3 cloud = vec3(1.0);
    vec3 color = mix(sky, cloud, n);
    gl_FragColor = vec4(color, 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000009-0005-0009-0000-000000000000',
    '11111111-0009-0000-0000-000000000000',
    'finer-detail',
    4,
    'Finer detail',
    '<p>Sample the noise at a higher frequency (<code>uv * 12.0</code>). The cloud picks up fine texture; the shape becomes more cumulus, less smear.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = smoothstep(0.0, 1.0, f);
    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float n = noise(uv * 4.0);
    vec3 sky = vec3(0.4, 0.6, 0.9);
    vec3 cloud = vec3(1.0);
    vec3 color = mix(sky, cloud, n);
    gl_FragColor = vec4(color, 1.0);
}',
    'float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = smoothstep(0.0, 1.0, f);
    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float n = noise(uv * 12.0);
    vec3 sky = vec3(0.4, 0.6, 0.9);
    vec3 cloud = vec3(1.0);
    vec3 color = mix(sky, cloud, n);
    gl_FragColor = vec4(color, 1.0);
}'
);

-- ===========================================================
-- COURSE 10 — Chapter 12: Cellular Noise / Voronoi (5 lessons)
-- Theme: stone tile.
-- ===========================================================

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000010-0001-0010-0000-000000000000',
    '11111111-0010-0000-0000-000000000000',
    'grid-distance',
    0,
    'Distance to grid centers',
    '<p>Divide the canvas into a 6&times;6 grid. For each pixel, find its <code>fract</code> position inside its cell, then compute distance from the cell center <code>(0.5, 0.5)</code>.</p>
<p>Render that distance as brightness &mdash; you get a tile pattern.</p>
<p>Reference: <a href="https://thebookofshaders.com/12/" target="_blank" rel="noreferrer">The Book of Shaders &mdash; Cellular noise</a></p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: distance from cell center on a 6x6 grid.
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 p = uv * 6.0;
    vec2 f = fract(p);
    float d = length(f - vec2(0.5));
    gl_FragColor = vec4(vec3(d), 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000010-0002-0010-0000-000000000000',
    '11111111-0010-0000-0000-000000000000',
    'random-offset',
    1,
    'Random offset per cell',
    '<p>Replace the fixed center with a random point per cell. Hash the cell coordinate twice (once shifted) to get a 2D position in <code>[0, 1)</code>.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 p = uv * 6.0;
    vec2 f = fract(p);
    float d = length(f - vec2(0.5));
    gl_FragColor = vec4(vec3(d), 1.0);
}',
    'float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 p = uv * 6.0;
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 point = vec2(rand(i), rand(i + 1.0));
    float d = length(f - point);
    gl_FragColor = vec4(vec3(d), 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000010-0003-0010-0000-000000000000',
    '11111111-0010-0000-0000-000000000000',
    'neighbour-search',
    2,
    '3x3 neighbour search',
    '<p>A point in a neighbouring cell can be closer than the current cell point. Loop over the 3&times;3 block of cells around the current one, find the minimum distance.</p>
<p>This is the true Voronoi tessellation.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 p = uv * 6.0;
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 point = vec2(rand(i), rand(i + 1.0));
    float d = length(f - point);
    gl_FragColor = vec4(vec3(d), 1.0);
}',
    'float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 p = uv * 6.0;
    vec2 i = floor(p);
    vec2 f = fract(p);
    float minD = 2.0;
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 n = vec2(float(x), float(y));
            vec2 point = n + vec2(rand(i + n), rand(i + n + 1.0));
            float d = length(point - f);
            minD = min(minD, d);
        }
    }
    gl_FragColor = vec4(vec3(minD), 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000010-0004-0010-0000-000000000000',
    '11111111-0010-0000-0000-000000000000',
    'cell-colors',
    3,
    'Cell colours',
    '<p>Track which neighbour was closest and assign it a hue. Reuse <code>hsv2rgb</code> from Chapter 06.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 p = uv * 6.0;
    vec2 i = floor(p);
    vec2 f = fract(p);
    float minD = 2.0;
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 n = vec2(float(x), float(y));
            vec2 point = n + vec2(rand(i + n), rand(i + n + 1.0));
            float d = length(point - f);
            minD = min(minD, d);
        }
    }
    gl_FragColor = vec4(vec3(minD), 1.0);
}',
    'float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 q = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(q - K.xxx, 0.0, 1.0), c.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 p = uv * 6.0;
    vec2 i = floor(p);
    vec2 f = fract(p);
    float minD = 2.0;
    vec2 nearest = vec2(0.0);
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 n = vec2(float(x), float(y));
            vec2 point = n + vec2(rand(i + n), rand(i + n + 1.0));
            float d = length(point - f);
            if (d < minD) {
                minD = d;
                nearest = i + n;
            }
        }
    }
    vec3 color = hsv2rgb(vec3(rand(nearest), 0.6, 1.0));
    gl_FragColor = vec4(color, 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000010-0005-0010-0000-000000000000',
    '11111111-0010-0000-0000-000000000000',
    'borders',
    4,
    'Draw the borders',
    '<p>A pixel is on a cell border when the distance to the nearest point is close to the distance to the second-nearest point. Track both, then darken when their difference is small.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 q = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(q - K.xxx, 0.0, 1.0), c.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 p = uv * 6.0;
    vec2 i = floor(p);
    vec2 f = fract(p);
    float minD = 2.0;
    vec2 nearest = vec2(0.0);
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 n = vec2(float(x), float(y));
            vec2 point = n + vec2(rand(i + n), rand(i + n + 1.0));
            float d = length(point - f);
            if (d < minD) {
                minD = d;
                nearest = i + n;
            }
        }
    }
    vec3 color = hsv2rgb(vec3(rand(nearest), 0.6, 1.0));
    gl_FragColor = vec4(color, 1.0);
}',
    'float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 q = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(q - K.xxx, 0.0, 1.0), c.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 p = uv * 6.0;
    vec2 i = floor(p);
    vec2 f = fract(p);
    float minD = 2.0;
    float minD2 = 2.0;
    vec2 nearest = vec2(0.0);
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 n = vec2(float(x), float(y));
            vec2 point = n + vec2(rand(i + n), rand(i + n + 1.0));
            float d = length(point - f);
            if (d < minD) {
                minD2 = minD;
                minD = d;
                nearest = i + n;
            } else if (d < minD2) {
                minD2 = d;
            }
        }
    }
    vec3 color = hsv2rgb(vec3(rand(nearest), 0.5, 0.9));
    float border = smoothstep(0.0, 0.05, minD2 - minD);
    color *= border;
    gl_FragColor = vec4(color, 1.0);
}'
);

-- ===========================================================
-- COURSE 11 — Chapter 13: Fractional Brownian Motion (5 lessons)
-- Theme: terrain heightmap.
-- ===========================================================

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000011-0001-0011-0000-000000000000',
    '11111111-0011-0000-0000-000000000000',
    'single-octave',
    0,
    'A single octave',
    '<p>Start with the 2D <code>noise</code> function from Chapter 11. Render it once at frequency 4 &mdash; soft, low-detail.</p>
<p>Reference: <a href="https://thebookofshaders.com/13/" target="_blank" rel="noreferrer">The Book of Shaders &mdash; Fractional Brownian Motion</a></p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: 2D noise at frequency 4.
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
    'float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = smoothstep(0.0, 1.0, f);
    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float h = noise(uv * 4.0);
    gl_FragColor = vec4(vec3(h), 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000011-0002-0011-0000-000000000000',
    '11111111-0011-0000-0000-000000000000',
    'two-octaves',
    1,
    'Sum two octaves',
    '<p>Add a second noise sample at double frequency and half amplitude. Divide by the total amplitude (<code>1.5</code>) so the output stays in 0..1.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = smoothstep(0.0, 1.0, f);
    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float h = noise(uv * 4.0);
    gl_FragColor = vec4(vec3(h), 1.0);
}',
    'float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = smoothstep(0.0, 1.0, f);
    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float h = (noise(uv * 4.0) + 0.5 * noise(uv * 8.0)) / 1.5;
    gl_FragColor = vec4(vec3(h), 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000011-0003-0011-0000-000000000000',
    '11111111-0011-0000-0000-000000000000',
    'four-octave-fbm',
    2,
    'Four-octave fBm loop',
    '<p>Generalize: loop four times, doubling frequency and halving amplitude on each step. The standard fBm pattern.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = smoothstep(0.0, 1.0, f);
    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float h = (noise(uv * 4.0) + 0.5 * noise(uv * 8.0)) / 1.5;
    gl_FragColor = vec4(vec3(h), 1.0);
}',
    'float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = smoothstep(0.0, 1.0, f);
    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float h = 0.0;
    float amp = 0.5;
    float freq = 4.0;
    for (int i = 0; i < 4; i++) {
        h += amp * noise(uv * freq);
        amp *= 0.5;
        freq *= 2.0;
    }
    gl_FragColor = vec4(vec3(h), 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000011-0004-0011-0000-000000000000',
    '11111111-0011-0000-0000-000000000000',
    'turbulence',
    3,
    'Turbulence',
    '<p>Replace each <code>noise()</code> sample with <code>abs(noise() - 0.5)</code>. The kinks at zero create the craggy "ridges" look characteristic of turbulence noise.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = smoothstep(0.0, 1.0, f);
    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float h = 0.0;
    float amp = 0.5;
    float freq = 4.0;
    for (int i = 0; i < 4; i++) {
        h += amp * noise(uv * freq);
        amp *= 0.5;
        freq *= 2.0;
    }
    gl_FragColor = vec4(vec3(h), 1.0);
}',
    'float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = smoothstep(0.0, 1.0, f);
    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float h = 0.0;
    float amp = 0.5;
    float freq = 4.0;
    for (int i = 0; i < 4; i++) {
        h += amp * abs(noise(uv * freq) - 0.5);
        amp *= 0.5;
        freq *= 2.0;
    }
    gl_FragColor = vec4(vec3(h), 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000011-0005-0011-0000-000000000000',
    '11111111-0011-0000-0000-000000000000',
    'terrain-colors',
    4,
    'Terrain colour bands',
    '<p>Map height to a colour: deep water at the low end, sand and grass in the middle, snow at the top. Use a chain of <code>smoothstep</code>s and <code>mix</code>es to blend bands.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = smoothstep(0.0, 1.0, f);
    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float h = 0.0;
    float amp = 0.5;
    float freq = 4.0;
    for (int i = 0; i < 4; i++) {
        h += amp * abs(noise(uv * freq) - 0.5);
        amp *= 0.5;
        freq *= 2.0;
    }
    gl_FragColor = vec4(vec3(h), 1.0);
}',
    'float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = smoothstep(0.0, 1.0, f);
    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float h = 0.0;
    float amp = 0.5;
    float freq = 4.0;
    for (int i = 0; i < 4; i++) {
        h += amp * abs(noise(uv * freq) - 0.5);
        amp *= 0.5;
        freq *= 2.0;
    }
    vec3 water = vec3(0.1, 0.3, 0.6);
    vec3 sand  = vec3(0.9, 0.8, 0.5);
    vec3 grass = vec3(0.2, 0.5, 0.2);
    vec3 snow  = vec3(0.95);
    vec3 color = water;
    color = mix(color, sand,  smoothstep(0.10, 0.13, h));
    color = mix(color, grass, smoothstep(0.18, 0.22, h));
    color = mix(color, snow,  smoothstep(0.35, 0.40, h));
    gl_FragColor = vec4(color, 1.0);
}'
);

-- ===========================================================
-- COURSE 12 — Chapter 15+: Image Operations (procedural) (5 lessons)
-- Theme: synthesize a procedural image, then transform it.
-- ===========================================================

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000012-0001-0012-0000-000000000000',
    '11111111-0012-0000-0000-000000000000',
    'synthesize-image',
    0,
    'Synthesize an image',
    '<p>This validator does not support <code>sampler2D</code>, so instead of loading a photo we synthesize one. Render a 4-octave fBm pattern at frequency 4 &mdash; the result is our "image".</p>
<p>Reference: <a href="https://thebookofshaders.com/15/" target="_blank" rel="noreferrer">The Book of Shaders &mdash; Textures</a></p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: render an fbm cloud as the "image".
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
    'float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = smoothstep(0.0, 1.0, f);
    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}
float fbm(vec2 p) {
    float h = 0.0;
    float amp = 0.5;
    float freq = 1.0;
    for (int i = 0; i < 4; i++) {
        h += amp * noise(p * freq);
        amp *= 0.5;
        freq *= 2.0;
    }
    return h;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float img = fbm(uv * 4.0);
    gl_FragColor = vec4(vec3(img), 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000012-0002-0012-0000-000000000000',
    '11111111-0012-0000-0000-000000000000',
    'invert',
    1,
    'Colour inversion',
    '<p>The simplest image operation: <code>1.0 - image</code>. Light pixels become dark, dark pixels become light.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = smoothstep(0.0, 1.0, f);
    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}
float fbm(vec2 p) {
    float h = 0.0;
    float amp = 0.5;
    float freq = 1.0;
    for (int i = 0; i < 4; i++) {
        h += amp * noise(p * freq);
        amp *= 0.5;
        freq *= 2.0;
    }
    return h;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float img = fbm(uv * 4.0);
    gl_FragColor = vec4(vec3(img), 1.0);
}',
    'float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = smoothstep(0.0, 1.0, f);
    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}
float fbm(vec2 p) {
    float h = 0.0;
    float amp = 0.5;
    float freq = 1.0;
    for (int i = 0; i < 4; i++) {
        h += amp * noise(p * freq);
        amp *= 0.5;
        freq *= 2.0;
    }
    return h;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float img = fbm(uv * 4.0);
    img = 1.0 - img;
    gl_FragColor = vec4(vec3(img), 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000012-0003-0012-0000-000000000000',
    '11111111-0012-0000-0000-000000000000',
    'multiply-blend',
    2,
    'Multiply blend',
    '<p>Multiply two images together. Sample the same fbm at two different offsets; the product is dark where either source is dark.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = smoothstep(0.0, 1.0, f);
    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}
float fbm(vec2 p) {
    float h = 0.0;
    float amp = 0.5;
    float freq = 1.0;
    for (int i = 0; i < 4; i++) {
        h += amp * noise(p * freq);
        amp *= 0.5;
        freq *= 2.0;
    }
    return h;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float img = fbm(uv * 4.0);
    img = 1.0 - img;
    gl_FragColor = vec4(vec3(img), 1.0);
}',
    'float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = smoothstep(0.0, 1.0, f);
    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}
float fbm(vec2 p) {
    float h = 0.0;
    float amp = 0.5;
    float freq = 1.0;
    for (int i = 0; i < 4; i++) {
        h += amp * noise(p * freq);
        amp *= 0.5;
        freq *= 2.0;
    }
    return h;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float a = fbm(uv * 4.0);
    float b = fbm(uv * 4.0 + vec2(7.0, 13.0));
    float img = a * b * 2.0;
    gl_FragColor = vec4(vec3(img), 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000012-0004-0012-0000-000000000000',
    '11111111-0012-0000-0000-000000000000',
    'box-blur',
    3,
    'Box blur (3x3)',
    '<p>Sample the procedural image nine times around the current pixel and average. This is a 3&times;3 box blur kernel without ever touching a texture.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = smoothstep(0.0, 1.0, f);
    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}
float fbm(vec2 p) {
    float h = 0.0;
    float amp = 0.5;
    float freq = 1.0;
    for (int i = 0; i < 4; i++) {
        h += amp * noise(p * freq);
        amp *= 0.5;
        freq *= 2.0;
    }
    return h;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float a = fbm(uv * 4.0);
    float b = fbm(uv * 4.0 + vec2(7.0, 13.0));
    float img = a * b * 2.0;
    gl_FragColor = vec4(vec3(img), 1.0);
}',
    'float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = smoothstep(0.0, 1.0, f);
    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}
float fbm(vec2 p) {
    float h = 0.0;
    float amp = 0.5;
    float freq = 1.0;
    for (int i = 0; i < 4; i++) {
        h += amp * noise(p * freq);
        amp *= 0.5;
        freq *= 2.0;
    }
    return h;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float sum = 0.0;
    float s = 0.01;
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 offset = vec2(float(x), float(y)) * s;
            sum += fbm((uv + offset) * 4.0);
        }
    }
    float img = sum / 9.0;
    gl_FragColor = vec4(vec3(img), 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000012-0005-0012-0000-000000000000',
    '11111111-0012-0000-0000-000000000000',
    'edge-detect',
    4,
    'Edge detection',
    '<p>Sample the image at <code>+/- s</code> in x and y, take the magnitude of the gradient. Bright pixels mark edges; flat areas stay dark.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = smoothstep(0.0, 1.0, f);
    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}
float fbm(vec2 p) {
    float h = 0.0;
    float amp = 0.5;
    float freq = 1.0;
    for (int i = 0; i < 4; i++) {
        h += amp * noise(p * freq);
        amp *= 0.5;
        freq *= 2.0;
    }
    return h;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float sum = 0.0;
    float s = 0.01;
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 offset = vec2(float(x), float(y)) * s;
            sum += fbm((uv + offset) * 4.0);
        }
    }
    float img = sum / 9.0;
    gl_FragColor = vec4(vec3(img), 1.0);
}',
    'float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = smoothstep(0.0, 1.0, f);
    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}
float fbm(vec2 p) {
    float h = 0.0;
    float amp = 0.5;
    float freq = 1.0;
    for (int i = 0; i < 4; i++) {
        h += amp * noise(p * freq);
        amp *= 0.5;
        freq *= 2.0;
    }
    return h;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float s = 0.01;
    float gx = fbm((uv + vec2(s, 0.0)) * 4.0) - fbm((uv - vec2(s, 0.0)) * 4.0);
    float gy = fbm((uv + vec2(0.0, s)) * 4.0) - fbm((uv - vec2(0.0, s)) * 4.0);
    float edge = length(vec2(gx, gy)) * 20.0;
    gl_FragColor = vec4(vec3(edge), 1.0);
}'
);
