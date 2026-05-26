\c shader_dojo;

-- Family H — Procedural generation (6 courses, 24 lessons)

INSERT INTO lesson (course_id, slug, display_order, title, description, starter_fragment_shader, canonical_fragment_shader) VALUES

-- ===== Course: proc-terrain =====
((SELECT id FROM course WHERE slug = 'proc-terrain'), 'Bvw0ZYStciI', 0,
 'Heightmap from fbm',
 '<p>Procedural terrain starts with a scalar heightfield. Sample <code>fbm(uv * 3.0)</code> across the canvas and output the height as grayscale — peaks are white, valleys are black.</p><p>This top-down view is the foundation of every later terrain trick: contours, color, weather.</p><p>Reference: <a href="https://iquilezles.org/articles/terrainmarching/" target="_blank" rel="noreferrer">IQ — Terrain raymarching</a>.</p>',
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
    // TODO: h = fbm(uv * 3.0); output vec3(h) as grayscale.
    float h = 0.0;
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
    float h = fbm(uv * 3.0);
    gl_FragColor = vec4(vec3(h), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'proc-terrain'), 'VDrjzjVZ7Fk', 1,
 'Banded contours',
 '<p>Quantize the height with <code>floor(h * N) / N</code> to draw topographic bands. Each band represents a fixed elevation slice, just like a contour map.</p><p>Reference: <a href="https://iquilezles.org/articles/terrainmarching/" target="_blank" rel="noreferrer">IQ — Terrain raymarching</a>.</p>',
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
    // TODO: b = floor(fbm(uv * 3.0) * 10.0) / 10.0;
    float b = fbm(uv * 3.0);
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
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float b = floor(fbm(uv * 3.0) * 10.0) / 10.0;
    gl_FragColor = vec4(vec3(b), 1.0);
}'),

((SELECT id FROM course WHERE slug = 'proc-terrain'), 'tgCjv17iPSw', 2,
 'Colorize by height',
 '<p>Run the height through a cosine palette to map elevation to a colored terrain — blue valleys, green slopes, warm peaks. The same palette recipe from Family B applies here.</p><p>Reference: <a href="https://iquilezles.org/articles/terrainmarching/" target="_blank" rel="noreferrer">IQ — Terrain raymarching</a>.</p>',
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
    // TODO: col = palette(h, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.00, 0.33, 0.67));
    vec3 col = vec3(h);
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
    vec3 col = palette(h, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.00, 0.33, 0.67));
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'proc-terrain'), 'Q3u_mBuhJs0', 3,
 'Animated wind',
 '<p>Translate the sample point through time on the x axis. The terrain pattern scrolls horizontally as if blown by wind — a free animation from a static heightfield.</p><p>Reference: <a href="https://iquilezles.org/articles/terrainmarching/" target="_blank" rel="noreferrer">IQ — Terrain raymarching</a>.</p>',
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
    // TODO: h = fbm(uv * 3.0 + vec2(u_time * 0.1, 0.0)); colorize with palette.
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
    float h = fbm(uv * 3.0 + vec2(u_time * 0.1, 0.0));
    vec3 col = palette(h, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.00, 0.33, 0.67));
    gl_FragColor = vec4(col, 1.0);
}'),

-- ===== Course: proc-clouds =====
((SELECT id FROM course WHERE slug = 'proc-clouds'), '2JiygQDRMEg', 0,
 'fbm cloud field',
 '<p>The simplest sky shader: mix a blue sky with white using <code>fbm</code> as the blend factor. Soft, foggy clouds appear immediately.</p><p>Reference: <a href="https://iquilezles.org/articles/dynclouds/" target="_blank" rel="noreferrer">IQ — 2D dynamic clouds</a>.</p>',
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
    // TODO: col = mix(vec3(0.4, 0.6, 0.9), vec3(1.0), fbm(uv * 4.0));
    vec3 col = vec3(0.4, 0.6, 0.9);
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
    vec3 col = mix(vec3(0.4, 0.6, 0.9), vec3(1.0), fbm(uv * 4.0));
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'proc-clouds'), 'Nhf-YKEnUsc', 1,
 'Thresholded clouds',
 '<p>Smoothstep the noise to cut sharp-edged cumulus clouds out of the sky. Values below the lower edge are pure sky, above the upper edge are pure white.</p><p>Reference: <a href="https://iquilezles.org/articles/dynclouds/" target="_blank" rel="noreferrer">IQ — 2D dynamic clouds</a>.</p>',
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
    // TODO: cloud = smoothstep(0.5, 0.7, fbm(uv * 4.0)); col = mix(sky, white, cloud);
    vec3 col = vec3(0.4, 0.6, 0.9);
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
 '<p>Offset the noise sample by <code>vec2(u_time * 0.05, 0.0)</code> to scroll the cloud cover horizontally. The wind direction is whichever component of the offset you animate.</p><p>Reference: <a href="https://iquilezles.org/articles/dynclouds/" target="_blank" rel="noreferrer">IQ — 2D dynamic clouds</a>.</p>',
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
    // TODO: cloud = smoothstep(0.5, 0.7, fbm(uv * 4.0 + vec2(u_time * 0.05, 0.0)));
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
 '<p>Add a warm sun: a radial falloff around a point near the horizon, blended into the sky underneath the clouds. The clouds catch the sun''s tint where the glow is brightest.</p><p>Reference: <a href="https://iquilezles.org/articles/dynclouds/" target="_blank" rel="noreferrer">IQ — 2D dynamic clouds</a>.</p>',
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
    // TODO: add warm sun glow at (0.7, 0.3), then overlay cloud = smoothstep(0.5, 0.7, fbm(uv*4.0 + vec2(u_time*0.05,0.0))).
    vec3 col = sky;
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
 '<p>Water surfaces are often the sum of a few sine waves at different frequencies and phases. Stack two sines along x, modulate a blue base color by the height, and you get a believable rolling sea.</p><p>Reference: <a href="https://iquilezles.org/articles/simplewater/" target="_blank" rel="noreferrer">IQ — Simple water</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: h = sin(uv.x * 8.0 + u_time) + 0.5 * sin(uv.x * 16.0 + u_time * 1.7);
    // TODO: col = vec3(0.3, 0.5, 0.8) + 0.1 * vec3(h);
    vec3 col = vec3(0.3, 0.5, 0.8);
    gl_FragColor = vec4(col, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float h = sin(uv.x * 8.0 + u_time) + 0.5 * sin(uv.x * 16.0 + u_time * 1.7);
    vec3 col = vec3(0.3, 0.5, 0.8) + 0.1 * vec3(h);
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'proc-water-waves'), '5_iUO0-dA58', 1,
 'Two-axis interference',
 '<p>Add a sine in y as well. Now waves cross at right angles and produce diamond-shaped interference patterns — closer to a top-down view of choppy water.</p><p>Reference: <a href="https://iquilezles.org/articles/simplewater/" target="_blank" rel="noreferrer">IQ — Simple water</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: h = sin(uv.x * 8.0 + u_time) + sin(uv.y * 8.0 + u_time * 0.7);
    float h = sin(uv.x * 8.0 + u_time);
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
 '<p>Use central-difference finite differences to take the gradient of the height. The two partials become the x and y of a surface normal; pack them as <code>0.5 + 0.5 * vec3(gx, gy, 1.0)</code> to visualize the normal map.</p><p>Reference: <a href="https://iquilezles.org/articles/simplewater/" target="_blank" rel="noreferrer">IQ — Simple water</a>.</p>',
 'float height(vec2 uv) {
    return sin(uv.x * 8.0 + u_time) + sin(uv.y * 8.0 + u_time * 0.7);
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float e = 0.005;
    // TODO: gx = height(uv + vec2(e,0)) - height(uv - vec2(e,0));
    // TODO: gy = height(uv + vec2(0,e)) - height(uv - vec2(0,e));
    // TODO: col = 0.5 + 0.5 * vec3(gx, gy, 1.0);
    vec3 col = vec3(0.5);
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
 '<p>With a normal, you can do lighting. Dot the unit normal with a light direction, raise to a high power for a tight specular lobe, and add it to the blue water color. Suddenly the surface looks wet.</p><p>Reference: <a href="https://iquilezles.org/articles/simplewater/" target="_blank" rel="noreferrer">IQ — Simple water</a>.</p>',
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
    // TODO: s = pow(max(dot(n, L), 0.0), 32.0); col = vec3(0.3, 0.5, 0.8) + s;
    vec3 col = vec3(0.3, 0.5, 0.8);
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
 '<p>Tile the canvas into a 30×30 grid. In each cell, hash the integer cell index to a random number; if it crosses a threshold, draw a star. <code>step(0.95, hash(cell))</code> lights up about 5% of cells.</p><p>Reference: <a href="https://iquilezles.org/articles/sfrand/" target="_blank" rel="noreferrer">IQ — sfrand</a>.</p>',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 g = uv * 30.0;
    vec2 cell = floor(g);
    // TODO: star = step(0.95, hash(cell)); output vec3(star).
    float star = 0.0;
    gl_FragColor = vec4(vec3(star), 1.0);
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
 '<p>Modulate each star''s brightness with <code>sin(u_time + hash * 6.28)</code>. Each cell gets a unique random phase from the hash, so stars twinkle independently.</p><p>Reference: <a href="https://iquilezles.org/articles/sfrand/" target="_blank" rel="noreferrer">IQ — sfrand</a>.</p>',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 g = uv * 30.0;
    vec2 cell = floor(g);
    float h = hash(cell);
    float star = step(0.95, h);
    // TODO: tw = 0.5 + 0.5 * sin(u_time + h * 6.28); star *= tw;
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
 '<p>Hard pixels feel digital. Place each star at a random sub-cell point, then compute distance from the current pixel to that point and use <code>exp(-d * 40.0)</code> as a halo. The result is a soft glow per star.</p><p>Reference: <a href="https://iquilezles.org/articles/sfrand/" target="_blank" rel="noreferrer">IQ — sfrand</a>.</p>',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 g = uv * 30.0;
    vec2 cell = floor(g);
    vec2 frac = fract(g);
    float h = hash(cell);
    vec2 pos = vec2(hash(cell + 1.0), hash(cell + 2.0));
    float d = length(frac - pos);
    // TODO: bright = step(0.95, h) * exp(-d * 40.0) * (0.5 + 0.5 * sin(u_time + h * 6.28));
    float bright = 0.0;
    gl_FragColor = vec4(vec3(bright), 1.0);
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
 '<p>Add a colored low-frequency fbm field behind the stars: <code>0.3 * palette(fbm(uv * 3.0), ...)</code>. The starfield sits on top of a soft nebula.</p><p>Reference: <a href="https://iquilezles.org/articles/sfrand/" target="_blank" rel="noreferrer">IQ — sfrand</a>.</p>',
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
    // TODO: neb = 0.3 * palette(fbm(uv * 3.0), vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.0, 0.33, 0.67));
    // TODO: col = neb + vec3(bright);
    vec3 col = vec3(bright);
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
 '<p>Marble is a sine wave through a perturbation field. Build <code>turb</code> (the absolute-value variant of fbm), then evaluate <code>sin(uv.x * 8.0 + 6.0 * turb(uv * 2.0))</code> and use it to blend between bright and dark marble.</p><p>Reference: <a href="https://iquilezles.org/articles/voronoise/" target="_blank" rel="noreferrer">IQ — Voronoise</a>.</p>',
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
    // TODO: m = sin(uv.x * 8.0 + 6.0 * turb(uv * 2.0));
    // TODO: col = mix(vec3(0.95, 0.92, 0.85), vec3(0.4, 0.35, 0.3), 0.5 + 0.5 * m);
    vec3 col = vec3(0.95, 0.92, 0.85);
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
    float m = sin(uv.x * 8.0 + 6.0 * turb(uv * 2.0));
    vec3 col = mix(vec3(0.95, 0.92, 0.85), vec3(0.4, 0.35, 0.3), 0.5 + 0.5 * m);
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'proc-wood-marble'), 'kWEWtHjxMS8', 1,
 'Wood grain',
 '<p>Wood is rings around a center. Take <code>r = length(uv - 0.5)</code>, then use <code>fract(r * 8.0 + 2.0 * turb(uv * 3.0))</code> as the ring coordinate. Mix two wood tones by the rings.</p><p>Reference: <a href="https://iquilezles.org/articles/voronoise/" target="_blank" rel="noreferrer">IQ — Voronoise</a>.</p>',
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
    // TODO: rings = fract(r * 8.0 + 2.0 * turb(uv * 3.0));
    // TODO: col = mix(vec3(0.55, 0.35, 0.2), vec3(0.85, 0.65, 0.4), rings);
    vec3 col = vec3(0.7, 0.5, 0.3);
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
 'Tunable ring spacing',
 '<p>Crank the ring-frequency knob from 8 to 16 to draw a denser wood. The same recipe, the same turbulence; one number changes the species.</p><p>Reference: <a href="https://iquilezles.org/articles/voronoise/" target="_blank" rel="noreferrer">IQ — Voronoise</a>.</p>',
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
    // TODO: rings = fract(r * 16.0 + 2.0 * turb(uv * 3.0));
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
    float r = length(uv - 0.5);
    float rings = fract(r * 16.0 + 2.0 * turb(uv * 3.0));
    vec3 col = mix(vec3(0.55, 0.35, 0.2), vec3(0.85, 0.65, 0.4), rings);
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'proc-wood-marble'), '9AAgLvvyIkM', 3,
 'Two-tone via palette',
 '<p>Drop the linear mix for a cosine palette. Now the rings cycle through a curve of colors instead of two endpoints, giving richer banding on an exotic veneer.</p><p>Reference: <a href="https://iquilezles.org/articles/palettes/" target="_blank" rel="noreferrer">IQ — Palettes</a>.</p>',
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
vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) { return a+b*cos(6.28318*(c*t+d)); }
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float r = length(uv - 0.5);
    float rings = fract(r * 16.0 + 2.0 * turb(uv * 3.0));
    // TODO: col = palette(rings, vec3(0.5, 0.35, 0.25), vec3(0.4, 0.3, 0.2), vec3(1.0), vec3(0.0, 0.15, 0.3));
    vec3 col = vec3(rings);
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
vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) { return a+b*cos(6.28318*(c*t+d)); }
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float r = length(uv - 0.5);
    float rings = fract(r * 16.0 + 2.0 * turb(uv * 3.0));
    vec3 col = palette(rings, vec3(0.5, 0.35, 0.25), vec3(0.4, 0.3, 0.2), vec3(1.0), vec3(0.0, 0.15, 0.3));
    gl_FragColor = vec4(col, 1.0);
}'),

-- ===== Course: proc-fire-smoke =====
((SELECT id FROM course WHERE slug = 'proc-fire-smoke'), '5tZvwJgM6Ak', 0,
 'Vertical warped fbm',
 '<p>Fire is fbm with a strong vertical drift. Sample <code>fbm(uv * 3.0 + vec2(0.0, u_time * 2.0))</code> and output it grayscale — the flame field rolls upward like rising heat.</p><p>Reference: <a href="https://iquilezles.org/articles/warp/" target="_blank" rel="noreferrer">IQ — Domain warping</a>.</p>',
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
    // TODO: q = fbm(uv * 3.0 + vec2(0.0, u_time * 2.0)); col = vec3(q);
    vec3 col = vec3(0.0);
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
    float q = fbm(uv * 3.0 + vec2(0.0, u_time * 2.0));
    vec3 col = vec3(q);
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'proc-fire-smoke'), 'aO4GX266tGw', 1,
 'Heat palette',
 '<p>Run the warped fbm through a cosine palette tuned for heat: black at the bottom, red, orange, yellow at the top. The shape of the flame field doesn''t change — only the colorization.</p><p>Reference: <a href="https://iquilezles.org/articles/palettes/" target="_blank" rel="noreferrer">IQ — Palettes</a>.</p>',
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
    // TODO: col = palette(q, vec3(0.5, 0.0, 0.0), vec3(0.5, 0.4, 0.0), vec3(1.0), vec3(0.0, 0.1, 0.2));
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
 'Alpha fade at top',
 '<p>Multiply the flame color by <code>smoothstep(1.0, 0.3, uv.y)</code>. The flame is full intensity at the bottom and fades to black near the top — like a real flame whose tongues thin out as they rise.</p><p>Reference: <a href="https://iquilezles.org/articles/warp/" target="_blank" rel="noreferrer">IQ — Domain warping</a>.</p>',
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
    // TODO: col *= smoothstep(1.0, 0.3, uv.y);
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
    col *= smoothstep(1.0, 0.3, uv.y);
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'proc-fire-smoke'), 'J2hJ3317iQE', 3,
 'Smoke layer',
 '<p>Above the flame, mix in a gray fbm smoke layer. Use <code>smoothstep(0.4, 0.7, uv.y)</code> as the blend factor so the bottom of the canvas is pure fire and the top fades into rising smoke.</p><p>Reference: <a href="https://iquilezles.org/articles/warp/" target="_blank" rel="noreferrer">IQ — Domain warping</a>.</p>',
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
    vec3 flame = palette(q, vec3(0.5, 0.0, 0.0), vec3(0.5, 0.4, 0.0), vec3(1.0), vec3(0.0, 0.1, 0.2));
    flame *= smoothstep(1.0, 0.3, uv.y);
    // TODO: smoke = vec3(0.3) * fbm(uv * 2.0 + vec2(0.0, u_time * 0.5));
    // TODO: col = mix(flame, smoke, smoothstep(0.4, 0.7, uv.y));
    vec3 col = flame;
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
    vec3 flame = palette(q, vec3(0.5, 0.0, 0.0), vec3(0.5, 0.4, 0.0), vec3(1.0), vec3(0.0, 0.1, 0.2));
    flame *= smoothstep(1.0, 0.3, uv.y);
    vec3 smoke = vec3(0.3) * fbm(uv * 2.0 + vec2(0.0, u_time * 0.5));
    vec3 col = mix(flame, smoke, smoothstep(0.4, 0.7, uv.y));
    gl_FragColor = vec4(col, 1.0);
}');
