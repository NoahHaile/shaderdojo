\c shader_dojo;

-- Family F — Image sampling (2 courses, 8 lessons)

INSERT INTO lesson (course_id, slug, display_order, title, description, starter_fragment_shader, canonical_fragment_shader) VALUES

-- ===== Course: image-sampling =====
((SELECT id FROM course WHERE slug = 'image-sampling'), 'zp-XRe_jywQ', 0,
 'Direct sample',
 '<p>A shader can read a picture. The call is <code>texture2D(sampler, uv)</code>. It looks up the color at the spot <code>uv</code>, where the spot is a pair of numbers from 0 to 1.</p><p>The picture you have is <code>u_image</code>: 256 by 256 pixels. It holds an HSV rainbow that sweeps left to right, a bright disc in the upper-left, and a dark square in the lower-right. Those three landmarks make it easy to tell when your sampling is right.</p><p>Try this: build <code>uv</code> from <code>gl_FragCoord.xy / u_resolution.xy</code>, then output <code>texture2D(u_image, uv)</code>. You should see the rainbow stretched to fill the canvas, with the circle and square in their places.</p><p>Read more at <a href="https://iquilezles.org/articles/texture/" target="_blank" rel="noreferrer">IQ, Improved bilinear filtering</a>.</p>',
 'void main() {
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    gl_FragColor = texture2D(u_image, uv);
}'),

((SELECT id FROM course WHERE slug = 'image-sampling'), 'umIdzT4ZADQ', 1,
 'Flipped/mirrored UV',
 '<p>The <code>uv</code> spot is just numbers. You can change those numbers before you sample. That moves or flips the picture.</p><p>Swap <code>uv.y</code> for <code>1.0 - uv.y</code>. Now the top reads from the bottom. The picture flips upside down. The same trick fixes pictures that load with their y axis the wrong way.</p><p>Try this: sample <code>u_image</code> at <code>vec2(uv.x, 1.0 - uv.y)</code>. Read more at <a href="https://iquilezles.org/articles/texture/" target="_blank" rel="noreferrer">IQ, Improved bilinear filtering</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    gl_FragColor = texture2D(u_image, uv);
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    gl_FragColor = texture2D(u_image, vec2(uv.x, 1.0 - uv.y));
}'),

((SELECT id FROM course WHERE slug = 'image-sampling'), 'p1ZJ3WDcse4', 2,
 'Tiled fract sample',
 '<p>Multiply <code>uv</code> by 3 and the numbers go from 0 to 3. That asks for spots outside the picture. The result depends on how the sampler is set up.</p><p>Use <code>fract()</code> to keep the spot in 0 to 1. It throws away the whole part and keeps the decimal. So <code>fract(uv * 3.0)</code> takes the address 1.7 and turns it into 0.7. The picture gets stamped down 3 by 3 across the canvas: 9 small copies of the rainbow, each with its own circle and square.</p><p>Try this: sample <code>u_image</code> at <code>fract(uv * 3.0)</code>. Bump the multiplier to 5.0 or 10.0 to see denser tiling. Read more at <a href="https://iquilezles.org/articles/texture/" target="_blank" rel="noreferrer">IQ, Improved bilinear filtering</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    gl_FragColor = texture2D(u_image, vec2(uv.x, 1.0 - uv.y));
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    gl_FragColor = texture2D(u_image, fract(uv * 3.0));
}'),

((SELECT id FROM course WHERE slug = 'image-sampling'), 'AfXxL4IYCyc', 3,
 'Time-scrolling UV',
 '<p>Add <code>u_time</code> to one part of <code>uv</code>. The spot moves a little more each second. The picture scrolls.</p><p>Wrap it in <code>fract()</code> so the spot stays in 0 to 1. The picture loops without a seam. This is how scrolling backgrounds work.</p><p>Try this: sample <code>u_image</code> at <code>fract(uv + vec2(u_time * 0.1, 0.0))</code>. Read more at <a href="https://iquilezles.org/articles/texture/" target="_blank" rel="noreferrer">IQ, Improved bilinear filtering</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    gl_FragColor = texture2D(u_image, fract(uv * 3.0));
}',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    gl_FragColor = texture2D(u_image, fract(uv + vec2(u_time * 0.1, 0.0)));
}'),

-- ===== Course: convolution-kernels =====
((SELECT id FROM course WHERE slug = 'convolution-kernels'), 'pV4gLIB6Fdg', 0,
 '3×3 box blur',
 '<p>A convolution kernel is a small grid of weights. You sample the neighbor pixels, multiply each by its weight, and add them up. That makes a new color.</p><p>The box blur uses 9 samples at offsets <code>(-1,-1)</code> through <code>(1,1)</code>. All weights are 1. You add them and divide by 9. One pixel step in <code>uv</code> is <code>1.0 / u_image_resolution</code>.</p><p>Try this: sum 9 samples and divide by 9. Read more at <a href="https://iquilezles.org/articles/filtering/" target="_blank" rel="noreferrer">IQ, Filtering procedural textures</a> and <a href="https://lygia.xyz/" target="_blank" rel="noreferrer">Lygia filter module</a>.</p>',
 'void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    gl_FragColor = texture2D(u_image, uv);
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

((SELECT id FROM course WHERE slug = 'convolution-kernels'), 'hk9fddh_K4c', 1,
 'Gaussian weights',
 '<p>A box blur gives every sample the same weight. The result looks flat. A Gaussian blur gives more weight to the middle and less to the corners. It looks softer.</p><p>The 3 by 3 weights are <code>[1,2,1; 2,4,2; 1,2,1]</code>. Their sum is 16. Multiply each sample by its weight, add them up, and divide by 16.</p><p>Try this: do the weighted sum and divide by 16. Read more at <a href="https://iquilezles.org/articles/filtering/" target="_blank" rel="noreferrer">IQ, Filtering procedural textures</a> and <a href="https://lygia.xyz/" target="_blank" rel="noreferrer">Lygia filter module</a>.</p>',
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

((SELECT id FROM course WHERE slug = 'convolution-kernels'), '7OTmIYMqcYg', 2,
 'Sobel edge magnitude',
 '<p>The Sobel operator finds edges. It uses two kernels. One looks for left to right change. One looks for up and down change. Then you mix them.</p><p>The kernels are <code>gx = [-1,0,1; -2,0,2; -1,0,1]</code> and <code>gy = [-1,-2,-1; 0,0,0; 1,2,1]</code>. First turn each sample to gray with <code>dot(rgb, vec3(0.299, 0.587, 0.114))</code>. Add up <code>gx</code> and <code>gy</code>. Output <code>sqrt(gx*gx + gy*gy)</code>. Edges show as white on black.</p><p>Try this: compute <code>gx</code>, <code>gy</code>, then the square root of their squares. Read more at <a href="https://iquilezles.org/articles/filtering/" target="_blank" rel="noreferrer">IQ, Filtering procedural textures</a> and <a href="https://lygia.xyz/" target="_blank" rel="noreferrer">Lygia filter module</a>.</p>',
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

((SELECT id FROM course WHERE slug = 'convolution-kernels'), 'T73Ah2SA5f8', 3,
 'Sharpen kernel',
 '<p>A sharpen kernel pushes the middle pixel up and pulls its neighbors down. That makes the edges stand out more.</p><p>The weights are <code>[0,-1,0; -1,5,-1; 0,-1,0]</code>. Only five spots have a weight. The weights add up to 1, so flat areas stay the same color. Use <code>clamp</code> to keep colors in 0 to 1.</p><p>Try this: do the weighted sum and clamp it. Read more at <a href="https://iquilezles.org/articles/filtering/" target="_blank" rel="noreferrer">IQ, Filtering procedural textures</a> and <a href="https://lygia.xyz/" target="_blank" rel="noreferrer">Lygia filter module</a>.</p>',
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
