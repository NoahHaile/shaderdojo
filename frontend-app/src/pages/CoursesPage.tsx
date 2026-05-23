import { useEffect, useMemo, useState } from 'react';
import { Link, useSearchParams } from 'react-router-dom';
import { coursesApi, type Course, type Difficulty } from '../api';
import { getCompletedLessons } from '../completion';
import { ProgressBar } from '../components/ProgressBar';

export function CoursesPage() {
    const [courses, setCourses] = useState<Course[] | null>(null);
    const [error, setError] = useState<string | null>(null);
    const [params, setParams] = useSearchParams();
    const requestedSlug = params.get('slug');
    const [selected, setSelected] = useState<string | null>(requestedSlug);

    useEffect(() => {
        coursesApi.list()
            .then((cs) => {
                setCourses(cs);
                const initial =
                    (requestedSlug && cs.some(c => c.slug === requestedSlug))
                        ? requestedSlug
                        : (cs[0]?.slug ?? null);
                setSelected(initial);
            })
            .catch((e: any) => setError(e.message ?? 'Failed to load courses'));
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, []);

    function pickCourse(slug: string) {
        setSelected(slug);
        setParams({ slug }, { replace: true });
    }

    // Group courses by category, preserving the server's display_order within each.
    const grouped = useMemo(() => {
        if (!courses) return null;
        const map = new Map<string, Course[]>();
        for (const c of courses) {
            const cat = c.category || 'Other';
            if (!map.has(cat)) map.set(cat, []);
            map.get(cat)!.push(c);
        }
        // Stable order: alphabetical category, but with "Fundamentals" pinned first.
        return [...map.entries()].sort(([a], [b]) => {
            if (a === 'Fundamentals') return -1;
            if (b === 'Fundamentals') return 1;
            return a.localeCompare(b);
        });
    }, [courses]);

    // Source of truth for completion: localStorage. Reading on every render is
    // cheap and ensures the bar updates after solving a lesson + navigating back.
    const completedAll = getCompletedLessons();
    const completedCountFor = (c: Course) =>
        c.lessons.reduce((n, l) => n + (completedAll.has(l.id) ? 1 : 0), 0);

    return (
        <div className="max-w-6xl mx-auto px-4 py-10 grid md:grid-cols-[240px_1fr] gap-8">
            <aside className="md:sticky md:top-20 md:self-start">
                {!courses && !error && <SidebarSkeleton />}
                {error && <p className="text-sm text-red-600">{error}</p>}
                {grouped && (
                    <div className="space-y-5">
                        {grouped.map(([category, list]) => (
                            <div key={category}>
                                <h3 className="text-[11px] uppercase tracking-wide font-semibold text-ink/50 mb-2 px-3">
                                    {category}
                                </h3>
                                <ul className="space-y-1">
                                    {list.map(c => {
                                        const done = completedCountFor(c);
                                        return (
                                            <li key={c.id}>
                                                <button
                                                    onClick={() => pickCourse(c.slug)}
                                                    className={
                                                        'w-full text-left px-3 py-2 rounded-md text-sm transition ' +
                                                        (selected === c.slug
                                                            ? 'bg-primary/40 text-ink font-medium'
                                                            : 'hover:bg-cream text-ink/70')
                                                    }>
                                                    <div className="flex items-center gap-2">
                                                        <span className="flex-1">{c.title}</span>
                                                        <DifficultyDot d={c.difficulty} />
                                                    </div>
                                                    {c.lessons.length > 0 && (
                                                        <ProgressBar
                                                            value={done}
                                                            max={c.lessons.length}
                                                            height={3}
                                                            className="mt-1.5"
                                                        />
                                                    )}
                                                </button>
                                            </li>
                                        );
                                    })}
                                </ul>
                            </div>
                        ))}
                    </div>
                )}
            </aside>

            <section>
                {!courses && !error && <MainSkeleton />}
                {courses && selected && (
                    <CourseDetail course={courses.find(c => c.slug === selected)!} />
                )}
            </section>
        </div>
    );
}

function CourseDetail({ course }: { course: Course }) {
    const total = course.lessons.length;
    const completed = getCompletedLessons();
    const doneCount = course.lessons.reduce((n, l) => n + (completed.has(l.id) ? 1 : 0), 0);
    const pct = total === 0 ? 0 : Math.round((doneCount / total) * 100);

    return (
        <div>
            <div className="text-[11px] uppercase tracking-wide font-semibold text-muted mb-2">
                {course.category}
            </div>
            <header className="mb-6">
                <div className="flex items-center gap-3 flex-wrap">
                    <h1 className="text-3xl font-semibold tracking-tight">{course.title}</h1>
                    <DifficultyPill d={course.difficulty} />
                </div>
                {course.description && (
                    <p className="mt-2 text-ink/70 max-w-prose">{course.description}</p>
                )}
                {total > 0 && (
                    <div className="mt-4 max-w-md">
                        <div className="flex items-baseline justify-between mb-1.5">
                            <span className="text-xs text-muted tabular-nums">
                                {doneCount} of {total} lesson{total === 1 ? '' : 's'} solved
                            </span>
                            <span className="text-xs font-medium text-ink/70 tabular-nums">{pct}%</span>
                        </div>
                        <ProgressBar value={doneCount} max={total} height={6} />
                    </div>
                )}
            </header>

            {total === 0 ? (
                <p className="text-sm text-ink/60">No lessons in this course yet.</p>
            ) : (
                <ol className="border border-muted/30 rounded-xl divide-y divide-muted/30 overflow-hidden bg-white">
                    {course.lessons.map((lesson, idx) => {
                        const done = completed.has(lesson.id);
                        return (
                            <li key={lesson.id}>
                                <Link
                                    to={`/lesson/${lesson.id}`}
                                    className="flex items-center gap-4 px-4 py-3 hover:bg-cream transition group">
                                    <span className="font-mono text-xs text-muted w-6 tabular-nums">
                                        {done ? '✓' : String(idx + 1).padStart(2, '0')}
                                    </span>
                                    <span className="flex-1 text-ink group-hover:text-accent transition">
                                        {lesson.title}
                                    </span>
                                    <span className={lesson.verified ? 'pill-verified' : 'pill-explore'}>
                                        {lesson.verified ? 'Verified' : 'Explore'}
                                    </span>
                                </Link>
                            </li>
                        );
                    })}
                </ol>
            )}
        </div>
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

function DifficultyPill({ d }: { d: Difficulty }) {
    const styles: Record<Difficulty, string> = {
        beginner:     'pill bg-green-50  text-green-700 border-green-200',
        intermediate: 'pill bg-amber-50  text-amber-700 border-amber-200',
        advanced:     'pill bg-red-50    text-red-700   border-red-200',
    };
    return <span className={styles[d]}>{d}</span>;
}

function SidebarSkeleton() {
    return (
        <div className="space-y-4">
            {[0, 1].map(i => (
                <div key={i}>
                    <div className="h-3 w-20 bg-cream rounded animate-pulse mb-2" />
                    <div className="space-y-1">
                        {[0, 1, 2].map(j => (
                            <div key={j} className="h-8 rounded-md bg-cream animate-pulse" />
                        ))}
                    </div>
                </div>
            ))}
        </div>
    );
}
function MainSkeleton() {
    return (
        <div>
            <div className="h-8 w-1/2 bg-cream rounded animate-pulse mb-3" />
            <div className="h-4 w-3/4 bg-cream rounded animate-pulse mb-6" />
            <ul className="space-y-2">
                {Array.from({ length: 5 }).map((_, i) => (
                    <li key={i} className="h-12 bg-cream rounded animate-pulse" />
                ))}
            </ul>
        </div>
    );
}
