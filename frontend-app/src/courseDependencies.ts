// Course prerequisite graph for the home-page roadmap.
//
// Keys are course slugs (must match `course.slug` in the DB). Values are the
// list of slugs the course actually builds on -- not "lives in the same
// family" but "you really need to have learned this first".
//
// Edit liberally. The graph drives the home-page roadmap; reactflow + dagre
// auto-lay it out, so adding or removing edges does not require any other
// changes.

export const COURSE_PREREQUISITES: Record<string, string[]> = {
    // Orientation -- the root.
    'glsl-environment':     [],

    // Foundations.
    'uv-coordinates':       ['glsl-environment'],
    'time-oscillation':     ['uv-coordinates'],
    'step-smoothstep':      ['uv-coordinates'],
    'mix-gradients':        ['uv-coordinates'],
    'plotting-curves':      ['step-smoothstep', 'mix-gradients'],
    'loop-fundamentals':    ['uv-coordinates'],

    // Color.
    'hsv-color':            ['mix-gradients'],
    'cosine-palettes':      ['time-oscillation', 'mix-gradients'],
    'tone-vignette-gamma':  ['mix-gradients'],

    // 2D distance fields.
    'sdf-2d-primitives':    ['uv-coordinates'],
    'sdf-booleans':         ['sdf-2d-primitives'],
    'smooth-min':           ['sdf-booleans'],
    'sdf-antialiasing':     ['sdf-2d-primitives', 'step-smoothstep'],

    // Space transforms.
    'rotations-2d':         ['uv-coordinates'],
    'polar-coordinates':    ['uv-coordinates'],
    'tiling-repetition':    ['uv-coordinates'],
    'kaleidoscope-mirror':  ['polar-coordinates', 'rotations-2d'],

    // Noise.
    'hash-random':          ['uv-coordinates'],
    'value-noise':          ['hash-random'],
    'gradient-noise':       ['hash-random'],
    'voronoi':              ['hash-random'],
    'fbm':                  ['value-noise', 'loop-fundamentals'],
    'domain-warping':       ['fbm'],

    // Image sampling.
    'image-sampling':       ['uv-coordinates'],
    'convolution-kernels':  ['image-sampling'],

    // Raymarching.
    'ray-pinhole-camera':   ['uv-coordinates'],
    'sdf-3d-primitives':    ['sdf-2d-primitives'],
    'sphere-tracing':       ['ray-pinhole-camera', 'sdf-3d-primitives', 'loop-fundamentals'],
    'surface-normals':      ['sphere-tracing'],
    'diffuse-lighting':     ['surface-normals'],
    'soft-shadows':         ['diffuse-lighting'],
    'sdf-3d-ops':           ['sdf-3d-primitives', 'sdf-booleans'],
    'sdf-fbm-detail':       ['sphere-tracing', 'fbm'],
    'fog-and-ao':           ['diffuse-lighting'],

    // Procedural generation -- explicit recombinations of earlier families.
    'proc-terrain':         ['fbm', 'cosine-palettes'],
    'proc-clouds':          ['fbm', 'mix-gradients'],
    'proc-water-waves':     ['time-oscillation', 'surface-normals'],
    'proc-starfield':       ['hash-random', 'voronoi'],
    'proc-wood-marble':     ['fbm', 'domain-warping'],
    'proc-fire-smoke':      ['domain-warping', 'cosine-palettes'],

    // Stylization / post-process.
    'posterize-dither':     ['step-smoothstep', 'hash-random'],
    'chromatic-aberration': ['image-sampling'],
    'bloom-glow':           ['sdf-2d-primitives', 'mix-gradients'],
    'fresnel-edges':        ['surface-normals', 'diffuse-lighting'],

    // Iteration & fractals.
    'accumulation-loops':   ['loop-fundamentals', 'fbm'],
    'mandelbrot':           ['loop-fundamentals'],
    'julia-sets':           ['mandelbrot'],
    'orbit-traps':          ['mandelbrot'],
    'ifs-folding':          ['loop-fundamentals', 'kaleidoscope-mirror'],
    'kifs-raymarched':      ['ifs-folding', 'sphere-tracing'],
};
