// Tracks which lessons the learner has consulted Concierge on.
// One small "stargazed" star is earned per lesson on first message sent.
// Stored client-side only; no server round-trip.

const KEY = 'stargazedLessons';

function read(): Set<string> {
    try {
        const raw = localStorage.getItem(KEY);
        return raw ? new Set(JSON.parse(raw)) : new Set();
    } catch { return new Set(); }
}

export function isStargazed(lessonId: string): boolean {
    return read().has(lessonId);
}

export function markStargazed(lessonId: string): void {
    const set = read();
    if (set.has(lessonId)) return;
    set.add(lessonId);
    try { localStorage.setItem(KEY, JSON.stringify([...set])); }
    catch { /* ignore */ }
    window.dispatchEvent(new Event('stargazed-changed'));
}

export function stargazedCount(): number {
    return read().size;
}
