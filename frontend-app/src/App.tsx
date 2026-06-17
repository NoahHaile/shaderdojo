import { Navigate, Route, Routes, useLocation } from 'react-router-dom';
import { Header } from './components/Header';
import { Footer } from './components/Footer';
import { HomePage } from './pages/HomePage';
import { CoursesPage } from './pages/CoursesPage';
import { LessonPage } from './pages/LessonPage';
import { ReferencePage } from './pages/ReferencePage';
import { DiscussionPage } from './pages/DiscussionPage';
import { AdminLoginPage } from './pages/AdminLoginPage';
import { AdminDashboardPage } from './pages/AdminDashboardPage';
import { AdminCourseEditPage } from './pages/AdminCourseEditPage';
import { AdminLessonEditPage } from './pages/AdminLessonEditPage';
import { isAdminSignedIn } from './admin-api';
import type { ReactNode } from 'react';

function RequireAdmin({ children }: { children: ReactNode }) {
    const loc = useLocation();
    if (!isAdminSignedIn()) {
        return <Navigate to={`/admin/login?from=${encodeURIComponent(loc.pathname + loc.search)}`} replace />;
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
                    <Route path="/reference" element={<ReferencePage />} />
                    <Route path="/lesson/:id" element={<LessonPage />} />
                    <Route path="/lesson/:id/discussion" element={<DiscussionPage />} />

                    {/* Admin */}
                    <Route path="/admin/login" element={<AdminLoginPage />} />
                    <Route path="/admin" element={<RequireAdmin><AdminDashboardPage /></RequireAdmin>} />
                    <Route path="/admin/courses/:id" element={<RequireAdmin><AdminCourseEditPage /></RequireAdmin>} />
                    <Route path="/admin/lessons/:id" element={<RequireAdmin><AdminLessonEditPage /></RequireAdmin>} />

                    <Route path="*" element={<Navigate to="/" replace />} />
                </Routes>
            </main>
            <Footer />
        </div>
    );
}
