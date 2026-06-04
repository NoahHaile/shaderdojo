\c shader_dojo;

-- Family H — Procedural generation (6 courses, 24 lessons)

INSERT INTO lesson (course_id, slug, display_order, title, description, starter_fragment_shader, canonical_fragment_shader) VALUES

-- ===== Course: proc-terrain =====
((SELECT id FROM course WHERE slug = 'proc-terrain'), 'Bvw0ZYStciI', 0,
 'Heightmap from fbm',
 '<p>Terrain starts with a height at each pixel. Sample <code>fbm(uv * 3.0)</code> across the canvas. Stack noise means fbm, the noise sum from earlier.</p><p>Output the height as gray. White pixels are peaks. Black pixels are valleys. You see the land from above.</p><p>Reference: <a href="https://iquilezles.org/articles/terrainmarching/" target="_blank" rel="noreferrer">IQ — Terrain raymarching</a>.</p>',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
float vnoise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    vec2 u = f*f*(3.0-2.0*f);
    return mix(mix(hash(i),         hash(i+vec2(1,0)), u.x),
               mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)), u.x), u.y);
}
float fbm(vec2 p) {
    float v=0.0, a=0.5;
    for (int i=0; i<5; i++) { v += a*vnoise(p); p *= 2.0; a *= 0.5; }
    return v;
}
void main() {
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
float vnoise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    vec2 u = f*f*(3.0-2.0*f);
    return mix(mix(hash(i),         hash(i+vec2(1,0)), u.x),
               mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)), u.x), u.y);
}
float fbm(vec2 p) {
    float v=0.0, a=0.5;
    for (int i=0; i<5; i++) { v += a*vnoise(p); p *= 2.0; a *= 0.5; }
    return v;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float h = fbm(uv * 3.0);
    gl_FragColor = vec4(vec3(h), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'proc-terrain'), 'VDrjzjVZ7Fk', 1,
 'Banded contours',
 '<p>The smooth fbm height is a continuous gradient — useful, but hard to read at a glance. Hikers solve the same problem on paper maps with contour lines: pick a vertical step (say every 100 meters) and only draw the elevation at those discrete levels. Suddenly the terrain reads as a stack of plateaus.</p><p>Do the same trick here with <code>floor(h * 10.0) / 10.0</code>. That quantizes the smooth height into 10 flat bands — every pixel in the same band shares the same exact value. The result looks like a topographic map seen from above: each band is one elevation step, and the band edges trace the contour lines.</p><p>Reference: <a href="https://iquilezles.org/articles/terrainmarching/" target="_blank" rel="noreferrer">IQ — Terrain raymarching</a>.</p>',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
float vnoise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    vec2 u = f*f*(3.0-2.0*f);
    return mix(mix(hash(i),         hash(i+vec2(1,0)), u.x),
               mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)), u.x), u.y);
}
float fbm(vec2 p) {
    float v=0.0, a=0.5;
    for (int i=0; i<5; i++) { v += a*vnoise(p); p *= 2.0; a *= 0.5; }
    return v;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float h = fbm(uv * 3.0);
    gl_FragColor = vec4(vec3(h), 1.0);
}',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
float vnoise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    vec2 u = f*f*(3.0-2.0*f);
    return mix(mix(hash(i),         hash(i+vec2(1,0)), u.x),
               mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)), u.x), u.y);
}
float fbm(vec2 p) {
    float v=0.0, a=0.5;
    for (int i=0; i<5; i++) { v += a*vnoise(p); p *= 2.0; a *= 0.5; }
    return v;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float b = floor(fbm(uv * 3.0) * 10.0) / 10.0;
    gl_FragColor = vec4(vec3(b), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'proc-terrain'), 'tgCjv17iPSw', 2,
 'Colorize by height',
 '<p>Feed the height into a cosine palette. That is the four-vector palette from the palette course. Each height gets a color.</p><p>Low pixels turn blue. Middle pixels turn green. High pixels turn warm. Now it looks like a map of land.</p><p>Reference: <a href="https://iquilezles.org/articles/terrainmarching/" target="_blank" rel="noreferrer">IQ — Terrain raymarching</a>.</p>',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
float vnoise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    vec2 u = f*f*(3.0-2.0*f);
    return mix(mix(hash(i),         hash(i+vec2(1,0)), u.x),
               mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)), u.x), u.y);
}
float fbm(vec2 p) {
    float v=0.0, a=0.5;
    for (int i=0; i<5; i++) { v += a*vnoise(p); p *= 2.0; a *= 0.5; }
    return v;
}
vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) { return a+b*cos(6.28318*(c*t+d)); }
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float b = floor(fbm(uv * 3.0) * 10.0) / 10.0;
    gl_FragColor = vec4(vec3(b), 1.0);
}',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
float vnoise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    vec2 u = f*f*(3.0-2.0*f);
    return mix(mix(hash(i),         hash(i+vec2(1,0)), u.x),
               mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)), u.x), u.y);
}
float fbm(vec2 p) {
    float v=0.0, a=0.5;
    for (int i=0; i<5; i++) { v += a*vnoise(p); p *= 2.0; a *= 0.5; }
    return v;
}
vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) { return a+b*cos(6.28318*(c*t+d)); }
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float h = fbm(uv * 3.0);
    vec3 col = palette(h, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.00, 0.33, 0.67));
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'proc-terrain'), 'Q3u_mBuhJs0', 3,
 'Two-band coloring',
 '<p>Real maps split land from sea at a single cutoff. Pick a <code>seaLevel</code> like <code>0.45</code>. Anywhere the height is below it, paint a flat sea blue. Anywhere above, mix from a grassy green up to a snowy white with <code>smoothstep(seaLevel, 1.0, h)</code>.</p><p>Use a <code>?:</code> ternary on <code>h &lt; seaLevel</code> to pick sea or land. The smooth height field snaps into a clear coastline, with green lowlands rolling up to white peaks. No animation needed — the split itself is the lesson.</p><p>Reference: <a href="https://iquilezles.org/articles/terrainmarching/" target="_blank" rel="noreferrer">IQ — Terrain raymarching</a>.</p>',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
float vnoise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    vec2 u = f*f*(3.0-2.0*f);
    return mix(mix(hash(i),         hash(i+vec2(1,0)), u.x),
               mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)), u.x), u.y);
}
float fbm(vec2 p) {
    float v=0.0, a=0.5;
    for (int i=0; i<5; i++) { v += a*vnoise(p); p *= 2.0; a *= 0.5; }
    return v;
}
vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) { return a+b*cos(6.28318*(c*t+d)); }
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float h = fbm(uv * 3.0);
    vec3 col = palette(h, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.00, 0.33, 0.67));
    gl_FragColor = vec4(col, 1.0);
}',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
float vnoise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    vec2 u = f*f*(3.0-2.0*f);
    return mix(mix(hash(i),         hash(i+vec2(1,0)), u.x),
               mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)), u.x), u.y);
}
float fbm(vec2 p) {
    float v=0.0, a=0.5;
    for (int i=0; i<5; i++) { v += a*vnoise(p); p *= 2.0; a *= 0.5; }
    return v;
}
vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) { return a+b*cos(6.28318*(c*t+d)); }
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float h = fbm(uv * 3.0);
    float seaLevel = 0.45;
    vec3 sea = vec3(0.15, 0.35, 0.55);
    vec3 land = mix(vec3(0.30, 0.55, 0.25), vec3(0.95, 0.95, 0.92), smoothstep(seaLevel, 1.0, h));
    vec3 col = h < seaLevel ? sea : land;
    gl_FragColor = vec4(col, 1.0);
}'),

-- ===== Course: proc-clouds =====
((SELECT id FROM course WHERE slug = 'proc-clouds'), '2JiygQDRMEg', 0,
 'fbm cloud field',
 '<p>Mix blue sky with white. Use <code>fbm(uv * 4.0)</code> as the blend amount. Stack noise means fbm again.</p><p>You get soft, foggy clouds right away. White where the noise is high. Blue where the noise is low.</p><p>Reference: <a href="https://iquilezles.org/articles/dynclouds/" target="_blank" rel="noreferrer">IQ — 2D dynamic clouds</a>.</p>',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
float vnoise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    vec2 u = f*f*(3.0-2.0*f);
    return mix(mix(hash(i),         hash(i+vec2(1,0)), u.x),
               mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)), u.x), u.y);
}
float fbm(vec2 p) {
    float v=0.0, a=0.5;
    for (int i=0; i<5; i++) { v += a*vnoise(p); p *= 2.0; a *= 0.5; }
    return v;
}
void main() {
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
float vnoise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    vec2 u = f*f*(3.0-2.0*f);
    return mix(mix(hash(i),         hash(i+vec2(1,0)), u.x),
               mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)), u.x), u.y);
}
float fbm(vec2 p) {
    float v=0.0, a=0.5;
    for (int i=0; i<5; i++) { v += a*vnoise(p); p *= 2.0; a *= 0.5; }
    return v;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 col = mix(vec3(0.4, 0.6, 0.9), vec3(1.0), fbm(uv * 4.0));
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'proc-clouds'), 'Nhf-YKEnUsc', 1,
 'Thresholded clouds',
 '<p>Use <code>smoothstep(0.5, 0.7, fbm(uv * 4.0))</code> to cut sharper clouds. Smoothstep gives a soft step from 0 to 1.</p><p>Noise below 0.5 is pure sky. Noise above 0.7 is pure white. You get puffy clouds with clear edges.</p><p>Reference: <a href="https://iquilezles.org/articles/dynclouds/" target="_blank" rel="noreferrer">IQ — 2D dynamic clouds</a>.</p>',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
float vnoise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    vec2 u = f*f*(3.0-2.0*f);
    return mix(mix(hash(i),         hash(i+vec2(1,0)), u.x),
               mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)), u.x), u.y);
}
float fbm(vec2 p) {
    float v=0.0, a=0.5;
    for (int i=0; i<5; i++) { v += a*vnoise(p); p *= 2.0; a *= 0.5; }
    return v;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 col = mix(vec3(0.4, 0.6, 0.9), vec3(1.0), fbm(uv * 4.0));
    gl_FragColor = vec4(col, 1.0);
}',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
float vnoise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    vec2 u = f*f*(3.0-2.0*f);
    return mix(mix(hash(i),         hash(i+vec2(1,0)), u.x),
               mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)), u.x), u.y);
}
float fbm(vec2 p) {
    float v=0.0, a=0.5;
    for (int i=0; i<5; i++) { v += a*vnoise(p); p *= 2.0; a *= 0.5; }
    return v;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float cloud = smoothstep(0.5, 0.7, fbm(uv * 4.0));
    vec3 col = mix(vec3(0.4, 0.6, 0.9), vec3(1.0), cloud);
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'proc-clouds'), '3YAyj9ZJBtc', 2,
 'Scrolling clouds',
 '<p>Shift the noise sample by <code>vec2(u_time * 0.05, 0.0)</code>. The clouds slide sideways across the sky.</p><p>Animate the x part for side wind. Animate the y part for up or down. You pick the wind direction.</p><p>Reference: <a href="https://iquilezles.org/articles/dynclouds/" target="_blank" rel="noreferrer">IQ — 2D dynamic clouds</a>.</p>',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
float vnoise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    vec2 u = f*f*(3.0-2.0*f);
    return mix(mix(hash(i),         hash(i+vec2(1,0)), u.x),
               mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)), u.x), u.y);
}
float fbm(vec2 p) {
    float v=0.0, a=0.5;
    for (int i=0; i<5; i++) { v += a*vnoise(p); p *= 2.0; a *= 0.5; }
    return v;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float cloud = smoothstep(0.5, 0.7, fbm(uv * 4.0));
    vec3 col = mix(vec3(0.4, 0.6, 0.9), vec3(1.0), cloud);
    gl_FragColor = vec4(col, 1.0);
}',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
float vnoise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    vec2 u = f*f*(3.0-2.0*f);
    return mix(mix(hash(i),         hash(i+vec2(1,0)), u.x),
               mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)), u.x), u.y);
}
float fbm(vec2 p) {
    float v=0.0, a=0.5;
    for (int i=0; i<5; i++) { v += a*vnoise(p); p *= 2.0; a *= 0.5; }
    return v;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float cloud = smoothstep(0.5, 0.7, fbm(uv * 4.0 + vec2(u_time * 0.05, 0.0)));
    vec3 col = mix(vec3(0.4, 0.6, 0.9), vec3(1.0), cloud);
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'proc-clouds'), 'XyGod8SJsUY', 3,
 'Sun-glow tinted',
 '<p>Add a warm sun near the horizon at <code>(0.7, 0.3)</code>. Use a falloff with <code>exp(-length(...) * 4.0)</code>. The glow fades out with distance.</p><p>Put the sun under the clouds. The clouds catch the warm tint where the glow is bright. You get a sky with a sun behind clouds.</p><p>Reference: <a href="https://iquilezles.org/articles/dynclouds/" target="_blank" rel="noreferrer">IQ — 2D dynamic clouds</a>.</p>',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
float vnoise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    vec2 u = f*f*(3.0-2.0*f);
    return mix(mix(hash(i),         hash(i+vec2(1,0)), u.x),
               mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)), u.x), u.y);
}
float fbm(vec2 p) {
    float v=0.0, a=0.5;
    for (int i=0; i<5; i++) { v += a*vnoise(p); p *= 2.0; a *= 0.5; }
    return v;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float cloud = smoothstep(0.5, 0.7, fbm(uv * 4.0 + vec2(u_time * 0.05, 0.0)));
    vec3 col = mix(vec3(0.4, 0.6, 0.9), vec3(1.0), cloud);
    gl_FragColor = vec4(col, 1.0);
}',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
float vnoise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    vec2 u = f*f*(3.0-2.0*f);
    return mix(mix(hash(i),         hash(i+vec2(1,0)), u.x),
               mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)), u.x), u.y);
}
float fbm(vec2 p) {
    float v=0.0, a=0.5;
    for (int i=0; i<5; i++) { v += a*vnoise(p); p *= 2.0; a *= 0.5; }
    return v;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 sky = vec3(0.4, 0.6, 0.9);
    float sun = exp(-length(uv - vec2(0.7, 0.3)) * 4.0);
    vec3 warm = vec3(1.0, 0.85, 0.6);
    vec3 col = sky + warm * sun;
    float cloud = smoothstep(0.5, 0.7, fbm(uv * 4.0 + vec2(u_time * 0.05, 0.0)));
    col = mix(col, vec3(1.0) * (0.7 + 0.3 * warm), cloud);
    gl_FragColor = vec4(col, 1.0);
}'),

-- ===== Course: proc-water-waves =====
((SELECT id FROM course WHERE slug = 'proc-water-waves'), 'EU6QZH29WHU', 0,
 'Stacked sines',
 '<p>Water is often a few sine waves added up. Add two sines along x at different speeds. Each sine is a smooth wave.</p><p>Use the sum as a height. Shift a blue color up and down by the height. You get a rolling sea.</p><p>Reference: <a href="https://iquilezles.org/articles/simplewater/" target="_blank" rel="noreferrer">IQ — Simple water</a>.</p>',
 'void main() {
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float h = sin(uv.x * 8.0 + u_time) + 0.5 * sin(uv.x * 16.0 + u_time * 1.7);
    vec3 col = vec3(0.3, 0.5, 0.8) + 0.1 * vec3(h);
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'proc-water-waves'), '5_iUO0-dA58', 1,
 'Two-axis interference',
 '<p>Add a sine wave in y as well as x. The two waves cross at right angles. They add and cancel in spots.</p><p>You get a diamond pattern. It looks like choppy water seen from above.</p><p>Reference: <a href="https://iquilezles.org/articles/simplewater/" target="_blank" rel="noreferrer">IQ — Simple water</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float h = sin(uv.x * 8.0 + u_time) + 0.5 * sin(uv.x * 16.0 + u_time * 1.7);
    vec3 col = vec3(0.3, 0.5, 0.8) + 0.1 * vec3(h);
    gl_FragColor = vec4(col, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float h = sin(uv.x * 8.0 + u_time) + sin(uv.y * 8.0 + u_time * 0.7);
    vec3 col = vec3(0.3, 0.5, 0.8) + 0.1 * vec3(h);
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'proc-water-waves'), '2rJUjervMCk', 2,
 'Derived normal',
 '<p>Find the slope of the height. Sample the height a tiny step left and right. Subtract them. That gives the slope in x. Do the same up and down for y.</p><p>The two slopes give the surface direction. Pack them as <code>0.5 + 0.5 * vec3(gx, gy, 1.0)</code> to see the normal map.</p><p>Reference: <a href="https://iquilezles.org/articles/simplewater/" target="_blank" rel="noreferrer">IQ — Simple water</a>.</p>',
 'float height(vec2 uv) {
    return sin(uv.x * 8.0 + u_time) + sin(uv.y * 8.0 + u_time * 0.7);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float h = height(uv);
    vec3 col = vec3(0.3, 0.5, 0.8) + 0.1 * vec3(h);
    gl_FragColor = vec4(col, 1.0);
}',
 'float height(vec2 uv) {
    return sin(uv.x * 8.0 + u_time) + sin(uv.y * 8.0 + u_time * 0.7);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float e = 0.005;
    float gx = height(uv + vec2(e, 0.0)) - height(uv - vec2(e, 0.0));
    float gy = height(uv + vec2(0.0, e)) - height(uv - vec2(0.0, e));
    vec3 col = 0.5 + 0.5 * vec3(gx, gy, 1.0);
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'proc-water-waves'), 'cQWZvs7h2X4', 3,
 'Specular highlight',
 '<p>With a normal you can light the water. Dot the normal with a light direction. Raise the result to a high power like 32. That gives a tight shiny spot.</p><p>Add the spot to the blue water color. The water now looks wet.</p><p>Reference: <a href="https://iquilezles.org/articles/simplewater/" target="_blank" rel="noreferrer">IQ — Simple water</a>.</p>',
 'float height(vec2 uv) {
    return sin(uv.x * 8.0 + u_time) + sin(uv.y * 8.0 + u_time * 0.7);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float e = 0.005;
    float gx = height(uv + vec2(e, 0.0)) - height(uv - vec2(e, 0.0));
    float gy = height(uv + vec2(0.0, e)) - height(uv - vec2(0.0, e));
    vec3 col = 0.5 + 0.5 * vec3(gx, gy, 1.0);
    gl_FragColor = vec4(col, 1.0);
}',
 'float height(vec2 uv) {
    return sin(uv.x * 8.0 + u_time) + sin(uv.y * 8.0 + u_time * 0.7);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float e = 0.005;
    float gx = height(uv + vec2(e, 0.0)) - height(uv - vec2(e, 0.0));
    float gy = height(uv + vec2(0.0, e)) - height(uv - vec2(0.0, e));
    vec3 n = normalize(vec3(-gx, -gy, 1.0));
    vec3 L = normalize(vec3(0.5, 0.6, 0.8));
    float s = pow(max(dot(n, L), 0.0), 32.0);
    vec3 col = vec3(0.3, 0.5, 0.8) + s;
    gl_FragColor = vec4(col, 1.0);
}'),

-- ===== Course: proc-starfield =====
((SELECT id FROM course WHERE slug = 'proc-starfield'), 'ZhLXXK82T2U', 0,
 'Hash stars',
 '<p>Split the canvas into a 30 by 30 grid. Hash means turn each cell index into a fake random number.</p><p>Use <code>step(0.95, hash(cell))</code> to pick about 5 percent of cells. Those cells light up as stars.</p><p>Reference: <a href="https://iquilezles.org/articles/sfrand/" target="_blank" rel="noreferrer">IQ — sfrand</a>.</p>',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
void main() {
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 g = uv * 30.0;
    vec2 cell = floor(g);
    float star = step(0.95, hash(cell));
    gl_FragColor = vec4(vec3(star), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'proc-starfield'), 'Mci4YXsebxQ', 1,
 'Twinkle from phase hash',
 '<p>Change each star''s brightness with <code>sin(u_time + h * 6.28)</code>. The <code>6.28</code> is one full wave cycle.</p><p>Each cell gets its own hash. So each star starts the wave at a different time. The stars twinkle on their own.</p><p>Reference: <a href="https://iquilezles.org/articles/sfrand/" target="_blank" rel="noreferrer">IQ — sfrand</a>.</p>',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 g = uv * 30.0;
    vec2 cell = floor(g);
    float star = step(0.95, hash(cell));
    gl_FragColor = vec4(vec3(star), 1.0);
}',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 g = uv * 30.0;
    vec2 cell = floor(g);
    float h = hash(cell);
    float star = step(0.95, h);
    float tw = 0.5 + 0.5 * sin(u_time + h * 6.28);
    star *= tw;
    gl_FragColor = vec4(vec3(star), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'proc-starfield'), 'gTppyjFB1l4', 2,
 'Soft bloom',
 '<p>Hard pixels look digital. Place each star at a random spot inside its cell. Get the distance from the pixel to that spot.</p><p>Use <code>exp(-d * 40.0)</code> as the brightness. Close pixels glow bright. Far pixels fade out. You get a soft halo per star.</p><p>Reference: <a href="https://iquilezles.org/articles/sfrand/" target="_blank" rel="noreferrer">IQ — sfrand</a>.</p>',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 g = uv * 30.0;
    vec2 cell = floor(g);
    float h = hash(cell);
    float star = step(0.95, h);
    float tw = 0.5 + 0.5 * sin(u_time + h * 6.28);
    star *= tw;
    gl_FragColor = vec4(vec3(star), 1.0);
}',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 g = uv * 30.0;
    vec2 cell = floor(g);
    vec2 frac = fract(g);
    float h = hash(cell);
    vec2 pos = vec2(hash(cell + 1.0), hash(cell + 2.0));
    float d = length(frac - pos);
    float bright = step(0.95, h) * exp(-d * 40.0) * (0.5 + 0.5 * sin(u_time + h * 6.28));
    gl_FragColor = vec4(vec3(bright), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'proc-starfield'), 'r1LJnDNjDL4', 3,
 'Nebula',
 '<p>Add a colored fbm field behind the stars. Use <code>0.3 * palette(fbm(uv * 3.0), ...)</code>. Stack noise plus a cosine palette gives a slow, colored cloud.</p><p>Then add the stars on top. You get bright stars on a soft nebula.</p><p>Reference: <a href="https://iquilezles.org/articles/sfrand/" target="_blank" rel="noreferrer">IQ — sfrand</a>.</p>',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
float vnoise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    vec2 u = f*f*(3.0-2.0*f);
    return mix(mix(hash(i),         hash(i+vec2(1,0)), u.x),
               mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)), u.x), u.y);
}
float fbm(vec2 p) {
    float v=0.0, a=0.5;
    for (int i=0; i<5; i++) { v += a*vnoise(p); p *= 2.0; a *= 0.5; }
    return v;
}
vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) { return a+b*cos(6.28318*(c*t+d)); }
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 g = uv * 30.0;
    vec2 cell = floor(g);
    vec2 frac = fract(g);
    float h = hash(cell);
    vec2 pos = vec2(hash(cell + 1.0), hash(cell + 2.0));
    float d = length(frac - pos);
    float bright = step(0.95, h) * exp(-d * 40.0) * (0.5 + 0.5 * sin(u_time + h * 6.28));
    gl_FragColor = vec4(vec3(bright), 1.0);
}',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
float vnoise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    vec2 u = f*f*(3.0-2.0*f);
    return mix(mix(hash(i),         hash(i+vec2(1,0)), u.x),
               mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)), u.x), u.y);
}
float fbm(vec2 p) {
    float v=0.0, a=0.5;
    for (int i=0; i<5; i++) { v += a*vnoise(p); p *= 2.0; a *= 0.5; }
    return v;
}
vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) { return a+b*cos(6.28318*(c*t+d)); }
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 g = uv * 30.0;
    vec2 cell = floor(g);
    vec2 frac = fract(g);
    float h = hash(cell);
    vec2 pos = vec2(hash(cell + 1.0), hash(cell + 2.0));
    float d = length(frac - pos);
    float bright = step(0.95, h) * exp(-d * 40.0) * (0.5 + 0.5 * sin(u_time + h * 6.28));
    vec3 neb = 0.3 * palette(fbm(uv * 3.0), vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.0, 0.33, 0.67));
    vec3 col = neb + vec3(bright);
    gl_FragColor = vec4(col, 1.0);
}'),

-- ===== Course: proc-wood-marble =====
((SELECT id FROM course WHERE slug = 'proc-wood-marble'), 'W46Gve0Bb5o', 0,
 'Marble via sin+turb',
 '<p>Marble is a sine wave bent by noise. Build <code>turb</code>, the absolute-value version of fbm. It makes sharp ridges.</p><p>Compute <code>sin(uv.x * 8.0 + 6.0 * turb(uv * 2.0))</code>. Use it to mix bright and dark marble. You get smooth stone veins.</p><p>Reference: <a href="https://iquilezles.org/articles/voronoise/" target="_blank" rel="noreferrer">IQ — Voronoise</a>.</p>',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
float vnoise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    vec2 u = f*f*(3.0-2.0*f);
    return mix(mix(hash(i),         hash(i+vec2(1,0)), u.x),
               mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)), u.x), u.y);
}
float turb(vec2 p) {
    float v=0.0, a=0.5;
    for (int i=0; i<5; i++) { v += a*abs(2.0*vnoise(p)-1.0); p *= 2.0; a *= 0.5; }
    return v;
}
void main() {
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
float vnoise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    vec2 u = f*f*(3.0-2.0*f);
    return mix(mix(hash(i),         hash(i+vec2(1,0)), u.x),
               mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)), u.x), u.y);
}
float turb(vec2 p) {
    float v=0.0, a=0.5;
    for (int i=0; i<5; i++) { v += a*abs(2.0*vnoise(p)-1.0); p *= 2.0; a *= 0.5; }
    return v;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float m = sin(uv.x * 8.0 + 6.0 * turb(uv * 2.0));
    vec3 col = mix(vec3(0.95, 0.92, 0.85), vec3(0.4, 0.35, 0.3), 0.5 + 0.5 * m);
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'proc-wood-marble'), 'kWEWtHjxMS8', 1,
 'Wood grain',
 '<p>Wood has rings around a center. Take <code>r = length(uv - 0.5)</code>. That is the distance from the middle.</p><p>Use <code>fract(r * 8.0 + 2.0 * turb(uv * 3.0))</code> as the ring value. Mix two wood tones by it. You get bent rings of wood.</p><p>Reference: <a href="https://iquilezles.org/articles/voronoise/" target="_blank" rel="noreferrer">IQ — Voronoise</a>.</p>',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
float vnoise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    vec2 u = f*f*(3.0-2.0*f);
    return mix(mix(hash(i),         hash(i+vec2(1,0)), u.x),
               mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)), u.x), u.y);
}
float turb(vec2 p) {
    float v=0.0, a=0.5;
    for (int i=0; i<5; i++) { v += a*abs(2.0*vnoise(p)-1.0); p *= 2.0; a *= 0.5; }
    return v;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float m = sin(uv.x * 8.0 + 6.0 * turb(uv * 2.0));
    vec3 col = mix(vec3(0.95, 0.92, 0.85), vec3(0.4, 0.35, 0.3), 0.5 + 0.5 * m);
    gl_FragColor = vec4(col, 1.0);
}',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
float vnoise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    vec2 u = f*f*(3.0-2.0*f);
    return mix(mix(hash(i),         hash(i+vec2(1,0)), u.x),
               mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)), u.x), u.y);
}
float turb(vec2 p) {
    float v=0.0, a=0.5;
    for (int i=0; i<5; i++) { v += a*abs(2.0*vnoise(p)-1.0); p *= 2.0; a *= 0.5; }
    return v;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float r = length(uv - 0.5);
    float rings = fract(r * 8.0 + 2.0 * turb(uv * 3.0));
    vec3 col = mix(vec3(0.55, 0.35, 0.2), vec3(0.85, 0.65, 0.4), rings);
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'proc-wood-marble'), 'O9-IBUzSwX4', 2,
 'Wood knot',
 '<p>Real wood is rarely a perfect set of concentric rings. A knot is a spot where a branch once grew out — the rings bulge around it like ripples around a dropped stone.</p><p>Pick a knot center like <code>vec2(0.55, 0.5)</code> and measure the distance <code>kd</code> from the pixel to it. Add a localized bulge <code>0.6 * exp(-kd * 8.0)</code> to the ring distance. The <code>exp</code> falloff is huge near the knot and dies off fast, so the warp is sharp and tight. The rings now wrap around the knot instead of running through it.</p><p>Reference: <a href="https://iquilezles.org/articles/voronoise/" target="_blank" rel="noreferrer">IQ — Voronoise</a>.</p>',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
float vnoise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    vec2 u = f*f*(3.0-2.0*f);
    return mix(mix(hash(i),         hash(i+vec2(1,0)), u.x),
               mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)), u.x), u.y);
}
float turb(vec2 p) {
    float v=0.0, a=0.5;
    for (int i=0; i<5; i++) { v += a*abs(2.0*vnoise(p)-1.0); p *= 2.0; a *= 0.5; }
    return v;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float r = length(uv - 0.5);
    float rings = fract(r * 8.0 + 2.0 * turb(uv * 3.0));
    vec3 col = mix(vec3(0.55, 0.35, 0.2), vec3(0.85, 0.65, 0.4), rings);
    gl_FragColor = vec4(col, 1.0);
}',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
float vnoise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    vec2 u = f*f*(3.0-2.0*f);
    return mix(mix(hash(i),         hash(i+vec2(1,0)), u.x),
               mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)), u.x), u.y);
}
float turb(vec2 p) {
    float v=0.0, a=0.5;
    for (int i=0; i<5; i++) { v += a*abs(2.0*vnoise(p)-1.0); p *= 2.0; a *= 0.5; }
    return v;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 knot = vec2(0.55, 0.5);
    float kd = length(uv - knot);
    float bulge = 0.6 * exp(-kd * 8.0);
    float r = length(uv - 0.5) + bulge;
    float rings = fract(r * 8.0 + 2.0 * turb(uv * 3.0));
    vec3 col = mix(vec3(0.30, 0.18, 0.08), vec3(0.70, 0.45, 0.22), rings);
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'proc-wood-marble'), '9AAgLvvyIkM', 3,
 'Marble veining',
 '<p>Marble is the other classic procedural material. The recipe is almost as small as wood: take a smooth sine line, then displace its argument with turbulence so the line wobbles into dark veins running across a pale stone.</p><p>Compute <code>veins = sin(uv.x * 12.0 + 6.0 * t)</code> where <code>t = turb(uv * 2.5)</code>, then remap to 0..1 and mix a creamy base with a dark vein color. The straight sine bands get pulled into curves by the noise, exactly like the mineral seams in real marble.</p><p>Reference: <a href="https://iquilezles.org/articles/voronoise/" target="_blank" rel="noreferrer">IQ — Voronoise</a>.</p>',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
float vnoise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    vec2 u = f*f*(3.0-2.0*f);
    return mix(mix(hash(i),         hash(i+vec2(1,0)), u.x),
               mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)), u.x), u.y);
}
float turb(vec2 p) {
    float v=0.0, a=0.5;
    for (int i=0; i<5; i++) { v += a*abs(2.0*vnoise(p)-1.0); p *= 2.0; a *= 0.5; }
    return v;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 knot = vec2(0.55, 0.5);
    float kd = length(uv - knot);
    float bulge = 0.6 * exp(-kd * 8.0);
    float r = length(uv - 0.5) + bulge;
    float rings = fract(r * 8.0 + 2.0 * turb(uv * 3.0));
    vec3 col = mix(vec3(0.30, 0.18, 0.08), vec3(0.70, 0.45, 0.22), rings);
    gl_FragColor = vec4(col, 1.0);
}',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
float vnoise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    vec2 u = f*f*(3.0-2.0*f);
    return mix(mix(hash(i),         hash(i+vec2(1,0)), u.x),
               mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)), u.x), u.y);
}
float turb(vec2 p) {
    float v=0.0, a=0.5;
    for (int i=0; i<5; i++) { v += a*abs(2.0*vnoise(p)-1.0); p *= 2.0; a *= 0.5; }
    return v;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float t = turb(uv * 2.5);
    float veins = sin(uv.x * 12.0 + 6.0 * t);
    veins = 0.5 + 0.5 * veins;
    vec3 col = mix(vec3(0.95, 0.92, 0.85), vec3(0.20, 0.18, 0.16), veins);
    gl_FragColor = vec4(col, 1.0);
}'),

-- ===== Course: proc-fire-smoke =====
((SELECT id FROM course WHERE slug = 'proc-fire-smoke'), '5tZvwJgM6Ak', 0,
 'Vertical warped fbm',
 '<p>Fire is fbm pushed upward over time. Sample <code>fbm(uv * 3.0 + vec2(0.0, u_time * 2.0))</code>. Stack noise plus a y shift makes it rise.</p><p>Output it in gray. The noise field rolls up the screen like hot air.</p><p>Reference: <a href="https://iquilezles.org/articles/warp/" target="_blank" rel="noreferrer">IQ — Domain warping</a>.</p>',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
float vnoise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    vec2 u = f*f*(3.0-2.0*f);
    return mix(mix(hash(i),         hash(i+vec2(1,0)), u.x),
               mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)), u.x), u.y);
}
float fbm(vec2 p) {
    float v=0.0, a=0.5;
    for (int i=0; i<5; i++) { v += a*vnoise(p); p *= 2.0; a *= 0.5; }
    return v;
}
void main() {
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
float vnoise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    vec2 u = f*f*(3.0-2.0*f);
    return mix(mix(hash(i),         hash(i+vec2(1,0)), u.x),
               mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)), u.x), u.y);
}
float fbm(vec2 p) {
    float v=0.0, a=0.5;
    for (int i=0; i<5; i++) { v += a*vnoise(p); p *= 2.0; a *= 0.5; }
    return v;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float q = fbm(uv * 3.0 + vec2(0.0, u_time * 2.0));
    vec3 col = vec3(q);
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'proc-fire-smoke'), 'aO4GX266tGw', 1,
 'Heat palette',
 '<p>Feed the warped fbm into a cosine palette set to heat colors. Low values map to black. Higher values map to red, orange, then yellow.</p><p>The flame shape stays the same. Only the colors change. Now it looks like real fire.</p><p>Reference: <a href="https://iquilezles.org/articles/palettes/" target="_blank" rel="noreferrer">IQ — Palettes</a>.</p>',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
float vnoise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    vec2 u = f*f*(3.0-2.0*f);
    return mix(mix(hash(i),         hash(i+vec2(1,0)), u.x),
               mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)), u.x), u.y);
}
float fbm(vec2 p) {
    float v=0.0, a=0.5;
    for (int i=0; i<5; i++) { v += a*vnoise(p); p *= 2.0; a *= 0.5; }
    return v;
}
vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) { return a+b*cos(6.28318*(c*t+d)); }
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float q = fbm(uv * 3.0 + vec2(0.0, u_time * 2.0));
    vec3 col = vec3(q);
    gl_FragColor = vec4(col, 1.0);
}',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
float vnoise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    vec2 u = f*f*(3.0-2.0*f);
    return mix(mix(hash(i),         hash(i+vec2(1,0)), u.x),
               mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)), u.x), u.y);
}
float fbm(vec2 p) {
    float v=0.0, a=0.5;
    for (int i=0; i<5; i++) { v += a*vnoise(p); p *= 2.0; a *= 0.5; }
    return v;
}
vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) { return a+b*cos(6.28318*(c*t+d)); }
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float q = fbm(uv * 3.0 + vec2(0.0, u_time * 2.0));
    vec3 col = palette(q, vec3(0.5, 0.0, 0.0), vec3(0.5, 0.4, 0.0), vec3(1.0), vec3(0.0, 0.1, 0.2));
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'proc-fire-smoke'), 'ipEhJ101BoQ', 2,
 'Flame with smoke',
 '<p>Finish the fire by adding the two missing pieces at once: flames that thin out at the top, and a band of smoke drifting above them.</p><p>Fade the flame with <code>smoothstep(1.0, 0.3, uv.y)</code> — value 1 at the bottom, 0 at the top — so the tongues taper into nothing. Build a separate gray smoke layer from a second fbm sampled at a different scale and speed. Then <code>mix(fire, smoke, smoothstep(0.4, 0.8, uv.y))</code>: the bottom of the canvas is pure flame, the top is pure smoke, and the transition happens where real fire transitions too.</p><p>Reference: <a href="https://iquilezles.org/articles/warp/" target="_blank" rel="noreferrer">IQ — Domain warping</a>.</p>',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
float vnoise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    vec2 u = f*f*(3.0-2.0*f);
    return mix(mix(hash(i),         hash(i+vec2(1,0)), u.x),
               mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)), u.x), u.y);
}
float fbm(vec2 p) {
    float v=0.0, a=0.5;
    for (int i=0; i<5; i++) { v += a*vnoise(p); p *= 2.0; a *= 0.5; }
    return v;
}
vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) { return a+b*cos(6.28318*(c*t+d)); }
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float q = fbm(uv * 3.0 + vec2(0.0, u_time * 2.0));
    vec3 col = palette(q, vec3(0.5, 0.0, 0.0), vec3(0.5, 0.4, 0.0), vec3(1.0), vec3(0.0, 0.1, 0.2));
    gl_FragColor = vec4(col, 1.0);
}',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
float vnoise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    vec2 u = f*f*(3.0-2.0*f);
    return mix(mix(hash(i),         hash(i+vec2(1,0)), u.x),
               mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)), u.x), u.y);
}
float fbm(vec2 p) {
    float v=0.0, a=0.5;
    for (int i=0; i<5; i++) { v += a*vnoise(p); p *= 2.0; a *= 0.5; }
    return v;
}
vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) { return a+b*cos(6.28318*(c*t+d)); }
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float q = fbm(uv * 3.0 + vec2(0.0, u_time * 2.0));
    vec3 fire = palette(q, vec3(0.5, 0.0, 0.0), vec3(0.5, 0.4, 0.0), vec3(1.0), vec3(0.0, 0.1, 0.2));
    float smokeMask = fbm(uv * 5.0 + vec2(0.0, u_time * 1.5));
    vec3 smoke = vec3(0.20, 0.20, 0.22) * smokeMask;
    vec3 col = mix(fire, smoke, smoothstep(0.4, 0.8, uv.y));
    col *= smoothstep(1.0, 0.3, uv.y);
    gl_FragColor = vec4(col, 1.0);
}');
