import { useEffect, useMemo, useState } from 'react';
import { Link } from 'react-router-dom';
import { ShaderCanvas } from '../components/ShaderCanvas';
import { ProgressBar } from '../components/ProgressBar';
import { coursesApi, type Course, type Difficulty } from '../api';
import { useCompletedLessons } from '../completion';

const HERO_SHADER = `// Original shader by Danilo Guanabara
void main() {
  vec3 c;
  float l, z = u_time;
  vec2 fragCoord = gl_FragCoord.xy;
  for (int i = 0; i < 3; i++) {
    vec2 uv, p = fragCoord / u_resolution.xy;
    uv = p;
    p -= 0.5;
    p.x *= u_resolution.x / u_resolution.y;
    z += 0.07;
    l = length(p);
    uv += p / l * (sin(z) + 1.0) * abs(sin(l * 9.0 - z - z));
    c[i] = 0.01 / length(mod(uv, 1.0) - 0.5);
  }
  gl_FragColor = vec4(c / l, 1.0);
}`;

export function HomePage() {
    return (
        <div className="max-w-6xl mx-auto px-4 py-12">
            <section className="grid lg:grid-cols-2 gap-10 items-center">
                <div>
                    <h1 className="text-4xl md:text-5xl font-semibold leading-tight tracking-tight text-ink">
                        Deconstruct & transform GPU code.
                    </h1>
                    <p className="mt-4 text-lg text-ink/70 max-w-prose">
                        ShaderDojo is a mix between{' '}
                        <a className="text-accent font-medium hover:underline" href="https://shadertoy.com/" target="_blank" rel="noreferrer">
                            ShaderToy
                        </a>{' '}and{' '}
                        <a className="text-accent font-medium hover:underline" href="https://www.freecodecamp.org/" target="_blank" rel="noreferrer">
                            freeCodeCamp
                        </a>. Take on shader challenges and bend light and math toward precise creative goals.
                    </p>
                    <div className="mt-6 flex gap-3">
                        <Link to="/courses" className="btn-primary">Start learning</Link>
                        <a className="btn-secondary" href="https://thebookofshaders.com/" target="_blank" rel="noreferrer">
                            The Book of Shaders
                        </a>
                    </div>
                </div>
                <div className="aspect-square w-full rounded-xl overflow-hidden border border-muted/30 bg-black shadow-sm">
                    <ShaderCanvas initialBody={HERO_SHADER} />
                </div>
            </section>

            <section className="mt-20 grid md:grid-cols-3 gap-4">
                <FeatureCard title="Write, run, verify">
                    Each lesson runs your GLSL in the browser and compares the rendered pixels
                    against the expected output.
                </FeatureCard>
                <FeatureCard title="One concept per step">
                    Lessons stay short on purpose: uniforms, shaping functions, distance fields,
                    noise — one at a time.
                </FeatureCard>
                <FeatureCard title="Build something you keep">
                    Courses are sequential. Finish one and you have a portfolio-grade shader, not
                    just a stack of one-offs.
                </FeatureCard>
            </section>

            <section className="mt-20">
                <header className="mb-6">
                    <h2 className="text-2xl md:text-3xl font-semibold tracking-tight">The roadmap</h2>
                    <p className="mt-1 text-ink/60 text-sm max-w-prose">
                        Ten families of named techniques, each one a weapon for the arsenal.
                        Pick any branch — once the foundations are in hand, the rest can be
                        learned out of order.
                    </p>
                </header>
                <Roadmap />
            </section>
        </div>
    );
}

function FeatureCard({ title, children }: { title: string; children: React.ReactNode }) {
    return (
        <div className="card">
            <h3 className="text-base font-semibold mb-2">{title}</h3>
            <p className="text-sm text-ink/70 leading-relaxed">{children}</p>
        </div>
    );
}

// ───────────────────────────────────────────────────────────────────────────
// Roadmap
// ───────────────────────────────────────────────────────────────────────────

function Roadmap() {
    const [courses, setCourses] = useState<Course[] | null>(null);
    const [error, setError] = useState<string | null>(null);
    const completed = useCompletedLessons();

    useEffect(() => {
        coursesApi.list()
            .then(setCourses)
            .catch((e: any) => setError(e?.message ?? 'Failed to load roadmap'));
    }, []);

    const grouped = useMemo(() => {
        if (!courses) return null;
        const map = new Map<string, Course[]>();
        for (const c of courses) {
            const cat = c.category || 'Other';
            if (!map.has(cat)) map.set(cat, []);
            map.get(cat)!.push(c);
        }
        for (const list of map.values()) {
            list.sort((a, b) => a.displayOrder - b.displayOrder);
        }
        return [...map.entries()].sort(
            ([, a], [, b]) => a[0].displayOrder - b[0].displayOrder,
        );
    }, [courses]);

    const [expanded, setExpanded] = useState<Set<string>>(() => {
        try {
            const raw = localStorage.getItem('home.roadmapExpanded');
            // Default: first family open. Stored as JSON array of category names.
            if (raw) return new Set(JSON.parse(raw));
        } catch { /* ignore */ }
        return new Set<string>();
    });
    function toggle(category: string) {
        setExpanded(prev => {
            const next = new Set(prev);
            if (next.has(category)) next.delete(category); else next.add(category);
            try { localStorage.setItem('home.roadmapExpanded', JSON.stringify([...next])); }
            catch { /* ignore */ }
            return next;
        });
    }

    // Default to the first family expanded on first render (when nothing is stored).
    useEffect(() => {
        if (!grouped || grouped.length === 0) return;
        if (expanded.size === 0 && localStorage.getItem('home.roadmapExpanded') === null) {
            setExpanded(new Set([grouped[0][0]]));
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [grouped]);

    if (error) return <p className="text-sm text-red-600">{error}</p>;
    if (!grouped) return <RoadmapSkeleton />;

    return (
        <div className="relative">
            {/* Spine line down the left side */}
            <div
                className="absolute top-3 bottom-3 w-px bg-gradient-to-b from-primary/40 via-accent/30 to-primary/10"
                style={{ left: '0.6875rem' }}
                aria-hidden
            />
            <ol className="space-y-3">
                {grouped.map(([category, list], idx) => (
                    <FamilyNode
                        key={category}
                        index={idx}
                        category={category}
                        courses={list}
                        completed={completed}
                        open={expanded.has(category)}
                        onToggle={() => toggle(category)}
                    />
                ))}
            </ol>
        </div>
    );
}

function FamilyNode({
    index, category, courses, completed, open, onToggle,
}: {
    index: number;
    category: string;
    courses: Course[];
    completed: Set<string>;
    open: boolean;
    onToggle: () => void;
}) {
    const totalLessons = courses.reduce((n, c) => n + c.lessons.length, 0);
    const doneLessons = courses.reduce(
        (n, c) => n + c.lessons.reduce((m, l) => m + (completed.has(l.id) ? 1 : 0), 0),
        0,
    );

    return (
        <li className="relative pl-10">
            {/* Marker dot on the spine */}
            <span
                className={
                    'absolute top-3 w-3 h-3 rounded-full border-2 border-cream shadow-sm transition ' +
                    (doneLessons === totalLessons && totalLessons > 0
                        ? 'bg-accent'
                        : doneLessons > 0
                            ? 'bg-primary'
                            : 'bg-white border-primary/50')
                }
                style={{ left: '0.3125rem' }}
                aria-hidden
            />
            <div className="card !p-0 overflow-hidden">
                <button
                    type="button"
                    onClick={onToggle}
                    className="w-full flex items-center gap-3 px-4 py-3 text-left hover:bg-cream/60 transition"
                    aria-expanded={open}>
                    <span className="text-xs font-mono text-muted tabular-nums w-6">
                        {String(index + 1).padStart(2, '0')}
                    </span>
                    <div className="flex-1 min-w-0">
                        <h3 className="text-base font-semibold text-ink">{category}</h3>
                        <p className="text-[11px] text-muted mt-0.5">
                            {courses.length} {courses.length === 1 ? 'course' : 'courses'} · {totalLessons} lessons
                        </p>
                    </div>
                    {totalLessons > 0 && (
                        <div className="hidden sm:flex flex-col items-end gap-1 w-32">
                            <span className="text-[11px] text-muted tabular-nums">
                                {doneLessons}/{totalLessons}
                            </span>
                            <ProgressBar value={doneLessons} max={totalLessons} height={3} className="w-full" />
                        </div>
                    )}
                    <span
                        className={
                            'text-ink/40 transition-transform text-xs ' + (open ? 'rotate-90' : '')
                        }
                        aria-hidden>
                        ▸
                    </span>
                </button>
                {open && (
                    <ul className="border-t border-muted/20 divide-y divide-muted/15 bg-cream/40">
                        {courses.map(course => {
                            const total = course.lessons.length;
                            const done = course.lessons.reduce(
                                (n, l) => n + (completed.has(l.id) ? 1 : 0), 0);
                            return (
                                <li key={course.id}>
                                    <Link
                                        to={`/courses?slug=${encodeURIComponent(course.slug)}`}
                                        className="flex items-center gap-3 px-4 py-2.5 hover:bg-white transition group">
                                        <span className="font-mono text-[10px] text-muted tabular-nums w-8">
                                            {done === total && total > 0 ? '✓' : `${done}/${total}`}
                                        </span>
                                        <span className="flex-1 text-sm text-ink group-hover:text-accent transition truncate">
                                            {course.title}
                                        </span>
                                        <DifficultyDot d={course.difficulty} />
                                    </Link>
                                </li>
                            );
                        })}
                    </ul>
                )}
            </div>
        </li>
    );
}

function DifficultyDot({ d }: { d: Difficulty }) {
    const map: Record<Difficulty, string> = {
        beginner:     'bg-green-400',
        intermediate: 'bg-amber-400',
        advanced:     'bg-red-400',
    };
    return <span className={`inline-block w-1.5 h-1.5 rounded-full ${map[d]}`} title={d} />;
}

function RoadmapSkeleton() {
    return (
        <div className="relative">
            <div
                className="absolute top-3 bottom-3 w-px bg-muted/30"
                style={{ left: '0.6875rem' }}
                aria-hidden
            />
            <ol className="space-y-3">
                {Array.from({ length: 5 }).map((_, i) => (
                    <li key={i} className="relative pl-10">
                        <span
                            className="absolute top-3 w-3 h-3 rounded-full bg-cream border-2 border-cream"
                            style={{ left: '0.3125rem' }}
                            aria-hidden
                        />
                        <div className="card h-14 animate-pulse" />
                    </li>
                ))}
            </ol>
        </div>
    );
}
