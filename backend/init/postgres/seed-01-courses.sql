\c shader_dojo;

-- 50 technique-aligned courses across 10 families (A-J).
-- See plan: rebuild ShaderDojo curriculum (May 2026).

INSERT INTO course (slug, title, description, category, difficulty, display_order) VALUES
-- ===== Family A — Foundations =====
('uv-coordinates',      'UV coordinates',       'Normalize, center, and aspect-correct fragment coordinates. The setup every other course assumes.', 'Foundations', 'beginner', 0),
('time-oscillation',    'Time & oscillation',   'Drive periodic signals with u_time. Sine, cosine, phase-offset, frequency.',                       'Foundations', 'beginner', 1),
('step-smoothstep',     'Step & smoothstep',    'Hard and soft thresholds. The two functions that draw every clean edge.',                          'Foundations', 'beginner', 2),
('mix-gradients',       'Mix & gradients',      'Linear color blending. Two-color, three-stop, radial.',                                            'Foundations', 'beginner', 3),
('plotting-curves',     'Plotting curves',      'Visualize 1D y=f(x) functions inside a 2D canvas.',                                                'Foundations', 'beginner', 4),
('loop-fundamentals',   'Loops & accumulators', 'Constant-bound for, break, and per-pixel reductions under the GLSL ES 1.0 rules. Pre-requisite for every later family that walks data.', 'Foundations', 'beginner', 5),
-- ===== Family B — Color =====
('hsv-color',           'HSV color',            'Cycle hue, saturation, and value. The first non-RGB color space.',                                 'Color',       'beginner', 5),
('cosine-palettes',     'Cosine palettes',      'Inigo Quilez''s a + b·cos(2π(c·t + d)) — four vectors, infinite palettes.',                        'Color',       'beginner', 6),
('tone-vignette-gamma', 'Tone, vignette, gamma','Final-pass color shaping: gamma correct, vignette, Reinhard, ACES.',                               'Color',       'intermediate', 7),
-- ===== Family C — 2D distance fields =====
('sdf-2d-primitives',   '2D SDF primitives',    'Circle, box, segment. Distance fields as the universal shape language.',                           '2D Distance Fields', 'intermediate', 8),
('sdf-booleans',        'SDF booleans',         'Combine SDFs with min, max, and subtraction. Build compound shapes.',                              '2D Distance Fields', 'intermediate', 9),
('smooth-min',          'Smooth min',           'Polynomial smin. Replace the kink of min() with a controllable blend.',                            '2D Distance Fields', 'intermediate', 10),
('sdf-antialiasing',    'SDF anti-aliasing',    'Clean edges via smoothstep and fwidth — pixel-perfect outlines without jaggies.',                  '2D Distance Fields', 'intermediate', 11),
-- ===== Family D — Space transforms =====
('rotations-2d',        '2D rotations',         'mat2 rotation. Around origin, around a pivot, composed with scale.',                               'Space',       'intermediate', 12),
('polar-coordinates',   'Polar coordinates',    '(r, θ) patterns. Radial gradients, angular wedges, rose curves, spirals.',                         'Space',       'intermediate', 13),
('tiling-repetition',   'Tiling & repetition',  'fract, mod, floor — turn one cell into a grid.',                                                   'Space',       'intermediate', 14),
('kaleidoscope-mirror', 'Kaleidoscope & mirror','Reflective symmetry via abs() and polar folds.',                                                   'Space',       'intermediate', 15),
-- ===== Family E — Noise =====
('hash-random',         'Hash random',          'Deterministic per-pixel and per-cell pseudo-randomness from a position.',                          'Noise',       'intermediate', 16),
('value-noise',         'Value noise',          'Smoothly interpolated lattice noise — the simplest organic field.',                                'Noise',       'intermediate', 17),
('gradient-noise',      'Gradient noise',       'Perlin-style gradient noise. Smoother than value noise, free derivatives.',                        'Noise',       'intermediate', 18),
('voronoi',             'Voronoi',              'Cellular F1 distance. Cells, borders, animated centers.',                                          'Noise',       'intermediate', 19),
('fbm',                 'fBM (octaves)',        'Stack noise at doubling frequencies and halving amplitudes.',                                      'Noise',       'intermediate', 20),
('domain-warping',      'Domain warping',       'Distort the UV before sampling. The trick that makes noise feel alive.',                           'Noise',       'intermediate', 21),
-- ===== Family F — Image sampling =====
('image-sampling',      'Image sampling',       'texture2D and UV transforms. The bundled u_image is your test bench.',                             'Image',       'intermediate', 22),
('convolution-kernels', 'Convolution kernels',  'Sample neighbors to blur, sharpen, and detect edges.',                                             'Image',       'intermediate', 23),
-- ===== Family G — Raymarching =====
('ray-pinhole-camera',  'Ray & pinhole camera', 'Build a 3D ray (origin + direction) from a 2D pixel UV.',                                          'Raymarching', 'advanced', 24),
('sdf-3d-primitives',   '3D SDF primitives',    'Sphere, box, plane, torus — the 3D shape vocabulary.',                                             'Raymarching', 'advanced', 25),
('sphere-tracing',      'Sphere tracing',       'The raymarch loop: step by the distance, stop on epsilon.',                                        'Raymarching', 'advanced', 26),
('surface-normals',     'Surface normals',      'Finite-difference normals from any SDF. Lighting starts here.',                                    'Raymarching', 'advanced', 27),
('diffuse-lighting',    'Diffuse lighting',     'Lambertian dot(n, l) + ambient. The first real shading.',                                          'Raymarching', 'advanced', 28),
('soft-shadows',        'Soft shadows',         'Cheap penumbra by accumulating the minimum SDF along a shadow ray.',                               'Raymarching', 'advanced', 29),
('sdf-3d-ops',          '3D SDF ops',           '3D booleans plus domain repetition and axis folding.',                                             'Raymarching', 'advanced', 30),
('sdf-fbm-detail',      'fBM detail on SDFs',   'Add fbm bumps to a 3D SDF to make organic, eroded surfaces.',                                      'Raymarching', 'advanced', 31),
('fog-and-ao',          'Fog & AO',             'Depth fog and cheap ambient occlusion. The final atmospheric layer.',                              'Raymarching', 'advanced', 32),
-- ===== Family H — Procedural generation =====
('proc-terrain',        'Procedural terrain',   'fbm heightfield colored by elevation.',                                                            'Procedural Generation', 'advanced', 33),
('proc-clouds',         'Procedural clouds',    'fbm thresholded and tinted into a soft cloud layer.',                                              'Procedural Generation', 'advanced', 34),
('proc-water-waves',    'Procedural water',     'Sums of sines plus a derived normal for water highlights.',                                       'Procedural Generation', 'advanced', 35),
('proc-starfield',      'Procedural starfield', 'Random points with glow. The space sky.',                                                          'Procedural Generation', 'advanced', 36),
('proc-wood-marble',    'Procedural wood/marble','Turbulence plus concentric rings for natural materials.',                                         'Procedural Generation', 'advanced', 37),
('proc-fire-smoke',     'Procedural fire & smoke','Vertical warped fbm with a heat palette.',                                                        'Procedural Generation', 'advanced', 38),
-- ===== Family I — Stylization / post-process =====
('posterize-dither',    'Posterize & dither',   'Quantize color levels and dither the seams away.',                                                 'Stylization', 'advanced', 39),
('chromatic-aberration','Chromatic aberration', 'Per-channel UV offset for that cheap lens-fringe look.',                                           'Stylization', 'advanced', 40),
('bloom-glow',          'Bloom & glow',         'Distance-based halos around bright shapes.',                                                       'Stylization', 'advanced', 41),
('fresnel-edges',       'Fresnel edges',        'Highlight by view/normal alignment. Rim lights on 3D surfaces.',                                   'Stylization', 'advanced', 42),
-- ===== Family J — Iteration & fractals =====
-- (loop-fundamentals lives in Foundations now; this family assumes you know the loop rules.)
('accumulation-loops',  'Accumulation loops',   'Sums and averages over iterations. The pattern behind fbm and blur.',                              'Iteration & Fractals', 'advanced', 44),
('mandelbrot',          'Mandelbrot',           'z = z² + c, escape time, smooth iteration count.',                                                 'Iteration & Fractals', 'advanced', 45),
('julia-sets',          'Julia sets',           'Same iteration, different parameter — a family of cousins.',                                       'Iteration & Fractals', 'advanced', 46),
('orbit-traps',         'Orbit traps',          'Color iterative fractals by the closest approach to a chosen shape.',                              'Iteration & Fractals', 'advanced', 47),
('ifs-folding',         'IFS folding',          'abs + offset + scale folds. Sierpinski, Koch, and beyond.',                                        'Iteration & Fractals', 'advanced', 48),
('kifs-raymarched',     'KIFS raymarched',      'Kaleidoscopic IFS in 3D — mandelbox-style folds rendered by sphere tracing.',                      'Iteration & Fractals', 'advanced', 49);
