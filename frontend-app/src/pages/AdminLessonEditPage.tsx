import { useCallback, useEffect, useMemo, useState } from 'react';
import { Link, useNavigate, useParams, useSearchParams } from 'react-router-dom';
import { adminApi, type CreateLessonPayload } from '../admin-api';
import { Editor } from '../components/Editor';
import { RichText } from '../components/RichText';
import { ShaderCanvas } from '../components/ShaderCanvas';
import type { Course } from '../api';

const NEW = 'new';

export function AdminLessonEditPage() {
    const { id = '' } = useParams();
    const isNew = id === NEW;
    const navigate = useNavigate();
    const [params] = useSearchParams();
    const courseIdFromQuery = params.get('courseId') ?? '';

    const [allCourses, setAllCourses] = useState<Course[] | null>(null);
    const [loadError, setLoadError] = useState<string | null>(null);

    const [form, setForm] = useState<CreateLessonPayload>({
        courseId: courseIdFromQuery,
        slug: '', title: '', displayOrder: 0,
        description: '',
        starterVertexShader:
            'attribute vec4 aVertexPosition;\nvoid main() { gl_Position = aVertexPosition; }',
        starterFragmentShader: 'void main() {\n    // TODO\n    gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);\n}',
        canonicalFragmentShader: '',
    });
    const [previewBody, setPreviewBody] = useState<string>(form.starterFragmentShader ?? '');
    const [saving, setSaving] = useState(false);
    const [saveError, setSaveError] = useState<string | null>(null);
    const [savedAt, setSavedAt] = useState<number | null>(null);
    const [postSaveRecompute, setPostSaveRecompute] = useState(true);

    // Load courses for the picker
    useEffect(() => {
        adminApi.listCourses().then(setAllCourses).catch((e: any) =>
            setLoadError(e?.message ?? 'Failed to load courses'));
    }, []);

    // Load existing lesson
    useEffect(() => {
        if (isNew) return;
        Promise.all([adminApi.getLesson(id), adminApi.getLessonSolution(id).catch(() => null)])
            .then(([l, sol]) => {
                setForm({
                    courseId: l.courseId ?? '',
                    slug: l.slug,
                    title: l.title,
                    displayOrder: l.displayOrder,
                    description: l.description ?? '',
                    starterVertexShader: l.starterVertexShader ?? '',
                    starterFragmentShader: l.starterFragmentShader ?? '',
                    canonicalFragmentShader: sol?.canonicalFragmentShader ?? '',
                });
                setPreviewBody(l.starterFragmentShader ?? '');
            })
            .catch((e: any) => setLoadError(e?.message ?? 'Failed to load lesson'));
    }, [id, isNew]);

    const update = <K extends keyof CreateLessonPayload>(k: K, v: CreateLessonPayload[K]) =>
        setForm(f => ({ ...f, [k]: v }));

    const onSave = useCallback(async () => {
        setSaving(true); setSaveError(null);
        try {
            const payload: CreateLessonPayload = {
                ...form,
                displayOrder: typeof form.displayOrder === 'string'
                    ? parseInt(form.displayOrder, 10) || 0
                    : form.displayOrder ?? 0,
                description: form.description?.trim() || undefined,
                starterVertexShader: form.starterVertexShader?.trim() || undefined,
                starterFragmentShader: form.starterFragmentShader?.trim() || undefined,
                canonicalFragmentShader: form.canonicalFragmentShader?.trim() || undefined,
            };
            const saved = isNew
                ? await adminApi.createLesson(payload)
                : await adminApi.updateLesson(id, payload);
            setSavedAt(Date.now());

            if (postSaveRecompute && payload.canonicalFragmentShader) {
                await adminApi.recomputeHashes();
            }

            if (isNew) navigate(`/admin/lessons/${saved.id}`, { replace: true });
        } catch (err: any) {
            setSaveError(err?.message ?? 'Save failed');
        } finally {
            setSaving(false);
        }
    }, [form, id, isNew, navigate, postSaveRecompute]);

    const onDelete = useCallback(async () => {
        if (isNew) return;
        if (!confirm(`Delete lesson "${form.title}"?`)) return;
        try {
            await adminApi.deleteLesson(id);
            if (form.courseId) navigate(`/admin/courses/${form.courseId}`, { replace: true });
            else navigate('/admin', { replace: true });
        } catch (err: any) {
            setSaveError(err?.message ?? 'Delete failed');
        }
    }, [id, isNew, form.title, form.courseId, navigate]);

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
        <div className="max-w-5xl mx-auto px-4 py-8">
            <nav className="text-xs text-muted mb-3">
                <Link to="/admin" className="hover:text-ink">Admin</Link> /{' '}
                {form.courseId && (
                    <>
                        <Link to={`/admin/courses/${form.courseId}`} className="hover:text-ink">
                            Course
                        </Link>{' / '}
                    </>
                )}
                <span className="text-ink">{isNew ? 'New lesson' : form.title || 'Lesson'}</span>
            </nav>
            <h1 className="text-2xl font-semibold tracking-tight mb-6">
                {isNew ? 'New lesson' : 'Edit lesson'}
            </h1>

            <div className="grid lg:grid-cols-[1fr_360px] gap-6">
                <form onSubmit={(e) => { e.preventDefault(); onSave(); }} className="space-y-5">
                    <div className="card space-y-4">
                        <Row label="Course">
                            <select className="field" value={form.courseId}
                                    onChange={(e) => update('courseId', e.target.value)} required>
                                <option value="" disabled>— select —</option>
                                {(allCourses ?? []).map(c => (
                                    <option key={c.id} value={c.id}>{c.category} · {c.title}</option>
                                ))}
                            </select>
                        </Row>
                        <div className="grid grid-cols-[2fr_1fr] gap-3">
                            <Row label="Title">
                                <input className="field" value={form.title}
                                       onChange={(e) => update('title', e.target.value)} required />
                            </Row>
                            <Row label="Display order">
                                <input className="field" type="number" value={form.displayOrder ?? 0}
                                       onChange={(e) => update('displayOrder', parseInt(e.target.value, 10) || 0)} />
                            </Row>
                        </div>
                        <Row label="Slug" hint="Unique within the course. URL-safe.">
                            <input className="field" value={form.slug}
                                   onChange={(e) => update('slug', e.target.value)} required />
                        </Row>
                        <Row label="Description (HTML)" hint="Rendered through DOMPurify. <a>, <img>, <code>, <pre>, lists, headings all allowed.">
                            <textarea className="field font-mono text-xs" rows={6}
                                      value={form.description ?? ''}
                                      onChange={(e) => update('description', e.target.value)} />
                        </Row>
                        {form.description && (
                            <div>
                                <label className="label">Description preview</label>
                                <div className="border border-muted/30 rounded-md p-3 bg-cream">
                                    <RichText html={form.description} />
                                </div>
                            </div>
                        )}
                    </div>

                    <div className="card space-y-4">
                        <h3 className="text-sm font-semibold">Shader code</h3>
                        <Row label="Starter vertex shader (informational; the FE always submits its own)">
                            <textarea className="field font-mono text-xs" rows={3}
                                      value={form.starterVertexShader ?? ''}
                                      onChange={(e) => update('starterVertexShader', e.target.value)} />
                        </Row>
                        <Row label="Starter fragment shader (loads into the student's editor)">
                            <div style={{ height: 200 }}>
                                <Editor
                                    value={form.starterFragmentShader ?? ''}
                                    onChange={(v) => update('starterFragmentShader', v)}
                                    height="200px"
                                />
                            </div>
                        </Row>
                        <Row label="Canonical fragment shader (the answer — its render is the hash)">
                            <div style={{ height: 200 }}>
                                <Editor
                                    value={form.canonicalFragmentShader ?? ''}
                                    onChange={(v) => update('canonicalFragmentShader', v)}
                                    height="200px"
                                />
                            </div>
                        </Row>
                        <button type="button" onClick={() => setPreviewBody(form.canonicalFragmentShader || form.starterFragmentShader || '')}
                                className="btn-secondary text-sm">
                            ⟳ Update preview
                        </button>
                    </div>

                    <div className="card space-y-3">
                        <label className="flex items-center gap-2 text-sm">
                            <input type="checkbox" checked={postSaveRecompute}
                                   onChange={(e) => setPostSaveRecompute(e.target.checked)} />
                            Recompute lesson hashes after saving (required for verification to work)
                        </label>
                        <div className="flex items-center gap-3">
                            <button type="submit" disabled={saving} className="btn-primary disabled:opacity-50">
                                {isNew ? 'Create lesson' : 'Save'}
                            </button>
                            {!isNew && (
                                <button type="button" onClick={onDelete} className="btn-secondary text-red-600">
                                    Delete
                                </button>
                            )}
                            {status && <span className="text-xs text-muted">{status}</span>}
                        </div>
                    </div>
                </form>

                <aside>
                    <div className="card sticky top-20">
                        <h3 className="text-sm font-semibold mb-3">Preview</h3>
                        <div className="aspect-square w-full bg-black rounded-md overflow-hidden">
                            <ShaderCanvas
                                key={previewBody}
                                initialBody={previewBody}
                            />
                        </div>
                        <p className="text-xs text-muted mt-2">
                            Animated. Click <em>Update preview</em> on the canonical to refresh.
                        </p>
                    </div>
                </aside>
            </div>
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
