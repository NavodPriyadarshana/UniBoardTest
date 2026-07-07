import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { useState, useEffect } from 'react';
import { auth } from './firebase';
import { onAuthStateChanged } from 'firebase/auth';
import Login from './pages/Login';
import Dashboard from './pages/Dashboard';
import Applications from './pages/Applications';
import Users from './pages/Users';
import Listings from './pages/Listings';
import Sidebar from './components/Sidebar';
import './App.css';

function App() {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [sidebarOpen, setSidebarOpen] = useState(false);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (user) => {
      setUser(user);
      setLoading(false);
    });
    return unsubscribe;
  }, []);

  if (loading) {
    return (
      <div style={{
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        height: '100vh',
        width: '100%',
        background: '#F1F9EE'
      }}>
        <div style={{ textAlign: 'center' }}>
          <div style={{
            width: 40, height: 40,
            border: '3px solid #F09418',
            borderTopColor: 'transparent',
            borderRadius: '50%',
            animation: 'spin 0.8s linear infinite',
            margin: '0 auto 12px'
          }}></div>
          <p style={{ color: '#5C6B8A', fontFamily: 'Poppins, sans-serif' }}>
            Loading UniBoard Admin...
          </p>
        </div>
      </div>
    );
  }

  if (!user) return <Login />;

  return (
    <Router>
      <div style={{
        display: 'flex',
        minHeight: '100vh',
        width: '100%',
        background: '#F1F3FA',
      }}>
        {/* Mobile overlay */}
        {sidebarOpen && (
          <div
            onClick={() => setSidebarOpen(false)}
            style={{
              position: 'fixed',
              inset: 0,
              background: 'rgba(0,0,0,0.4)',
              zIndex: 40,
              display: window.innerWidth < 768 ? 'block' : 'none',
            }}
          />
        )}

        <Sidebar
          sidebarOpen={sidebarOpen}
          setSidebarOpen={setSidebarOpen}
        />

        <div style={{
          flex: 1,
          marginLeft: window.innerWidth >= 768 ? 240 : 0,
          padding: window.innerWidth >= 768 ? 24 : 16,
          minHeight: '100vh',
          width: '100%',
          overflowY: 'auto',
        }}>
          {/* Mobile header */}
          <div style={{
            display: window.innerWidth < 768 ? 'flex' : 'none',
            alignItems: 'center',
            gap: 12,
            marginBottom: 16,
            padding: '12px 0',
          }}>
            <button
              onClick={() => setSidebarOpen(true)}
              style={{
                background: 'white',
                border: '1px solid #DDE3F0',
                borderRadius: 10,
                padding: '8px 10px',
                cursor: 'pointer',
                fontSize: 18,
              }}
            >
              ☰
            </button>
            <h2 style={{
              fontSize: 16,
              fontWeight: 700,
              color: '#1A1A2E',
              margin: 0,
              fontFamily: 'Poppins, sans-serif',
            }}>
              <span style={{ color: '#2B658B' }}>Uni</span>
              <span style={{ color: '#F09418' }}>Board</span>
              {' '}Admin
            </h2>
          </div>

          <Routes>
            <Route path="/" element={<Navigate to="/dashboard" />} />
            <Route path="/dashboard" element={<Dashboard />} />
            <Route path="/applications" element={<Applications />} />
            <Route path="/users" element={<Users />} />
            <Route path="/listings" element={<Listings />} />
          </Routes>
        </div>
      </div>
    </Router>
  );
}

export default App;