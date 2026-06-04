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
 '<p>A shader is a small program. The GPU runs it once for every pixel on the canvas. The preview is 400 by 400. So your code runs 160,000 times. Every copy runs the exact same lines.</p><p>Each copy has one job. It must set <code>gl_FragColor</code>. That is the pixel''s final color. It is a <code>vec4</code> with four numbers: red, green, blue, and alpha. Alpha says how solid the pixel is. Each number runs from <code>0.0</code> (none) to <code>1.0</code> (full).</p><p>Paint every pixel a warm yellow. Set red to <code>0.95</code>, green to <code>0.81</code>, and blue to <code>0.36</code>. Keep alpha at <code>1.0</code> so the pixel is solid:</p><p><code>gl_FragColor = vec4(0.95, 0.81, 0.36, 1.0);</code></p><p>That one line is the whole shader. New to any of this? The <strong>Concierge</strong> below can walk you through it.</p><p>Read more at <a href="https://thebookofshaders.com/02/" target="_blank" rel="noreferrer">Book of Shaders, Hello World</a>.</p>',
 'void main() {
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
 'void main() {
    gl_FragColor = vec4(0.95, 0.81, 0.36, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'glsl-environment'), 'Hkx6a0ctuj8', 1,
 'Build with variables',
 '<p>Variables make a shader easier to read. GLSL has two kinds. A scalar is one number. Its type is <code>float</code>. A vector is a small group of numbers. The types are <code>vec2</code>, <code>vec3</code>, and <code>vec4</code>.</p><p>Store a soft salmon in a <code>vec3</code>. The three numbers are red, green, and blue:</p><p><code>vec3 sunset = vec3(0.96, 0.62, 0.51);</code></p><p><strong>Swizzling</strong> is how you read parts of a vector by name. Put a dot after the vector. Then list the parts you want. The slots have two name sets that mean the same thing: <code>x y z w</code> or <code>r g b a</code>. So <code>sunset.r</code> is just the red number. <code>sunset.rgb</code> is all three. And <code>sunset.bgr</code> is the same three with red and blue swapped.</p><p>You can also build a bigger vector from a smaller one. <code>vec4(sunset, 1.0)</code> takes your <code>vec3</code> and adds an alpha of <code>1.0</code>. That is the kind of <code>vec4</code> that <code>gl_FragColor</code> wants:</p><p><code>gl_FragColor = vec4(sunset, 1.0);</code></p><p>The whole canvas turns one salmon color. No gradient yet. Next lesson, each pixel gets its own.</p><p>Read more at <a href="https://thebookofshaders.com/02/" target="_blank" rel="noreferrer">Book of Shaders, Hello World</a>.</p>',
 'void main() {
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
 'void main() {
    vec3 sunset = vec3(0.96, 0.62, 0.51);
    gl_FragColor = vec4(sunset, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'glsl-environment'), 'oXidWKram9w', 2,
 'Every pixel knows its place',
 '<p>So far every pixel had the same color. To make pixels differ, the shader needs an input that changes per pixel.</p><p>That input is <code>gl_FragCoord.xy</code>. It is the pixel''s spot on the canvas in pixels. <code>(0, 0)</code> is the bottom-left. The top-right is <code>(400, 400)</code> on this canvas.</p><p>Divide by <code>400.0</code> to get a number from 0 to 1 across the canvas. Store the two numbers in a <code>vec2</code> named <code>uv</code>:</p><p><code>vec2 uv = gl_FragCoord.xy / 400.0;</code></p><p>A <code>vec2</code> holds two numbers. Just like the <code>vec3</code> last lesson, you read the parts with a dot. For colors you used <code>.r</code> and <code>.g</code>. For spots you use <code>.x</code> and <code>.y</code>. So <code>uv.x</code> is how far across, and <code>uv.y</code> is how far up.</p><p>Put <code>uv.x</code> on red, <code>uv.y</code> on green, and <code>0.5</code> on blue:</p><p><code>gl_FragColor = vec4(uv.x, uv.y, 0.5, 1.0);</code></p><p>Read more at <a href="https://thebookofshaders.com/03/" target="_blank" rel="noreferrer">Book of Shaders, Uniforms</a>.</p>',
 'void main() {
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / 400.0;
    gl_FragColor = vec4(uv.x, uv.y, 0.5, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'glsl-environment'), '2ALiNoL9MVE', 3,
 'Make it breathe',
 '<p><code>u_time</code> is a built-in number you can use in any shader. It counts the seconds since the page loaded. Every pixel in a frame sees the same <code>u_time</code>. But it grows from frame to frame. That is what drives animation.</p><p><code>sin()</code> is a function built into GLSL. You give it a number. It gives back the sine of that number. As the input climbs, the output swings up and down forever, between -1 and 1. Feed it <code>u_time</code> and that steady swing becomes motion.</p><p>But color channels only go from 0 to 1. Raw <code>sin</code> dips below 0. Reshape it in two steps:</p><p>First shrink the swing by half. <code>0.5 * sin(u_time)</code> now swings between -0.5 and 0.5.</p><p>Then add 0.5 to lift it up. <code>0.5 + 0.5 * sin(u_time)</code> swings between 0 and 1. That is perfect for a color. Store it in a <code>float</code> named <code>wave</code>.</p><p>Put <code>wave</code> on red. Keep <code>uv.y</code> on green and <code>0.5</code> on blue like last lesson. The canvas will pulse red while the green gradient stays still.</p><p>If the swing or the remap feels fuzzy, ask the <strong>Concierge</strong> below. It can trace your code one pixel at a time and read any compile error.</p><p>Read more at <a href="https://thebookofshaders.com/03/" target="_blank" rel="noreferrer">Book of Shaders, Uniforms</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / 400.0;
    gl_FragColor = vec4(uv.x, uv.y, 0.5, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / 400.0;
    float wave = 0.5 + 0.5 * sin(u_time);
    gl_FragColor = vec4(wave, uv.y, 0.5, 1.0);
}');
