\c shader_dojo;

-- Level 0 — Orientation (1 course, 4 lessons)
-- Code style: the description teaches. The starter is a near-empty shader,
-- the canonical is the full working answer. No didactic comments inside the
-- code — the learner writes meaningful lines from a recipe in the description.
-- Each lesson's canonical includes ideas from the prior lesson, so progression
-- is visible just by reading the code.

INSERT INTO lesson (course_id, slug, display_order, title, description, starter_fragment_shader, canonical_fragment_shader) VALUES

((SELECT id FROM course WHERE slug = 'glsl-environment'), 'yOfy60x1XkM', 0,
 'Hello pixel',
 '<p>A shader is a small program. The GPU runs it once for every pixel on the canvas. The preview is 400 by 400, so your code runs 160,000 times — once per pixel. Every copy runs the exact same lines.</p><p>Each copy has one job: set <code>gl_FragColor</code>, the pixel''s final color. It is a <code>vec4</code> — four numbers holding red, green, blue, and alpha (opacity). Each number runs from <code>0.0</code> (none) to <code>1.0</code> (full).</p><p>Paint every pixel a warm yellow. Set red to <code>0.95</code>, green to <code>0.81</code>, blue to <code>0.36</code>, and keep alpha at <code>1.0</code> so the pixel is solid:</p><p><code>gl_FragColor = vec4(0.95, 0.81, 0.36, 1.0);</code></p><p>That single line is the whole shader. New to any of this? The <strong>Concierge</strong> terminal below can walk you through it.</p><p>Read more at <a href="https://thebookofshaders.com/02/" target="_blank" rel="noreferrer">Book of Shaders, Hello World</a>.</p>',
 'void main() {
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
 'void main() {
    gl_FragColor = vec4(0.95, 0.81, 0.36, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'glsl-environment'), 'Hkx6a0ctuj8', 1,
 'Build with variables',
 '<p>Storing values in <strong>variables</strong> keeps a shader readable. GLSL has two kinds. A scalar is one number — type <code>float</code>. A vector is a small group of numbers — <code>vec2</code>, <code>vec3</code>, or <code>vec4</code>.</p><p>Store a soft salmon in a <code>vec3</code>. The three numbers are red, green, and blue:</p><p><code>vec3 sunset = vec3(0.96, 0.62, 0.51);</code></p><p><strong>Swizzling</strong> is reading parts of a vector by name. Put a dot after the vector, then list the parts you want in any order. The slots have two name sets that mean the same thing: <code>x y z w</code> or <code>r g b a</code>. So <code>sunset.r</code> is just the red number, <code>sunset.rgb</code> is all three, and <code>sunset.bgr</code> is the same three with red and blue swapped.</p><p>You can also build a wider vector from a narrower one. <code>vec4(sunset, 1.0)</code> takes your <code>vec3</code> and adds an alpha of <code>1.0</code> — exactly the <code>vec4</code> that <code>gl_FragColor</code> needs:</p><p><code>gl_FragColor = vec4(sunset, 1.0);</code></p><p>The whole canvas turns that one salmon color — no gradient yet. Next lesson, each pixel gets its own.</p><p>Read more at <a href="https://thebookofshaders.com/02/" target="_blank" rel="noreferrer">Book of Shaders, Hello World</a>.</p>',
 'void main() {
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
 'void main() {
    vec3 sunset = vec3(0.96, 0.62, 0.51);
    gl_FragColor = vec4(sunset, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'glsl-environment'), 'oXidWKram9w', 2,
 'Every pixel knows its place',
 '<p>So far every pixel had the same color. To make pixels differ, the shader needs an input that changes per pixel.</p><p>That input is <code>gl_FragCoord.xy</code>. It is the pixel''s position in screen pixels. <code>(0, 0)</code> is the bottom-left. Everything else (<code>u_resolution</code>, <code>u_time</code>, <code>u_image</code>) is a <strong>uniform</strong> — the same value for every pixel in the frame.</p><p>Compute <code>uv = gl_FragCoord.xy / u_resolution.xy</code>. That is a coordinate from 0 to 1 across the canvas. Put <code>uv.x</code> on red, <code>uv.y</code> on green, and <code>0.5</code> on blue.</p><p>Read more at <a href="https://thebookofshaders.com/03/" target="_blank" rel="noreferrer">Book of Shaders, Uniforms</a>.</p>',
 'void main() {
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    gl_FragColor = vec4(uv.x, uv.y, 0.5, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'glsl-environment'), '2ALiNoL9MVE', 3,
 'Make it breathe',
 '<p>The uniform <code>u_time</code> is a <code>float</code>. It counts the seconds since the page loaded. It is the same for every pixel in a frame, but it grows frame after frame — so it is what drives animation.</p><p><code>sin()</code> is a function built into GLSL. You hand it a number; it hands back the sine of that number. As the input climbs, the output <strong>swings</strong> smoothly up and down forever, between -1 and 1. Feed it <code>u_time</code> and that steady swing becomes motion.</p><p>But color channels only run from 0 to 1, and raw <code>sin</code> dips below 0 (which would clip to black). Reshape it in two steps:</p><p>First <strong>shrink</strong> the swing by half — <code>0.5 * sin(u_time)</code> now swings between -0.5 and 0.5.</p><p>Then <strong>add</strong> 0.5 to lift the whole thing up — <code>0.5 + 0.5 * sin(u_time)</code> swings between 0 and 1, perfect for a color. Store it in a <code>float</code> named <code>wave</code>.</p><p>Put <code>wave</code> on the red channel, and keep <code>uv.y</code> on green and <code>0.5</code> on blue like last lesson. The canvas pulses red while the green gradient holds still.</p><p>If the swing, the remap, or the per-pixel <code>uv</code> feels fuzzy, ask the <strong>Concierge</strong> in the terminal below — it can trace your code one pixel at a time and read any compile error.</p><p>Read more at <a href="https://thebookofshaders.com/03/" target="_blank" rel="noreferrer">Book of Shaders, Uniforms</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    gl_FragColor = vec4(uv.x, uv.y, 0.5, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float wave = 0.5 + 0.5 * sin(u_time);
    gl_FragColor = vec4(wave, uv.y, 0.5, 1.0);
}');
