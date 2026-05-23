import { useEffect, useState } from 'react';
import { accountApi, type AccountResponse } from '../api';

export function ProfilePage() {
    const [me, setMe] = useState<AccountResponse | null>(null);
    const [loadError, setLoadError] = useState<string | null>(null);

    useEffect(() => {
        accountApi.me().then(setMe).catch((e: any) => setLoadError(e?.message ?? 'Failed to load.'));
    }, []);

    if (loadError) return <p className="max-w-3xl mx-auto px-4 py-10 text-red-600">{loadError}</p>;
    if (!me) return <Skeleton />;

    return (
        <div className="max-w-3xl mx-auto px-4 py-10 space-y-6">
            <h1 className="text-2xl font-semibold tracking-tight">Profile</h1>
            <ProfileInfoForm initial={me} onSaved={setMe} />
            <AccountInfoForm currentUsername={me.username} />
        </div>
    );
}

function ProfileInfoForm({ initial, onSaved }: {
    initial: AccountResponse;
    onSaved: (next: AccountResponse) => void;
}) {
    const [email, setEmail]   = useState(initial.email ?? '');
    const [country, setCountry] = useState(initial.country ?? '');
    const [bio, setBio]       = useState(initial.bio ?? '');
    const [pending, setPending] = useState(false);
    const [status, setStatus] = useState<string | null>(null);

    async function submit(e: React.FormEvent) {
        e.preventDefault();
        setPending(true); setStatus(null);
        try {
            await accountApi.updateProfile({ email, country, bio });
            setStatus('Saved.');
            onSaved({ ...initial, email, country, bio });
        } catch (err: any) {
            setStatus(err?.message ?? 'Save failed.');
        } finally { setPending(false); }
    }

    return (
        <form onSubmit={submit} className="card space-y-4">
            <h2 className="text-base font-semibold">Profile info</h2>
            <div>
                <label htmlFor="email" className="label">Email</label>
                <input id="email" type="email" value={email}
                       onChange={(e) => setEmail(e.target.value)} className="field" />
            </div>
            <div>
                <label htmlFor="country" className="label">Country</label>
                <input id="country" value={country}
                       onChange={(e) => setCountry(e.target.value)} className="field" />
            </div>
            <div>
                <label htmlFor="bio" className="label">Bio</label>
                <textarea id="bio" rows={3} value={bio}
                          onChange={(e) => setBio(e.target.value)} className="field" />
            </div>
            <div className="flex items-center gap-3">
                <button type="submit" className="btn-primary" disabled={pending}>
                    {pending ? 'Saving…' : 'Save profile'}
                </button>
                {status && <p className="text-xs text-muted">{status}</p>}
            </div>
        </form>
    );
}

function AccountInfoForm({ currentUsername }: { currentUsername: string }) {
    const [username, setUsername] = useState(currentUsername);
    const [oldPassword, setOld]   = useState('');
    const [password, setPassword] = useState('');
    const [confirm, setConfirm]   = useState('');
    const [pending, setPending]   = useState(false);
    const [status, setStatus]     = useState<string | null>(null);

    async function submit(e: React.FormEvent) {
        e.preventDefault();
        setStatus(null);
        if (password !== confirm) { setStatus('New passwords don\'t match.'); return; }
        setPending(true);
        try {
            await accountApi.updateAccount({ username, password, oldPassword });
            setStatus('Account updated.');
            setOld(''); setPassword(''); setConfirm('');
        } catch (err: any) {
            if (err?.status === 401) setStatus('Old password incorrect.');
            else if (err?.status === 409) setStatus('Username already taken.');
            else setStatus(err?.message ?? 'Save failed.');
        } finally { setPending(false); }
    }

    return (
        <form onSubmit={submit} className="card space-y-4">
            <h2 className="text-base font-semibold">Account</h2>
            <div>
                <label htmlFor="acct-username" className="label">Username</label>
                <input id="acct-username" autoComplete="username" value={username}
                       onChange={(e) => setUsername(e.target.value)} className="field" required />
            </div>
            <div>
                <label htmlFor="acct-old" className="label">Current password</label>
                <input id="acct-old" type="password" autoComplete="current-password" value={oldPassword}
                       onChange={(e) => setOld(e.target.value)} className="field" required />
            </div>
            <div>
                <label htmlFor="acct-new" className="label">New password</label>
                <input id="acct-new" type="password" autoComplete="new-password" value={password}
                       onChange={(e) => setPassword(e.target.value)} className="field" required />
            </div>
            <div>
                <label htmlFor="acct-confirm" className="label">Confirm new password</label>
                <input id="acct-confirm" type="password" autoComplete="new-password" value={confirm}
                       onChange={(e) => setConfirm(e.target.value)} className="field" required />
            </div>
            <div className="flex items-center gap-3">
                <button type="submit" className="btn-primary" disabled={pending}>
                    {pending ? 'Saving…' : 'Save account'}
                </button>
                {status && <p className="text-xs text-muted">{status}</p>}
            </div>
        </form>
    );
}

function Skeleton() {
    return (
        <div className="max-w-3xl mx-auto px-4 py-10 space-y-6">
            <div className="h-8 w-32 bg-cream rounded animate-pulse" />
            <div className="card"><div className="h-64 bg-cream rounded animate-pulse" /></div>
            <div className="card"><div className="h-64 bg-cream rounded animate-pulse" /></div>
        </div>
    );
}
