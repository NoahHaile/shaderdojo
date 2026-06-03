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
                        Learn to write shaders.
                    </h1>
                    <p className="mt-4 text-lg text-ink/70 max-w-prose">
                        ShaderDojo teaches one shader trick at a time. You write the code.
                        The page runs it in your browser. It tells you if it looks right.
                        It is like{' '}
                        <a className="text-accent font-medium hover:underline" href="https://shadertoy.com/" target="_blank" rel="noreferrer">
                            ShaderToy
                        </a>{' '}meets{' '}
                        <a className="text-accent font-medium hover:underline" href="https://www.freecodecamp.org/" target="_blank" rel="noreferrer">
                            freeCodeCamp
                        </a>.
                    </p>
                    <div className="mt-6 flex gap-3">
                        <Link to="/courses" className="btn-primary">Start learning</Link>
                        <Link to="/reference" className="btn-secondary">Reference</Link>
                    </div>
                </div>
                <div className="aspect-square w-full rounded-xl overflow-hidden border border-muted/30 bg-black shadow-sm">
                    <ShaderCanvas initialBody={HERO_SHADER} />
                </div>
            </section>

            <section className="mt-16">
                <header className="mb-6">
                    <h2 className="text-2xl md:text-3xl font-semibold tracking-tight">The roadmap</h2>
                    <p className="mt-1 text-ink/60 text-sm max-w-prose">
                        Start with Orientation. Then Foundations. After that, pick any branch.
                        Each branch teaches one family of tricks.
                    </p>
                </header>
                <Roadmap />
            </section>

            <section className="mt-20 grid md:grid-cols-3 gap-4">
                <FeatureCard title="Write, run, check">
                    You write GLSL. The page runs it in your browser.
                    It checks that your picture matches the goal.
                </FeatureCard>
                <FeatureCard title="One idea per lesson">
                    Each lesson teaches one trick. UVs. Smoothstep. Noise.
                    You finish one and move on.
                </FeatureCard>
                <FeatureCard title="Build a toolkit">
                    Each course gives you a new tool.
                    By the end you can mix them to make your own art.
                </FeatureCard>
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
// Roadmap — drawn as an indented tree: trunk on the left, branches kinked out
// to family nodes, leaves (courses) hanging off each family's vertical guide.
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
        <div className="relative font-mono text-[13px] leading-relaxed">
            {/* The trunk: a single line down the left edge, glowing primary→accent→primary. */}
            <div
                className="absolute top-0 bottom-0 w-px bg-gradient-to-b from-primary/50 via-accent/40 to-primary/20"
                style={{ left: '0.5rem' }}
                aria-hidden
            />
            <ol className="space-y-2">
                {grouped.map(([category, list], idx) => {
                    const isLast = idx === grouped.length - 1;
                    return (
                        <FamilyBranch
                            key={category}
                            index={idx}
                            isLast={isLast}
                            category={category}
                            courses={list}
                            completed={completed}
                            open={expanded.has(category)}
                            onToggle={() => toggle(category)}
                        />
                    );
                })}
            </ol>
        </div>
    );
}

function FamilyBranch({
    index, isLast, category, courses, completed, open, onToggle,
}: {
    index: number;
    isLast: boolean;
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
    const allDone = totalLessons > 0 && doneLessons === totalLessons;
    const someDone = doneLessons > 0;

    return (
        <li className="relative">
            <div className="relative pl-7 group">
                {/* Branch elbow off the trunk into the family node. */}
                <TrunkElbow isLast={isLast && !open} />
                {/* Family marker dot, on top of the elbow's right end. */}
                <span
                    className={
                        'absolute top-[0.55rem] w-2.5 h-2.5 rounded-full border-2 border-cream shadow-sm transition ' +
                        (allDone ? 'bg-accent' : someDone ? 'bg-primary' : 'bg-white border-primary/50')
                    }
                    style={{ left: '0.25rem' }}
                    aria-hidden
                />
                <button
                    type="button"
                    onClick={onToggle}
                    className="w-full flex items-center gap-3 px-3 py-2 rounded-md text-left hover:bg-cream/60 transition"
                    aria-expanded={open}>
                    <span className="text-[11px] text-muted tabular-nums w-6">
                        {String(index + 1).padStart(2, '0')}
                    </span>
                    <div className="flex-1 min-w-0 font-sans">
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
            </div>

            {open && (
                <div className="relative mt-1">
                    <ul className="space-y-0.5">
                        {courses.map((course, ci) => {
                            const total = course.lessons.length;
                            const done = course.lessons.reduce(
                                (n, l) => n + (completed.has(l.id) ? 1 : 0), 0);
                            const courseDone = total > 0 && done === total;
                            const courseStarted = done > 0;
                            const isLastChild = ci === courses.length - 1;
                            return (
                                <li key={course.id} className="relative">
                                    {/* Child elbow into the course node. */}
                                    <ChildElbow isLast={isLastChild} />
                                    {/* Course leaf dot. */}
                                    <span
                                        className={
                                            'absolute top-[0.7rem] w-1.5 h-1.5 rounded-full border border-cream transition ' +
                                            (courseDone ? 'bg-accent' : courseStarted ? 'bg-primary' : 'bg-white border-primary/40')
                                        }
                                        style={{ left: '1.55rem' }}
                                        aria-hidden
                                    />
                                    <Link
                                        to={`/courses?slug=${encodeURIComponent(course.slug)}`}
                                        className="flex items-center gap-3 pl-9 pr-3 py-1.5 rounded-md hover:bg-cream/60 transition group">
                                        <span className="font-mono text-[10px] text-muted tabular-nums w-8">
                                            {courseDone ? '✓' : `${done}/${total}`}
                                        </span>
                                        <span className="flex-1 font-sans text-sm text-ink group-hover:text-accent transition truncate">
                                            {course.title}
                                        </span>
                                        <DifficultyDot d={course.difficulty} />
                                    </Link>
                                </li>
                            );
                        })}
                    </ul>
                </div>
            )}
        </li>
    );
}

// Right-angle connector from the trunk into a family node.
// Visually: ┌─, or └─ when isLast.
function TrunkElbow({ isLast }: { isLast: boolean }) {
    return (
        <>
            {/* Vertical leg: from top of the row down to the node center. */}
            <span
                className="absolute top-0 w-px bg-muted/40"
                style={{
                    left: '0.5rem',
                    height: isLast ? '0.7rem' : '100%',
                }}
                aria-hidden
            />
            {/* Horizontal leg: from the vertical leg out to the marker dot. */}
            <span
                className="absolute h-px bg-muted/40"
                style={{ left: '0.5rem', top: '0.7rem', width: '0.85rem' }}
                aria-hidden
            />
        </>
    );
}

// Per-row elbow for course leaves. Non-last rows draw a full-height vertical
// leg so the legs of consecutive rows stitch together into a continuous sub-trunk;
// the last row's leg stops at the elbow level so the trunk visually terminates.
function ChildElbow({ isLast }: { isLast: boolean }) {
    return (
        <>
            <span
                className="absolute top-0 w-px bg-muted/35"
                style={{
                    left: '1.55rem',
                    height: isLast ? '0.85rem' : '100%',
                }}
                aria-hidden
            />
            <span
                className="absolute h-px bg-muted/35"
                style={{ left: '1.55rem', top: '0.85rem', width: '0.6rem' }}
                aria-hidden
            />
        </>
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
                className="absolute top-0 bottom-0 w-px bg-muted/30"
                style={{ left: '0.5rem' }}
                aria-hidden
            />
            <ol className="space-y-2">
                {Array.from({ length: 5 }).map((_, i) => (
                    <li key={i} className="relative pl-7">
                        <span
                            className="absolute h-px bg-muted/30"
                            style={{ left: '0.5rem', top: '0.7rem', width: '0.85rem' }}
                            aria-hidden
                        />
                        <span
                            className="absolute top-[0.55rem] w-2.5 h-2.5 rounded-full bg-cream border-2 border-cream"
                            style={{ left: '0.25rem' }}
                            aria-hidden
                        />
                        <div className="h-10 rounded-md bg-cream/50 animate-pulse" />
                    </li>
                ))}
            </ol>
        </div>
    );
}
