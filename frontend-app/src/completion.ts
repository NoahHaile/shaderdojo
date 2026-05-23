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

// ─── per-lesson code autosave ────────────────────────────────────────
// Keyed by lesson id so multiple lessons coexist. Cleared by explicit
// reset in the UI (the ↻ button), not on submit.

const CODE_PREFIX = 'sd:lesson-code:';

export function loadLessonCode(lessonId: string): string | null {
    try { return localStorage.getItem(CODE_PREFIX + lessonId); }
    catch { return null; }
}
export function saveLessonCode(lessonId: string, code: string) {
    try { localStorage.setItem(CODE_PREFIX + lessonId, code); }
    catch { /* quota / private mode */ }
}
export function clearLessonCode(lessonId: string) {
    try { localStorage.removeItem(CODE_PREFIX + lessonId); }
    catch { /* noop */ }
}
