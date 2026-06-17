// Thin fetch wrapper. All paths are origin-relative; nginx proxies /auth/* and /app/* to the API.

export type ApiError = { status: number; message: string };

export interface LessonSummary {
    id: string;
    slug: string;
    title: string;
    displayOrder: number;
    verified: boolean;
}
export type Difficulty = 'beginner' | 'intermediate' | 'advanced';

export interface Course {
    id: string;
    slug: string;
    title: string;
    description: string | null;
    category: string;
    difficulty: Difficulty;
    displayOrder: number;
    underReview: boolean;
    lessons: LessonSummary[];
}
export interface Lesson {
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
export interface LessonSolution {
    id: string;
    title: string;
    canonicalFragmentShader: string | null;
    starterVertexShader: string | null;
}
export interface Comment {
    id: string;
    code: string | null;
    content: string | null;
    username: string | null;
}
async function request<T = unknown>(
    method: string,
    path: string,
    opts: { body?: any; raw?: boolean } = {},
): Promise<T> {
    const headers: Record<string, string> = {};
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
        throw { status: res.status, message } as ApiError;
    }

    if (opts.raw) return text as unknown as T;
    if (!text) return undefined as T;
    try { return JSON.parse(text) as T; }
    catch { return text as unknown as T; }
}

// ─── courses ─────────────────────────────────────────────────────────
export const coursesApi = {
    list: () => request<Course[]>('GET', '/app/courses'),
    bySlug: (slug: string) => request<Course>('GET', `/app/courses/${encodeURIComponent(slug)}`),
};

// ─── lessons ─────────────────────────────────────────────────────────
export const lessonsApi = {
    get: (id: string) => request<Lesson>('GET', `/app/lessons/${encodeURIComponent(id)}`),
    solution: (id: string) =>
        request<LessonSolution>('GET', `/app/lessons/${encodeURIComponent(id)}/solution`),
    // Anonymous submit: returns a verdict; no server-side attempt history.
    verify: (lessonId: string, fragmentShader: string) =>
        request<string>('POST', '/app/lessons/verify', {
            body: { lessonId, fragmentShader },
            raw: true,
        }),
};

// ─── comments ────────────────────────────────────────────────────────
export const commentsApi = {
    list: (lessonId: string) =>
        request<Comment[]>('GET', `/app/comments/${encodeURIComponent(lessonId)}`),
    // Comments save with account=null and render as Anonymous.
    post: (lessonId: string, code: string, content: string) =>
        request<Comment>('POST', `/app/comments/${encodeURIComponent(lessonId)}`, {
            body: { code, content },
        }),
};
