import { useEffect, useState } from 'react';
import { NavLink, Link, useLocation } from 'react-router-dom';
import { isAdminSignedIn, setAdminKey } from '../admin-api';

const navItem =
    'px-3 py-1.5 rounded-md text-sm font-medium text-ink/70 hover:text-ink hover:bg-cream';
const navItemActive =
    'px-3 py-1.5 rounded-md text-sm font-medium text-ink bg-cream';

export function Header() {
    const loc = useLocation();
    // Re-read the admin flag on every navigation so the link appears/disappears.
    const [adminSignedIn, setAdminSignedIn] = useState(isAdminSignedIn());
    useEffect(() => { setAdminSignedIn(isAdminSignedIn()); }, [loc.pathname]);

    return (
        <header className="border-b border-muted/30 bg-white sticky top-0 z-30">
            <div className="max-w-6xl mx-auto px-4 h-14 flex items-center justify-between gap-4">
                <Link to="/" className="flex items-center gap-2 group">
                    <img src="/logo.png" alt="ShaderDojo" className="w-8 h-8" />
                    <span className="font-semibold tracking-tight text-ink">ShaderDojo</span>
                </Link>
                <nav className="flex items-center gap-1">
                    <NavLink to="/courses" className={({ isActive }) => isActive ? navItemActive : navItem}>
                        Courses
                    </NavLink>
                    <NavLink to="/reference" className={({ isActive }) => isActive ? navItemActive : navItem}>
                        Reference
                    </NavLink>
                    {adminSignedIn && (
                        <>
                            <NavLink to="/admin" className={({ isActive }) => isActive ? navItemActive : navItem}>
                                Admin
                            </NavLink>
                            <button
                                onClick={() => { setAdminKey(null); setAdminSignedIn(false); }}
                                className={navItem + ' text-ink/40'}
                                title="Forget the admin key on this browser">
                                Lock
                            </button>
                        </>
                    )}
                </nav>
            </div>
        </header>
    );
}
