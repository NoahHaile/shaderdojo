import { useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { adminApi, setAdminKey } from '../admin-api';

export function AdminLoginPage() {
    const [key, setKey] = useState('');
    const [pending, setPending] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const nav = useNavigate();
    const [params] = useSearchParams();
    const from = params.get('from') || '/admin';

    async function submit(e: React.FormEvent) {
        e.preventDefault();
        setError(null);
        setPending(true);
        setAdminKey(key.trim());
        try {
            // Probe with the cheapest admin-only endpoint. recompute-hashes is
            // idempotent so it's safe; on success we know the key is valid.
            await adminApi.recomputeHashes();
            nav(from, { replace: true });
        } catch (err: any) {
            setAdminKey(null);
            setError(err?.status === 401 ? 'That key is not accepted.' : (err?.message ?? 'Sign-in failed.'));
        } finally {
            setPending(false);
        }
    }

    return (
        <div className="max-w-md mx-auto px-4 py-16">
            <h1 className="text-2xl font-semibold tracking-tight mb-2">Admin sign-in</h1>
            <p className="text-sm text-muted mb-6">
                Paste the <code>API_KEY</code> value from your server's <code>.env</code>.
                It'll be cached in this browser so you don't need to retype it.
            </p>
            <form onSubmit={submit} className="card space-y-4">
                <div>
                    <label htmlFor="admin-key" className="label">Admin key</label>
                    <input
                        id="admin-key"
                        type="password"
                        value={key}
                        onChange={(e) => setKey(e.target.value)}
                        className="field font-mono text-sm"
                        autoComplete="off"
                        autoFocus
                        required
                    />
                </div>
                {error && <p className="text-sm text-red-600">{error}</p>}
                <button type="submit" disabled={pending || !key.trim()} className="btn-primary w-full disabled:opacity-50">
                    {pending ? 'Verifying…' : 'Sign in'}
                </button>
            </form>
        </div>
    );
}
