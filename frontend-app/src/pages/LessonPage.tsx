import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { Link, useNavigate, useParams } from 'react-router-dom';
import {
    accountApi, coursesApi, lessonsApi,
    type AttemptResponse, type Course, type Lesson,
} from '../api';
import { useAuth } from '../auth';
import { isLocallyCompleted, markLocallyCompleted } from '../completion';
import { Editor } from '../components/Editor';
import { Modal } from '../components/Modal';
import { RichText } from '../components/RichText';
import { ShaderCanvas, type ShaderCanvasHandle } from '../components/ShaderCanvas';
import { FRAGMENT_HEADER } from '../shader-pipeline';

type Verdict = 'idle' | 'verifying' | 'correct' | 'incorrect' | 'error';

const PANE_HEIGHT = 460;
const PANE_HEADER_HEIGHT = 40;          // matches `h-10` on the pane header
const PANE_BODY_HEIGHT = PANE_HEIGHT - PANE_HEADER_HEIGHT;

export function LessonPage() {
    const { id = '' } = useParams();
    const navigate = useNavigate();
    const { isAuthed } = useAuth();

    const [lesson, setLesson] = useState<Lesson | null>(null);
    const [course, setCourse] = useState<Course | null>(null);
    const [loadError, setLoadError] = useState<string | null>(null);
    const [code, setCode] = useState<string>('');
    const [attempt, setAttempt] = useState<AttemptResponse | null>(null);
    const [verdict, setVerdict] = useState<Verdict>('idle');
    const [verdictMsg, setVerdictMsg] = useState<string>('');

    const canvasRef = useRef<ShaderCanvasHandle | null>(null);

    // ── Load lesson + parent course (for breadcrumb / next-lesson) ────
    useEffect(() => {
        let cancelled = false;
        setLesson(null); setCourse(null); setLoadError(null); setVerdict('idle');
        lessonsApi.get(id)
            .then(l => {
                if (cancelled) return;
                setLesson(l);
                setCode(l.starterFragmentShader ?? '');
                if (l.courseSlug) {
                    coursesApi.bySlug(l.courseSlug)
                        .then(c => { if (!cancelled) setCourse(c); })
                        .catch(() => {});
                }
            })
            .catch((e: any) => !cancelled && setLoadError(e.message ?? 'Lesson not found'));
        return () => { cancelled = true; };
    }, [id]);

    // Authed users get server-side attempt status (used for the badge)
    useEffect(() => {
        if (!isAuthed || !lesson) { setAttempt(null); return; }
        accountApi.status(lesson.id).then(setAttempt).catch(() => {});
    }, [isAuthed, lesson]);

    const nextLesson = useMemo(() => {
        if (!course || !lesson) return null;
        const idx = course.lessons.findIndex(l => l.id === lesson.id);
        return (idx >= 0 && idx + 1 < course.lessons.length) ? course.lessons[idx + 1] : null;
    }, [course, lesson]);

    const run = useCallback(() => {
        if (!canvasRef.current) return;
        const ok = canvasRef.current.run(code);
        if (!ok) {
            setVerdict('error');
            setVerdictMsg('GLSL compile error — check your browser devtools console for the line.');
        } else if (verdict === 'error') {
            setVerdict('idle');
        }
    }, [code, verdict]);

    const submit = useCallback(async () => {
        if (!lesson) return;
        canvasRef.current?.run(code);
        setVerdict('verifying'); setVerdictMsg('');
        try {
            await lessonsApi.verify(lesson.id, FRAGMENT_HEADER + code);
            setVerdict('correct');
            setVerdictMsg('Solved.');
            // Anonymous users persist completion in localStorage; authed users
            // also get it stashed locally so subsequent navigation is instant.
            markLocallyCompleted(lesson.id);
        } catch (e: any) {
            if (e?.status === 400) {
                setVerdict('incorrect');
                setVerdictMsg("Not quite — your output didn't match.");
            } else {
                setVerdict('error');
                setVerdictMsg(e?.message ?? 'Verification failed.');
            }
        } finally {
            if (isAuthed && lesson) {
                accountApi.status(lesson.id).then(setAttempt).catch(() => {});
            }
        }
    }, [code, isAuthed, lesson]);

    const resetCode = useCallback(() => {
        if (lesson?.starterFragmentShader) setCode(lesson.starterFragmentShader);
    }, [lesson]);

    const goToNext = useCallback(() => {
        if (nextLesson) navigate(`/lesson/${nextLesson.id}`);
        else if (course) navigate(`/courses?slug=${course.slug}`);
        else navigate('/courses');
    }, [navigate, nextLesson, course]);

    const goToDiscussion = useCallback(() => {
        if (lesson) navigate(`/lesson/${lesson.id}/discussion`);
    }, [navigate, lesson]);

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
            <nav className="text-xs text-muted mb-3 flex items-center gap-1.5 flex-wrap">
                <Link to="/courses" className="hover:text-ink">Courses</Link>
                <span>/</span>
                {lesson.courseSlug ? (
                    <Link
                        to={`/courses?slug=${encodeURIComponent(lesson.courseSlug)}`}
                        className="hover:text-ink">
                        {lesson.courseTitle ?? lesson.courseSlug}
                    </Link>
                ) : (
                    lesson.courseTitle && <span>{lesson.courseTitle}</span>
                )}
                {(lesson.courseSlug || lesson.courseTitle) && <span>/</span>}
                <span className="text-ink">{lesson.title}</span>
            </nav>

            <header className="flex items-baseline justify-between gap-4 mb-3">
                <h1 className="text-2xl md:text-3xl font-semibold tracking-tight">{lesson.title}</h1>
                <AttemptBadge
                    attempt={attempt}
                    locallyCompleted={isLocallyCompleted(lesson.id)}
                    verified={lesson.verified}
                    authed={isAuthed}
                />
            </header>

            {lesson.description && (
                <RichText html={lesson.description} className="mb-6 max-w-3xl" />
            )}

            <div className="grid lg:grid-cols-2 gap-4">
                <section className="border border-muted/30 rounded-xl bg-white overflow-hidden flex flex-col"
                         style={{ height: PANE_HEIGHT }}>
                    <div className="flex items-center justify-between px-4 h-10 border-b border-muted/30 bg-cream flex-shrink-0">
                        <span className="text-[11px] font-semibold uppercase tracking-wide text-ink/60">
                            Fragment shader
                        </span>
                        <button onClick={resetCode} className="text-xs text-muted hover:text-ink" title="Reset to starter code">
                            ↻ Reset
                        </button>
                    </div>
                    <div className="flex-1 min-h-0">
                        <Editor value={code} onChange={setCode} height={`${PANE_BODY_HEIGHT}px`} />
                    </div>
                </section>

                <section className="border border-muted/30 rounded-xl bg-white overflow-hidden flex flex-col"
                         style={{ height: PANE_HEIGHT }}>
                    <div className="flex items-center justify-between px-4 h-10 border-b border-muted/30 bg-cream flex-shrink-0">
                        <span className="text-[11px] font-semibold uppercase tracking-wide text-ink/60">
                            Output
                        </span>
                    </div>
                    <div className="flex-1 min-h-0 bg-black">
                        <ShaderCanvas
                            key={lesson.id}
                            ref={canvasRef}
                            initialBody={code || lesson.starterFragmentShader || ''}
                        />
                    </div>
                </section>
            </div>

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

            <Modal
                open={verdict === 'correct'}
                onOpenChange={(o) => !o && setVerdict('idle')}
                title="Solved"
                description={nextLesson
                    ? `On to "${nextLesson.title}" when you're ready — or jump into the discussion.`
                    : 'You finished the course. Take a look at the discussion or pick another from the list.'}
                footer={
                    <>
                        <button className="btn-secondary" onClick={goToDiscussion}>
                            View discussion
                        </button>
                        <button className="btn-primary" onClick={goToNext}>
                            {nextLesson ? 'Next lesson →' : 'Back to courses'}
                        </button>
                    </>
                }
            />
        </div>
    );
}

function AttemptBadge({ attempt, locallyCompleted, verified, authed }: {
    attempt: AttemptResponse | null;
    locallyCompleted: boolean;
    verified: boolean;
    authed: boolean;
}) {
    if (!verified) return <span className="pill-explore">Exploratory</span>;

    // Anonymous users get a localStorage-only verdict.
    if (!authed) {
        return locallyCompleted
            ? <span className="pill-passed">Solved</span>
            : <span className="pill-explore">Submit anytime — no sign-in needed</span>;
    }

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
    if (!verified) return <p className="text-xs text-muted italic">Exploratory lesson — no automatic grading.</p>;
    if (verdict === 'verifying') return <p className="text-xs text-muted">Rendering and comparing…</p>;
    if (verdict === 'correct')   return <p className="text-xs text-green-700">✓ Correct</p>;
    if (verdict === 'incorrect') return <p className="text-xs text-amber-700">{message || 'Not quite — try again.'}</p>;
    if (verdict === 'error')     return <p className="text-xs text-red-600">{message}</p>;
    return <p className="text-xs text-muted">Click <b>Run</b> to preview, <b>Submit</b> to grade.</p>;
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
