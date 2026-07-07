import { NavLink } from 'react-router-dom';
import { auth } from '../firebase';
import { signOut } from 'firebase/auth';
import {
  LayoutDashboard,
  FileText,
  Users,
  Home,
  LogOut,
} from 'lucide-react';

const navItems = [
  { path: '/dashboard', icon: LayoutDashboard, label: 'Dashboard' },
  { path: '/applications', icon: FileText, label: 'Applications' },
  { path: '/users', icon: Users, label: 'Users' },
  { path: '/listings', icon: Home, label: 'Listings' },
];

export default function Sidebar() {
  const handleSignOut = async () => {
    if (confirm('Are you sure you want to sign out?')) {
      await signOut(auth);
    }
  };

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
    }}>
      {/* Logo */}
      <div style={{ marginBottom: 32, paddingLeft: 8 }}>
        <h2 style={{ fontSize: 20, fontWeight: 700, color: '#1A1A2E' }}>
          <span style={{ color: '#2B658B' }}>Uni</span>
          <span style={{ color: '#F09418' }}>Board</span>
        </h2>
        <p style={{ fontSize: 11, color: '#5C6B8A', marginTop: 2 }}>
          Admin Dashboard
        </p>
      </div>

      {/* Nav items */}
      <nav style={{ flex: 1 }}>
        {navItems.map((item) => {
          const Icon = item.icon;
          return (
            <NavLink
              key={item.path}
              to={item.path}
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