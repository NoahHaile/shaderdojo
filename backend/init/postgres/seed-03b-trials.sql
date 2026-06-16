\c shader_dojo;

-- Trials, first creative checkpoint (1 course, 1 lesson)
-- This breaks the convergent lesson model on purpose. There is no canonical
-- answer and no hashed_answer: the piece is the learner's own, and "done" means
-- they shared it. Because there is nothing to verify, light guiding comments in
-- the starter are intentional here (unlike the recipe-driven technique lessons).

INSERT INTO lesson (course_id, slug, display_order, title, description, starter_fragment_shader) VALUES

((SELECT id FROM course WHERE slug = 'first-masterwork'), 'Kq3ZpVn7sLx', 0,
 'Your first masterwork',
 '<p>You came in setting one flat color. Look at what is in your hands now: UV and polar coordinates, time and oscillation, step and smoothstep, mix and gradients, loops, HSV, cosine palettes, and a finishing pass that makes any of it look done.</p><p>This trial has no answer to match. Make something of your own. A breathing color field. A radial mandala. A plasma of stacked sines run through a palette. A slow sunset that darkens at the edges. Reach for at least a few of your techniques, then finish the piece with gamma, a vignette, or a tone map so it looks composed, not like a test.</p><p>The starter gives you a launchpad: the <code>palette</code> and <code>hsv2rgb</code> helpers are already loaded, with a centered <code>p</code> and a plain <code>uv</code> ready to use. Keep the example line or delete it and begin from black. There is no wrong move here.</p><p><strong>The dojo is the gym. This is the gallery.</strong> When you have made something you are proud of, share it with other shader artists at <a href="https://www.reddit.com/r/ShaderArt/" target="_blank" rel="noreferrer">r/ShaderArt</a>. Post the image, and drop your code in the comments so others can learn from it.</p><p>That is your first masterwork. The next families add shapes, noise, and 3D, but everything you build from here rests on what you just proved you can do.</p>',
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
