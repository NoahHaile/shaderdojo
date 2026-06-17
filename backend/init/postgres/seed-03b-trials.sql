\c shader_dojo;

-- Trials, first creative checkpoint (1 course, 1 lesson)
-- This breaks the convergent lesson model on purpose. There is no canonical
-- answer and no hashed_answer: the piece is the learner's own, and "done" means
-- they shared it. Because there is nothing to verify, light guiding comments in
-- the starter are intentional here (unlike the recipe-driven technique lessons).

INSERT INTO lesson (course_id, slug, display_order, title, description, starter_fragment_shader) VALUES

((SELECT id FROM course WHERE slug = 'first-masterwork'), 'Kq3ZpVn7sLx', 0,
 'Your first masterwork',
 '<p>You came in setting one flat color. Look at what is in your hands now: two ways to name <em>where</em> a pixel is, and a whole kit for turning that into color.</p>
<p><strong>Think about the space two ways.</strong> The plain <code>uv</code> names a pixel by how far along each edge it sits: <code>uv.x</code> runs left to right across the canvas, and <code>uv.y</code> runs bottom to top. That is the grid, rows and columns. But the centered <code>p</code> lets you ask a different question: <code>r = length(p)</code> is how far the pixel sits from the middle, and <code>ang = atan(p.y, p.x)</code> is the angle it sits at. That is the wheel, rings and spokes. Same canvas, two coordinate systems.</p>
<p><strong>The interesting part is feeding one into the other.</strong> Whatever you put inside a function becomes the thing that makes the pattern. Drive color by <code>uv.y</code> and you get horizontal bands. Drive it by <code>r</code> and those bands curl into rings. Drive it by <code>ang</code> and they fan into petals around the center. Put <code>r</code> and <code>ang</code> in the same expression and the rings begin to spiral. You are not drawing shapes by hand. You are choosing which coordinate addresses the color.</p>
<p><strong>Lean on sin and cos.</strong> They take any of those inputs, a radius that grows without end or an angle that jumps at its seam, and ease them into a smooth wave that repeats cleanly. Wrap one in <code>* 0.5 + 0.5</code> and it normalizes neatly back into the <code>0</code> to <code>1</code> range every color knob wants. And always reach for <code>u_time</code> somewhere. A still frame is a sketch; a moving one is alive. Let something breathe, spin, or drift.</p>
<p><strong>Then layer with a loop.</strong> One wave is thin. Run a fixed loop and add several together, each at its own frequency, speed, or phase, and they interfere into something far richer than any single line. That is how a flat ring becomes a plasma, a mandala, a whole field of motion. Quiet the later layers so the big shape stays readable.</p>
<p>Now finish it like everything else you learned: pick colors with <code>hsv2rgb</code> or the cosine <code>palette</code>, carve edges with <code>step</code> and <code>smoothstep</code>, blend with <code>mix</code>, then close with gamma, a vignette, or a tone map so the piece looks composed, not like a test.</p>
<p>The starter gives you a launchpad: the <code>palette</code> and <code>hsv2rgb</code> helpers are loaded, with a centered <code>p</code> and a plain <code>uv</code> ready to use. Keep the example line or delete it and begin from black. There is no answer to match here and no wrong move.</p>
<p><strong>The dojo is the gym. This is the gallery.</strong> Make something you are proud of. The next families add shapes, noise, and 3D, but everything you build from here rests on what you just proved you can do.</p>',
 'vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
    return a + b * cos(6.28318 * (c * t + d));
}
void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;

    // Your canvas. Keep this palette as a starting point, or delete it and begin fresh.
    vec3 col = palette(length(p) + u_time * 0.1, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.00, 0.33, 0.67));

    // Finish the piece: gamma here, and try a vignette or a tone map too.
    col = pow(col, vec3(1.0/2.2));

    gl_FragColor = vec4(col, 1.0);
}');
