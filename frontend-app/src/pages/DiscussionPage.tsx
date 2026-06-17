import { useCallback, useEffect, useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import {
    commentsApi, lessonsApi,
    type Comment, type Lesson,
} from '../api';
import { isLocallyCompleted } from '../completion';

export function DiscussionPage() {
    const { id = '' } = useParams();

    const [lesson, setLesson] = useState<Lesson | null>(null);
    const [loadError, setLoadError] = useState<string | null>(null);
    const [comments, setComments] = useState<Comment[] | null>(null);

    useEffect(() => {
        let cancelled = false;
        setLesson(null); setLoadError(null);
        lessonsApi.get(id)
            .then(l => { if (!cancelled) setLesson(l); })
            .catch((e: any) => !cancelled && setLoadError(e.message ?? 'Lesson not found'));
        return () => { cancelled = true; };
    }, [id]);

    const refresh = useCallback(() => {
        commentsApi.list(id).then(setComments).catch(() => setComments([]));
    }, [id]);
    useEffect(() => { refresh(); }, [refresh]);

    if (loadError) {
        return (
            <div className="max-w-3xl mx-auto px-4 py-12">
                <h1 className="text-2xl font-semibold mb-2">Lesson not found</h1>
                <p className="text-ink/60 mb-4">{loadError}</p>
                <Link to="/courses" className="btn-secondary">Back to courses</Link>
            </div>
        );
    }
    if (!lesson) return <Skeleton />;

    const canComment = isLocallyCompleted(lesson.id);

    return (
        <div className="max-w-3xl mx-auto px-4 py-8">
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
                <Link to={`/lesson/${lesson.id}`} className="hover:text-ink">{lesson.title}</Link>
                <span>/</span>
                <span className="text-ink">Discussion</span>
            </nav>

            <header className="mb-6 flex items-baseline justify-between gap-4 flex-wrap">
                <div>
                    <h1 className="text-2xl md:text-3xl font-semibold tracking-tight">
                        {lesson.title}
                    </h1>
                    <p className="text-xs text-muted mt-1">Discussion</p>
                </div>
                <Link to={`/lesson/${lesson.id}`} className="btn-secondary text-sm">
                    ← Back to lesson
                </Link>
            </header>

            <Comments comments={comments} />

            <section className="mt-10 border-t border-muted/30 pt-6">
                {canComment ? (
                    <CommentForm lessonId={lesson.id} onPosted={refresh} />
                ) : (
                    <p className="text-sm text-muted">
                        Solve the lesson first to leave a comment.{' '}
                        <Link to={`/lesson/${lesson.id}`} className="text-accent hover:underline">
                            Open lesson →
                        </Link>
                    </p>
                )}
            </section>
        </div>
    );
}

function Comments({ comments }: { comments: Comment[] | null }) {
    if (comments === null) return <p className="text-sm text-muted">Loading comments…</p>;
    if (comments.length === 0) return <p className="text-sm text-muted">No comments yet — be the first.</p>;
    return (
        <ul className="space-y-3">
            {comments.map(c => <CommentCard key={c.id} comment={c} />)}
        </ul>
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
    const author = comment.username ?? 'Anonymous';
    return (
        <li className="card">
            <div className="flex items-center justify-between mb-3">
                <p className={'text-sm font-medium ' + (comment.username ? 'text-ink' : 'text-muted italic')}>
                    {author}
                </p>
                {comment.code && (
                    <button
                        onClick={copy}
                        className="text-xs text-muted hover:text-ink border border-muted/30 rounded-md px-2 py-1">
                        {copied ? 'Copied' : 'Copy code'}
                    </button>
                )}
            </div>
            {comment.content && (
                <p className="text-sm text-ink/80 mb-2 whitespace-pre-wrap">{comment.content}</p>
            )}
            {comment.code && (
                <pre className="text-xs font-mono bg-cream border border-muted/20 rounded-md p-3 overflow-x-auto whitespace-pre">
                    {comment.code}
                </pre>
            )}
        </li>
    );
}

function CommentForm({ lessonId, onPosted }: { lessonId: string; onPosted: () => void }) {
    const [code, setCode] = useState('');
    const [content, setContent] = useState('');
    const [posting, setPosting] = useState(false);
    const [postError, setPostError] = useState<string | null>(null);

    async function submit(e: React.FormEvent) {
        e.preventDefault();
        if (!code.trim() && !content.trim()) return;
        setPosting(true); setPostError(null);
        try {
            await commentsApi.post(lessonId, code, content);
            setCode(''); setContent('');
            onPosted();
        } catch (err: any) {
            setPostError(err?.message ?? 'Failed to post.');
        } finally {
            setPosting(false);
        }
    }

    return (
        <form onSubmit={submit} className="space-y-3">
            <h2 className="text-base font-semibold text-ink">Leave a comment</h2>
            <p className="text-xs text-muted">
                You're commenting as <strong>Anonymous</strong>.
            </p>
            <div>
                <label className="label">Code snippet (optional)</label>
                <textarea
                    value={code}
                    onChange={(e) => setCode(e.target.value)}
                    rows={5}
                    className="field font-mono text-sm"
                    placeholder="Optional — paste a snippet to share"
                />
            </div>
            <div>
                <label className="label">Comment</label>
                <input
                    value={content}
                    onChange={(e) => setContent(e.target.value)}
                    className="field"
                    placeholder="Share a note, question, or alternative approach"
                />
            </div>
            {postError && <p className="text-xs text-red-600">{postError}</p>}
            <button type="submit" className="btn-primary" disabled={posting}>
                {posting ? 'Posting…' : 'Add comment'}
            </button>
        </form>
    );
}

function Skeleton() {
    return (
        <div className="max-w-3xl mx-auto px-4 py-8">
            <div className="h-3 w-40 bg-cream rounded animate-pulse mb-4" />
            <div className="h-8 w-2/3 bg-cream rounded animate-pulse mb-6" />
            <div className="space-y-3">
                {Array.from({ length: 3 }).map((_, i) => (
                    <div key={i} className="h-24 bg-cream rounded animate-pulse" />
                ))}
            </div>
        </div>
    );
}
