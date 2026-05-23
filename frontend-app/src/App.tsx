import { Navigate, Route, Routes, useLocation } from 'react-router-dom';
import { Header } from './components/Header';
import { Footer } from './components/Footer';
import { useAuth } from './auth';
import { HomePage } from './pages/HomePage';
import { CoursesPage } from './pages/CoursesPage';
import { LessonPage } from './pages/LessonPage';
import { LoginPage } from './pages/LoginPage';
import { ProfilePage } from './pages/ProfilePage';
import type { ReactNode } from 'react';

function RequireAuth({ children }: { children: ReactNode }) {
    const { isAuthed } = useAuth();
    const loc = useLocation();
    if (!isAuthed) {
        return <Navigate to={`/login?from=${encodeURIComponent(loc.pathname + loc.search)}`} replace />;
    }
    return <>{children}</>;
}

export function App() {
    return (
        <div className="min-h-full flex flex-col">
            <Header />
            <main className="flex-1">
                <Routes>
                    <Route path="/" element={<HomePage />} />
                    <Route path="/courses" element={<CoursesPage />} />
                    <Route path="/lesson/:id" element={<LessonPage />} />
                    <Route path="/login" element={<LoginPage />} />
                    <Route path="/profile" element={<RequireAuth><ProfilePage /></RequireAuth>} />
                    <Route path="*" element={<Navigate to="/" replace />} />
                </Routes>
            </main>
            <Footer />
        </div>
    );
}
