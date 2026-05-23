// Tracks which lessons the current visitor has solved.
//
// For signed-in users this is just a cache; the source of truth is the
// `attempt` table on the server (accountApi.status). For anonymous users
// localStorage IS the source of truth — verify endpoint returns a verdict
// but doesn't persist anything server-side.

const KEY = 'sd:completed-lessons';

function read(): Set<string> {
    try {
        const raw = localStorage.getItem(KEY);
        if (!raw) return new Set();
        const arr = JSON.parse(raw);
        return new Set(Array.isArray(arr) ? arr.filter((x: unknown) => typeof x === 'string') : []);
    } catch { return new Set(); }
}

function write(set: Set<string>) {
    try { localStorage.setItem(KEY, JSON.stringify([...set])); } catch { /* quota / private mode */ }
}

export function isLocallyCompleted(lessonId: string): boolean {
    return read().has(lessonId);
}

export function markLocallyCompleted(lessonId: string) {
    const s = read();
    if (!s.has(lessonId)) { s.add(lessonId); write(s); }
}

/** For UI badges on courses/lessons lists — returns the full set. */
export function getCompletedLessons(): Set<string> {
    return read();
}
