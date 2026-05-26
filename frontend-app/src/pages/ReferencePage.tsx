import { useEffect, useState } from 'react';

// ────────────────────────────────────────────────────────────────────────────
// Reference page — uniforms, GLSL syntax cheat sheet, and a primer on how
// the editor / validator works. Linked from the header.
// ────────────────────────────────────────────────────────────────────────────

interface Section {
    id: string;
    title: string;
}

const SECTIONS: Section[] = [
    { id: 'how',         title: 'How the app works' },
    { id: 'uniforms',    title: 'Built-in uniforms' },
    { id: 'header',      title: 'The hidden header' },
    { id: 'types',       title: 'Types & swizzles' },
    { id: 'operators',   title: 'Operators' },
    { id: 'control',     title: 'Control flow & loops' },
    { id: 'builtins',    title: 'Built-in functions' },
    { id: 'recipes',     title: 'Recipes you reuse everywhere' },
    { id: 'limits',      title: 'WebGL1 / GLSL ES 1.0 limits' },
];

export function ReferencePage() {
    const [active, setActive] = useState<string>('how');

    // Scroll-spy: pick the section nearest the top.
    useEffect(() => {
        function onScroll() {
            let best = SECTIONS[0].id;
            let bestY = Infinity;
            for (const s of SECTIONS) {
                const el = document.getElementById(s.id);
                if (!el) continue;
                const y = Math.abs(el.getBoundingClientRect().top - 80);
                if (y < bestY) { bestY = y; best = s.id; }
            }
            setActive(best);
        }
        window.addEventListener('scroll', onScroll, { passive: true });
        onScroll();
        return () => window.removeEventListener('scroll', onScroll);
    }, []);

    return (
        <div className="max-w-6xl mx-auto px-4 py-10">
            <header className="mb-8">
                <h1 className="text-3xl md:text-4xl font-semibold tracking-tight">Reference</h1>
                <p className="mt-2 text-ink/70 max-w-prose">
                    Every uniform you can read, every GLSL ES 1.0 trick the lessons assume, and
                    a quick tour of what happens when you press <span className="font-mono bg-cream px-1.5 py-0.5 rounded text-[0.9em]">Verify</span>.
                </p>
            </header>

            <div className="grid lg:grid-cols-[12rem_1fr] gap-10">
                <nav className="hidden lg:block sticky top-20 self-start">
                    <ol className="space-y-1 text-sm">
                        {SECTIONS.map(s => (
                            <li key={s.id}>
                                <a
                                    href={`#${s.id}`}
                                    className={
                                        'block px-2 py-1 rounded transition ' +
                                        (active === s.id
                                            ? 'bg-cream text-ink font-medium'
                                            : 'text-ink/60 hover:text-ink hover:bg-cream/60')
                                    }>
                                    {s.title}
                                </a>
                            </li>
                        ))}
                    </ol>
                </nav>

                <main className="min-w-0 space-y-12">
                    <HowItWorks />
                    <Uniforms />
                    <HiddenHeader />
                    <TypesSwizzles />
                    <Operators />
                    <ControlFlow />
                    <Builtins />
                    <Recipes />
                    <Limits />
                </main>
            </div>
        </div>
    );
}

// ────────────────────────────────────────────────────────────────────────────

function Section({ id, title, children }: { id: string; title: string; children: React.ReactNode }) {
    return (
        <section id={id} className="scroll-mt-24">
            <h2 className="text-xl md:text-2xl font-semibold text-ink mb-3 tracking-tight">{title}</h2>
            <div className="space-y-3 text-sm text-ink/80 leading-relaxed">{children}</div>
        </section>
    );
}

function Code({ children, block = false }: { children: React.ReactNode; block?: boolean }) {
    if (block) {
        return (
            <pre className="bg-cream border border-muted/20 rounded-md p-3 overflow-x-auto text-[12.5px] leading-relaxed font-mono my-3">
                {children}
            </pre>
        );
    }
    return <code className="px-1 py-0.5 rounded bg-cream font-mono text-[0.9em]">{children}</code>;
}

// ────────────────────────────────────────────────────────────────────────────
// Sections
// ────────────────────────────────────────────────────────────────────────────

function HowItWorks() {
    return (
        <Section id="how" title="How the app works">
            <p>
                Every lesson is one fragment shader. You write the body of <Code>void main()</Code>;
                ShaderDojo wraps it with a precision declaration and a few uniform declarations
                (see <a className="text-accent hover:underline" href="#header">The hidden header</a>) and ships it to the GPU.
            </p>
            <p>The editor runs your shader live in the canvas on the right. Every change recompiles immediately — there is no "build" step.</p>
            <p className="font-medium text-ink">When you press Verify:</p>
            <ol className="list-decimal pl-6 space-y-1.5">
                <li>The frontend sends your fragment-shader body to the validator.</li>
                <li>The validator renders your shader and the canonical shader at a fixed resolution, with a fixed <Code>u_time</Code> sequence, into offscreen buffers.</li>
                <li>It hashes the rendered pixel grids and compares hashes. If they match, the lesson passes — the visual output is byte-identical to the canonical.</li>
            </ol>
            <p>
                That means <em>any</em> shader that produces the same pixels counts. Stylistic differences are fine; only the visible output matters.
            </p>
        </Section>
    );
}

function Uniforms() {
    return (
        <Section id="uniforms" title="Built-in uniforms">
            <p>These are declared for you. Use them directly — never re-declare them.</p>
            <div className="overflow-x-auto">
                <table className="w-full text-left border border-muted/20 rounded-md overflow-hidden text-sm">
                    <thead className="bg-cream/60">
                        <tr>
                            <th className="px-3 py-2 font-semibold">Name</th>
                            <th className="px-3 py-2 font-semibold">Type</th>
                            <th className="px-3 py-2 font-semibold">Meaning</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-muted/15">
                        <tr>
                            <td className="px-3 py-2 font-mono">u_resolution</td>
                            <td className="px-3 py-2 font-mono text-ink/70">vec2</td>
                            <td className="px-3 py-2">Canvas size in pixels. <Code>u_resolution.x</Code> is width, <Code>u_resolution.y</Code> is height.</td>
                        </tr>
                        <tr>
                            <td className="px-3 py-2 font-mono">u_time</td>
                            <td className="px-3 py-2 font-mono text-ink/70">float</td>
                            <td className="px-3 py-2">Seconds since the shader started. Drives every animation.</td>
                        </tr>
                        <tr>
                            <td className="px-3 py-2 font-mono">u_image</td>
                            <td className="px-3 py-2 font-mono text-ink/70">sampler2D</td>
                            <td className="px-3 py-2">Bundled test texture for the image-sampling lessons. Sample with <Code>texture2D(u_image, uv)</Code>.</td>
                        </tr>
                        <tr>
                            <td className="px-3 py-2 font-mono">u_image_resolution</td>
                            <td className="px-3 py-2 font-mono text-ink/70">vec2</td>
                            <td className="px-3 py-2">Width and height of <Code>u_image</Code> in pixels — useful for convolution kernels.</td>
                        </tr>
                        <tr>
                            <td className="px-3 py-2 font-mono">gl_FragCoord</td>
                            <td className="px-3 py-2 font-mono text-ink/70">vec4</td>
                            <td className="px-3 py-2">Provided by the language. <Code>gl_FragCoord.xy</Code> is the pixel''s screen position, lower-left origin.</td>
                        </tr>
                        <tr>
                            <td className="px-3 py-2 font-mono">gl_FragColor</td>
                            <td className="px-3 py-2 font-mono text-ink/70">vec4</td>
                            <td className="px-3 py-2">The output of your shader. Assign <Code>vec4(r, g, b, a)</Code> in <Code>main</Code>.</td>
                        </tr>
                    </tbody>
                </table>
            </div>
            <p className="text-ink/60">
                There is intentionally no <Code>u_mouse</Code>. Lessons should look identical across browsers, sessions, and re-renders — so we don''t feed any input that varies.
            </p>
        </Section>
    );
}

function HiddenHeader() {
    return (
        <Section id="header" title="The hidden header">
            <p>Before your code reaches the GPU, the app prepends this header — byte-for-byte identical to what the validator uses, so your local preview matches Verify exactly:</p>
            <Code block>{`precision mediump float;
uniform vec2 u_resolution;
uniform float u_time;
uniform sampler2D u_image;
uniform vec2 u_image_resolution;`}</Code>
            <p>That''s why you can read those uniforms without declaring them. You also don''t need (and shouldn''t add) a precision declaration of your own.</p>
            <p>The vertex shader is a fixed full-screen quad — every lesson''s fragment shader runs once per pixel.</p>
        </Section>
    );
}

function TypesSwizzles() {
    return (
        <Section id="types" title="Types & swizzles">
            <h3 className="text-base font-semibold text-ink mt-4">The scalar and vector types</h3>
            <ul className="list-disc pl-6 space-y-1">
                <li><Code>float</Code> — always write a decimal point: <Code>1.0</Code>, not <Code>1</Code>. Integer literals are a different type.</li>
                <li><Code>int</Code>, <Code>bool</Code> — used for loop counters and flags.</li>
                <li><Code>vec2</Code>, <Code>vec3</Code>, <Code>vec4</Code> — fixed-size float vectors. Construct with <Code>vec3(1.0)</Code> (all components 1), <Code>vec3(r, g, b)</Code>, or by extending: <Code>vec4(rgb, 1.0)</Code>.</li>
                <li><Code>mat2</Code>, <Code>mat3</Code>, <Code>mat4</Code> — square matrices. Constructed in column-major order: <Code>mat2(col0.x, col0.y, col1.x, col1.y)</Code>.</li>
            </ul>

            <h3 className="text-base font-semibold text-ink mt-4">Swizzles</h3>
            <p>Any vector lets you address its components with letter combinations. The letters come in three interchangeable groups (use one group per swizzle):</p>
            <ul className="list-disc pl-6 space-y-1">
                <li>Position: <Code>.x .y .z .w</Code></li>
                <li>Color: <Code>.r .g .b .a</Code></li>
                <li>Texture: <Code>.s .t .p .q</Code></li>
            </ul>
            <p>Mix and reorder freely:</p>
            <Code block>{`vec4 c = vec4(0.1, 0.2, 0.3, 1.0);
c.rg          // vec2(0.1, 0.2)
c.bgr         // vec3(0.3, 0.2, 0.1)   — reversed
c.xxxx        // vec4(0.1)             — broadcast
vec4 d = c.bgra;                       // swap r and b`}</Code>
            <p>Swizzles also work on the left side for assignment: <Code>p.xy = vec2(0.0)</Code> zeros out the first two components.</p>
        </Section>
    );
}

function Operators() {
    return (
        <Section id="operators" title="Operators">
            <p>Arithmetic operators (<Code>+</Code>, <Code>-</Code>, <Code>*</Code>, <Code>/</Code>) work component-wise on vectors:</p>
            <Code block>{`vec3 a = vec3(1.0, 2.0, 3.0);
vec3 b = vec3(0.1, 0.2, 0.3);
a + b                 // (1.1, 2.2, 3.3)
a * 2.0               // (2.0, 4.0, 6.0)
a * b                 // (0.1, 0.4, 0.9)`}</Code>
            <p>
                <Code>mat * vec</Code> is matrix-vector multiplication (not component-wise). Comparisons (<Code>&lt;</Code>, <Code>&gt;</Code>, etc.) only work on scalars; for vector comparisons use <Code>lessThan</Code>, <Code>greaterThan</Code>, etc.
            </p>
            <p>The ternary <Code>cond ? a : b</Code> exists and works fine, but both branches must have the same type. The lessons use it freely.</p>
        </Section>
    );
}

function ControlFlow() {
    return (
        <Section id="control" title="Control flow & loops">
            <p><Code>if</Code> / <Code>else</Code> work as you''d expect.</p>
            <p className="font-medium text-ink">The big GLSL ES 1.0 loop rule:</p>
            <p>The loop bound has to be a constant the compiler can see at compile time. The standard form:</p>
            <Code block>{`for (int i = 0; i < 16; i++) {
    // do something with i
}`}</Code>
            <p>Things that <em>do</em> work inside:</p>
            <ul className="list-disc pl-6 space-y-1">
                <li><Code>break</Code> to exit early.</li>
                <li><Code>continue</Code> to skip the rest of an iteration.</li>
                <li><Code>if (cond) break;</Code> to stop on a per-pixel condition — used everywhere in raymarching and fractals.</li>
            </ul>
            <p>Things that <em>don''t</em> work:</p>
            <ul className="list-disc pl-6 space-y-1">
                <li>Variable bounds: <Code>for (int i = 0; i &lt; n; i++)</Code> where <Code>n</Code> is a uniform.</li>
                <li>While loops with a non-constant condition.</li>
            </ul>
            <p>If you need "up to N steps but maybe fewer," combine a constant bound with <Code>break</Code>.</p>
        </Section>
    );
}

function Builtins() {
    return (
        <Section id="builtins" title="Built-in functions">
            <p>The shortlist that covers nearly every lesson:</p>
            <div className="grid md:grid-cols-2 gap-3">
                <BuiltinGroup
                    title="Math"
                    items={[
                        ['abs(x)', 'absolute value'],
                        ['sign(x)', '-1, 0, or +1'],
                        ['floor(x)', 'round down'],
                        ['fract(x)', 'x - floor(x); always in [0, 1)'],
                        ['mod(x, y)', 'x - y * floor(x / y)'],
                        ['clamp(x, lo, hi)', 'pin to range'],
                        ['min(a, b)', 'smaller'],
                        ['max(a, b)', 'larger'],
                        ['pow(x, y)', 'x to the y'],
                        ['exp(x)', 'e^x'],
                        ['log(x)', 'natural log'],
                        ['sqrt(x)', 'square root'],
                    ]}
                />
                <BuiltinGroup
                    title="Trig"
                    items={[
                        ['sin(x)', 'sine'],
                        ['cos(x)', 'cosine'],
                        ['tan(x)', 'tangent'],
                        ['atan(y, x)', 'arc-tangent of y/x with quadrant'],
                        ['radians(deg)', 'degrees to radians'],
                    ]}
                />
                <BuiltinGroup
                    title="Mixing"
                    items={[
                        ['mix(a, b, t)', 'linear interpolation a*(1-t) + b*t'],
                        ['step(edge, x)', '0 if x<edge else 1'],
                        ['smoothstep(a, b, x)', 'smooth 0→1 ramp on [a, b]'],
                    ]}
                />
                <BuiltinGroup
                    title="Vector"
                    items={[
                        ['length(v)', 'Euclidean length'],
                        ['distance(a, b)', 'length(a - b)'],
                        ['dot(a, b)', 'sum of component-wise products'],
                        ['cross(a, b)', '3D cross product'],
                        ['normalize(v)', 'unit-length version of v'],
                        ['reflect(I, N)', 'reflection across normal N'],
                    ]}
                />
                <BuiltinGroup
                    title="Derivatives"
                    items={[
                        ['fwidth(x)', 'sum of |derivatives| across one pixel'],
                        ['dFdx(x)', 'derivative along screen x'],
                        ['dFdy(x)', 'derivative along screen y'],
                    ]}
                />
                <BuiltinGroup
                    title="Texture"
                    items={[
                        ['texture2D(tex, uv)', 'sample a texture at uv'],
                    ]}
                />
            </div>
        </Section>
    );
}

function BuiltinGroup({ title, items }: { title: string; items: [string, string][] }) {
    return (
        <div className="border border-muted/20 rounded-md overflow-hidden">
            <div className="bg-cream/60 px-3 py-1.5 text-xs font-semibold text-ink/70 uppercase tracking-wider">
                {title}
            </div>
            <ul className="divide-y divide-muted/10 text-[13px]">
                {items.map(([name, desc]) => (
                    <li key={name} className="px-3 py-1.5 grid grid-cols-[10rem_1fr] gap-3 items-baseline">
                        <span className="font-mono text-ink">{name}</span>
                        <span className="text-ink/65">{desc}</span>
                    </li>
                ))}
            </ul>
        </div>
    );
}

function Recipes() {
    return (
        <Section id="recipes" title="Recipes you reuse everywhere">
            <h3 className="text-base font-semibold text-ink mt-4">Aspect-corrected centered UV</h3>
            <p>Every shape lesson opens with this. Both axes use <Code>u_resolution.y</Code> so the unit is "one screen-height" regardless of aspect:</p>
            <Code block>{`vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;`}</Code>

            <h3 className="text-base font-semibold text-ink mt-4">0..1 oscillator from time</h3>
            <Code block>{`float t = 0.5 + 0.5 * sin(u_time);   // breathes 0..1..0
// or with offset:
float t = 0.5 + 0.5 * sin(u_time * 0.3 + 1.7);`}</Code>

            <h3 className="text-base font-semibold text-ink mt-4">Hash a vec2 to pseudo-random</h3>
            <Code block>{`float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}`}</Code>

            <h3 className="text-base font-semibold text-ink mt-4">SDF fill + outline</h3>
            <Code block>{`float d = ...;                               // SDF
float w = fwidth(d);                         // 1-pixel width
float fill   = smoothstep(w, -w, d);         // 1 inside
float stroke = smoothstep(w, -w, abs(d) - 0.01);
float mask   = max(fill, stroke);`}</Code>

            <h3 className="text-base font-semibold text-ink mt-4">2D rotation matrix</h3>
            <Code block>{`float c = cos(a), s = sin(a);
p = mat2(c, -s, s, c) * p;`}</Code>

            <h3 className="text-base font-semibold text-ink mt-4">Cosine palette (IQ)</h3>
            <Code block>{`vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
    return a + b * cos(6.28318 * (c * t + d));
}
// classic rainbow: vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.00, 0.33, 0.67)`}</Code>
        </Section>
    );
}

function Limits() {
    return (
        <Section id="limits" title="WebGL1 / GLSL ES 1.0 limits">
            <p>The whole curriculum targets WebGL1 (GLSL ES 1.0) — the broadest-compatible browser target.</p>
            <ul className="list-disc pl-6 space-y-1">
                <li>Loop bounds must be compile-time constants. Use <Code>break</Code> for early exit.</li>
                <li>Array indices must also be constant — no <Code>arr[i]</Code> where <Code>i</Code> varies at runtime (except as a loop counter in some drivers).</li>
                <li>No integer division. <Code>1/2</Code> in floats is <Code>0.5</Code>; in ints it''s 0.</li>
                <li>No <Code>#version 300 es</Code>, no <Code>in/out</Code> qualifiers (use <Code>attribute</Code> / <Code>varying</Code> in vertex shaders; you''re only writing fragment shaders).</li>
                <li>No <Code>textureSize</Code>. We expose <Code>u_image_resolution</Code> for that.</li>
                <li>Precision must be declared. The header sets it to <Code>mediump</Code> for you.</li>
            </ul>
            <p>If your shader compiles in the editor, it will also compile in the validator — they share the same header.</p>
        </Section>
    );
}

