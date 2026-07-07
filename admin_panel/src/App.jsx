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
        overflow: 'hidden',
      }}>
        <Sidebar />
        <div style={{
          flex: 1,
          marginLeft: 240,
          padding: 24,
          minHeight: '100vh',
          width: 'calc(100% - 240px)',
          overflowY: 'auto',
        }}>
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