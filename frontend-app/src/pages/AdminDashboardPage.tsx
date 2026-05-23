import { useEffect, useMemo, useState } from 'react';
import { Link } from 'react-router-dom';
import { adminApi, type RecomputeResult } from '../admin-api';
import type { Course } from '../api';

export function AdminDashboardPage() {
    const [courses, setCourses] = useState<Course[] | null>(null);
    const [error, setError] = useState<string | null>(null);
    const [recompute, setRecompute] = useState<{
        pending: boolean; result: RecomputeResult | null; error: string | null;
    }>({ pending: false, result: null, error: null });

    function refresh() {
        adminApi.listCourses()
            .then(setCourses)
            .catch((e: any) => setError(e?.message ?? 'Failed to load courses'));
    }
    useEffect(() => { refresh(); }, []);

    async function runRecompute() {
        setRecompute({ pending: true, result: null, error: null });
        try {
            const r = await adminApi.recomputeHashes();
            setRecompute({ pending: false, result: r, error: null });
            refresh();
        } catch (err: any) {
            setRecompute({ pending: false, result: null, error: err?.message ?? 'Recompute failed' });
        }
    }

    const grouped = useMemo(() => {
        if (!courses) return null;
        const map = new Map<string, Course[]>();
        for (const c of courses) {
            const cat = c.category || 'Other';
            if (!map.has(cat)) map.set(cat, []);
            map.get(cat)!.push(c);
        }
        return [...map.entries()].sort(([a], [b]) => {
            if (a === 'Fundamentals') return -1;
            if (b === 'Fundamentals') return 1;
            return a.localeCompare(b);
        });
    }, [courses]);

    return (
        <div className="max-w-5xl mx-auto px-4 py-8">
            <div className="flex items-center justify-between flex-wrap gap-3 mb-6">
                <h1 className="text-2xl font-semibold tracking-tight">Admin</h1>
                <div className="flex gap-2">
                    <button
                        onClick={runRecompute}
                        disabled={recompute.pending}
                        className="btn-secondary text-sm disabled:opacity-50">
                        {recompute.pending ? 'Recomputing…' : 'Recompute all hashes'}
                    </button>
                    <Link to="/admin/courses/new" className="btn-primary text-sm">New course</Link>
                </div>
            </div>

            {recompute.result && <RecomputeBanner result={recompute.result} />}
            {recompute.error  && <p className="text-sm text-red-600 mb-4">{recompute.error}</p>}

            {error && <p className="text-sm text-red-600">{error}</p>}
            {!courses && !error && <p className="text-sm text-muted">Loading…</p>}
            {grouped && grouped.length === 0 && <p className="text-sm text-muted">No courses yet. Create one.</p>}

            {grouped && grouped.map(([category, list]) => (
                <section key={category} className="mb-8">
                    <h2 className="text-[11px] uppercase tracking-wide font-semibold text-ink/50 mb-2">{category}</h2>
                    <ol className="border border-muted/30 rounded-xl divide-y divide-muted/30 bg-white overflow-hidden">
                        {list.map(c => (
                            <li key={c.id} className="flex items-center gap-3 px-4 py-3 hover:bg-cream transition">
                                <span className="text-xs font-mono text-muted w-6 tabular-nums">{c.displayOrder}</span>
                                <Link to={`/admin/courses/${c.id}`} className="flex-1 text-ink hover:text-accent">
                                    {c.title}
                                </Link>
                                <span className="text-xs text-muted">{c.lessons.length} lesson{c.lessons.length === 1 ? '' : 's'}</span>
                                <span className="text-xs text-muted">{c.difficulty}</span>
                            </li>
                        ))}
                    </ol>
                </section>
            ))}
        </div>
    );
}

function RecomputeBanner({ result }: { result: RecomputeResult }) {
    const ok    = result.updated.length;
    const skip  = result.skipped.length;
    const bad   = result.failed.length;
    const tone  = bad > 0 ? 'border-red-200 bg-red-50 text-red-700'
               : skip > 0 ? 'border-amber-200 bg-amber-50 text-amber-700'
                          : 'border-green-200 bg-green-50 text-green-700';
    return (
        <div className={`border rounded-md px-3 py-2 text-sm mb-4 ${tone}`}>
            Recompute: <strong>{ok}</strong> updated · {skip} skipped · {bad} failed
            (canonical rendered at t={result.verificationTime}).
            {bad > 0 && (
                <ul className="mt-2 list-disc pl-5 text-xs">
                    {result.failed.map(f => (
                        <li key={f.id}><span className="font-medium">{f.title}</span>: {f.error}</li>
                    ))}
                </ul>
            )}
        </div>
    );
}
