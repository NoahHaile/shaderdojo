import { useCallback, useEffect, useMemo, useState } from 'react';
import { Link, useNavigate, useParams } from 'react-router-dom';
import { adminApi, type CreateCoursePayload } from '../admin-api';
import type { Course, Difficulty, LessonSummary } from '../api';

const NEW = 'new';

const DIFFICULTIES: Difficulty[] = ['beginner', 'intermediate', 'advanced'];

export function AdminCourseEditPage() {
    const { id = '' } = useParams();
    const isNew = id === NEW;
    const navigate = useNavigate();

    const [loaded, setLoaded] = useState<Course | null>(null);
    const [lessons, setLessons] = useState<LessonSummary[]>([]);
    const [loadError, setLoadError] = useState<string | null>(null);

    const [form, setForm] = useState<CreateCoursePayload>({
        slug: '', title: '', description: '',
        category: 'Fundamentals', difficulty: 'beginner', displayOrder: 0,
    });
    const [saving, setSaving] = useState(false);
    const [saveError, setSaveError] = useState<string | null>(null);
    const [savedAt, setSavedAt] = useState<number | null>(null);

    // Load existing course
    useEffect(() => {
        if (isNew) return;
        // We need the course by id — but the public API uses slug. Use list and find.
        adminApi.listCourses().then(list => {
            const c = list.find(x => x.id === id);
            if (!c) { setLoadError('Course not found'); return; }
            setLoaded(c);
            setLessons(c.lessons);
            setForm({
                slug: c.slug, title: c.title,
                description: c.description ?? '',
                category: c.category, difficulty: c.difficulty,
                displayOrder: c.displayOrder,
            });
        }).catch((e: any) => setLoadError(e?.message ?? 'Failed to load'));
    }, [id, isNew]);

    const update = <K extends keyof CreateCoursePayload>(k: K, v: CreateCoursePayload[K]) =>
        setForm(f => ({ ...f, [k]: v }));

    const onSave = useCallback(async () => {
        setSaving(true); setSaveError(null);
        try {
            const payload: CreateCoursePayload = {
                ...form,
                displayOrder: typeof form.displayOrder === 'string'
                    ? parseInt(form.displayOrder, 10) || 0
                    : form.displayOrder ?? 0,
                description: form.description?.trim() || undefined,
            };
            const saved = isNew
                ? await adminApi.createCourse(payload)
                : await adminApi.updateCourse(id, payload);
            setSavedAt(Date.now());
            if (isNew) navigate(`/admin/courses/${saved.id}`, { replace: true });
        } catch (err: any) {
            setSaveError(err?.message ?? 'Save failed');
        } finally {
            setSaving(false);
        }
    }, [form, id, isNew, navigate]);

    const onDelete = useCallback(async () => {
        if (isNew || !loaded) return;
        if (!confirm(`Delete "${loaded.title}" and all its lessons?`)) return;
        try {
            await adminApi.deleteCourse(id);
            navigate('/admin', { replace: true });
        } catch (err: any) {
            setSaveError(err?.message ?? 'Delete failed');
        }
    }, [id, isNew, loaded, navigate]);

    const status = useMemo(() => {
        if (saving) return 'Saving…';
        if (saveError) return saveError;
        if (savedAt) return 'Saved ' + new Date(savedAt).toLocaleTimeString();
        return null;
    }, [saving, saveError, savedAt]);

    if (loadError) {
        return (
            <div className="max-w-3xl mx-auto px-4 py-10">
                <p className="text-red-600 mb-4">{loadError}</p>
                <Link to="/admin" className="btn-secondary">Back</Link>
            </div>
        );
    }

    return (
        <div className="max-w-3xl mx-auto px-4 py-8">
            <nav className="text-xs text-muted mb-3">
                <Link to="/admin" className="hover:text-ink">Admin</Link> /{' '}
                <span className="text-ink">{isNew ? 'New course' : loaded?.title ?? 'Course'}</span>
            </nav>
            <h1 className="text-2xl font-semibold tracking-tight mb-6">
                {isNew ? 'New course' : `Edit course`}
            </h1>

            <form onSubmit={(e) => { e.preventDefault(); onSave(); }} className="card space-y-4">
                <Row label="Slug" hint="URL-safe id, e.g. art-tutorials-pixel-art">
                    <input className="field" value={form.slug}
                           onChange={(e) => update('slug', e.target.value)} required />
                </Row>
                <Row label="Title">
                    <input className="field" value={form.title}
                           onChange={(e) => update('title', e.target.value)} required />
                </Row>
                <Row label="Description" hint="Plain text. Shown under the course title.">
                    <textarea className="field" rows={3} value={form.description ?? ''}
                              onChange={(e) => update('description', e.target.value)} />
                </Row>
                <div className="grid grid-cols-3 gap-3">
                    <Row label="Category" hint="Freeform. Groups courses in the sidebar.">
                        <input className="field" value={form.category ?? ''}
                               onChange={(e) => update('category', e.target.value)} />
                    </Row>
                    <Row label="Difficulty">
                        <select className="field" value={form.difficulty}
                                onChange={(e) => update('difficulty', e.target.value as Difficulty)}>
                            {DIFFICULTIES.map(d => <option key={d} value={d}>{d}</option>)}
                        </select>
                    </Row>
                    <Row label="Display order" hint="Lower numbers first within category.">
                        <input className="field" type="number"
                               value={form.displayOrder ?? 0}
                               onChange={(e) => update('displayOrder', parseInt(e.target.value, 10) || 0)} />
                    </Row>
                </div>

                <div className="flex items-center gap-3 pt-2">
                    <button type="submit" disabled={saving} className="btn-primary disabled:opacity-50">
                        {isNew ? 'Create course' : 'Save'}
                    </button>
                    {!isNew && (
                        <button type="button" onClick={onDelete} className="btn-secondary text-red-600">
                            Delete
                        </button>
                    )}
                    {status && <span className="text-xs text-muted">{status}</span>}
                </div>
            </form>

            {/* Lessons list — only after the course exists. */}
            {!isNew && loaded && (
                <section className="mt-10">
                    <div className="flex items-center justify-between mb-3">
                        <h2 className="text-lg font-semibold">Lessons</h2>
                        <Link to={`/admin/lessons/new?courseId=${loaded.id}`} className="btn-primary text-sm">
                            New lesson
                        </Link>
                    </div>
                    {lessons.length === 0 ? (
                        <p className="text-sm text-muted">No lessons yet.</p>
                    ) : (
                        <ol className="border border-muted/30 rounded-xl divide-y divide-muted/30 bg-white overflow-hidden">
                            {lessons.map((l, idx) => (
                                <li key={l.id}>
                                    <Link
                                        to={`/admin/lessons/${l.id}`}
                                        className="flex items-center gap-4 px-4 py-3 hover:bg-cream transition">
                                        <span className="font-mono text-xs text-muted w-8 tabular-nums">
                                            {String(idx + 1).padStart(2, '0')}
                                        </span>
                                        <span className="flex-1 text-ink">{l.title}</span>
                                        <span className={l.verified ? 'pill-verified' : 'pill-explore'}>
                                            {l.verified ? 'Verified' : 'No hash'}
                                        </span>
                                    </Link>
                                </li>
                            ))}
                        </ol>
                    )}
                </section>
            )}
        </div>
    );
}

function Row({ label, hint, children }: { label: string; hint?: string; children: React.ReactNode }) {
    return (
        <div>
            <label className="label">{label}</label>
            {children}
            {hint && <p className="mt-1 text-[11px] text-muted">{hint}</p>}
        </div>
    );
}
