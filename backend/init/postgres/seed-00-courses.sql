\c shader_dojo;

-- 51 technique-aligned courses across 11 families (Level 0 + A-J).

INSERT INTO course (slug, title, description, category, difficulty, display_order) VALUES
-- ===== Family Z. Orientation =====
('glsl-environment',     'The shader environment','Learn what a shader is. See how the GPU runs your code once for each pixel. Meet the inputs you get.',                                       'Orientation', 'beginner', 0),
-- ===== Family A, Foundations =====
('uv-coordinates',       'UV coordinates',        'Find your pixel''s spot on the screen. Get a number from 0 to 1 across the canvas.',                                                       'Foundations', 'beginner', 1),
('time-oscillation',     'Time and oscillation',  'Use u_time to move things. Make values pulse with sin and cos.',                                                                           'Foundations', 'beginner', 2),
('step-smoothstep',      'Step and smoothstep',   'Draw a hard edge with step. Draw a soft edge with smoothstep. These two functions draw every clean line.',                                 'Foundations', 'beginner', 3),
('mix-gradients',        'Mix and gradients',     'Blend two colors. Pick how much of each with a number from 0 to 1.',                                                                       'Foundations', 'beginner', 4),
('plotting-curves',      'Plotting curves',       'Draw a line for a math function. Like y = sin(x). See the wave in 2D.',                                                                    'Foundations', 'beginner', 5),
('loop-fundamentals',    'Loops and counters',    'Use for, break, and a running counter. GLSL needs a fixed loop count. Learn the rules before any later family that walks data.',           'Foundations', 'beginner', 6),
-- ===== Family B, Color =====
('hsv-color',            'HSV color',             'Pick a color by hue, not red-green-blue. Spin the hue to walk a rainbow.',                                                                 'Color',       'beginner', 7),
('cosine-palettes',      'Cosine palettes',       'Make any palette with one cosine. Four numbers in, smooth color out. A trick by Inigo Quilez.',                                            'Color',       'beginner', 8),
('tone-vignette-gamma',  'Tone, vignette, gamma', 'Polish the colors at the end. Gamma. Vignette. Tone map. The final pass on every shader.',                                                 'Color',       'intermediate', 9),
-- ===== Trials. First creative checkpoint =====
-- Shares display_order 9 with the last Color course on purpose. The UI orders
-- categories by their minimum display_order, so 9 places Trials between Color
-- (min 7) and 2D Distance Fields (min 10) with no renumbering of later courses.
('first-masterwork',     'Your first masterwork', 'No new technique. Take everything from Foundations and Color and make one piece you are proud of, then share it with the world.',           'Trials',      'intermediate', 9),
-- ===== Family C. 2D distance fields =====
('sdf-2d-primitives',    '2D SDF shapes',         'Draw shapes by distance. A circle is the spots within r of the center. Same idea for boxes and lines.',                                    '2D Distance Fields', 'intermediate', 10),
('sdf-booleans',         'SDF booleans',          'Combine SDF shapes. Take the smaller distance to join them. Take the larger to clip them.',                                                '2D Distance Fields', 'intermediate', 11),
('smooth-min',           'Smooth min',            'Glue two shapes with a soft seam. Use smin in place of min. Pick how soft it should be.',                                                  '2D Distance Fields', 'intermediate', 12),
('sdf-antialiasing',     'SDF anti-aliasing',     'Make SDF edges smooth, not pixelated. Use smoothstep or fwidth. Get clean outlines at any size.',                                          '2D Distance Fields', 'intermediate', 13),
-- ===== Family D, Space transforms =====
('rotations-2d',         '2D rotations',          'Turn coordinates by an angle. Use a 2x2 matrix. Rotate around any point.',                                                                 'Space',       'intermediate', 14),
('polar-coordinates',    'Polar coordinates',     'Use distance and angle in place of x and y. Good for rings, spirals, and stars.',                                                          'Space',       'intermediate', 15),
('tiling-repetition',    'Tiling and repetition', 'Use fract and mod to tile one cell across the screen. Build grids and checkers.',                                                          'Space',       'intermediate', 16),
('kaleidoscope-mirror',  'Kaleidoscope',          'Fold space with abs. Get mirror copies. Build a kaleidoscope.',                                                                            'Space',       'intermediate', 17),
-- ===== Family E, Noise =====
('hash-random',          'Hash random',           'Get random numbers from a position. Same input, same output. The base of every GPU noise.',                                                'Noise',       'intermediate', 18),
('value-noise',          'Value noise',           'Smooth random fields on a grid. Blend the four corners of each cell. The simplest noise.',                                                 'Noise',       'intermediate', 19),
('gradient-noise',       'Gradient noise',        'Smoother than value noise. Each grid point gets a random direction. Ken Perlin''s original.',                                              'Noise',       'intermediate', 20),
('voronoi',              'Voronoi',               'Scatter points. Color each pixel by its closest one. Get natural cells and borders.',                                                      'Noise',       'intermediate', 21),
('fbm',                  'fBM (octaves)',         'Stack noise at smaller and smaller scales. Add detail without changing the big shape.',                                                    'Noise',       'intermediate', 22),
('domain-warping',       'Domain warping',        'Bend the input before noise. Get swirls, flames, and strange patterns. A favorite trick of Inigo Quilez.',                                 'Noise',       'intermediate', 23),
-- ===== Family F, Image sampling =====
('image-sampling',       'Image sampling',        'Read a color from a picture. Flip it. Tile it. Move it over time.',                                                                        'Image',       'intermediate', 24),
('convolution-kernels',  'Convolution kernels',   'Read 9 nearby pixels. Mix them. Blur, sharpen, or find edges.',                                                                            'Image',       'intermediate', 25),
-- ===== Family G, Raymarching =====
('ray-pinhole-camera',   'Ray and pinhole camera','Turn a 2D pixel into a 3D ray. Set the camera spot and the look direction.',                                                               'Raymarching', 'advanced', 26),
('sdf-3d-primitives',    '3D SDF shapes',         'The 3D shape vocabulary. Sphere, box, plane, torus.',                                                                                      'Raymarching', 'advanced', 27),
('sphere-tracing',       'Sphere tracing',        'Walk along a ray. Step by the SDF distance. Stop when you hit a surface.',                                                                 'Raymarching', 'advanced', 28),
('surface-normals',      'Surface normals',       'Find the direction out of a surface. Sample the SDF a tiny bit in each axis.',                                                             'Raymarching', 'advanced', 29),
('diffuse-lighting',     'Diffuse lighting',      'Light a surface by its normal. Dot the normal with the light direction. Add an ambient floor.',                                            'Raymarching', 'advanced', 30),
('soft-shadows',         'Soft shadows',          'Make shadow edges soft, not sharp. Sample the SDF along the ray to the light. Keep the smallest value.',                                   'Raymarching', 'advanced', 31),
('sdf-3d-ops',           '3D SDF ops',            'Combine 3D shapes. Repeat them on a grid. Fold space.',                                                                                    'Raymarching', 'advanced', 32),
('sdf-fbm-detail',       'fBM detail on SDFs',    'Add fbm bumps to a 3D shape. Get rocks, planets, and rough surfaces.',                                                                     'Raymarching', 'advanced', 33),
('fog-and-ao',           'Fog and AO',            'Fade far things into haze. Darken corners with ambient occlusion. The final scene polish.',                                                'Raymarching', 'advanced', 34),
-- ===== Family H, Procedural generation =====
('proc-terrain',         'Procedural terrain',    'Use fbm as a heightmap. Color by elevation. Get a top-down landscape.',                                                                    'Procedural Generation', 'advanced', 35),
('proc-clouds',          'Procedural clouds',     'Threshold fbm into clouds. Drift them with time. Light them with a sun.',                                                                  'Procedural Generation', 'advanced', 36),
('proc-water-waves',     'Procedural water',      'Stack sine waves. Use the slope as a normal. Get specular highlights.',                                                                    'Procedural Generation', 'advanced', 37),
('proc-starfield',       'Procedural starfield',  'Scatter bright points. Add a soft glow. Get a night sky.',                                                                                 'Procedural Generation', 'advanced', 38),
('proc-wood-marble',     'Wood and marble',       'Use turbulence with rings or stripes. Get wood grain. Get marble.',                                                                        'Procedural Generation', 'advanced', 39),
('proc-fire-smoke',      'Fire and smoke',        'Warp fbm upward. Color it with a heat palette. Get flames and rising smoke.',                                                              'Procedural Generation', 'advanced', 40),
-- ===== Family I, Stylization / post-process =====
('posterize-dither',     'Posterize and dither',  'Cut colors into steps. Hide the bands with dither.',                                                                                       'Stylization', 'advanced', 41),
('chromatic-aberration', 'Chromatic aberration',  'Sample red, green, and blue at slightly different spots. Get a lens-fringe look.',                                                         'Stylization', 'advanced', 42),
('bloom-glow',           'Bloom and glow',        'Add a soft halo around bright shapes. Sum the glow if you have many.',                                                                     'Stylization', 'advanced', 43),
('fresnel-edges',        'Fresnel edges',         'Brighten edges based on the view angle. Get rim lights on 3D surfaces.',                                                                   'Stylization', 'advanced', 44),
-- ===== Family J, Iteration & fractals =====
-- (loop-fundamentals lives in Foundations now; this family assumes you know the loop rules.)
('accumulation-loops',   'Accumulation loops',    'Sum or average values across a loop. The pattern behind blur and fbm.',                                                                    'Iteration & Fractals', 'advanced', 45),
('mandelbrot',           'Mandelbrot',            'z = z*z + c, run in a loop. Color by how fast it escapes. The classic fractal.',                                                           'Iteration & Fractals', 'advanced', 46),
('julia-sets',           'Julia sets',            'Same loop as Mandelbrot, but c is fixed. Each c gives a different shape.',                                                                  'Iteration & Fractals', 'advanced', 47),
('orbit-traps',          'Orbit traps',           'Color a fractal by the closest approach to a shape. Like a point, a line, or a circle.',                                                   'Iteration & Fractals', 'advanced', 48),
('ifs-folding',          'IFS folding',           'Fold space with abs and scale. Get Sierpinski triangles. Get Koch snowflakes.',                                                             'Iteration & Fractals', 'advanced', 49),
('kifs-raymarched',      'KIFS raymarched',       'Fold 3D space in a loop. Raymarch the result. Get mandelbox fractals.',                                                                    'Iteration & Fractals', 'advanced', 50);
