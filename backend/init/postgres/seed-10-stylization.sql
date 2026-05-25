\c shader_dojo;

-- Family I — Stylization / post-process (4 courses, 16 lessons)

INSERT INTO lesson (id, course_id, slug, display_order, title, description, starter_fragment_shader, canonical_fragment_shader) VALUES

-- ===== Course: posterize-dither =====
('c0000040-0001-0000-0000-000000000000', 'c0000040-0000-0000-0000-000000000000', '0EbB9_v7jMg', 0,
 'N-step posterize',
 '<p>Posterization snaps continuous colors onto a small set of levels. Multiply by <code>N</code>, <code>floor</code>, then divide by <code>N</code> — every pixel lands on one of <code>N+1</code> evenly spaced bins per channel.</p><p>Sample the reference image and quantize to five levels to see the smooth HSV gradient collapse into chunky bands.</p><p>Reference: <a href="https://lygia.xyz/" target="_blank" rel="noreferrer">Lygia shader library</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 col = texture2D(u_image, uv).rgb;
    // TODO: quantize col to 5 levels per channel: floor(col * 5.0) / 5.0
    gl_FragColor = vec4(col, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 col = texture2D(u_image, uv).rgb;
    col = floor(col * 5.0) / 5.0;
    gl_FragColor = vec4(col, 1.0);
}'),

('c0000040-0002-0000-0000-000000000000', 'c0000040-0000-0000-0000-000000000000', '2TyvndnucHg', 1,
 'Bayer 4×4 dither',
 '<p>A Bayer matrix is a fixed threshold pattern that breaks up posterization banding. Build a per-pixel threshold from <code>gl_FragCoord</code> mod 4, add it to the scaled color before flooring, then divide back down.</p><p>The arithmetic <code>(2x + 3y) mod 16</code> produces an ordered pattern that mimics a 16-level dither with only 4 quantize levels.</p><p>Reference: <a href="https://lygia.xyz/" target="_blank" rel="noreferrer">Lygia shader library</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 col = texture2D(u_image, uv).rgb;
    // TODO: bayer = mod(2.0*float(int(mod(gl_FragCoord.x,4.0))) + 3.0*float(int(mod(gl_FragCoord.y,4.0))), 16.0) / 16.0;
    // TODO: col = floor(col * 4.0 + bayer) / 4.0;
    gl_FragColor = vec4(col, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 col = texture2D(u_image, uv).rgb;
    float bayer = mod(2.0 * float(int(mod(gl_FragCoord.x, 4.0))) + 3.0 * float(int(mod(gl_FragCoord.y, 4.0))), 16.0) / 16.0;
    col = floor(col * 4.0 + bayer) / 4.0;
    gl_FragColor = vec4(col, 1.0);
}'),

('c0000040-0003-0000-0000-000000000000', 'c0000040-0000-0000-0000-000000000000', 'wE2GWxd-i0Q', 2,
 'Noise dither via hash',
 '<p>Swap the ordered Bayer threshold for a random one. A hash on <code>gl_FragCoord.xy</code> gives a per-pixel value in <code>[0, 1)</code> that scrambles the quantize boundaries — banding becomes film grain.</p><p>Reference: <a href="https://lygia.xyz/" target="_blank" rel="noreferrer">Lygia shader library</a>.</p>',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: col = floor(texture2D(u_image, uv).rgb * 4.0 + hash(gl_FragCoord.xy)) / 4.0;
    vec3 col = texture2D(u_image, uv).rgb;
    gl_FragColor = vec4(col, 1.0);
}',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 col = floor(texture2D(u_image, uv).rgb * 4.0 + hash(gl_FragCoord.xy)) / 4.0;
    gl_FragColor = vec4(col, 1.0);
}'),

('c0000040-0004-0000-0000-000000000000', 'c0000040-0000-0000-0000-000000000000', '_sGhGoJFgVw', 3,
 'Posterized gradient with dither',
 '<p>Drop the image and feed a synthetic gradient <code>vec3(uv.x)</code> through the same pipeline. Adding the Bayer threshold before a 5-level quantize spreads the steps into a clean dithered ramp — the classic NES-era sky.</p><p>Reference: <a href="https://lygia.xyz/" target="_blank" rel="noreferrer">Lygia shader library</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec3 col = vec3(uv.x);
    // TODO: bayer = mod(2.0*float(int(mod(gl_FragCoord.x,4.0))) + 3.0*float(int(mod(gl_FragCoord.y,4.0))), 16.0) / 16.0;
    // TODO: col = floor(col * 5.0 + bayer) / 5.0;
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
('c0000041-0001-0000-0000-000000000000', 'c0000041-0000-0000-0000-000000000000', 'vXooNTx10K4', 0,
 'Linear R/G/B offset',
 '<p>Chromatic aberration fakes a lens that focuses different wavelengths at different points. Sample each color channel at a slightly different UV — red shifted right, green at center, blue shifted left — and recombine.</p><p>Reference: <a href="https://lygia.xyz/" target="_blank" rel="noreferrer">Lygia shader library</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: r = texture2D(u_image, uv + vec2(0.01, 0.0)).r;
    // TODO: g = texture2D(u_image, uv).g;
    // TODO: b = texture2D(u_image, uv - vec2(0.01, 0.0)).b;
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

('c0000041-0002-0000-0000-000000000000', 'c0000041-0000-0000-0000-000000000000', '90qGhZ00KYU', 1,
 'Radial offset',
 '<p>Real lens fringing radiates from the center. Build an offset that points outward — <code>(uv - 0.5) * k</code> — and use it to push R and B in opposite directions along the radius.</p><p>Reference: <a href="https://lygia.xyz/" target="_blank" rel="noreferrer">Lygia shader library</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: off = (uv - 0.5) * 0.05;
    // TODO: r at uv + off, g at uv, b at uv - off
    vec3 col = texture2D(u_image, uv).rgb;
    gl_FragColor = vec4(col, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 off = (uv - 0.5) * 0.05;
    float r = texture2D(u_image, uv + off).r;
    float g = texture2D(u_image, uv).g;
    float b = texture2D(u_image, uv - off).b;
    gl_FragColor = vec4(r, g, b, 1.0);
}'),

('c0000041-0003-0000-0000-000000000000', 'c0000041-0000-0000-0000-000000000000', 'a7669aBF03Q', 2,
 'Animated wobble',
 '<p>Modulate the radial offset strength with a time oscillator. The fringe breathes in and out — the cheap glitch-VHS look.</p><p>Reference: <a href="https://lygia.xyz/" target="_blank" rel="noreferrer">Lygia shader library</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: off = (uv - 0.5) * 0.05 * (0.5 + 0.5 * sin(u_time));
    vec3 col = texture2D(u_image, uv).rgb;
    gl_FragColor = vec4(col, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 off = (uv - 0.5) * 0.05 * (0.5 + 0.5 * sin(u_time));
    float r = texture2D(u_image, uv + off).r;
    float g = texture2D(u_image, uv).g;
    float b = texture2D(u_image, uv - off).b;
    gl_FragColor = vec4(r, g, b, 1.0);
}'),

('c0000041-0004-0000-0000-000000000000', 'c0000041-0000-0000-0000-000000000000', 'xcxuDH0QQjk', 3,
 'Aberration + vignette',
 '<p>Stack the radial split with a vignette mask for the full cinematic look: corners both color-fringed and darkened.</p><p>Reference: <a href="https://lygia.xyz/" target="_blank" rel="noreferrer">Lygia shader library</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 off = (uv - 0.5) * 0.05;
    float r = texture2D(u_image, uv + off).r;
    float g = texture2D(u_image, uv).g;
    float b = texture2D(u_image, uv - off).b;
    vec3 col = vec3(r, g, b);
    // TODO: v = 1.0 - smoothstep(0.4, 0.8, length(uv - 0.5));
    // TODO: col *= v;
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
('c0000042-0001-0000-0000-000000000000', 'c0000042-0000-0000-0000-000000000000', 'TnyYmcEDq2I', 0,
 'Halo around circle',
 '<p>The cheapest bloom: an exponential falloff on the signed distance to a shape. <code>exp(-d * k)</code> is bright at the surface, fades fast outside. Tint it warm to get a candle-flame halo.</p><p>Reference: <a href="https://iquilezles.org/articles/gamma/" target="_blank" rel="noreferrer">IQ — Gamma correct blurring</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d = length(p) - 0.2;
    // TODO: halo = exp(-d * 8.0); col = vec3(halo) * vec3(1.0, 0.8, 0.4);
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

('c0000042-0002-0000-0000-000000000000', 'c0000042-0000-0000-0000-000000000000', '0k8nwTMVJNI', 1,
 'Multiple glows',
 '<p>Bloom is additive. Compute the halo from three different centers and sum them — wherever they overlap, the canvas pushes brighter.</p><p>Reference: <a href="https://iquilezles.org/articles/gamma/" target="_blank" rel="noreferrer">IQ — Gamma correct blurring</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    // TODO: sum exp(-(length(p - c_i) - 0.1) * 8.0) for c_i in {(-0.3,0), (0,0.2), (0.3,0)}
    vec3 col = vec3(0.0);
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

('c0000042-0003-0000-0000-000000000000', 'c0000042-0000-0000-0000-000000000000', 'KohjeOia4DA', 2,
 'Breathing glow',
 '<p>Modulate the halo intensity with a time oscillator. The glow inhales and exhales — a warm hearth, a charging core.</p><p>Reference: <a href="https://iquilezles.org/articles/gamma/" target="_blank" rel="noreferrer">IQ — Gamma correct blurring</a>.</p>',
 'void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d = length(p) - 0.2;
    float halo = exp(-d * 8.0);
    // TODO: halo *= 0.5 + 0.5 * sin(u_time);
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

('c0000042-0004-0000-0000-000000000000', 'c0000042-0000-0000-0000-000000000000', 'N3bGRbIieW0', 3,
 'Tinted via palette',
 '<p>Replace the fixed warm tint with a cosine palette driven by time. The halo shifts hue while it pulses — the same glow becomes magma, ice, plasma.</p><p>Reference: <a href="https://iquilezles.org/articles/gamma/" target="_blank" rel="noreferrer">IQ — Gamma correct blurring</a>.</p>',
 'vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
    return a + b * cos(6.28318 * (c * t + d));
}
void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float d = length(p) - 0.2;
    float halo = exp(-d * 8.0);
    // TODO: tint = palette(u_time * 0.1, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.00, 0.33, 0.67));
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
('c0000043-0001-0000-0000-000000000000', 'c0000043-0000-0000-0000-000000000000', 'F-JIXxl179w', 0,
 'Basic fresnel',
 '<p>Fresnel is the optical fact that surfaces look more reflective when you view them at a glancing angle. The shader proxy: <code>pow(1.0 - dot(n, v), k)</code> — 0 at the center of the sphere, 1 at the silhouette.</p><p>Raymarch a sphere, compute the normal, and output the fresnel term as grayscale to see the rim light it carves.</p><p>Reference: <a href="https://iquilezles.org/articles/outdoorslighting/" target="_blank" rel="noreferrer">IQ — Outdoors lighting (fresnel)</a>.</p>',
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
        // TODO: f = pow(1.0 - max(dot(n, v), 0.0), 3.0); col = vec3(f);
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
        col = vec3(f);
    }
    gl_FragColor = vec4(col, 1.0);
}'),

('c0000043-0002-0000-0000-000000000000', 'c0000043-0000-0000-0000-000000000000', 'E1cb2TY4uug', 1,
 'Fresnel-tinted sphere',
 '<p>Combine a basic Lambert diffuse with the fresnel term to get a soap-bubble look: the body of the sphere is shaded by light direction, the rim glows cyan-blue.</p><p>Reference: <a href="https://iquilezles.org/articles/outdoorslighting/" target="_blank" rel="noreferrer">IQ — Outdoors lighting (fresnel)</a>.</p>',
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
        // TODO: diff = max(dot(n, normalize(vec3(0.5, 0.8, 0.3))), 0.0);
        // TODO: f = pow(1.0 - max(dot(n, v), 0.0), 3.0);
        // TODO: col = vec3(diff) * 0.5 + f * vec3(0.4, 0.7, 1.0);
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

('c0000043-0003-0000-0000-000000000000', 'c0000043-0000-0000-0000-000000000000', 'yzpTNfLhaBE', 2,
 'Rim light mask',
 '<p>Treat the fresnel term as a pure mask and multiply by a warm color. The body of the sphere stays dark, only the silhouette glows — classic stylized rim light.</p><p>Reference: <a href="https://iquilezles.org/articles/outdoorslighting/" target="_blank" rel="noreferrer">IQ — Outdoors lighting (fresnel)</a>.</p>',
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
        // TODO: f = pow(1.0 - max(dot(n, v), 0.0), 3.0);
        // TODO: col = vec3(f) * vec3(1.0, 0.7, 0.3);
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

('c0000043-0004-0000-0000-000000000000', 'c0000043-0000-0000-0000-000000000000', 'VdtUvRtpTvE', 3,
 'Combine with diffuse',
 '<p>The full stylized lighting model: a base color, Lambert diffuse from a key light, an ambient floor so shadows are not black, and a fresnel rim that pops the silhouette off the sky.</p><p>Reference: <a href="https://iquilezles.org/articles/outdoorslighting/" target="_blank" rel="noreferrer">IQ — Outdoors lighting (fresnel)</a>.</p>',
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
        // TODO: diff = max(dot(n, normalize(vec3(0.5, 0.8, 0.3))), 0.0);
        // TODO: f = pow(1.0 - max(dot(n, v), 0.0), 3.0);
        // TODO: col = vec3(0.95, 0.81, 0.36) * (diff * 0.7 + 0.2) + f * vec3(1.0, 0.7, 0.3);
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
