\c shader_dojo;

-- Level 0 — Orientation (1 course, 4 lessons)
-- Runs after seed-01-courses.sql (alphabetical sort: "01-" < "01a-" < "02-").

INSERT INTO lesson (course_id, slug, display_order, title, description, starter_fragment_shader, canonical_fragment_shader) VALUES

((SELECT id FROM course WHERE slug = 'glsl-environment'), 'yOfy60x1XkM', 0,
 'One program per pixel',
 '<p>A shader is a small program. The GPU runs it once for each pixel on the canvas. The preview is 400 by 400, so the GPU runs your code 160,000 times in parallel. Every copy runs the same code.</p><p>Each copy has one job. It must set <code>gl_FragColor</code>. That is the pixel''s final color. It is a <code>vec4</code> with four numbers: red, green, blue, and alpha. Each number goes from 0 to 1.</p><p>Try this: set <code>gl_FragColor</code> to red. Use <code>vec4(1.0, 0.0, 0.0, 1.0)</code>. Read more at <a href="https://thebookofshaders.com/02/" target="_blank" rel="noreferrer">Book of Shaders, Hello World</a>.</p>',
 'void main() {
    // TODO: set gl_FragColor to opaque red, i.e. vec4(1.0, 0.0, 0.0, 1.0).
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
 'void main() {
    gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'glsl-environment'), 'Hkx6a0ctuj8', 1,
 'Variables and types',
 '<p>GLSL has numbers and groups of numbers. A single number is a <code>float</code>. A group of two is a <code>vec2</code>. A group of three is a <code>vec3</code>. A group of four is a <code>vec4</code>.</p><p>You can build a bigger group from a smaller one. <code>vec4(rgb, 1.0)</code> takes a <code>vec3</code> of color and adds an alpha of 1. You can also pick parts out. <code>color.r</code> gets the red. <code>color.xy</code> gets the first two numbers.</p><p>Try this: make a <code>vec3</code> with the warm yellow <code>(0.95, 0.81, 0.36)</code>. Then put it in a <code>vec4</code> with alpha 1. Read more at <a href="https://thebookofshaders.com/02/" target="_blank" rel="noreferrer">Book of Shaders, Hello World</a>.</p>',
 'void main() {
    // TODO: declare vec3 rgb = vec3(0.95, 0.81, 0.36); then gl_FragColor = vec4(rgb, 1.0);
    gl_FragColor = vec4(0.5, 0.5, 0.5, 1.0);
}',
 'void main() {
    vec3 rgb = vec3(0.95, 0.81, 0.36);
    gl_FragColor = vec4(rgb, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'glsl-environment'), 'oXidWKram9w', 2,
 'Your pixel''s address',
 '<p>Every copy of your code runs at a different pixel. How does a copy know which pixel it is? It reads <code>gl_FragCoord.xy</code>. That is the pixel''s spot on the canvas, like <code>(0, 0)</code> at the bottom left.</p><p>The other inputs are the same for every pixel. They are called uniforms. You get <code>u_resolution</code> (the canvas size), <code>u_time</code> (seconds since the page loaded), and <code>u_image</code> (a 256 by 256 picture you can sample).</p><p>Try this: divide <code>gl_FragCoord.xy</code> by <code>u_resolution.xy</code>. That gives you <code>uv</code>, a number from 0 to 1 across the screen. Output it with a blue of 0.5. Read more at <a href="https://thebookofshaders.com/03/" target="_blank" rel="noreferrer">Book of Shaders, Uniforms</a>.</p>',
 'void main() {
    // TODO: vec2 uv = gl_FragCoord.xy / u_resolution.xy;  then gl_FragColor = vec4(uv, 0.5, 1.0);
    gl_FragColor = vec4(0.0, 0.0, 0.5, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    gl_FragColor = vec4(uv, 0.5, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'glsl-environment'), '2ALiNoL9MVE', 3,
 'Time as an input',
 '<p>The uniform <code>u_time</code> is a number. It counts the seconds since the page loaded. It grows every frame.</p><p>Pass it into <code>sin()</code> or <code>cos()</code>. Those give a smooth wave between -1 and 1. The line <code>0.5 + 0.5 * sin(u_time)</code> gives you a value that moves between 0 and 1 over time.</p><p>Try this: set <code>v</code> to that wave. Then output <code>vec4(v, 0.0, 0.0, 1.0)</code>. The whole canvas will pulse red. Read more at <a href="https://thebookofshaders.com/03/" target="_blank" rel="noreferrer">Book of Shaders, Uniforms</a>.</p>',
 'void main() {
    // TODO: float v = 0.5 + 0.5 * sin(u_time); then gl_FragColor = vec4(v, 0.0, 0.0, 1.0);
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
 'void main() {
    float v = 0.5 + 0.5 * sin(u_time);
    gl_FragColor = vec4(v, 0.0, 0.0, 1.0);
}');
