// Thin fetch wrapper. All paths are origin-relative; nginx proxies /auth/* and /app/* to the API.

export type ApiError = { status: number; message: string };

export interface LessonSummary {
    id: string;
    slug: string;
    title: string;
    displayOrder: number;
    verified: boolean;
}
export interface Course {
    id: string;
    slug: string;
    title: string;
    description: string | null;
    displayOrder: number;
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
export type AttemptStatus = 'SUCCESSFUL' | 'FAILED' | 'UNATTEMPTED';
export interface AttemptResponse {
    count: number;
    status: AttemptStatus;
}
export interface AccountResponse {
    username: string;
    email: string | null;
    country: string | null;
    bio: string | null;
}

const TOKEN_KEY = 'token';

export function getToken(): string | null {
    return localStorage.getItem(TOKEN_KEY);
}
export function setToken(t: string | null) {
    if (t) localStorage.setItem(TOKEN_KEY, t);
    else   localStorage.removeItem(TOKEN_KEY);
}

async function request<T = unknown>(
    method: string,
    path: string,
    opts: { body?: any; auth?: boolean; raw?: boolean } = {},
): Promise<T> {
    const headers: Record<string, string> = {};
    if (opts.body !== undefined) headers['Content-Type'] = 'application/json';
    if (opts.auth) {
        const token = getToken();
        if (!token) throw { status: 401, message: 'Not signed in' } as ApiError;
        headers['Authorization'] = `Bearer ${token}`;
    }

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

// ─── auth ────────────────────────────────────────────────────────────
export const authApi = {
    login: (username: string, password: string) =>
        request<string>('POST', '/auth/login', { body: { username, password }, raw: true }),
    register: (username: string, password: string, email?: string) =>
        request<string>('POST', '/auth/register', { body: { username, password, email }, raw: true }),
};

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
    verify: (lessonId: string, fragmentShader: string) =>
        request<string>('POST', '/app/lessons/verify', {
            body: { lessonId, fragmentShader, vertexShader: '', time: 20 },
            auth: true,
            raw: true,
        }),
};

// ─── comments ────────────────────────────────────────────────────────
export const commentsApi = {
    list: (lessonId: string) =>
        request<Comment[]>('GET', `/app/comments/${encodeURIComponent(lessonId)}`),
    post: (lessonId: string, code: string, content: string) =>
        request<Comment>('POST', `/app/account/comment/${encodeURIComponent(lessonId)}`, {
            body: { code, content },
            auth: true,
        }),
};

// ─── account ─────────────────────────────────────────────────────────
export const accountApi = {
    me: () => request<AccountResponse>('GET', '/app/account', { auth: true }),
    status: (lessonId: string) =>
        request<AttemptResponse>('GET', `/app/account/status/${encodeURIComponent(lessonId)}`, { auth: true }),
    updateProfile: (data: { email?: string; country?: string; bio?: string }) =>
        request<string>('POST', '/app/account/profile_info', { body: data, auth: true, raw: true }),
    updateAccount: (data: { username: string; password: string; oldPassword: string }) =>
        request<string>('POST', '/app/account/account_info', { body: data, auth: true, raw: true }),
};
