import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { coursesApi, type Course } from '../api';

export function CoursesPage() {
    const [courses, setCourses] = useState<Course[] | null>(null);
    const [error, setError] = useState<string | null>(null);
    const [selected, setSelected] = useState<string | null>(null);

    useEffect(() => {
        coursesApi.list()
            .then((cs) => {
                setCourses(cs);
                if (cs.length > 0) setSelected(cs[0].slug);
            })
            .catch((e: any) => setError(e.message ?? 'Failed to load courses'));
    }, []);

    return (
        <div className="max-w-6xl mx-auto px-4 py-10 grid md:grid-cols-[220px_1fr] gap-8">
            {/* Sidebar */}
            <aside className="md:sticky md:top-20 md:self-start">
                <h2 className="text-xs uppercase tracking-wide font-semibold text-ink/60 mb-3">Courses</h2>
                {!courses && !error && <SidebarSkeleton />}
                {error && <p className="text-sm text-red-600">{error}</p>}
                {courses && (
                    <ul className="space-y-1">
                        {courses.map(c => (
                            <li key={c.id}>
                                <button
                                    onClick={() => setSelected(c.slug)}
                                    className={
                                        'w-full text-left px-3 py-2 rounded-md text-sm transition ' +
                                        (selected === c.slug
                                            ? 'bg-primary/40 text-ink font-medium'
                                            : 'hover:bg-cream text-ink/70')
                                    }>
                                    {c.title}
                                </button>
                            </li>
                        ))}
                    </ul>
                )}
            </aside>

            {/* Main */}
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
    return (
        <div>
            <header className="mb-6">
                <h1 className="text-3xl font-semibold tracking-tight">{course.title}</h1>
                {course.description && (
                    <p className="mt-2 text-ink/70 max-w-prose">{course.description}</p>
                )}
                <p className="mt-3 text-xs text-muted tabular-nums">
                    {total} lesson{total === 1 ? '' : 's'}
                </p>
            </header>

            {total === 0 ? (
                <p className="text-sm text-ink/60">No lessons in this course yet.</p>
            ) : (
                <ol className="border border-muted/30 rounded-xl divide-y divide-muted/30 overflow-hidden bg-white">
                    {course.lessons.map((lesson, idx) => (
                        <li key={lesson.id}>
                            <Link
                                to={`/lesson/${lesson.id}`}
                                className="flex items-center gap-4 px-4 py-3 hover:bg-cream transition group">
                                <span className="font-mono text-xs text-muted w-6 tabular-nums">
                                    {String(idx + 1).padStart(2, '0')}
                                </span>
                                <span className="flex-1 text-ink group-hover:text-accent transition">
                                    {lesson.title}
                                </span>
                                <span className={lesson.verified ? 'pill-verified' : 'pill-explore'}>
                                    {lesson.verified ? 'Verified' : 'Explore'}
                                </span>
                            </Link>
                        </li>
                    ))}
                </ol>
            )}
        </div>
    );
}

function SidebarSkeleton() {
    return (
        <ul className="space-y-2">
            {[0, 1, 2].map(i => (
                <li key={i} className="h-8 rounded-md bg-cream animate-pulse" />
            ))}
        </ul>
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
