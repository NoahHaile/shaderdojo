\c shader_dojo;

-- Family I, Stylization / post-process (4 courses, 16 lessons)

INSERT INTO lesson (course_id, slug, display_order, title, description, starter_fragment_shader, canonical_fragment_shader) VALUES

-- ===== Course: posterize-dither =====
((SELECT id FROM course WHERE slug = 'posterize-dither'), '0EbB9_v7jMg', 0,
 'N-step posterize',
 '<p>Posterize means you cut the number of color steps. Smooth colors become a few flat levels. You go from many shades to just a handful.</p><p>The math is simple. Multiply the color by <code>N</code>, use <code>floor</code>, then divide by <code>N</code>. Each channel lands on one of <code>N+1</code> evenly spaced bins.</p><p>Try this: read the picture and snap it to 5 levels. The smooth gradient breaks into chunky bands. Read more at <a href="https://lygia.xyz/" target="_blank" rel="noreferrer">Lygia shader library</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 col = texture2D(u_image, uv).rgb;
    gl_FragColor = vec4(col, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 col = texture2D(u_image, uv).rgb;
    col = floor(col * 5.0) / 5.0;
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'posterize-dither'), '2TyvndnucHg', 1,
 'Bayer 4×4 dither',
 '<p>Posterize alone is brutal. Every smooth gradient snaps to a few flat levels, and the seams between those levels show up as ugly visible bands across the image.</p><p>A Bayer matrix scatters small offsets across the pixels in a deterministic, repeating 4×4 pattern. Add the offset before <code>floor</code> and neighbouring pixels land on different sides of each step boundary. The eye blends them and the bands turn into a smooth transition, without using random noise, which would look like static.</p><p>This is the trick old printers, early game consoles, and monochrome screens used to fake more shades than the hardware actually had. The math <code>(2x + 3y) mod 16</code> builds the pattern, so 4 real levels read as 16. Read more at <a href="https://lygia.xyz/" target="_blank" rel="noreferrer">Lygia shader library</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 col = texture2D(u_image, uv).rgb;
    col = floor(col * 5.0) / 5.0;
    gl_FragColor = vec4(col, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 col = texture2D(u_image, uv).rgb;
    float bayer = mod(2.0 * float(int(mod(gl_FragCoord.x, 4.0))) + 3.0 * float(int(mod(gl_FragCoord.y, 4.0))), 16.0) / 16.0;
    col = floor(col * 4.0 + bayer) / 4.0;
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'posterize-dither'), 'wE2GWxd-i0Q', 2,
 'Noise dither via hash',
 '<p>Swap the Bayer pattern for random noise. A hash on <code>gl_FragCoord.xy</code> gives each pixel a random value in <code>[0, 1)</code>.</p><p>That random value scrambles the step lines. Bands turn into film grain. Read more at <a href="https://lygia.xyz/" target="_blank" rel="noreferrer">Lygia shader library</a>.</p>',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 col = texture2D(u_image, uv).rgb;
    float bayer = mod(2.0 * float(int(mod(gl_FragCoord.x, 4.0))) + 3.0 * float(int(mod(gl_FragCoord.y, 4.0))), 16.0) / 16.0;
    col = floor(col * 4.0 + bayer) / 4.0;
    gl_FragColor = vec4(col, 1.0);
}',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 col = floor(texture2D(u_image, uv).rgb * 4.0 + hash(gl_FragCoord.xy)) / 4.0;
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'posterize-dither'), '_sGhGoJFgVw', 3,
 'Posterized gradient with dither',
 '<p>Skip the picture. Feed a plain gradient <code>vec3(uv.x)</code> through the same steps. Add the Bayer threshold, then quantize to 5 levels.</p><p>The steps spread out into a clean dithered ramp. You get the classic NES-era sky. Read more at <a href="https://lygia.xyz/" target="_blank" rel="noreferrer">Lygia shader library</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 col = vec3(uv.x);
    gl_FragColor = vec4(col, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 col = vec3(uv.x);
    float bayer = mod(2.0 * float(int(mod(gl_FragCoord.x, 4.0))) + 3.0 * float(int(mod(gl_FragCoord.y, 4.0))), 16.0) / 16.0;
    col = floor(col * 5.0 + bayer) / 5.0;
    gl_FragColor = vec4(col, 1.0);
}'),

-- ===== Course: chromatic-aberration =====
((SELECT id FROM course WHERE slug = 'chromatic-aberration'), 'vXooNTx10K4', 0,
 'Linear R/G/B offset',
 '<p>Chromatic aberration fakes a cheap camera lens. The lens bends each color a bit differently, so the channels do not line up.</p><p>Sample each color at a slightly different spot. Red shifts right. Green stays at the center. Blue shifts left. Put them back together. Read more at <a href="https://lygia.xyz/" target="_blank" rel="noreferrer">Lygia shader library</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 col = texture2D(u_image, uv).rgb;
    gl_FragColor = vec4(col, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float r = texture2D(u_image, uv + vec2(0.01, 0.0)).r;
    float g = texture2D(u_image, uv).g;
    float b = texture2D(u_image, uv - vec2(0.01, 0.0)).b;
    gl_FragColor = vec4(r, g, b, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'chromatic-aberration'), '90qGhZ00KYU', 1,
 'Radial offset',
 '<p>On a real lens, the color fringe spreads out from the center. Build an offset that points outward with <code>(uv - 0.5) * k</code>.</p><p>Use that offset to push red and blue the opposite way along the line from the middle. Read more at <a href="https://lygia.xyz/" target="_blank" rel="noreferrer">Lygia shader library</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float r = texture2D(u_image, uv + vec2(0.01, 0.0)).r;
    float g = texture2D(u_image, uv).g;
    float b = texture2D(u_image, uv - vec2(0.01, 0.0)).b;
    gl_FragColor = vec4(r, g, b, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 off = (uv - 0.5) * 0.05;
    float r = texture2D(u_image, uv + off).r;
    float g = texture2D(u_image, uv).g;
    float b = texture2D(u_image, uv - off).b;
    gl_FragColor = vec4(r, g, b, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'chromatic-aberration'), 'a7669aBF03Q', 2,
 'Animated wobble',
 '<p>Make the offset strength change over time. Use a sine wave on <code>u_time</code>. The fringe will grow and shrink with each frame.</p><p>The fringe breathes in and out. You get a glitchy VHS look. Read more at <a href="https://lygia.xyz/" target="_blank" rel="noreferrer">Lygia shader library</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 off = (uv - 0.5) * 0.05;
    float r = texture2D(u_image, uv + off).r;
    float g = texture2D(u_image, uv).g;
    float b = texture2D(u_image, uv - off).b;
    gl_FragColor = vec4(r, g, b, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 off = (uv - 0.5) * 0.05 * (0.5 + 0.5 * sin(u_time));
    float r = texture2D(u_image, uv + off).r;
    float g = texture2D(u_image, uv).g;
    float b = texture2D(u_image, uv - off).b;
    gl_FragColor = vec4(r, g, b, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'chromatic-aberration'), 'xcxuDH0QQjk', 3,
 'Aberration + vignette',
 '<p>Stack two effects. Use the radial color split from before. Then add a vignette mask that darkens the corners.</p><p>The corners get the color fringe and a dim wash at the same time. Read more at <a href="https://lygia.xyz/" target="_blank" rel="noreferrer">Lygia shader library</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 off = (uv - 0.5) * 0.05;
    float r = texture2D(u_image, uv + off).r;
    float g = texture2D(u_image, uv).g;
    float b = texture2D(u_image, uv - off).b;
    vec3 col = vec3(r, g, b);
    gl_FragColor = vec4(col, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 off = (uv - 0.5) * 0.05;
    float r = texture2D(u_image, uv + off).r;
    float g = texture2D(u_image, uv).g;
    float b = texture2D(u_image, uv - off).b;
    vec3 col = vec3(r, g, b);
    float v = 1.0 - smoothstep(0.4, 0.8, length(uv - 0.5));
    col *= v;
    gl_FragColor = vec4(col, 1.0);
}'),

-- ===== Course: bloom-glow =====
((SELECT id FROM course WHERE slug = 'bloom-glow'), 'TnyYmcEDq2I', 0,
 'Halo around circle',
 '<p>Bloom means a soft halo around a bright shape. The cheapest way: use the distance to the shape and shrink it fast with <code>exp(-d * k)</code>.</p><p>The value is bright at the edge and fades fast as you move away. Tint it warm and you get a candle-flame halo. Read more at <a href="https://iquilezles.org/articles/gamma/" target="_blank" rel="noreferrer">IQ on gamma correct blurring</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d = length(p) - 0.2;
    vec3 col = vec3(0.0);
    gl_FragColor = vec4(col, 1.0);
}',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d = length(p) - 0.2;
    float halo = exp(-d * 8.0);
    vec3 col = vec3(halo) * vec3(1.0, 0.8, 0.4);
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'bloom-glow'), '0k8nwTMVJNI', 1,
 'Multiple glows',
 '<p>Bloom adds up. Pick three different centers and compute the halo for each one. Then add the three halos together.</p><p>Where they overlap, the canvas glows brighter. Read more at <a href="https://iquilezles.org/articles/gamma/" target="_blank" rel="noreferrer">IQ on gamma correct blurring</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d = length(p) - 0.2;
    float halo = exp(-d * 8.0);
    vec3 col = vec3(halo) * vec3(1.0, 0.8, 0.4);
    gl_FragColor = vec4(col, 1.0);
}',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float h1 = exp(-(length(p - vec2(-0.3, 0.0)) - 0.1) * 8.0);
    float h2 = exp(-(length(p - vec2( 0.0, 0.2)) - 0.1) * 8.0);
    float h3 = exp(-(length(p - vec2( 0.3, 0.0)) - 0.1) * 8.0);
    vec3 col = (h1 + h2 + h3) * vec3(1.0, 0.8, 0.4);
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'bloom-glow'), 'KohjeOia4DA', 2,
 'Breathing glow',
 '<p>Change the halo strength with a sine wave on <code>u_time</code>. The glow rises and falls over time.</p><p>It feels like a warm hearth or a charging core. Read more at <a href="https://iquilezles.org/articles/gamma/" target="_blank" rel="noreferrer">IQ on gamma correct blurring</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d = length(p) - 0.2;
    float halo = exp(-d * 8.0);
    vec3 col = vec3(halo) * vec3(1.0, 0.8, 0.4);
    gl_FragColor = vec4(col, 1.0);
}',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d = length(p) - 0.2;
    float halo = exp(-d * 8.0) * (0.5 + 0.5 * sin(u_time));
    vec3 col = vec3(halo) * vec3(1.0, 0.8, 0.4);
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'bloom-glow'), 'N3bGRbIieW0', 3,
 'Tinted via palette',
 '<p>Drop the fixed warm color. Use a cosine palette driven by <code>u_time</code>. The tint walks through hues as time moves.</p><p>The same halo turns into magma, then ice, then plasma. Read more at <a href="https://iquilezles.org/articles/gamma/" target="_blank" rel="noreferrer">IQ on gamma correct blurring</a>.</p>',
 'vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
    return a + b * cos(6.28318 * (c * t + d));
}
void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d = length(p) - 0.2;
    float halo = exp(-d * 8.0) * (0.5 + 0.5 * sin(u_time));
    vec3 tint = vec3(1.0, 0.8, 0.4);
    gl_FragColor = vec4(vec3(halo) * tint, 1.0);
}',
 'vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
    return a + b * cos(6.28318 * (c * t + d));
}
void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d = length(p) - 0.2;
    float halo = exp(-d * 8.0);
    vec3 tint = palette(u_time * 0.1, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.00, 0.33, 0.67));
    gl_FragColor = vec4(vec3(halo) * tint, 1.0);
}'),

-- ===== Course: fresnel-edges =====
((SELECT id FROM course WHERE slug = 'fresnel-edges'), 'F-JIXxl179w', 0,
 'Basic fresnel',
 '<p>Fresnel is a real fact about light. The edges of a 3D shape look brighter when your view almost slides past them. Head-on, the same spot looks dull.</p><p>The shader trick: <code>pow(1.0 - dot(n, v), k)</code>. It is 0 at the center of the sphere and 1 at the edge.</p><p>Raymarch a sphere. Find the normal. Output the fresnel value as gray to see the rim light. Read more at <a href="https://iquilezles.org/articles/outdoorslighting/" target="_blank" rel="noreferrer">IQ on outdoors lighting</a>.</p>',
 'float scene(vec3 p) { return length(p) - 0.7; }
vec3 normal(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0.0, 0.0)) - scene(p - vec3(e, 0.0, 0.0)),
        scene(p + vec3(0.0, e, 0.0)) - scene(p - vec3(0.0, e, 0.0)),
        scene(p + vec3(0.0, 0.0, e)) - scene(p - vec3(0.0, 0.0, e))
    ));
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0; bool hit = false;
    for (int i = 0; i < 64; i++) {
        vec3 p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    gl_FragColor = vec4(col, 1.0);
}',
 'float scene(vec3 p) { return length(p) - 0.7; }
vec3 normal(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0.0, 0.0)) - scene(p - vec3(e, 0.0, 0.0)),
        scene(p + vec3(0.0, e, 0.0)) - scene(p - vec3(0.0, e, 0.0)),
        scene(p + vec3(0.0, 0.0, e)) - scene(p - vec3(0.0, 0.0, e))
    ));
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0; bool hit = false;
    for (int i = 0; i < 64; i++) {
        vec3 p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        vec3 n = normal(p);
        vec3 v = -rd;
        float f = pow(1.0 - max(dot(n, v), 0.0), 3.0);
        col = vec3(f);
    }
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'fresnel-edges'), 'E1cb2TY4uug', 1,
 'Fresnel-tinted sphere',
 '<p>Mix a Lambert diffuse with the fresnel term. Lambert shades the body of the sphere from the light direction.</p><p>Fresnel adds a cyan-blue glow at the rim. Together they look like a soap bubble. Read more at <a href="https://iquilezles.org/articles/outdoorslighting/" target="_blank" rel="noreferrer">IQ on outdoors lighting</a>.</p>',
 'float scene(vec3 p) { return length(p) - 0.7; }
vec3 normal(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0.0, 0.0)) - scene(p - vec3(e, 0.0, 0.0)),
        scene(p + vec3(0.0, e, 0.0)) - scene(p - vec3(0.0, e, 0.0)),
        scene(p + vec3(0.0, 0.0, e)) - scene(p - vec3(0.0, 0.0, e))
    ));
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0; bool hit = false;
    for (int i = 0; i < 64; i++) {
        vec3 p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        vec3 n = normal(p);
        vec3 v = -rd;
        float f = pow(1.0 - max(dot(n, v), 0.0), 3.0);
        col = vec3(f);
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'float scene(vec3 p) { return length(p) - 0.7; }
vec3 normal(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0.0, 0.0)) - scene(p - vec3(e, 0.0, 0.0)),
        scene(p + vec3(0.0, e, 0.0)) - scene(p - vec3(0.0, e, 0.0)),
        scene(p + vec3(0.0, 0.0, e)) - scene(p - vec3(0.0, 0.0, e))
    ));
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0; bool hit = false;
    for (int i = 0; i < 64; i++) {
        vec3 p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        vec3 n = normal(p);
        vec3 v = -rd;
        float diff = max(dot(n, normalize(vec3(0.5, 0.8, 0.3))), 0.0);
        float f = pow(1.0 - max(dot(n, v), 0.0), 3.0);
        col = vec3(diff) * 0.5 + f * vec3(0.4, 0.7, 1.0);
    }
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'fresnel-edges'), 'yzpTNfLhaBE', 2,
 'Rim light mask',
 '<p>Use the fresnel value as a mask. Multiply it by a warm color. The body of the sphere stays dark.</p><p>Only the edge glows. You get a clean stylized rim light. Read more at <a href="https://iquilezles.org/articles/outdoorslighting/" target="_blank" rel="noreferrer">IQ on outdoors lighting</a>.</p>',
 'float scene(vec3 p) { return length(p) - 0.7; }
vec3 normal(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0.0, 0.0)) - scene(p - vec3(e, 0.0, 0.0)),
        scene(p + vec3(0.0, e, 0.0)) - scene(p - vec3(0.0, e, 0.0)),
        scene(p + vec3(0.0, 0.0, e)) - scene(p - vec3(0.0, 0.0, e))
    ));
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0; bool hit = false;
    for (int i = 0; i < 64; i++) {
        vec3 p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        vec3 n = normal(p);
        vec3 v = -rd;
        float diff = max(dot(n, normalize(vec3(0.5, 0.8, 0.3))), 0.0);
        float f = pow(1.0 - max(dot(n, v), 0.0), 3.0);
        col = vec3(diff) * 0.5 + f * vec3(0.4, 0.7, 1.0);
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'float scene(vec3 p) { return length(p) - 0.7; }
vec3 normal(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0.0, 0.0)) - scene(p - vec3(e, 0.0, 0.0)),
        scene(p + vec3(0.0, e, 0.0)) - scene(p - vec3(0.0, e, 0.0)),
        scene(p + vec3(0.0, 0.0, e)) - scene(p - vec3(0.0, 0.0, e))
    ));
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0; bool hit = false;
    for (int i = 0; i < 64; i++) {
        vec3 p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        vec3 n = normal(p);
        vec3 v = -rd;
        float f = pow(1.0 - max(dot(n, v), 0.0), 3.0);
        col = vec3(f) * vec3(1.0, 0.7, 0.3);
    }
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'fresnel-edges'), 'VdtUvRtpTvE', 3,
 'Combine with diffuse',
 '<p>Stack four parts for a full stylized look. Start with a base color. Add Lambert diffuse from a key light. Add a small ambient floor so shadows are not pure black.</p><p>Then add a fresnel rim. The rim pops the edge of the sphere off the sky behind it. Read more at <a href="https://iquilezles.org/articles/outdoorslighting/" target="_blank" rel="noreferrer">IQ on outdoors lighting</a>.</p>',
 'float scene(vec3 p) { return length(p) - 0.7; }
vec3 normal(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0.0, 0.0)) - scene(p - vec3(e, 0.0, 0.0)),
        scene(p + vec3(0.0, e, 0.0)) - scene(p - vec3(0.0, e, 0.0)),
        scene(p + vec3(0.0, 0.0, e)) - scene(p - vec3(0.0, 0.0, e))
    ));
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0; bool hit = false;
    for (int i = 0; i < 64; i++) {
        vec3 p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        col = vec3(0.0);
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'float scene(vec3 p) { return length(p) - 0.7; }
vec3 normal(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0.0, 0.0)) - scene(p - vec3(e, 0.0, 0.0)),
        scene(p + vec3(0.0, e, 0.0)) - scene(p - vec3(0.0, e, 0.0)),
        scene(p + vec3(0.0, 0.0, e)) - scene(p - vec3(0.0, 0.0, e))
    ));
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0; bool hit = false;
    for (int i = 0; i < 64; i++) {
        vec3 p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        vec3 n = normal(p);
        vec3 v = -rd;
        float diff = max(dot(n, normalize(vec3(0.5, 0.8, 0.3))), 0.0);
        float f = pow(1.0 - max(dot(n, v), 0.0), 3.0);
        col = vec3(0.95, 0.81, 0.36) * (diff * 0.7 + 0.2) + f * vec3(1.0, 0.7, 0.3);
    }
    gl_FragColor = vec4(col, 1.0);
}');
