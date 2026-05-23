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
CREATE TABLE course
(
    id            VARCHAR(36) PRIMARY KEY,
    slug          VARCHAR(128) UNIQUE NOT NULL,
    title         VARCHAR(256) NOT NULL,
    description   TEXT,
    display_order INT NOT NULL DEFAULT 0,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_course_display_order ON course (display_order);

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
-- COURSES
-- ===========================================================

INSERT INTO course (id, slug, title, description, display_order) VALUES
    ('11111111-0001-0000-0000-000000000000',
     'basics',
     'Basics',
     'Output color. Read coordinates. Move with time. Five lessons covering everything a fragment shader actually does.',
     0),
    ('11111111-0002-0000-0000-000000000000',
     'shaping',
     'Shaping',
     'Step, smoothstep, distance fields. The toolkit for drawing shapes without conditionals.',
     1),
    ('11111111-0003-0000-0000-000000000000',
     'color',
     'Color',
     'Mix, gradient, HSV — the vocabulary for painting with shaders.',
     2);

-- ===========================================================
-- COURSE 1: Basics
-- ===========================================================

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000001-0001-0001-0000-000000000000',
    '11111111-0001-0000-0000-000000000000',
    'hello-color',
    0,
    'Hello, color',
    '<p>Every fragment shader sets <code>gl_FragColor</code> — a four-component <code>(R, G, B, A)</code> value where each component runs from <code>0.0</code> to <code>1.0</code>.</p>
<p>Edit <code>gl_FragColor</code> so the canvas renders pure <strong>green</strong>.</p>
<p>Reference: <a href="https://thebookofshaders.com/02/" target="_blank" rel="noreferrer">The Book of Shaders — Hello World</a></p>
<img src="/lesson-images/hello-color.png" alt="A solid green square" />',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    // TODO: change this to opaque green.
    gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
}',
    'void main() {
    gl_FragColor = vec4(0.0, 1.0, 0.0, 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000001-0002-0001-0000-000000000000',
    '11111111-0001-0000-0000-000000000000',
    'half-and-half',
    1,
    'Half and half',
    '<p><code>gl_FragCoord.xy</code> gives the pixel''s screen position. <code>u_resolution.xy</code> gives the canvas size.</p>
<p>Make the left half of the screen <strong>red</strong> and the right half <strong>blue</strong>.</p>
<p><em>Hint:</em> divide <code>gl_FragCoord</code> by <code>u_resolution</code> to get a 0..1 coordinate.</p>
<p>Reference: <a href="https://thebookofshaders.com/03/" target="_blank" rel="noreferrer">The Book of Shaders — Uniforms</a></p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: pick red when uv.x < 0.5, blue otherwise.
    vec3 color = vec3(uv.x);
    gl_FragColor = vec4(color, 1.0);
}',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 color = uv.x < 0.5 ? vec3(1.0, 0.0, 0.0) : vec3(0.0, 0.0, 1.0);
    gl_FragColor = vec4(color, 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000001-0003-0001-0000-000000000000',
    '11111111-0001-0000-0000-000000000000',
    'uv-gradient',
    2,
    'UV as color',
    '<p>Render the normalized coordinates directly: red increases with <code>x</code>, green increases with <code>y</code>. This is the canonical <em>"see what your UVs look like"</em> debug view.</p>
<p>Reference: <a href="https://thebookofshaders.com/03/" target="_blank" rel="noreferrer">The Book of Shaders — Uniforms</a></p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: red on x, green on y, blue 0.
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    gl_FragColor = vec4(uv.x, uv.y, 0.0, 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000001-0004-0001-0000-000000000000',
    '11111111-0001-0000-0000-000000000000',
    'pulse-with-time',
    3,
    'Pulse with time',
    '<p><code>u_time</code> is a uniform float that increases every frame. Verification runs at <code>t = 20.0</code> exactly.</p>
<p>Render a single uniform grey whose brightness is <code>0.5 + 0.5 * sin(u_time)</code> — your whole canvas should be one shade of grey.</p>
<p>Reference: <a href="https://thebookofshaders.com/03/" target="_blank" rel="noreferrer">The Book of Shaders — Uniforms (u_time)</a></p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    // TODO: brightness = 0.5 + 0.5 * sin(u_time).
    float brightness = 1.0;
    gl_FragColor = vec4(vec3(brightness), 1.0);
}',
    'void main() {
    float brightness = 0.5 + 0.5 * sin(u_time);
    gl_FragColor = vec4(vec3(brightness), 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000001-0005-0001-0000-000000000000',
    '11111111-0001-0000-0000-000000000000',
    'diagonal-gradient',
    4,
    'Diagonal gradient',
    '<p>Combine <code>x</code> and <code>y</code> into a single value to produce a corner-to-corner greyscale gradient:</p>
<pre><code>brightness = (uv.x + uv.y) * 0.5</code></pre>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: brightness from (uv.x + uv.y) * 0.5.
    float brightness = uv.x;
    gl_FragColor = vec4(vec3(brightness), 1.0);
}',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float brightness = (uv.x + uv.y) * 0.5;
    gl_FragColor = vec4(vec3(brightness), 1.0);
}'
);

-- ===========================================================
-- COURSE 2: Shaping
-- ===========================================================

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000002-0001-0002-0000-000000000000',
    '11111111-0002-0000-0000-000000000000',
    'step-edge',
    0,
    'A hard edge with step()',
    '<p><code>step(edge, x)</code> returns <code>0.0</code> when <code>x &lt; edge</code> and <code>1.0</code> otherwise.</p>
<p>Use it to draw the right half of the screen white and the left half black.</p>
<p>Reference: <a href="https://thebookofshaders.com/05/" target="_blank" rel="noreferrer">The Book of Shaders — Shaping functions</a></p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: use step() to make uv.x >= 0.5 white.
    float mask = uv.x;
    gl_FragColor = vec4(vec3(mask), 1.0);
}',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float mask = step(0.5, uv.x);
    gl_FragColor = vec4(vec3(mask), 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000002-0002-0002-0000-000000000000',
    '11111111-0002-0000-0000-000000000000',
    'smoothstep-edge',
    1,
    'A soft edge with smoothstep()',
    '<p><code>smoothstep(a, b, x)</code> ramps <code>0 → 1</code> across the <code>[a, b]</code> range with a smooth Hermite curve.</p>
<p>Use <code>smoothstep(0.4, 0.6, uv.x)</code> for a soft vertical transition.</p>
<p>Reference: <a href="https://thebookofshaders.com/05/" target="_blank" rel="noreferrer">The Book of Shaders — Shaping functions</a></p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: smoothstep with edges 0.4 and 0.6.
    float mask = step(0.5, uv.x);
    gl_FragColor = vec4(vec3(mask), 1.0);
}',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float mask = smoothstep(0.4, 0.6, uv.x);
    gl_FragColor = vec4(vec3(mask), 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000002-0003-0002-0000-000000000000',
    '11111111-0002-0000-0000-000000000000',
    'horizontal-band',
    2,
    'A horizontal band',
    '<p>Stack two <code>smoothstep</code>s back-to-back to draw a thin glowing band centered at <code>y = 0.5</code>:</p>
<pre><code>band = smoothstep(0.49, 0.5, uv.y) - smoothstep(0.5, 0.51, uv.y);</code></pre>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: bright band centered at y = 0.5, thickness ~0.02.
    float band = 0.0;
    gl_FragColor = vec4(vec3(band), 1.0);
}',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float band = smoothstep(0.49, 0.5, uv.y) - smoothstep(0.5, 0.51, uv.y);
    gl_FragColor = vec4(vec3(band), 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000002-0004-0002-0000-000000000000',
    '11111111-0002-0000-0000-000000000000',
    'circle',
    3,
    'A filled circle',
    '<p>A <strong>distance field</strong> gives you a continuous "how far am I from this point?" value. <code>length(uv - center)</code> is the SDF for a circle.</p>
<p>Combine with <code>smoothstep</code> to draw a filled disc of radius <code>0.3</code> centered at <code>(0.5, 0.5)</code>.</p>
<p>Reference: <a href="https://thebookofshaders.com/07/" target="_blank" rel="noreferrer">The Book of Shaders — Shapes</a></p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: 1.0 inside radius 0.3, 0.0 outside; antialiased.
    float mask = 0.0;
    gl_FragColor = vec4(vec3(mask), 1.0);
}',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float d = length(uv - vec2(0.5));
    float mask = 1.0 - smoothstep(0.29, 0.31, d);
    gl_FragColor = vec4(vec3(mask), 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000002-0005-0002-0000-000000000000',
    '11111111-0002-0000-0000-000000000000',
    'plot-parabola',
    4,
    'Plot a parabola',
    '<p>Draw the curve <code>y = x²</code> as a thin line. For each fragment, compare <code>uv.y</code> to the curve''s value and use a pair of <code>smoothstep</code>s to draw a 1 px line where they meet.</p>
<p>Reference: <a href="https://thebookofshaders.com/05/" target="_blank" rel="noreferrer">The Book of Shaders — Plotting a function</a></p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: draw a line where uv.y = uv.x * uv.x.
    float plot = 0.0;
    gl_FragColor = vec4(vec3(plot), 1.0);
}',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float y = uv.x * uv.x;
    float plot = smoothstep(y - 0.01, y, uv.y) - smoothstep(y, y + 0.01, uv.y);
    gl_FragColor = vec4(vec3(plot), 1.0);
}'
);

-- ===========================================================
-- COURSE 3: Color
-- ===========================================================

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000003-0001-0003-0000-000000000000',
    '11111111-0003-0000-0000-000000000000',
    'mix-red-blue',
    0,
    'Mix two colors',
    '<p><code>mix(a, b, t)</code> does linear interpolation: <code>0</code> returns <code>a</code>, <code>1</code> returns <code>b</code>, anything between blends.</p>
<p>Render a horizontal ramp from red on the left to blue on the right.</p>
<p>Reference: <a href="https://thebookofshaders.com/06/" target="_blank" rel="noreferrer">The Book of Shaders — Colors</a></p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: mix red and blue using uv.x.
    vec3 color = vec3(1.0, 0.0, 0.0);
    gl_FragColor = vec4(color, 1.0);
}',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 color = mix(vec3(1.0, 0.0, 0.0), vec3(0.0, 0.0, 1.0), uv.x);
    gl_FragColor = vec4(color, 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000003-0002-0003-0000-000000000000',
    '11111111-0003-0000-0000-000000000000',
    'three-color',
    1,
    'Three-color gradient',
    '<p>Chain two <code>mix</code>es to pass through three colors: red → green at the halfway point, then green → blue at the end. Use <code>smoothstep</code> to control where each transition happens.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: red -> green -> blue along x.
    vec3 color = vec3(uv.x);
    gl_FragColor = vec4(color, 1.0);
}',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 c1 = mix(vec3(1.0, 0.0, 0.0), vec3(0.0, 1.0, 0.0), smoothstep(0.0, 0.5, uv.x));
    vec3 c2 = mix(c1, vec3(0.0, 0.0, 1.0), smoothstep(0.5, 1.0, uv.x));
    gl_FragColor = vec4(c2, 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000003-0003-0003-0000-000000000000',
    '11111111-0003-0000-0000-000000000000',
    'hsv-rainbow',
    2,
    'HSV rainbow',
    '<p><strong>HSV</strong> (hue, saturation, value) is a colour space that puts the rainbow on a single axis.</p>
<p>Map <code>uv.x</code> to hue, hold saturation and value at <code>1.0</code>, then convert HSV → RGB. The classic conversion is a six-line trick — peek at the canonical solution for the formula.</p>
<p>Reference: <a href="https://thebookofshaders.com/06/" target="_blank" rel="noreferrer">The Book of Shaders — HSB / HSV</a></p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: render hsv(uv.x, 1, 1) as RGB. See description for the conversion.
    vec3 color = vec3(uv.x);
    gl_FragColor = vec4(color, 1.0);
}',
    'vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 color = hsv2rgb(vec3(uv.x, 1.0, 1.0));
    gl_FragColor = vec4(color, 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000003-0004-0003-0000-000000000000',
    '11111111-0003-0000-0000-000000000000',
    'vignette',
    3,
    'Vignette',
    '<p>Darken the edges, keep the center bright. Compute distance from center and use <code>smoothstep(0.3, 0.7, d)</code> to falloff. Subtract from <code>1.0</code> so the center is full white.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: 1.0 in the middle, fades to 0.0 in the corners.
    float vig = 1.0;
    gl_FragColor = vec4(vec3(vig), 1.0);
}',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float d = length(uv - vec2(0.5));
    float vig = 1.0 - smoothstep(0.3, 0.7, d);
    gl_FragColor = vec4(vec3(vig), 1.0);
}'
);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader
) VALUES (
    'a0000003-0005-0003-0000-000000000000',
    '11111111-0003-0000-0000-000000000000',
    'coord-color-time',
    4,
    'Color from coordinates + time',
    '<p>Pack three signals into one <code>vec3</code>: red = <code>uv.x</code>, green = <code>uv.y</code>, blue = <code>0.5 + 0.5 * sin(u_time)</code>.</p>
<p>Verification runs at <code>t = 20.0</code>.</p>',
    'attribute vec4 aVertexPosition;
void main() { gl_Position = aVertexPosition; }',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: r=uv.x, g=uv.y, b=0.5+0.5*sin(u_time).
    vec3 color = vec3(uv.x, uv.y, 0.0);
    gl_FragColor = vec4(color, 1.0);
}',
    'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 color = vec3(uv.x, uv.y, 0.5 + 0.5 * sin(u_time));
    gl_FragColor = vec4(color, 1.0);
}'
);
