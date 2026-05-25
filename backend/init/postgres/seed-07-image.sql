\c shader_dojo;

-- Family F — Image sampling (2 courses, 8 lessons)

INSERT INTO lesson (id, course_id, slug, display_order, title, description, starter_fragment_shader, canonical_fragment_shader) VALUES

-- ===== Course: image-sampling =====
('c0000023-0001-0000-0000-000000000000', 'c0000023-0000-0000-0000-000000000000', 'zp-XRe_jywQ', 0,
 'Direct sample',
 '<p>A fragment shader can read a texture with <code>texture2D(sampler, uv)</code>. Build a UV in <code>[0, 1]</code> from <code>gl_FragCoord</code> and sample the bound reference image directly.</p><p>The bundled <code>u_image</code> is a 256×256 HSV gradient with a bright circle and a dark square — useful landmarks for spotting any UV transform you apply later.</p><p>Reference: <a href="https://iquilezles.org/articles/texture/" target="_blank" rel="noreferrer">IQ — Improved bilinear filtering</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: sample u_image at uv and output it.
    gl_FragColor = vec4(uv, 0.0, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    gl_FragColor = texture2D(u_image, uv);
}'),

('c0000023-0002-0000-0000-000000000000', 'c0000023-0000-0000-0000-000000000000', 'umIdzT4ZADQ', 1,
 'Flipped/mirrored UV',
 '<p>Texture coordinates are just numbers — swap or invert components to transform the sampled image. Replacing <code>uv.y</code> with <code>1.0 - uv.y</code> flips the image vertically.</p><p>This is also how you reconcile a texture loaded with a different vertical convention than the framebuffer expects.</p><p>Reference: <a href="https://iquilezles.org/articles/texture/" target="_blank" rel="noreferrer">IQ — Improved bilinear filtering</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: sample u_image with y flipped: vec2(uv.x, 1.0 - uv.y).
    gl_FragColor = texture2D(u_image, uv);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    gl_FragColor = texture2D(u_image, vec2(uv.x, 1.0 - uv.y));
}'),

('c0000023-0003-0000-0000-000000000000', 'c0000023-0000-0000-0000-000000000000', 'p1ZJ3WDcse4', 2,
 'Tiled fract sample',
 '<p>Multiply the UV before sampling and the texture repeats — but only if the sampler is set to wrap. <code>fract()</code> guarantees the same tiling regardless of the sampler''s clamp/repeat state: multiply, then take the fractional part.</p><p>Try <code>fract(uv * 3.0)</code> to fit a 3×3 grid of the source image across the canvas.</p><p>Reference: <a href="https://iquilezles.org/articles/texture/" target="_blank" rel="noreferrer">IQ — Improved bilinear filtering</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: sample u_image at fract(uv * 3.0) for a 3x3 tiling.
    gl_FragColor = texture2D(u_image, uv);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    gl_FragColor = texture2D(u_image, fract(uv * 3.0));
}'),

('c0000023-0004-0000-0000-000000000000', 'c0000023-0000-0000-0000-000000000000', 'AfXxL4IYCyc', 3,
 'Time-scrolling UV',
 '<p>Add <code>u_time</code> to one axis of the UV before sampling and the image scrolls. Wrap with <code>fract()</code> so the texture loops cleanly regardless of how the sampler is configured.</p><p>This is the core trick behind animated wallpaper effects, scrolling backgrounds, and any "conveyor belt" texture motion.</p><p>Reference: <a href="https://iquilezles.org/articles/texture/" target="_blank" rel="noreferrer">IQ — Improved bilinear filtering</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    // TODO: scroll horizontally: sample u_image at fract(uv + vec2(u_time * 0.1, 0.0)).
    gl_FragColor = texture2D(u_image, uv);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    gl_FragColor = texture2D(u_image, fract(uv + vec2(u_time * 0.1, 0.0)));
}'),

-- ===== Course: convolution-kernels =====
('c0000024-0001-0000-0000-000000000000', 'c0000024-0000-0000-0000-000000000000', 'pV4gLIB6Fdg', 0,
 '3×3 box blur',
 '<p>A convolution kernel reads several neighboring texels and combines them with weights. The simplest is a 3×3 box blur: nine samples at <code>(-1,-1)</code> through <code>(1,1)</code> texel offsets, averaged.</p><p>Compute a one-texel step in UV space as <code>1.0 / u_image_resolution</code>, then sum nine <code>texture2D</code> calls and divide by 9.</p><p>References: <a href="https://iquilezles.org/articles/filtering/" target="_blank" rel="noreferrer">IQ — Filtering procedural textures</a>, <a href="https://lygia.xyz/" target="_blank" rel="noreferrer">Lygia filter module</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 px = 1.0 / u_image_resolution;
    // TODO: sum 9 samples of u_image at offsets (-1..1, -1..1) * px and divide by 9.
    vec3 c = texture2D(u_image, uv).rgb;
    gl_FragColor = vec4(c, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 px = 1.0 / u_image_resolution;
    vec3 c = vec3(0.0);
    c += texture2D(u_image, uv + vec2(-1.0, -1.0) * px).rgb;
    c += texture2D(u_image, uv + vec2( 0.0, -1.0) * px).rgb;
    c += texture2D(u_image, uv + vec2( 1.0, -1.0) * px).rgb;
    c += texture2D(u_image, uv + vec2(-1.0,  0.0) * px).rgb;
    c += texture2D(u_image, uv + vec2( 0.0,  0.0) * px).rgb;
    c += texture2D(u_image, uv + vec2( 1.0,  0.0) * px).rgb;
    c += texture2D(u_image, uv + vec2(-1.0,  1.0) * px).rgb;
    c += texture2D(u_image, uv + vec2( 0.0,  1.0) * px).rgb;
    c += texture2D(u_image, uv + vec2( 1.0,  1.0) * px).rgb;
    c /= 9.0;
    gl_FragColor = vec4(c, 1.0);
}'),

('c0000024-0002-0000-0000-000000000000', 'c0000024-0000-0000-0000-000000000000', 'hk9fddh_K4c', 1,
 'Gaussian weights',
 '<p>A box blur weights every sample equally, which is cheap but flat. A 3×3 Gaussian uses weights <code>[1,2,1; 2,4,2; 1,2,1] / 16</code> — center pixel counts most, corners least — producing a softer, more natural blur.</p><p>Sum nine weighted samples, normalize by 16 (the sum of the weights).</p><p>References: <a href="https://iquilezles.org/articles/filtering/" target="_blank" rel="noreferrer">IQ — Filtering procedural textures</a>, <a href="https://lygia.xyz/" target="_blank" rel="noreferrer">Lygia filter module</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 px = 1.0 / u_image_resolution;
    // TODO: weighted sum with [1,2,1; 2,4,2; 1,2,1] / 16.
    vec3 c = texture2D(u_image, uv).rgb;
    gl_FragColor = vec4(c, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 px = 1.0 / u_image_resolution;
    vec3 c = vec3(0.0);
    c += 1.0 * texture2D(u_image, uv + vec2(-1.0, -1.0) * px).rgb;
    c += 2.0 * texture2D(u_image, uv + vec2( 0.0, -1.0) * px).rgb;
    c += 1.0 * texture2D(u_image, uv + vec2( 1.0, -1.0) * px).rgb;
    c += 2.0 * texture2D(u_image, uv + vec2(-1.0,  0.0) * px).rgb;
    c += 4.0 * texture2D(u_image, uv + vec2( 0.0,  0.0) * px).rgb;
    c += 2.0 * texture2D(u_image, uv + vec2( 1.0,  0.0) * px).rgb;
    c += 1.0 * texture2D(u_image, uv + vec2(-1.0,  1.0) * px).rgb;
    c += 2.0 * texture2D(u_image, uv + vec2( 0.0,  1.0) * px).rgb;
    c += 1.0 * texture2D(u_image, uv + vec2( 1.0,  1.0) * px).rgb;
    c /= 16.0;
    gl_FragColor = vec4(c, 1.0);
}'),

('c0000024-0003-0000-0000-000000000000', 'c0000024-0000-0000-0000-000000000000', '7OTmIYMqcYg', 2,
 'Sobel edge magnitude',
 '<p>The Sobel operator finds edges by running two kernels — one for horizontal change, one for vertical — and combining their magnitudes. <code>gx = [-1,0,1; -2,0,2; -1,0,1]</code> detects vertical edges; <code>gy = [-1,-2,-1; 0,0,0; 1,2,1]</code> detects horizontal ones.</p><p>Convert each sample to grayscale via <code>dot(rgb, vec3(0.299, 0.587, 0.114))</code>, accumulate <code>gx</code> and <code>gy</code>, then output <code>sqrt(gx*gx + gy*gy)</code> as white-on-black.</p><p>References: <a href="https://iquilezles.org/articles/filtering/" target="_blank" rel="noreferrer">IQ — Filtering procedural textures</a>, <a href="https://lygia.xyz/" target="_blank" rel="noreferrer">Lygia filter module</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 px = 1.0 / u_image_resolution;
    // TODO: compute Sobel gx and gy on grayscale samples, output sqrt(gx*gx + gy*gy).
    vec3 c = texture2D(u_image, uv).rgb;
    gl_FragColor = vec4(c, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 px = 1.0 / u_image_resolution;
    vec3 lum = vec3(0.299, 0.587, 0.114);
    float s00 = dot(texture2D(u_image, uv + vec2(-1.0, -1.0) * px).rgb, lum);
    float s10 = dot(texture2D(u_image, uv + vec2( 0.0, -1.0) * px).rgb, lum);
    float s20 = dot(texture2D(u_image, uv + vec2( 1.0, -1.0) * px).rgb, lum);
    float s01 = dot(texture2D(u_image, uv + vec2(-1.0,  0.0) * px).rgb, lum);
    float s21 = dot(texture2D(u_image, uv + vec2( 1.0,  0.0) * px).rgb, lum);
    float s02 = dot(texture2D(u_image, uv + vec2(-1.0,  1.0) * px).rgb, lum);
    float s12 = dot(texture2D(u_image, uv + vec2( 0.0,  1.0) * px).rgb, lum);
    float s22 = dot(texture2D(u_image, uv + vec2( 1.0,  1.0) * px).rgb, lum);
    float gx = -s00 + s20 - 2.0 * s01 + 2.0 * s21 - s02 + s22;
    float gy = -s00 - 2.0 * s10 - s20 + s02 + 2.0 * s12 + s22;
    float m = sqrt(gx * gx + gy * gy);
    gl_FragColor = vec4(vec3(m), 1.0);
}'),

('c0000024-0004-0000-0000-000000000000', 'c0000024-0000-0000-0000-000000000000', 'T73Ah2SA5f8', 3,
 'Sharpen kernel',
 '<p>A sharpen kernel boosts the center pixel and subtracts its neighbors, exaggerating local contrast. The classic 3×3 form is <code>[0,-1,0; -1,5,-1; 0,-1,0]</code> — five cross-shaped taps whose weights sum to 1, so flat regions stay unchanged.</p><p>Apply to color, then <code>clamp</code> the result into <code>[0, 1]</code> to keep the output in range.</p><p>References: <a href="https://iquilezles.org/articles/filtering/" target="_blank" rel="noreferrer">IQ — Filtering procedural textures</a>, <a href="https://lygia.xyz/" target="_blank" rel="noreferrer">Lygia filter module</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 px = 1.0 / u_image_resolution;
    // TODO: kernel [0,-1,0; -1,5,-1; 0,-1,0]; clamp result to [0, 1].
    vec3 c = texture2D(u_image, uv).rgb;
    gl_FragColor = vec4(c, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 px = 1.0 / u_image_resolution;
    vec3 c = vec3(0.0);
    c += -1.0 * texture2D(u_image, uv + vec2( 0.0, -1.0) * px).rgb;
    c += -1.0 * texture2D(u_image, uv + vec2(-1.0,  0.0) * px).rgb;
    c +=  5.0 * texture2D(u_image, uv + vec2( 0.0,  0.0) * px).rgb;
    c += -1.0 * texture2D(u_image, uv + vec2( 1.0,  0.0) * px).rgb;
    c += -1.0 * texture2D(u_image, uv + vec2( 0.0,  1.0) * px).rgb;
    c = clamp(c, 0.0, 1.0);
    gl_FragColor = vec4(c, 1.0);
}');
