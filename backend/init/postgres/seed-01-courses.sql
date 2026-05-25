\c shader_dojo;

-- 50 technique-aligned courses across 10 families (A-J).
-- See plan: rebuild ShaderDojo curriculum (May 2026).

INSERT INTO course (id, slug, title, description, category, difficulty, display_order) VALUES
-- ===== Family A — Foundations =====
('c0000001-0000-0000-0000-000000000000', 'uv-coordinates',      'UV coordinates',       'Normalize, center, and aspect-correct fragment coordinates. The setup every other course assumes.', 'Foundations', 'beginner', 0),
('c0000002-0000-0000-0000-000000000000', 'time-oscillation',    'Time & oscillation',   'Drive periodic signals with u_time. Sine, cosine, phase-offset, frequency.',                       'Foundations', 'beginner', 1),
('c0000003-0000-0000-0000-000000000000', 'step-smoothstep',     'Step & smoothstep',    'Hard and soft thresholds. The two functions that draw every clean edge.',                          'Foundations', 'beginner', 2),
('c0000004-0000-0000-0000-000000000000', 'mix-gradients',       'Mix & gradients',      'Linear color blending. Two-color, three-stop, radial.',                                            'Foundations', 'beginner', 3),
('c0000005-0000-0000-0000-000000000000', 'plotting-curves',     'Plotting curves',      'Visualize 1D y=f(x) functions inside a 2D canvas.',                                                'Foundations', 'beginner', 4),
-- ===== Family B — Color =====
('c0000006-0000-0000-0000-000000000000', 'hsv-color',           'HSV color',            'Cycle hue, saturation, and value. The first non-RGB color space.',                                 'Color',       'beginner', 5),
('c0000007-0000-0000-0000-000000000000', 'cosine-palettes',     'Cosine palettes',      'Inigo Quilez''s a + b·cos(2π(c·t + d)) — four vectors, infinite palettes.',                        'Color',       'beginner', 6),
('c0000008-0000-0000-0000-000000000000', 'tone-vignette-gamma', 'Tone, vignette, gamma','Final-pass color shaping: gamma correct, vignette, Reinhard, ACES.',                               'Color',       'intermediate', 7),
-- ===== Family C — 2D distance fields =====
('c0000009-0000-0000-0000-000000000000', 'sdf-2d-primitives',   '2D SDF primitives',    'Circle, box, segment. Distance fields as the universal shape language.',                           '2D Distance Fields', 'intermediate', 8),
('c0000010-0000-0000-0000-000000000000', 'sdf-booleans',        'SDF booleans',         'Combine SDFs with min, max, and subtraction. Build compound shapes.',                              '2D Distance Fields', 'intermediate', 9),
('c0000011-0000-0000-0000-000000000000', 'smooth-min',          'Smooth min',           'Polynomial smin. Replace the kink of min() with a controllable blend.',                            '2D Distance Fields', 'intermediate', 10),
('c0000012-0000-0000-0000-000000000000', 'sdf-antialiasing',    'SDF anti-aliasing',    'Clean edges via smoothstep and fwidth — pixel-perfect outlines without jaggies.',                  '2D Distance Fields', 'intermediate', 11),
-- ===== Family D — Space transforms =====
('c0000013-0000-0000-0000-000000000000', 'rotations-2d',        '2D rotations',         'mat2 rotation. Around origin, around a pivot, composed with scale.',                               'Space',       'intermediate', 12),
('c0000014-0000-0000-0000-000000000000', 'polar-coordinates',   'Polar coordinates',    '(r, θ) patterns. Radial gradients, angular wedges, rose curves, spirals.',                         'Space',       'intermediate', 13),
('c0000015-0000-0000-0000-000000000000', 'tiling-repetition',   'Tiling & repetition',  'fract, mod, floor — turn one cell into a grid.',                                                   'Space',       'intermediate', 14),
('c0000016-0000-0000-0000-000000000000', 'kaleidoscope-mirror', 'Kaleidoscope & mirror','Reflective symmetry via abs() and polar folds.',                                                   'Space',       'intermediate', 15),
-- ===== Family E — Noise =====
('c0000017-0000-0000-0000-000000000000', 'hash-random',         'Hash random',          'Deterministic per-pixel and per-cell pseudo-randomness from a position.',                          'Noise',       'intermediate', 16),
('c0000018-0000-0000-0000-000000000000', 'value-noise',         'Value noise',          'Smoothly interpolated lattice noise — the simplest organic field.',                                'Noise',       'intermediate', 17),
('c0000019-0000-0000-0000-000000000000', 'gradient-noise',      'Gradient noise',       'Perlin-style gradient noise. Smoother than value noise, free derivatives.',                        'Noise',       'intermediate', 18),
('c0000020-0000-0000-0000-000000000000', 'voronoi',             'Voronoi',              'Cellular F1 distance. Cells, borders, animated centers.',                                          'Noise',       'intermediate', 19),
('c0000021-0000-0000-0000-000000000000', 'fbm',                 'fBM (octaves)',        'Stack noise at doubling frequencies and halving amplitudes.',                                      'Noise',       'intermediate', 20),
('c0000022-0000-0000-0000-000000000000', 'domain-warping',      'Domain warping',       'Distort the UV before sampling. The trick that makes noise feel alive.',                           'Noise',       'intermediate', 21),
-- ===== Family F — Image sampling =====
('c0000023-0000-0000-0000-000000000000', 'image-sampling',      'Image sampling',       'texture2D and UV transforms. The bundled u_image is your test bench.',                             'Image',       'intermediate', 22),
('c0000024-0000-0000-0000-000000000000', 'convolution-kernels', 'Convolution kernels',  'Sample neighbors to blur, sharpen, and detect edges.',                                             'Image',       'intermediate', 23),
-- ===== Family G — Raymarching =====
('c0000025-0000-0000-0000-000000000000', 'ray-pinhole-camera',  'Ray & pinhole camera', 'Build a 3D ray (origin + direction) from a 2D pixel UV.',                                          'Raymarching', 'advanced', 24),
('c0000026-0000-0000-0000-000000000000', 'sdf-3d-primitives',   '3D SDF primitives',    'Sphere, box, plane, torus — the 3D shape vocabulary.',                                             'Raymarching', 'advanced', 25),
('c0000027-0000-0000-0000-000000000000', 'sphere-tracing',      'Sphere tracing',       'The raymarch loop: step by the distance, stop on epsilon.',                                        'Raymarching', 'advanced', 26),
('c0000028-0000-0000-0000-000000000000', 'surface-normals',     'Surface normals',      'Finite-difference normals from any SDF. Lighting starts here.',                                    'Raymarching', 'advanced', 27),
('c0000029-0000-0000-0000-000000000000', 'diffuse-lighting',    'Diffuse lighting',     'Lambertian dot(n, l) + ambient. The first real shading.',                                          'Raymarching', 'advanced', 28),
('c0000030-0000-0000-0000-000000000000', 'soft-shadows',        'Soft shadows',         'Cheap penumbra by accumulating the minimum SDF along a shadow ray.',                               'Raymarching', 'advanced', 29),
('c0000031-0000-0000-0000-000000000000', 'sdf-3d-ops',          '3D SDF ops',           '3D booleans plus domain repetition and axis folding.',                                             'Raymarching', 'advanced', 30),
('c0000032-0000-0000-0000-000000000000', 'sdf-fbm-detail',      'fBM detail on SDFs',   'Add fbm bumps to a 3D SDF to make organic, eroded surfaces.',                                      'Raymarching', 'advanced', 31),
('c0000033-0000-0000-0000-000000000000', 'fog-and-ao',          'Fog & AO',             'Depth fog and cheap ambient occlusion. The final atmospheric layer.',                              'Raymarching', 'advanced', 32),
-- ===== Family H — Procedural generation =====
('c0000034-0000-0000-0000-000000000000', 'proc-terrain',        'Procedural terrain',   'fbm heightfield colored by elevation.',                                                            'Procedural Generation', 'advanced', 33),
('c0000035-0000-0000-0000-000000000000', 'proc-clouds',         'Procedural clouds',    'fbm thresholded and tinted into a soft cloud layer.',                                              'Procedural Generation', 'advanced', 34),
('c0000036-0000-0000-0000-000000000000', 'proc-water-waves',    'Procedural water',     'Sums of sines plus a derived normal for water highlights.',                                       'Procedural Generation', 'advanced', 35),
('c0000037-0000-0000-0000-000000000000', 'proc-starfield',      'Procedural starfield', 'Random points with glow. The space sky.',                                                          'Procedural Generation', 'advanced', 36),
('c0000038-0000-0000-0000-000000000000', 'proc-wood-marble',    'Procedural wood/marble','Turbulence plus concentric rings for natural materials.',                                         'Procedural Generation', 'advanced', 37),
('c0000039-0000-0000-0000-000000000000', 'proc-fire-smoke',     'Procedural fire & smoke','Vertical warped fbm with a heat palette.',                                                        'Procedural Generation', 'advanced', 38),
-- ===== Family I — Stylization / post-process =====
('c0000040-0000-0000-0000-000000000000', 'posterize-dither',    'Posterize & dither',   'Quantize color levels and dither the seams away.',                                                 'Stylization', 'advanced', 39),
('c0000041-0000-0000-0000-000000000000', 'chromatic-aberration','Chromatic aberration', 'Per-channel UV offset for that cheap lens-fringe look.',                                           'Stylization', 'advanced', 40),
('c0000042-0000-0000-0000-000000000000', 'bloom-glow',          'Bloom & glow',         'Distance-based halos around bright shapes.',                                                       'Stylization', 'advanced', 41),
('c0000043-0000-0000-0000-000000000000', 'fresnel-edges',       'Fresnel edges',        'Highlight by view/normal alignment. Rim lights on 3D surfaces.',                                   'Stylization', 'advanced', 42),
-- ===== Family J — Iteration & fractals =====
('c0000044-0000-0000-0000-000000000000', 'loop-fundamentals',   'Loop fundamentals',    'Constant-bound for, break, continue under the GLSL ES 1.0 rules.',                                 'Iteration & Fractals', 'advanced', 43),
('c0000045-0000-0000-0000-000000000000', 'accumulation-loops',  'Accumulation loops',   'Sums and averages over iterations. The pattern behind fbm and blur.',                              'Iteration & Fractals', 'advanced', 44),
('c0000046-0000-0000-0000-000000000000', 'mandelbrot',          'Mandelbrot',           'z = z² + c, escape time, smooth iteration count.',                                                 'Iteration & Fractals', 'advanced', 45),
('c0000047-0000-0000-0000-000000000000', 'julia-sets',          'Julia sets',           'Same iteration, different parameter — a family of cousins.',                                       'Iteration & Fractals', 'advanced', 46),
('c0000048-0000-0000-0000-000000000000', 'orbit-traps',         'Orbit traps',          'Color iterative fractals by the closest approach to a chosen shape.',                              'Iteration & Fractals', 'advanced', 47),
('c0000049-0000-0000-0000-000000000000', 'ifs-folding',         'IFS folding',          'abs + offset + scale folds. Sierpinski, Koch, and beyond.',                                        'Iteration & Fractals', 'advanced', 48),
('c0000050-0000-0000-0000-000000000000', 'kifs-raymarched',     'KIFS raymarched',      'Kaleidoscopic IFS in 3D — mandelbox-style folds rendered by sphere tracing.',                      'Iteration & Fractals', 'advanced', 49);
