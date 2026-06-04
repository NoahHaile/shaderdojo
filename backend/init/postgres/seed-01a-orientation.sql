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
 '<p>A shader is a small program. The GPU runs it once for each pixel on the canvas. The preview is 400 by 400. So the GPU runs your code 160,000 times in parallel. Every copy runs the same code.</p><p>Each copy must set <code>gl_FragColor</code>. That is the pixel''s final color. It is a <code>vec4</code> with red, green, blue, and alpha. Each part is a number from 0 to 1.</p><p>Paint every pixel a warm yellow. Use the values <code>0.95</code> for red, <code>0.81</code> for green, and <code>0.36</code> for blue. Keep alpha at <code>1.0</code>.</p><p>To add a touch of life, multiply the whole color by a slow vertical wave: <code>0.85 + 0.15 * sin(gl_FragCoord.y * 0.04)</code>. Soft horizontal bands appear, all in the same warm yellow family.</p><p>Read more at <a href="https://thebookofshaders.com/02/" target="_blank" rel="noreferrer">Book of Shaders, Hello World</a>.</p>',
 'void main() {
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
 'void main() {
    float band = 0.85 + 0.15 * sin(gl_FragCoord.y * 0.04);
    gl_FragColor = vec4(0.95 * band, 0.81 * band, 0.36 * band, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'glsl-environment'), 'Hkx6a0ctuj8', 1,
 'Build with variables',
 '<p>GLSL has scalars (a single number) and vectors (a small group of numbers). The scalar is <code>float</code>. The vectors are <code>vec2</code>, <code>vec3</code>, and <code>vec4</code>.</p><p>You can build a wider vector from a narrower one. <code>vec4(rgb, 1.0)</code> takes a <code>vec3</code> and adds an alpha. You can read parts with swizzle: <code>color.r</code>, <code>color.xy</code>, <code>color.bgr</code>.</p><p>Store a soft salmon <code>(0.96, 0.62, 0.51)</code> in a <code>vec3</code> named <code>sunset</code>. Then fade it toward black from top to bottom: scale the color by <code>gl_FragCoord.y / 400.0</code>. The result is a sunset gradient that''s bright at the top and dark at the bottom.</p><p>Read more at <a href="https://thebookofshaders.com/02/" target="_blank" rel="noreferrer">Book of Shaders, Hello World</a>.</p>',
 'void main() {
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
 'void main() {
    vec3 sunset = vec3(0.96, 0.62, 0.51);
    float falloff = gl_FragCoord.y / 400.0;
    gl_FragColor = vec4(sunset * falloff, 1.0);
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
 '<p>The uniform <code>u_time</code> is a float. It counts the seconds since the page loaded. It is the same for every pixel in a frame, but it grows each frame, so it drives animation.</p><p>Plug <code>u_time</code> into <code>sin()</code>. Raw <code>sin</code> swings between -1 and 1, but color channels go from 0 to 1. So remap with <code>0.5 + 0.5 * sin(u_time)</code>. Multiply by 0.5 to shrink the swing. Add 0.5 to lift it up.</p><p>Use that wave on the red channel. Build on the last lesson by keeping <code>uv.y</code> on green and <code>0.5</code> on blue. The canvas will pulse red while the green gradient stays still.</p><p>Read more at <a href="https://thebookofshaders.com/03/" target="_blank" rel="noreferrer">Book of Shaders, Uniforms</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    gl_FragColor = vec4(uv.x, uv.y, 0.5, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float wave = 0.5 + 0.5 * sin(u_time);
    gl_FragColor = vec4(wave, uv.y, 0.5, 1.0);
}');
