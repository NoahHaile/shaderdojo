import { useEffect, useRef, useState } from 'react';
import { markStargazed } from '../stargazed';

interface Msg { role: 'user' | 'assistant'; content: string; }

interface Props {
    lessonId: string;
    /** The shader code the learner is currently editing. */
    code: string;
    /** Last WebGL compile error, or null if the shader compiled. */
    compileError: string | null;
}

/**
 * Per-lesson AI tutor styled as a shell terminal.
 *
 * Streams chunked text/plain responses from POST /app/lessons/:id/concierge.
 * The current code and (if any) compile error travel with every request so
 * Concierge sees what the learner sees.
 */
export function ConciergeTerminal({ lessonId, code, compileError }: Props) {
    const [history, setHistory] = useState<Msg[]>([]);
    const [input, setInput] = useState('');
    const [streaming, setStreaming] = useState(false);
    const [streamedText, setStreamedText] = useState('');
    const [errorBanner, setErrorBanner] = useState<string | null>(null);
    const scrollRef = useRef<HTMLDivElement>(null);
    const inputRef = useRef<HTMLInputElement>(null);

    // Reset state when the lesson changes (LessonPage re-mounts via key, but be defensive).
    useEffect(() => {
        setHistory([]);
        setInput('');
        setStreaming(false);
        setStreamedText('');
        setErrorBanner(null);
    }, [lessonId]);

    // Stick to the bottom as new tokens stream in.
    useEffect(() => {
        const el = scrollRef.current;
        if (!el) return;
        el.scrollTop = el.scrollHeight;
    }, [history, streamedText, errorBanner]);

    async function submit(text: string) {
        const trimmed = text.trim();
        if (!trimmed || streaming) return;

        const nextHistory: Msg[] = [...history, { role: 'user', content: trimmed }];
        setHistory(nextHistory);
        setInput('');
        setStreaming(true);
        setStreamedText('');
        setErrorBanner(null);

        try {
            const res = await fetch(`/app/lessons/${encodeURIComponent(lessonId)}/concierge`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    messages: nextHistory,
                    code,
                    compileError,
                }),
            });

            if (!res.ok || !res.body) {
                const errText = await res.text().catch(() => `HTTP ${res.status}`);
                setErrorBanner(errText || `HTTP ${res.status}`);
                setHistory(nextHistory); // keep the user turn; drop the failed assistant slot
                return;
            }

            const reader = res.body.getReader();
            const decoder = new TextDecoder();
            let full = '';
            while (true) {
                const { value, done } = await reader.read();
                if (done) break;
                full += decoder.decode(value, { stream: true });
                setStreamedText(full);
            }
            full += decoder.decode(); // flush

            setHistory([...nextHistory, { role: 'assistant', content: full }]);
            setStreamedText('');
            markStargazed(lessonId);
        } catch (e: any) {
            setErrorBanner(e?.message ?? 'network error');
        } finally {
            setStreaming(false);
            // Refocus so the learner can keep typing.
            queueMicrotask(() => inputRef.current?.focus());
        }
    }

    return (
        <div className="rounded-md overflow-hidden border border-emerald-900/50 bg-[#0a0d10] shadow-inner">
            {/* Title bar — three traffic lights for the shell feel. */}
            <div className="flex items-center gap-2 px-3 py-1.5 bg-[#13181d] border-b border-emerald-900/40">
                <span className="w-2.5 h-2.5 rounded-full bg-red-500/70" />
                <span className="w-2.5 h-2.5 rounded-full bg-yellow-500/70" />
                <span className="w-2.5 h-2.5 rounded-full bg-green-500/70" />
                <span className="ml-3 font-mono text-[11px] text-emerald-300/70 tracking-wide">
                    concierge@shaderdojo:~$
                </span>
                {compileError && (
                    <span className="ml-auto font-mono text-[10px] text-amber-400/90">
                        ! shader did not compile
                    </span>
                )}
            </div>

            {/* Scroll area */}
            <div
                ref={scrollRef}
                className="h-72 overflow-y-auto px-3 py-2 font-mono text-[13px] leading-relaxed text-emerald-200/90"
                role="log"
                aria-live="polite">
                {history.length === 0 && !streaming && !errorBanner && (
                    <div className="text-emerald-300/40 space-y-1">
                        <p>Concierge sees your code and your last compile error.</p>
                        <p>Try one of these:</p>
                        <p className="text-emerald-400/60">{`> what does this lesson teach?`}</p>
                        <p className="text-emerald-400/60">{`> trace pixel (0.5, 0.5) through my code`}</p>
                        <p className="text-emerald-400/60">{`> why does my shader not compile?`}</p>
                    </div>
                )}

                {history.map((msg, i) => (
                    msg.role === 'user' ? (
                        <div key={i} className="mt-2">
                            <span className="text-emerald-500">$ </span>
                            <span className="text-emerald-100">{msg.content}</span>
                        </div>
                    ) : (
                        <div key={i} className="mt-2 whitespace-pre-wrap">
                            <span className="text-amber-300">✦ </span>
                            <span>{msg.content}</span>
                        </div>
                    )
                ))}

                {streaming && (
                    <div className="mt-2 whitespace-pre-wrap">
                        <span className="text-amber-300">✦ </span>
                        <span>{streamedText}</span>
                        <span className="inline-block w-2 h-4 ml-0.5 bg-emerald-300/80 align-middle animate-pulse" />
                    </div>
                )}

                {errorBanner && (
                    <div className="mt-2 text-red-400">
                        <span>! {errorBanner}</span>
                    </div>
                )}
            </div>

            {/* Prompt input */}
            <form
                onSubmit={(e) => { e.preventDefault(); submit(input); }}
                className="flex items-center gap-2 px-3 py-2 border-t border-emerald-900/40 bg-[#0a0d10]">
                <span className="font-mono text-emerald-500">$</span>
                <input
                    ref={inputRef}
                    type="text"
                    value={input}
                    onChange={(e) => setInput(e.target.value)}
                    disabled={streaming}
                    placeholder={
                        streaming
                            ? '…streaming…'
                            : compileError
                                ? 'compile failed — ask why'
                                : 'ask the concierge anything about this lesson'
                    }
                    aria-label="ask Concierge"
                    spellCheck={false}
                    autoComplete="off"
                    className="flex-1 bg-transparent outline-none font-mono text-[13px] text-emerald-100 placeholder:text-emerald-500/40 disabled:opacity-50"
                />
                <button
                    type="submit"
                    disabled={streaming || !input.trim()}
                    className="font-mono text-[11px] uppercase tracking-wider text-emerald-300 hover:text-emerald-100 disabled:text-emerald-700 disabled:cursor-not-allowed">
                    send ↵
                </button>
            </form>
        </div>
    );
}
