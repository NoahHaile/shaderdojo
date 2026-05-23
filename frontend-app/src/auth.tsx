import { createContext, useCallback, useContext, useEffect, useMemo, useState, type ReactNode } from 'react';
import { authApi, getToken, setToken as persistToken } from './api';

interface AuthState {
    token: string | null;
    isAuthed: boolean;
    login: (username: string, password: string) => Promise<void>;
    register: (username: string, password: string, email?: string) => Promise<void>;
    logout: () => void;
}

const AuthCtx = createContext<AuthState | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
    const [token, setTokenState] = useState<string | null>(() => getToken());

    useEffect(() => { persistToken(token); }, [token]);

    const login = useCallback(async (username: string, password: string) => {
        const t = await authApi.login(username, password);
        setTokenState(t);
    }, []);

    const register = useCallback(async (username: string, password: string, email?: string) => {
        const t = await authApi.register(username, password, email);
        setTokenState(t);
    }, []);

    const logout = useCallback(() => setTokenState(null), []);

    const value = useMemo<AuthState>(() => ({
        token,
        isAuthed: !!token,
        login,
        register,
        logout,
    }), [token, login, register, logout]);

    return <AuthCtx.Provider value={value}>{children}</AuthCtx.Provider>;
}

export function useAuth(): AuthState {
    const v = useContext(AuthCtx);
    if (!v) throw new Error('useAuth must be used within <AuthProvider>');
    return v;
}
