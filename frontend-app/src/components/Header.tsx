import { NavLink, Link } from 'react-router-dom';
import { useAuth } from '../auth';

const navItem =
    'px-3 py-1.5 rounded-md text-sm font-medium text-ink/70 hover:text-ink hover:bg-cream';
const navItemActive =
    'px-3 py-1.5 rounded-md text-sm font-medium text-ink bg-cream';

export function Header() {
    const { isAuthed, logout } = useAuth();
    return (
        <header className="border-b border-muted/30 bg-white sticky top-0 z-30">
            <div className="max-w-6xl mx-auto px-4 h-14 flex items-center justify-between gap-4">
                <Link to="/" className="flex items-center gap-2 group">
                    <span className="inline-block w-7 h-7 rounded-md bg-primary group-hover:bg-accent transition" />
                    <span className="font-semibold tracking-tight text-ink">ShaderDojo</span>
                </Link>
                <nav className="flex items-center gap-1">
                    <NavLink to="/courses" className={({ isActive }) => isActive ? navItemActive : navItem}>
                        Courses
                    </NavLink>
                    {isAuthed ? (
                        <>
                            <NavLink to="/profile" className={({ isActive }) => isActive ? navItemActive : navItem}>
                                Profile
                            </NavLink>
                            <button onClick={logout} className={navItem + ' text-ink/60'}>
                                Sign out
                            </button>
                        </>
                    ) : (
                        <NavLink to="/login" className={({ isActive }) => isActive ? navItemActive : navItem}>
                            Sign in
                        </NavLink>
                    )}
                </nav>
            </div>
        </header>
    );
}
