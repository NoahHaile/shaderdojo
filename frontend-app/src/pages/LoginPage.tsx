import { useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { useAuth } from '../auth';

export function LoginPage() {
    const { login, register } = useAuth();
    const nav = useNavigate();
    const [params] = useSearchParams();
    const redirect = params.get('from') || '/courses';

    return (
        <div className="max-w-4xl mx-auto px-4 py-12 grid md:grid-cols-2 gap-6">
            <SignInForm onDone={() => nav(redirect, { replace: true })} login={login} />
            <SignUpForm onDone={() => nav(redirect, { replace: true })} register={register} />
        </div>
    );
}

function SignInForm({ login, onDone }: {
    login: (u: string, p: string) => Promise<void>;
    onDone: () => void;
}) {
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    const [pending, setPending]   = useState(false);
    const [error, setError]       = useState<string | null>(null);

    async function submit(e: React.FormEvent) {
        e.preventDefault();
        setError(null); setPending(true);
        try {
            await login(username, password);
            onDone();
        } catch (err: any) {
            setError(err?.status === 401 ? 'Incorrect username or password.' : (err?.message ?? 'Sign-in failed.'));
        } finally { setPending(false); }
    }

    return (
        <form onSubmit={submit} className="card space-y-4">
            <h1 className="text-xl font-semibold tracking-tight">Sign in</h1>
            <div>
                <label htmlFor="login-username" className="label">Username or email</label>
                <input id="login-username" autoComplete="username"
                       value={username} onChange={(e) => setUsername(e.target.value)}
                       className="field" required />
            </div>
            <div>
                <label htmlFor="login-password" className="label">Password</label>
                <input id="login-password" type="password" autoComplete="current-password"
                       value={password} onChange={(e) => setPassword(e.target.value)}
                       className="field" required />
            </div>
            {error && <p className="text-sm text-red-600">{error}</p>}
            <button type="submit" disabled={pending} className="btn-primary w-full disabled:opacity-50">
                {pending ? 'Signing in…' : 'Sign in'}
            </button>
        </form>
    );
}

function SignUpForm({ register, onDone }: {
    register: (u: string, p: string, email?: string) => Promise<void>;
    onDone: () => void;
}) {
    const [email, setEmail]       = useState('');
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    const [confirm, setConfirm]   = useState('');
    const [pending, setPending]   = useState(false);
    const [error, setError]       = useState<string | null>(null);

    async function submit(e: React.FormEvent) {
        e.preventDefault();
        setError(null);
        if (password !== confirm) { setError('Passwords don\'t match.'); return; }
        setPending(true);
        try {
            await register(username, password, email);
            onDone();
        } catch (err: any) {
            if (err?.status === 409) setError('That username is taken.');
            else setError(err?.message ?? 'Sign-up failed.');
        } finally { setPending(false); }
    }

    return (
        <form onSubmit={submit} className="card space-y-4">
            <h1 className="text-xl font-semibold tracking-tight">Create account</h1>
            <div>
                <label htmlFor="su-email" className="label">Email</label>
                <input id="su-email" type="email" autoComplete="email"
                       value={email} onChange={(e) => setEmail(e.target.value)}
                       className="field" required />
            </div>
            <div>
                <label htmlFor="su-username" className="label">Username</label>
                <input id="su-username" autoComplete="username"
                       value={username} onChange={(e) => setUsername(e.target.value)}
                       className="field" required />
            </div>
            <div>
                <label htmlFor="su-password" className="label">Password</label>
                <input id="su-password" type="password" autoComplete="new-password"
                       value={password} onChange={(e) => setPassword(e.target.value)}
                       className="field" required />
            </div>
            <div>
                <label htmlFor="su-confirm" className="label">Confirm password</label>
                <input id="su-confirm" type="password" autoComplete="new-password"
                       value={confirm} onChange={(e) => setConfirm(e.target.value)}
                       className="field" required />
            </div>
            {error && <p className="text-sm text-red-600">{error}</p>}
            <button type="submit" disabled={pending} className="btn-primary w-full disabled:opacity-50">
                {pending ? 'Creating account…' : 'Create account'}
            </button>
        </form>
    );
}
