import { useCallback, useEffect, useRef, useState } from 'react';
import { Link, useNavigate, useParams } from 'react-router-dom';
import {
    accountApi, commentsApi, lessonsApi,
    type AttemptResponse, type Comment, type Lesson,
} from '../api';
import { useAuth } from '../auth';
import { Editor } from '../components/Editor';
import { Modal } from '../components/Modal';
import { ShaderCanvas, type ShaderCanvasHandle } from '../components/ShaderCanvas';
import { FRAGMENT_HEADER } from '../shader-pipeline';

type Verdict = 'idle' | 'verifying' | 'correct' | 'incorrect' | 'error';

export function LessonPage() {
    const { id = '' } = useParams();
    const navigate = useNavigate();
    const { isAuthed } = useAuth();

    const [lesson, setLesson] = useState<Lesson | null>(null);
    const [loadError, setLoadError] = useState<string | null>(null);
    const [code, setCode] = useState<string>('');
    const [attempt, setAttempt] = useState<AttemptResponse | null>(null);
    const [verdict, setVerdict] = useState<Verdict>('idle');
    const [verdictMsg, setVerdictMsg] = useState<string>('');

    const canvasRef = useRef<ShaderCanvasHandle | null>(null);

    // ── Load lesson ───────────────────────────────────────────────────
    useEffect(() => {
        let cancelled = false;
        setLesson(null); setLoadError(null); setVerdict('idle');
        lessonsApi.get(id)
            .then(l => {
                if (cancelled) return;
                setLesson(l);
                setCode(l.starterFragmentShader ?? '');
            })
            .catch((e: any) => !cancelled && setLoadError(e.message ?? 'Lesson not found'));
        return () => { cancelled = true; };
    }, [id]);

    // ── Load attempt status when authed ───────────────────────────────
    useEffect(() => {
        if (!isAuthed || !lesson) return;
        accountApi.status(lesson.id).then(setAttempt).catch(() => {});
    }, [isAuthed, lesson]);

    // ── Run / Submit ──────────────────────────────────────────────────
    const run = useCallback(() => {
        if (!canvasRef.current) return;
        const ok = canvasRef.current.run(code);
        if (!ok) {
            setVerdict('error');
            setVerdictMsg('GLSL compile error — check console / browser devtools.');
        }
    }, [code]);

    const submit = useCallback(async () => {
        if (!lesson) return;
        if (!isAuthed) {
            navigate(`/login?from=${encodeURIComponent(`/lesson/${lesson.id}`)}`);
            return;
        }
        // Always run the latest code locally first
        canvasRef.current?.run(code);
        setVerdict('verifying'); setVerdictMsg('');
        try {
            await lessonsApi.verify(lesson.id, FRAGMENT_HEADER + code);
            setVerdict('correct');
            setVerdictMsg('Solved.');
        } catch (e: any) {
            if (e?.status === 400) {
                setVerdict('incorrect');
                setVerdictMsg('Not quite — your output didn\'t match.');
            } else {
                setVerdict('error');
                setVerdictMsg(e?.message ?? 'Verification failed.');
            }
        } finally {
            accountApi.status(lesson.id).then(setAttempt).catch(() => {});
        }
    }, [code, isAuthed, lesson, navigate]);

    const resetCode = useCallback(() => {
        if (lesson?.starterFragmentShader) setCode(lesson.starterFragmentShader);
    }, [lesson]);

    if (loadError) {
        return (
            <div className="max-w-3xl mx-auto px-4 py-12">
                <h1 className="text-2xl font-semibold mb-2">Lesson not found</h1>
                <p className="text-ink/60 mb-4">{loadError}</p>
                <Link to="/courses" className="btn-secondary">Back to courses</Link>
            </div>
        );
    }
    if (!lesson) return <LessonSkeleton />;

    return (
        <div className="max-w-6xl mx-auto px-4 py-6">
            {/* Breadcrumb */}
            <nav className="text-xs text-muted mb-3 flex items-center gap-1.5">
                <Link to="/courses" className="hover:text-ink">Courses</Link>
                <span>/</span>
                {lesson.courseTitle && <span>{lesson.courseTitle}</span>}
                {lesson.courseTitle && <span>/</span>}
                <span className="text-ink">{lesson.title}</span>
            </nav>

            {/* Title + status */}
            <header className="flex items-baseline justify-between gap-4 mb-2">
                <h1 className="text-2xl md:text-3xl font-semibold tracking-tight">{lesson.title}</h1>
                <AttemptBadge attempt={attempt} verified={lesson.verified} authed={isAuthed} />
            </header>
            {lesson.description && (
                <p className="text-sm text-ink/70 mb-6 whitespace-pre-wrap leading-relaxed">
                    {lesson.description}
                </p>
            )}

            {/* Workspace: editor (left) + canvas (right) */}
            <div className="grid lg:grid-cols-2 gap-4">
                <section className="border border-muted/30 rounded-xl bg-white overflow-hidden flex flex-col">
                    <div className="flex items-center justify-between px-4 h-10 border-b border-muted/30 bg-cream">
                        <span className="text-[11px] font-semibold uppercase tracking-wide text-ink/60">
                            Fragment shader
                        </span>
                        <button
                            onClick={resetCode}
                            className="text-xs text-muted hover:text-ink"
                            title="Reset to starter code">
                            ↻ Reset
                        </button>
                    </div>
                    <div className="flex-1 min-h-[420px]">
                        <Editor value={code} onChange={setCode} height="420px" />
                    </div>
                </section>

                <section className="border border-muted/30 rounded-xl bg-white overflow-hidden flex flex-col">
                    <div className="flex items-center justify-between px-4 h-10 border-b border-muted/30 bg-cream">
                        <span className="text-[11px] font-semibold uppercase tracking-wide text-ink/60">
                            Output
                        </span>
                    </div>
                    <div className="aspect-square w-full bg-black">
                        <ShaderCanvas
                            key={lesson.id}                       /* remount when lesson changes */
                            ref={canvasRef}
                            initialBody={code || lesson.starterFragmentShader || ''}
                        />
                    </div>
                </section>
            </div>

            {/* Actions */}
            <div className="mt-4 flex items-center justify-between flex-wrap gap-3">
                <VerdictBanner verdict={verdict} message={verdictMsg} verified={lesson.verified} />
                <div className="flex gap-2">
                    <button onClick={run} className="btn-secondary">Run</button>
                    <button
                        onClick={submit}
                        disabled={!lesson.verified || verdict === 'verifying'}
                        className="btn-primary disabled:opacity-50 disabled:cursor-not-allowed">
                        {verdict === 'verifying' ? 'Verifying…' : 'Submit'}
                    </button>
                </div>
            </div>

            {/* Discussion */}
            <Discussion lessonId={lesson.id} isAuthed={isAuthed} />

            {/* Result modal */}
            <Modal
                open={verdict === 'correct'}
                onOpenChange={(o) => !o && setVerdict('idle')}
                title="Solved"
                description="Your output matched. Pick the next lesson when you're ready."
                footer={
                    <>
                        <button className="btn-secondary" onClick={() => setVerdict('idle')}>Keep tweaking</button>
                        <Link className="btn-primary" to="/courses">Back to course</Link>
                    </>
                }
            />
        </div>
    );
}

// ─── helpers ─────────────────────────────────────────────────────────

function AttemptBadge({ attempt, verified, authed }: {
    attempt: AttemptResponse | null; verified: boolean; authed: boolean;
}) {
    if (!verified) return <span className="pill-explore">Exploratory</span>;
    if (!authed) return <span className="pill-explore">Sign in to submit</span>;
    if (!attempt) return <span className="pill-explore">Loading status…</span>;
    if (attempt.status === 'SUCCESSFUL') {
        return <span className="pill-passed">Solved · {attempt.count} attempt{attempt.count === 1 ? '' : 's'}</span>;
    }
    if (attempt.status === 'FAILED') {
        return <span className="pill-failed">Attempted · {attempt.count}</span>;
    }
    return <span className="pill-explore">Unattempted</span>;
}

function VerdictBanner({ verdict, message, verified }: {
    verdict: Verdict; message: string; verified: boolean;
}) {
    if (!verified) {
        return (
            <p className="text-xs text-muted italic">
                Exploratory lesson — no automatic grading.
            </p>
        );
    }
    if (verdict === 'verifying') return <p className="text-xs text-muted">Rendering and comparing…</p>;
    if (verdict === 'correct')   return <p className="text-xs text-green-700">✓ Correct</p>;
    if (verdict === 'incorrect') return <p className="text-xs text-amber-700">{message || 'Not quite — try again.'}</p>;
    if (verdict === 'error')     return <p className="text-xs text-red-600">{message}</p>;
    return <p className="text-xs text-muted">Click <b>Run</b> to preview, <b>Submit</b> to grade.</p>;
}

function Discussion({ lessonId, isAuthed }: { lessonId: string; isAuthed: boolean }) {
    const [comments, setComments] = useState<Comment[] | null>(null);
    const [code, setCode] = useState('');
    const [content, setContent] = useState('');
    const [posting, setPosting] = useState(false);
    const [postError, setPostError] = useState<string | null>(null);

    const refresh = useCallback(() => {
        commentsApi.list(lessonId).then(setComments).catch(() => setComments([]));
    }, [lessonId]);

    useEffect(() => { refresh(); }, [refresh]);

    async function submit(e: React.FormEvent) {
        e.preventDefault();
        if (!code.trim() && !content.trim()) return;
        setPosting(true); setPostError(null);
        try {
            await commentsApi.post(lessonId, code, content);
            setCode(''); setContent('');
            refresh();
        } catch (err: any) {
            setPostError(err?.message ?? 'Failed to post.');
        } finally {
            setPosting(false);
        }
    }

    return (
        <section className="mt-12 border-t border-muted/30 pt-8">
            <h2 className="text-xl font-semibold mb-4">Discussion</h2>

            {comments === null && <p className="text-sm text-muted">Loading…</p>}
            {comments && comments.length === 0 && (
                <p className="text-sm text-muted">No alternative solutions posted yet.</p>
            )}
            {comments && comments.length > 0 && (
                <ul className="space-y-3 mb-8">
                    {comments.map(c => <CommentCard key={c.id} comment={c} />)}
                </ul>
            )}

            {isAuthed ? (
                <form onSubmit={submit} className="space-y-3">
                    <div>
                        <label className="label">Your code</label>
                        <textarea
                            value={code}
                            onChange={(e) => setCode(e.target.value)}
                            rows={6}
                            className="field font-mono text-sm"
                            placeholder="void main() { ... }"
                        />
                    </div>
                    <div>
                        <label className="label">Description</label>
                        <input
                            value={content}
                            onChange={(e) => setContent(e.target.value)}
                            className="field"
                            placeholder="One-line description of what's different"
                        />
                    </div>
                    {postError && <p className="text-xs text-red-600">{postError}</p>}
                    <button type="submit" className="btn-primary" disabled={posting}>
                        {posting ? 'Posting…' : 'Post solution'}
                    </button>
                </form>
            ) : (
                <p className="text-sm text-muted">
                    <Link to={`/login?from=${encodeURIComponent(`/lesson/${lessonId}`)}`} className="text-accent hover:underline">
                        Sign in
                    </Link>{' '}to post your own solution.
                </p>
            )}
        </section>
    );
}

function CommentCard({ comment }: { comment: Comment }) {
    const [copied, setCopied] = useState(false);
    function copy() {
        if (!comment.code) return;
        navigator.clipboard.writeText(comment.code).then(() => {
            setCopied(true);
            setTimeout(() => setCopied(false), 1000);
        }).catch(() => {});
    }
    return (
        <li className="card">
            <div className="flex items-center justify-between mb-3">
                <p className="text-sm font-medium text-ink">{comment.username ?? 'unknown'}</p>
                {comment.code && (
                    <button
                        onClick={copy}
                        className="text-xs text-muted hover:text-ink border border-muted/30 rounded-md px-2 py-1">
                        {copied ? 'Copied' : 'Copy code'}
                    </button>
                )}
            </div>
            {comment.content && <p className="text-sm text-ink/80 mb-2 whitespace-pre-wrap">{comment.content}</p>}
            {comment.code && (
                <pre className="text-xs font-mono bg-cream border border-muted/20 rounded-md p-3 overflow-x-auto whitespace-pre">
                    {comment.code}
                </pre>
            )}
        </li>
    );
}

function LessonSkeleton() {
    return (
        <div className="max-w-6xl mx-auto px-4 py-8">
            <div className="h-3 w-40 bg-cream rounded animate-pulse mb-4" />
            <div className="h-8 w-2/3 bg-cream rounded animate-pulse mb-2" />
            <div className="h-3 w-full max-w-prose bg-cream rounded animate-pulse mb-6" />
            <div className="grid lg:grid-cols-2 gap-4">
                <div className="h-[460px] bg-cream rounded-xl animate-pulse" />
                <div className="h-[460px] bg-cream rounded-xl animate-pulse" />
            </div>
        </div>
    );
}
