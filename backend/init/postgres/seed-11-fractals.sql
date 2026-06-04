\c shader_dojo;

-- Family J — Iteration & fractals (6 courses, 24 lessons).
-- loop-fundamentals moved to Foundations (seed-02) — it's a prerequisite for noise & raymarching.

INSERT INTO lesson (course_id, slug, display_order, title, description, starter_fragment_shader, canonical_fragment_shader) VALUES

-- ===== Course: accumulation-loops =====
((SELECT id FROM course WHERE slug = 'accumulation-loops'), 'CAixj7DUkss', 0,
 'N-tap blur on image',
 '<p>A box blur reads many pixels near each pixel. You add them all up and divide. That gives a smooth average.</p><p>Use a 5 by 5 grid of samples. That is 25 reads. Set <code>px = 0.005</code> as the step. Sum <code>texture2D(u_image, uv + vec2(x, y) * px)</code> for every <code>(x, y)</code>. Then divide by 25.</p><p>Read more at <a href="https://thebookofshaders.com/13/" target="_blank" rel="noreferrer">Book of Shaders, Fractal Brownian Motion</a>.</p>',
 'void main() {
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float px = 0.005;
    vec4 sum = vec4(0.0);
    for (int x = -2; x <= 2; x++) {
        for (int y = -2; y <= 2; y++) {
            sum += texture2D(u_image, uv + vec2(float(x), float(y)) * px);
        }
    }
    gl_FragColor = sum / 25.0;
}'),

((SELECT id FROM course WHERE slug = 'accumulation-loops'), 'xMi5t4GFZuo', 1,
 'Jitter-sampled AA',
 '<p>You can sample at random spots instead of a grid. Hash a number to get a small offset. Then read the image there. This helps smooth jagged edges.</p><p>Take 8 samples. For each step <code>i</code>, build a jitter from two hash calls. Scale it by a few pixels. Add the <code>u_image</code> sample. Then divide by 8.</p><p>Read more at <a href="https://thebookofshaders.com/13/" target="_blank" rel="noreferrer">Book of Shaders, Fractal Brownian Motion</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float px = 0.005;
    vec4 sum = vec4(0.0);
    for (int x = -2; x <= 2; x++) {
        for (int y = -2; y <= 2; y++) {
            sum += texture2D(u_image, uv + vec2(float(x), float(y)) * px);
        }
    }
    gl_FragColor = sum / 25.0;
}',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec4 sum = vec4(0.0);
    for (int i = 0; i < 8; i++) {
        vec2 j = vec2(hash(uv + float(i)), hash(uv - float(i))) - 0.5;
        sum += texture2D(u_image, uv + j * 0.01);
    }
    gl_FragColor = sum / 8.0;
}'),

((SELECT id FROM course WHERE slug = 'accumulation-loops'), 'Y3cAQQcOcxE', 2,
 'Motion blur',
 '<p>Motion blur takes samples in a line. You add them up. That makes the image smear in one direction.</p><p>Take 8 samples up the y axis. For each step <code>i</code>, sample at <code>uv + vec2(0.0, float(i) * 0.005)</code>. Divide by 8 at the end.</p><p>Read more at <a href="https://thebookofshaders.com/13/" target="_blank" rel="noreferrer">Book of Shaders, Fractal Brownian Motion</a>.</p>',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec4 sum = vec4(0.0);
    for (int i = 0; i < 8; i++) {
        vec2 j = vec2(hash(uv + float(i)), hash(uv - float(i))) - 0.5;
        sum += texture2D(u_image, uv + j * 0.01);
    }
    gl_FragColor = sum / 8.0;
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec4 sum = vec4(0.0);
    for (int i = 0; i < 8; i++) {
        sum += texture2D(u_image, uv + vec2(0.0, float(i) * 0.005));
    }
    gl_FragColor = sum / 8.0;
}'),

((SELECT id FROM course WHERE slug = 'accumulation-loops'), 'wpWMZoP8VUU', 3,
 'Stacked octaves with cutoff',
 '<p>Stacking noise octaves at doubling frequencies is the secret sauce of natural-looking detail. Each octave is half the amplitude and double the frequency of the last, so the sum adds finer wrinkles without overwhelming the base shape.</p><p>To make the cumulative effect obvious, each region of the canvas uses a different octave cutoff: the left third runs 1 octave (raw noise), the middle runs 2, the right runs 4. Walking your eye across the canvas shows the same noise field gaining detail with each added octave.</p><p>Read more at <a href="https://thebookofshaders.com/13/" target="_blank" rel="noreferrer">Book of Shaders, Fractal Brownian Motion</a>.</p>',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 p = uv * 4.0;
    float v = vnoise(p);
    gl_FragColor = vec4(vec3(v), 1.0);
}',
 'float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    int octaves = 1;
    if (uv.x > 0.333) octaves = 2;
    if (uv.x > 0.666) octaves = 4;
    float v = 0.0;
    float a = 0.5;
    vec2 p = uv * 3.0;
    for (int i = 0; i < 4; i++) {
        if (i >= octaves) break;
        v += a * vnoise(p);
        p *= 2.0;
        a *= 0.5;
    }
    gl_FragColor = vec4(vec3(v), 1.0);
}'),

-- ===== Course: mandelbrot =====
((SELECT id FROM course WHERE slug = 'mandelbrot'), 'WWTQAiyd_H8', 0,
 'Binary in-set mask',
 '<p>The Mandelbrot set starts with <code>z = 0</code>. Then you repeat <code>z = z*z + c</code>. The pixel''s spot on the plane is <code>c</code>. If <code>z</code> stays small, the pixel is in the set. If <code>z</code> grows big, it escapes.</p><p>Loop 64 times. Check <code>dot(z, z) &gt; 4.0</code> each step. If true, color the pixel white. If <code>z</code> stays small for all 64 steps, color it black.</p><p>Read more at <a href="https://iquilezles.org/articles/arquimedes/" target="_blank" rel="noreferrer">IQ, Mandelbrot intro</a>.</p>',
 'void main() {
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
 'void main() {
    vec2 c = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0 - vec2(0.5, 0.0);
    vec2 z = vec2(0.0);
    float m = 0.0;
    for (int i = 0; i < 64; i++) {
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        if (dot(z, z) > 4.0) { m = 1.0; break; }
    }
    gl_FragColor = vec4(vec3(m), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'mandelbrot'), 'N2Abg_Mu-aY', 1,
 'Iter count gray',
 '<p>You can save when each pixel escapes. That step number is the escape time. It tells you how far the point is from the set.</p><p>Loop up to 64 times. When <code>dot(z, z) &gt; 4.0</code>, save <code>it = i</code> and break. Output <code>vec3(float(it) / 64.0)</code>. You will see gray bands.</p><p>Read more at <a href="https://iquilezles.org/articles/arquimedes/" target="_blank" rel="noreferrer">IQ, Mandelbrot intro</a>.</p>',
 'void main() {
    vec2 c = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0 - vec2(0.5, 0.0);
    vec2 z = vec2(0.0);
    float m = 0.0;
    for (int i = 0; i < 64; i++) {
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        if (dot(z, z) > 4.0) { m = 1.0; break; }
    }
    gl_FragColor = vec4(vec3(m), 1.0);
}',
 'void main() {
    vec2 c = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0 - vec2(0.5, 0.0);
    vec2 z = vec2(0.0);
    int it = 0;
    for (int i = 0; i < 64; i++) {
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        if (dot(z, z) > 4.0) break;
        it = i;
    }
    gl_FragColor = vec4(vec3(float(it) / 64.0), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'mandelbrot'), 'Bas0UtXRa0Y', 2,
 'Palette colorize',
 '<p>The escape count is one number per pixel. You can feed it into a cosine palette. That maps the number to a color, instead of plain gray.</p><p>The loop and integer escape count are done. Set <code>col</code> to the IQ palette at <code>float(it) * 0.05</code> when the point escaped. Keep it black inside the set. The stairstep banding you''ll see is fixed in the next lesson with the smooth-iter formula.</p><p>Read more at <a href="https://iquilezles.org/articles/distancefractals/" target="_blank" rel="noreferrer">IQ, Distance fractals</a>.</p>',
 'void main() {
    vec2 c = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0 - vec2(0.5, 0.0);
    vec2 z = vec2(0.0);
    int it = 0;
    for (int i = 0; i < 64; i++) {
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        if (dot(z, z) > 4.0) break;
        it = i;
    }
    gl_FragColor = vec4(vec3(float(it) / 64.0), 1.0);
}',
 'vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
    return a + b * cos(6.28318 * (c * t + d));
}
void main() {
    vec2 c = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0 - vec2(0.5, 0.0);
    vec2 z = vec2(0.0);
    int it = 0;
    bool escaped = false;
    for (int i = 0; i < 64; i++) {
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        if (dot(z, z) > 4.0) { escaped = true; break; }
        it = i;
    }
    vec3 col = escaped
        ? palette(float(it) * 0.05, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.0, 0.33, 0.67))
        : vec3(0.0);
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'mandelbrot'), 'B3-FzWCpiMc', 3,
 'Smooth iter count',
 '<p>This removes the staircase you saw in the previous palette lesson. Whole-number escape counts make stair-step color bands. The fix is a smooth count that moves between bands with no seam.</p><p>The starter has the colorized integer-count loop. Add an <code>escaped</code> flag and compute <code>n = float(it) - log2(log2(dot(z, z)))</code> after the loop. Set <code>n = 0.0</code> when the point never escaped so <code>log2</code> doesn''t give NaN. Feed <code>n * 0.05</code> into the same palette and the bands melt into smooth gradients.</p><p>Read more at <a href="https://iquilezles.org/articles/msetsmooth/" target="_blank" rel="noreferrer">IQ, Continuous iteration count</a>.</p>',
 'vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
    return a + b * cos(6.28318 * (c * t + d));
}
void main() {
    vec2 c = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0 - vec2(0.5, 0.0);
    vec2 z = vec2(0.0);
    int it = 0;
    bool escaped = false;
    for (int i = 0; i < 64; i++) {
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        if (dot(z, z) > 4.0) { escaped = true; break; }
        it = i;
    }
    vec3 col = escaped
        ? palette(float(it) * 0.05, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.0, 0.33, 0.67))
        : vec3(0.0);
    gl_FragColor = vec4(col, 1.0);
}',
 'vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
    return a + b * cos(6.28318 * (c * t + d));
}
void main() {
    vec2 c = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0 - vec2(0.5, 0.0);
    vec2 z = vec2(0.0);
    int it = 0;
    bool escaped = false;
    for (int i = 0; i < 64; i++) {
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        if (dot(z, z) > 4.0) { escaped = true; break; }
        it = i;
    }
    float n = float(it) - log2(log2(dot(z, z)));
    if (!escaped) n = 0.0;
    vec3 col = escaped
        ? palette(n * 0.05, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.0, 0.33, 0.67))
        : vec3(0.0);
    gl_FragColor = vec4(col, 1.0);
}'),

-- ===== Course: julia-sets =====
((SELECT id FROM course WHERE slug = 'julia-sets'), 'JjgP_PFlzqw', 0,
 'Static Julia',
 '<p>A Julia set uses the same loop as Mandelbrot. But <code>c</code> is fixed for the whole picture. The pixel''s spot is the starting <code>z</code>. Each <code>c</code> gives a new shape.</p><p>The step is <code>z = vec2(z.x*z.x - z.y*z.y, 2.0*z.x*z.y) + c</code>. Fill in the 64-step loop. Set <code>n = 0.0</code> when the point never escaped.</p><p>Read more at <a href="https://iquilezles.org/articles/juliasets3d/" target="_blank" rel="noreferrer">IQ, 3D Julia sets</a>.</p>',
 'void main() {
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
 'void main() {
    vec2 z = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0;
    vec2 c = vec2(-0.7, 0.27);
    int it = 0;
    bool escaped = false;
    for (int i = 0; i < 64; i++) {
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        if (dot(z, z) > 4.0) { escaped = true; break; }
        it = i;
    }
    float n = float(it) - log2(log2(dot(z, z)));
    if (!escaped) n = 0.0;
    gl_FragColor = vec4(vec3(n / 64.0), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'julia-sets'), 'GUqs2ifF4zc', 1,
 'Animate c on circle',
 '<p>Move <code>c</code> in a circle over time. The Julia shape morphs as <code>c</code> moves. The radius and speed change how much it bends.</p><p>The loop stays the same. Only <code>c</code> moves. Set <code>c = 0.7 * vec2(cos(u_time * 0.3), sin(u_time * 0.3))</code>.</p><p>Read more at <a href="https://iquilezles.org/articles/juliasets3d/" target="_blank" rel="noreferrer">IQ, 3D Julia sets</a>.</p>',
 'void main() {
    vec2 z = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0;
    vec2 c = vec2(-0.7, 0.27);
    int it = 0;
    bool escaped = false;
    for (int i = 0; i < 64; i++) {
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        if (dot(z, z) > 4.0) { escaped = true; break; }
        it = i;
    }
    float n = float(it) - log2(log2(dot(z, z)));
    if (!escaped) n = 0.0;
    gl_FragColor = vec4(vec3(n / 64.0), 1.0);
}',
 'void main() {
    vec2 z = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0;
    vec2 c = 0.7 * vec2(cos(u_time * 0.3), sin(u_time * 0.3));
    int it = 0;
    bool escaped = false;
    for (int i = 0; i < 64; i++) {
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        if (dot(z, z) > 4.0) { escaped = true; break; }
        it = i;
    }
    float n = float(it) - log2(log2(dot(z, z)));
    if (!escaped) n = 0.0;
    gl_FragColor = vec4(vec3(n / 64.0), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'julia-sets'), 'z_aQg0oSmGQ', 2,
 'Zoom into feature',
 '<p>Julia sets repeat at small scales. Zoom in on the edge and you see tiny copies of the whole shape. A small math change on <code>z</code> moves the camera.</p><p>Shrink and shift <code>z</code> before the loop: <code>z = z * 0.4 + vec2(-0.1, 0.6)</code>. That zooms in 2.5x. Keep <code>c</code> at <code>(-0.7, 0.27)</code>.</p><p>Read more at <a href="https://iquilezles.org/articles/juliasets3d/" target="_blank" rel="noreferrer">IQ, 3D Julia sets</a>.</p>',
 'void main() {
    vec2 z = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0;
    vec2 c = vec2(-0.7, 0.27);
    int it = 0;
    bool escaped = false;
    for (int i = 0; i < 64; i++) {
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        if (dot(z, z) > 4.0) { escaped = true; break; }
        it = i;
    }
    float n = float(it) - log2(log2(dot(z, z)));
    if (!escaped) n = 0.0;
    gl_FragColor = vec4(vec3(n / 64.0), 1.0);
}',
 'void main() {
    vec2 z = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0;
    z = z * 0.4 + vec2(-0.1, 0.6);
    vec2 c = vec2(-0.7, 0.27);
    int it = 0;
    bool escaped = false;
    for (int i = 0; i < 64; i++) {
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        if (dot(z, z) > 4.0) { escaped = true; break; }
        it = i;
    }
    float n = float(it) - log2(log2(dot(z, z)));
    if (!escaped) n = 0.0;
    gl_FragColor = vec4(vec3(n / 64.0), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'julia-sets'), 'd3Imp0svQQk', 3,
 'Two-Julia crossfade',
 '<p>Run two Julia loops at once. Each one uses a different <code>c</code>. Start both from the same <code>z</code>. Then blend the results over time.</p><p>One loop bound runs both at once. Track an <code>escaped</code> flag for each. That stops a finished loop from updating its count. Mix the two smooth counts with <code>0.5 + 0.5 * sin(u_time * 0.3)</code>.</p><p>Read more at <a href="https://iquilezles.org/articles/juliasets3d/" target="_blank" rel="noreferrer">IQ, 3D Julia sets</a>.</p>',
 'void main() {
    vec2 z = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0;
    z = z * 0.4 + vec2(-0.1, 0.6);
    vec2 c = vec2(-0.7, 0.27);
    int it = 0;
    bool escaped = false;
    for (int i = 0; i < 64; i++) {
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        if (dot(z, z) > 4.0) { escaped = true; break; }
        it = i;
    }
    float n = float(it) - log2(log2(dot(z, z)));
    if (!escaped) n = 0.0;
    gl_FragColor = vec4(vec3(n / 64.0), 1.0);
}',
 'void main() {
    vec2 z0 = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0;
    vec2 c1 = vec2(-0.7, 0.27);
    vec2 c2 = vec2(0.285, 0.01);
    vec2 za = z0;
    vec2 zb = z0;
    int ita = 0;
    int itb = 0;
    bool ea = false;
    bool eb = false;
    for (int i = 0; i < 64; i++) {
        if (!ea) {
            za = vec2(za.x * za.x - za.y * za.y, 2.0 * za.x * za.y) + c1;
            if (dot(za, za) > 4.0) ea = true; else ita = i;
        }
        if (!eb) {
            zb = vec2(zb.x * zb.x - zb.y * zb.y, 2.0 * zb.x * zb.y) + c2;
            if (dot(zb, zb) > 4.0) eb = true; else itb = i;
        }
    }
    float na = ea ? (float(ita) - log2(log2(dot(za, za)))) : 0.0;
    float nb = eb ? (float(itb) - log2(log2(dot(zb, zb)))) : 0.0;
    float t = 0.5 + 0.5 * sin(u_time * 0.3);
    float n = mix(na, nb, t);
    gl_FragColor = vec4(vec3(n / 64.0), 1.0);
}'),

-- ===== Course: orbit-traps =====
((SELECT id FROM course WHERE slug = 'orbit-traps'), 'cbG-2ccChv8', 0,
 'Point trap (Mandelbrot)',
 '<p>An orbit trap watches how close <code>z</code> gets to a shape during the loop. You save the smallest distance. Use that distance as the color.</p><p>Run the Mandelbrot loop. Each step, update <code>trap = min(trap, length(z - vec2(0.0, 1.0)))</code>. Output the trap as gray. You will see new patterns shaped by the trap point.</p><p>Read more at <a href="https://iquilezles.org/articles/ftrapsprocedural/" target="_blank" rel="noreferrer">IQ, Procedural orbit traps</a>.</p>',
 'void main() {
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
 'void main() {
    vec2 c = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0 - vec2(0.5, 0.0);
    vec2 z = vec2(0.0);
    float trap = 1e10;
    for (int i = 0; i < 64; i++) {
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        trap = min(trap, length(z - vec2(0.0, 1.0)));
        if (dot(z, z) > 4.0) break;
    }
    gl_FragColor = vec4(vec3(trap), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'orbit-traps'), 'Z0mmaXwERaU', 1,
 'Line trap (Julia)',
 '<p>You can change the trap shape. A line trap grows ribbon patterns. The distance from <code>z</code> to the y axis is just <code>abs(z.x)</code>.</p><p>Run a Julia loop with <code>c = (-0.7, 0.27)</code>. Each step, update <code>trap = min(trap, abs(z.x))</code>.</p><p>Read more at <a href="https://iquilezles.org/articles/ftrapsgeometric/" target="_blank" rel="noreferrer">IQ, Geometric orbit traps</a>.</p>',
 'void main() {
    vec2 c = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0 - vec2(0.5, 0.0);
    vec2 z = vec2(0.0);
    float trap = 1e10;
    for (int i = 0; i < 64; i++) {
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        trap = min(trap, length(z - vec2(0.0, 1.0)));
        if (dot(z, z) > 4.0) break;
    }
    gl_FragColor = vec4(vec3(trap), 1.0);
}',
 'void main() {
    vec2 z = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0;
    vec2 c = vec2(-0.7, 0.27);
    float trap = 1e10;
    for (int i = 0; i < 64; i++) {
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        trap = min(trap, abs(z.x));
        if (dot(z, z) > 4.0) break;
    }
    gl_FragColor = vec4(vec3(trap), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'orbit-traps'), 'YAohKdAMs-4', 2,
 'Multi-trap min',
 '<p>You can mix many traps. Take the smallest distance from all of them. Each trap adds its own features to the picture.</p><p>Use Julia with <code>c = (-0.7, 0.27)</code>. Each step, update <code>trap = min(trap, min(length(z), abs(z.y - 0.5)))</code>. That uses a point at the origin and a flat line.</p><p>Read more at <a href="https://iquilezles.org/articles/ftrapsbitmap/" target="_blank" rel="noreferrer">IQ, Bitmap orbit traps</a>.</p>',
 'void main() {
    vec2 z = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0;
    vec2 c = vec2(-0.7, 0.27);
    float trap = 1e10;
    for (int i = 0; i < 64; i++) {
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        trap = min(trap, abs(z.x));
        if (dot(z, z) > 4.0) break;
    }
    gl_FragColor = vec4(vec3(trap), 1.0);
}',
 'void main() {
    vec2 z = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0;
    vec2 c = vec2(-0.7, 0.27);
    float trap = 1e10;
    for (int i = 0; i < 64; i++) {
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        trap = min(trap, min(length(z), abs(z.y - 0.5)));
        if (dot(z, z) > 4.0) break;
    }
    gl_FragColor = vec4(vec3(trap), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'orbit-traps'), 'E2g3RC2CD2U', 3,
 'Animated trap',
 '<p>Move the trap point in a circle over time. The fractal and the loop stay the same. The inner pattern swirls as the trap moves.</p><p>Set the trap point to <code>0.5 * vec2(cos(u_time * 0.3), sin(u_time * 0.3))</code>. Each step, update <code>trap = min(trap, length(z - p))</code>.</p><p>Read more at <a href="https://iquilezles.org/articles/ftrapsprocedural/" target="_blank" rel="noreferrer">IQ, Procedural orbit traps</a>.</p>',
 'void main() {
    vec2 z = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0;
    vec2 c = vec2(-0.7, 0.27);
    float trap = 1e10;
    for (int i = 0; i < 64; i++) {
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        trap = min(trap, min(length(z), abs(z.y - 0.5)));
        if (dot(z, z) > 4.0) break;
    }
    gl_FragColor = vec4(vec3(trap), 1.0);
}',
 'void main() {
    vec2 z = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y * 2.0;
    vec2 c = vec2(-0.7, 0.27);
    vec2 p = 0.5 * vec2(cos(u_time * 0.3), sin(u_time * 0.3));
    float trap = 1e10;
    for (int i = 0; i < 64; i++) {
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        trap = min(trap, length(z - p));
        if (dot(z, z) > 4.0) break;
    }
    gl_FragColor = vec4(vec3(trap), 1.0);
}'),

-- ===== Course: ifs-folding =====
((SELECT id FROM course WHERE slug = 'ifs-folding'), 'uP3HCxq4Tco', 0,
 '2D Sierpinski',
 '<p>An IFS fold bends and shrinks space. Each step adds more detail near the origin. The Sierpinski fold takes <code>abs</code>, flips when the sum is over 1, then scales by 2 and shifts.</p><p>Run 6 fold steps on a centered <code>p</code>. Use <code>step(length(p), 1.0)</code> as the mask.</p><p>Read more at <a href="https://iquilezles.org/articles/ifsfractals/" target="_blank" rel="noreferrer">IQ, IFS fractals</a>.</p>',
 'void main() {
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 p = (uv - 0.5) * 2.0;
    for (int i = 0; i < 6; i++) {
        p = abs(p);
        if (p.x + p.y > 1.0) p = vec2(1.0) - p.yx;
        p = p * 2.0 - vec2(1.0);
    }
    float m = step(length(p), 1.0);
    gl_FragColor = vec4(vec3(m), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'ifs-folding'), '_LDkavCZ2fs', 1,
 'Koch detail',
 '<p>Each fold gives a new fractal. Mix <code>abs</code>, a rotate, and a scale. You get spiky Koch-like edges.</p><p>Run 6 steps. Each step takes <code>abs</code>, rotates <code>p</code> by a fixed matrix, then scales by 2 and shifts.</p><p>Read more at <a href="https://iquilezles.org/articles/ifsfractals/" target="_blank" rel="noreferrer">IQ, IFS fractals</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 p = (uv - 0.5) * 2.0;
    for (int i = 0; i < 6; i++) {
        p = abs(p);
        if (p.x + p.y > 1.0) p = vec2(1.0) - p.yx;
        p = p * 2.0 - vec2(1.0);
    }
    float m = step(length(p), 1.0);
    gl_FragColor = vec4(vec3(m), 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 p = (uv - 0.5) * 2.0;
    float a = 0.5;
    mat2 R = mat2(cos(a), -sin(a), sin(a), cos(a));
    for (int i = 0; i < 6; i++) {
        p = abs(p);
        p = R * p;
        p = p * 2.0 - vec2(1.0);
    }
    float m = step(length(p), 1.0);
    gl_FragColor = vec4(vec3(m), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'ifs-folding'), 'DbJr87pcKpo', 2,
 'Asymmetric IFS',
 '<p>The Sierpinski fold scales x and y by the same factor, which is why the result is symmetric. Pick different scale factors for x and y and the fractal stretches in one direction — same fold rule, very different shape.</p><p>Keep the Sierpinski abs and corner flip. Then replace <code>p * 2.0 - vec2(1.0)</code> with <code>vec2(p.x * 2.0, p.y * 1.6) - vec2(1.0, 0.8)</code>. The x axis still doubles each step but the y axis grows slower, so the fractal looks visibly stretched horizontally.</p><p>Read more at <a href="https://iquilezles.org/articles/ifsfractals/" target="_blank" rel="noreferrer">IQ, IFS fractals</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 p = (uv - 0.5) * 2.0;
    for (int i = 0; i < 6; i++) {
        p = abs(p);
        if (p.x + p.y > 1.0) p = vec2(1.0) - p.yx;
        p = p * 2.0 - vec2(1.0);
    }
    float m = step(length(p), 1.0);
    gl_FragColor = vec4(vec3(m), 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 p = (uv - 0.5) * 2.0;
    for (int i = 0; i < 6; i++) {
        p = abs(p);
        if (p.x + p.y > 1.0) p = vec2(1.0) - p.yx;
        p = vec2(p.x * 2.0, p.y * 1.6) - vec2(1.0, 0.8);
    }
    float m = step(length(p), 1.0);
    gl_FragColor = vec4(vec3(m), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'ifs-folding'), 'w_yMH23pxjg', 3,
 'Animated fold param',
 '<p>The loop bound must be constant. But the values inside can change. Animate the scale factor over time.</p><p>Use a fixed 6-step Sierpinski loop. Replace <code>p * 2.0</code> with <code>p * s</code>. Set <code>s = 1.95 + 0.1 * sin(u_time * 0.3)</code>. The fractal pulses.</p><p>Read more at <a href="https://iquilezles.org/articles/ifsfractals/" target="_blank" rel="noreferrer">IQ, IFS fractals</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 p = (uv - 0.5) * 2.0;
    for (int i = 0; i < 6; i++) {
        p = abs(p);
        if (p.x + p.y > 1.0) p = vec2(1.0) - p.yx;
        p = p * 2.0 - vec2(1.0);
    }
    float m = step(length(p), 1.0);
    gl_FragColor = vec4(vec3(m), 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 p = (uv - 0.5) * 2.0;
    float s = 1.95 + 0.1 * sin(u_time * 0.3);
    for (int i = 0; i < 6; i++) {
        p = abs(p);
        if (p.x + p.y > 1.0) p = vec2(1.0) - p.yx;
        p = p * s - vec2(1.0);
    }
    float m = step(length(p), 1.0);
    gl_FragColor = vec4(vec3(m), 1.0);
}'),

-- ===== Course: kifs-raymarched =====
((SELECT id FROM course WHERE slug = 'kifs-raymarched'), '2R5iMV8viwM', 0,
 'Simple fold + raymarch',
 '<p>A KIFS is a 3D fold with a real SDF. You raymarch the result. Each step also tracks a scale value so the distance stays right.</p><p>Inside <code>scene(p)</code>, fold 6 times with <code>abs</code> and sorted swap. Multiply <code>p</code> by 1.5 and <code>s</code> by 1.5 each step. Return <code>(length(p) - 2.0) / s</code> as the distance. Then raymarch from a fixed camera.</p><p>Read more at <a href="https://iquilezles.org/articles/menger/" target="_blank" rel="noreferrer">IQ, Menger fractal</a>.</p>',
 'void main() {
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
 'float scene(vec3 p) {
    float s = 1.0;
    for (int i = 0; i < 6; i++) {
        p = abs(p) - vec3(1.0);
        if (p.x < p.y) p.xy = p.yx;
        if (p.y < p.z) p.yz = p.zy;
        if (p.x < p.y) p.xy = p.yx;
        p *= 1.5;
        s *= 1.5;
    }
    return (length(p) - 2.0) / s;
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 4.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    for (int i = 0; i < 64; i++) {
        vec3 p = ro + rd * t;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        t += d;
        if (t > 20.0) break;
    }
    vec3 col = hit ? vec3(1.0) : vec3(0.85, 0.90, 0.95);
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'kifs-raymarched'), 'XrXdetTC8tQ', 1,
 'Mandelbox-lite',
 '<p>A sphere fold is half of the Mandelbox idea. It shrinks points near the origin and flips points just outside a unit sphere. The result has bubble-like holes.</p><p>Inside the loop, compute <code>r2 = dot(p, p)</code>. If <code>r2 &lt; 0.25</code>, multiply <code>p</code> by 4. Else if <code>r2 &lt; 1.0</code>, divide by <code>r2</code>. Mix this with the KIFS abs-fold.</p><p>Read more at <a href="https://iquilezles.org/articles/distancefractals/" target="_blank" rel="noreferrer">IQ, Distance fractals</a>.</p>',
 'float scene(vec3 p) {
    float s = 1.0;
    for (int i = 0; i < 6; i++) {
        p = abs(p) - vec3(1.0);
        if (p.x < p.y) p.xy = p.yx;
        if (p.y < p.z) p.yz = p.zy;
        if (p.x < p.y) p.xy = p.yx;
        p *= 1.5;
        s *= 1.5;
    }
    return (length(p) - 2.0) / s;
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 4.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    for (int i = 0; i < 64; i++) {
        vec3 p = ro + rd * t;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        t += d;
        if (t > 20.0) break;
    }
    vec3 col = hit ? vec3(1.0) : vec3(0.85, 0.90, 0.95);
    gl_FragColor = vec4(col, 1.0);
}',
 'float scene(vec3 p) {
    float s = 1.0;
    for (int i = 0; i < 6; i++) {
        p = abs(p) - vec3(1.0);
        float r2 = dot(p, p);
        if (r2 < 0.25) { p *= 4.0; s *= 4.0; }
        else if (r2 < 1.0) { p /= r2; s /= r2; }
        p *= 1.5;
        s *= 1.5;
    }
    return (length(p) - 2.0) / s;
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 4.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    for (int i = 0; i < 64; i++) {
        vec3 p = ro + rd * t;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        t += d;
        if (t > 20.0) break;
    }
    vec3 col = hit ? vec3(1.0) : vec3(0.85, 0.90, 0.95);
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'kifs-raymarched'), 'Hk7dP6NHCus', 2,
 'Off-center fold pivot',
 '<p>The standard KIFS folds around the origin: <code>abs(p) - vec3(1.0)</code> mirrors space across the three planes through <code>x = 0</code>, <code>y = 0</code>, <code>z = 0</code>. Shifting the pivot is a tiny code change with a dramatic visual one — the same fold rule, applied around a different center, produces a different fractal entirely.</p><p>Add an <code>offset = vec3(1.2, 1.0, 0.8)</code> and replace <code>abs(p) - vec3(1.0)</code> with <code>abs(p + offset) - offset</code>. The fold now mirrors space across planes through <code>-offset</code> instead of through the origin, so each iteration carves a new asymmetric structure.</p><p>Read more at <a href="https://mercury.sexy/hg_sdf/" target="_blank" rel="noreferrer">hg_sdf, SDF library</a>.</p>',
 'float scene(vec3 p) {
    float s = 1.0;
    for (int i = 0; i < 6; i++) {
        p = abs(p) - vec3(1.0);
        if (p.x < p.y) p.xy = p.yx;
        if (p.y < p.z) p.yz = p.zy;
        if (p.x < p.y) p.xy = p.yx;
        p *= 1.5;
        s *= 1.5;
    }
    return (length(p) - 2.0) / s;
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 4.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    for (int i = 0; i < 64; i++) {
        vec3 p = ro + rd * t;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        t += d;
        if (t > 20.0) break;
    }
    vec3 col = hit ? vec3(1.0) : vec3(0.85, 0.90, 0.95);
    gl_FragColor = vec4(col, 1.0);
}',
 'float scene(vec3 p) {
    float s = 1.0;
    vec3 offset = vec3(1.2, 1.0, 0.8);
    for (int i = 0; i < 6; i++) {
        p = abs(p + offset) - offset;
        if (p.x < p.y) p.xy = p.yx;
        if (p.y < p.z) p.yz = p.zy;
        if (p.x < p.y) p.xy = p.yx;
        p *= 1.5;
        s *= 1.5;
    }
    return (length(p) - 2.0) / s;
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 4.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    for (int i = 0; i < 64; i++) {
        vec3 p = ro + rd * t;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        t += d;
        if (t > 20.0) break;
    }
    vec3 col = hit ? vec3(1.0) : vec3(0.85, 0.90, 0.95);
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'kifs-raymarched'), '-qQ7eiM9vK4', 3,
 'Orbit-trap color',
 '<p>Orbit traps work in 3D too. Track how close <code>p</code> gets to the origin during the fold. Save the smallest distance. Use that number as a color input.</p><p>Add a global <code>g_trap</code>. The scene function writes to it each fold step. Feed <code>g_trap</code> to the IQ palette for the hit color.</p><p>Read more at <a href="https://iquilezles.org/articles/menger/" target="_blank" rel="noreferrer">IQ, Menger fractal</a>.</p>',
 'float scene(vec3 p) {
    float s = 1.0;
    vec3 offset = vec3(1.2, 1.0, 0.8);
    for (int i = 0; i < 6; i++) {
        p = abs(p + offset) - offset;
        if (p.x < p.y) p.xy = p.yx;
        if (p.y < p.z) p.yz = p.zy;
        if (p.x < p.y) p.xy = p.yx;
        p *= 1.5;
        s *= 1.5;
    }
    return (length(p) - 2.0) / s;
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 4.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    for (int i = 0; i < 64; i++) {
        vec3 p = ro + rd * t;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        t += d;
        if (t > 20.0) break;
    }
    vec3 col = hit ? vec3(1.0) : vec3(0.85, 0.90, 0.95);
    gl_FragColor = vec4(col, 1.0);
}',
 'vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
    return a + b * cos(6.28318 * (c * t + d));
}
float g_trap;
float scene(vec3 p) {
    float s = 1.0;
    g_trap = 1e10;
    for (int i = 0; i < 6; i++) {
        p = abs(p) - vec3(1.0);
        if (p.x < p.y) p.xy = p.yx;
        if (p.y < p.z) p.yz = p.zy;
        if (p.x < p.y) p.xy = p.yx;
        p *= 1.5;
        s *= 1.5;
        g_trap = min(g_trap, length(p));
    }
    return (length(p) - 2.0) / s;
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 4.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    for (int i = 0; i < 64; i++) {
        vec3 p = ro + rd * t;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        t += d;
        if (t > 20.0) break;
    }
    vec3 col = hit
        ? palette(g_trap * 0.2, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.0, 0.33, 0.67))
        : vec3(0.85, 0.90, 0.95);
    gl_FragColor = vec4(col, 1.0);
}');
