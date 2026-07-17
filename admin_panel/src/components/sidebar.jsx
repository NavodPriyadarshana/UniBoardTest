import { NavLink } from 'react-router-dom';
import { auth } from '../firebase';
import { signOut } from 'firebase/auth';
import { useEffect, useState } from 'react';
import {
  LayoutDashboard,
  FileText,
  Users,
  Home,
  LogOut,
  X,
} from 'lucide-react';

const navItems = [
  { path: '/dashboard', icon: LayoutDashboard, label: 'Dashboard' },
  { path: '/applications', icon: FileText, label: 'Applications' },
  { path: '/users', icon: Users, label: 'Users' },
  { path: '/listings', icon: Home, label: 'Listings' },
];

export default function Sidebar({ sidebarOpen, setSidebarOpen }) {
  const [isMobile, setIsMobile] = useState(window.innerWidth < 768);

  useEffect(() => {
    const handleResize = () => {
      setIsMobile(window.innerWidth < 768);
      if (window.innerWidth >= 768) setSidebarOpen(false);
    };
    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  const handleSignOut = async () => {
    if (confirm('Are you sure you want to sign out?')) {
      await signOut(auth);
    }
  };

  const isVisible = !isMobile || sidebarOpen;

  return (
    <div style={{
      width: 240,
      height: '100vh',
      background: 'white',
      position: 'fixed',
      left: 0, top: 0,
      borderRight: '1px solid #DDE3F0',
      display: 'flex',
      flexDirection: 'column',
      padding: '24px 16px',
      zIndex: 50,
      transform: isVisible ? 'translateX(0)' : 'translateX(-100%)',
      transition: 'transform 0.3s ease',
      boxShadow: isMobile && sidebarOpen
        ? '4px 0 20px rgba(0,0,0,0.15)'
        : 'none',
    }}>
      {/* Header with close button on mobile */}
      <div style={{
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        marginBottom: 32,
        paddingLeft: 8,
      }}>
        <div>
          <h2 style={{ fontSize: 20, fontWeight: 700, color: '#1A1A2E', margin: 0 }}>
            <span style={{ color: '#2B658B', fontFamily: "'Agency FB', sans-serif" }}>Uni</span>
            <span style={{ color: '#F09418', fontFamily: "'Agency FB', sans-serif" }}>Board</span>
          </h2>
          <p style={{ fontSize: 11, color: '#5C6B8A', marginTop: 2 }}>
            Admin Dashboard
          </p>
        </div>
        {isMobile && (
          <button
            onClick={() => setSidebarOpen(false)}
            style={{
              background: 'none',
              border: 'none',
              cursor: 'pointer',
              color: '#5C6B8A',
              padding: 4,
            }}
          >
            <X size={20} />
          </button>
        )}
      </div>

      {/* Nav items */}
      <nav style={{ flex: 1 }}>
        {navItems.map((item) => {
          const Icon = item.icon;
          return (
            <NavLink
              key={item.path}
              to={item.path}
              onClick={() => isMobile && setSidebarOpen(false)}
              style={({ isActive }) => ({
                display: 'flex',
                alignItems: 'center',
                gap: 12,
                padding: '10px 14px',
                borderRadius: 10,
                marginBottom: 4,
                textDecoration: 'none',
                fontSize: 14,
                fontWeight: isActive ? 600 : 400,
                color: isActive ? '#F09418' : '#5C6B8A',
                background: isActive ? '#FFF8EC' : 'transparent',
                transition: 'all 0.2s',
              })}
            >
              <Icon size={18} />
              {item.label}
            </NavLink>
          );
        })}
      </nav>

      {/* Sign out */}
      <button
        onClick={handleSignOut}
        style={{
          display: 'flex',
          alignItems: 'center',
          gap: 10,
          padding: '10px 14px',
          borderRadius: 10,
          border: '1px solid #FFCCCC',
          background: '#FFF0F0',
          color: '#E53935',
          fontSize: 14,
          fontWeight: 600,
          cursor: 'pointer',
          width: '100%',
        }}
      >
        <LogOut size={16} />
        Sign Out
      </button>
    </div>
  );
}