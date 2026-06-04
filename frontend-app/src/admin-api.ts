// Admin endpoints are gated by the `Admin-Authorization` header. The "admin
// key" is just the API_KEY value from backend/.env. The user pastes it once
// on /admin/login; we cache it in localStorage and add it to every admin call.

import type { Course, LessonSummary } from './api';

const KEY_STORAGE = 'sd:admin-key';

export function getAdminKey(): string | null {
    try { return localStorage.getItem(KEY_STORAGE); }
    catch { return null; }
}
export function setAdminKey(k: string | null) {
    try {
        if (k) localStorage.setItem(KEY_STORAGE, k);
        else localStorage.removeItem(KEY_STORAGE);
    } catch { /* private mode / quota */ }
}
export function isAdminSignedIn(): boolean {
    const k = getAdminKey();
    return !!k && k.length > 0;
}

export interface AdminApiError { status: number; message: string; }

async function adminRequest<T = unknown>(
    method: string,
    path: string,
    opts: { body?: any; raw?: boolean } = {},
): Promise<T> {
    const key = getAdminKey();
    if (!key) throw { status: 401, message: 'Admin not signed in' } as AdminApiError;

    const headers: Record<string, string> = { 'Admin-Authorization': key };
    if (opts.body !== undefined) headers['Content-Type'] = 'application/json';

    const res = await fetch(path, {
        method,
        headers,
        body: opts.body !== undefined ? JSON.stringify(opts.body) : undefined,
    });
    const text = await res.text();
    if (!res.ok) {
        let message = res.statusText;
        try {
            const parsed = JSON.parse(text);
            message = parsed.message || parsed.error || message;
        } catch { if (text) message = text; }
        throw { status: res.status, message } as AdminApiError;
    }
    if (opts.raw) return text as unknown as T;
    if (!text) return undefined as T;
    try { return JSON.parse(text) as T; }
    catch { return text as unknown as T; }
}

// ─── Course payloads ─────────────────────────────────────────────────
export interface CreateCoursePayload {
    slug: string;
    title: string;
    description?: string;
    category?: string;
    difficulty?: 'beginner' | 'intermediate' | 'advanced';
    displayOrder?: number;
}
export type UpdateCoursePayload = Partial<CreateCoursePayload>;

// ─── Lesson payloads ─────────────────────────────────────────────────
export interface AdminLesson {
    id: string;
    courseId: string | null;
    courseSlug: string | null;
    courseTitle: string | null;
    slug: string;
    title: string;
    displayOrder: number;
    description: string | null;
    starterVertexShader: string | null;
    starterFragmentShader: string | null;
    verified: boolean;
}
export interface AdminLessonSolution {
    id: string;
    title: string;
    canonicalFragmentShader: string | null;
    starterVertexShader: string | null;
    conciergeHint: string | null;
}
export interface CreateLessonPayload {
    courseId: string;
    slug?: string;
    displayOrder?: number;
    title: string;
    description?: string;
    starterVertexShader?: string;
    starterFragmentShader?: string;
    canonicalFragmentShader?: string;
    conciergeHint?: string;
    hashedAnswer?: string;
}
export type UpdateLessonPayload = Partial<Omit<CreateLessonPayload, 'courseId'>>;

export interface RecomputeResult {
    updated: { id: string; title: string; hash: string }[];
    skipped: { id: string; title: string; reason: string }[];
    failed:  { id: string; title: string; error: string }[];
    verificationTime: number;
}

export const adminApi = {
    // Reuses the public GET endpoints for read paths — no admin auth needed for reads.
    listCourses: () =>
        fetch('/app/courses').then(r => r.json()) as Promise<Course[]>,
    getCourse: (slug: string) =>
        fetch(`/app/courses/${encodeURIComponent(slug)}`).then(r => {
            if (!r.ok) throw { status: r.status, message: r.statusText } as AdminApiError;
            return r.json() as Promise<Course & { lessons: LessonSummary[] }>;
        }),
    getLesson: (id: string) =>
        fetch(`/app/lessons/${encodeURIComponent(id)}`).then(r => {
            if (!r.ok) throw { status: r.status, message: r.statusText } as AdminApiError;
            return r.json() as Promise<AdminLesson>;
        }),
    getLessonSolution: (id: string) =>
        fetch(`/app/lessons/${encodeURIComponent(id)}/solution`).then(r => {
            if (!r.ok) throw { status: r.status, message: r.statusText } as AdminApiError;
            return r.json() as Promise<AdminLessonSolution>;
        }),

    createCourse: (body: CreateCoursePayload) =>
        adminRequest<Course>('POST', '/app/courses', { body }),
    updateCourse: (id: string, body: UpdateCoursePayload) =>
        adminRequest<Course>('PUT', `/app/courses/${encodeURIComponent(id)}`, { body }),
    deleteCourse: (id: string) =>
        adminRequest<void>('DELETE', `/app/courses/${encodeURIComponent(id)}`),

    createLesson: (body: CreateLessonPayload) =>
        adminRequest<AdminLesson>('POST', '/app/lessons', { body }),
    updateLesson: (id: string, body: UpdateLessonPayload) =>
        adminRequest<AdminLesson>('PUT', `/app/lessons/${encodeURIComponent(id)}`, { body }),
    deleteLesson: (id: string) =>
        adminRequest<void>('DELETE', `/app/lessons/${encodeURIComponent(id)}`),

    recomputeHashes: () =>
        adminRequest<RecomputeResult>('POST', '/app/lessons/recompute-hashes'),
};
