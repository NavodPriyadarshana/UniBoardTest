import { useState } from 'react';
import { auth } from '../firebase';
import { signInWithEmailAndPassword } from 'firebase/auth';

export default function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleLogin = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      await signInWithEmailAndPassword(auth, email, password);
    } catch (err) {
      setError('Invalid email or password');
    }
    setLoading(false);
  };

  return (
    <div style={{
      minHeight: '100vh',
      background: 'linear-gradient(180deg, #F1F9EE, #F1F3FA)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
    }}>
      <div style={{
        background: 'white',
        borderRadius: 20,
        padding: 'clamp(24px, 5vw, 40px)',
        width: 'min(400px, 90vw)',
        boxShadow: '0 4px 24px rgba(0,0,0,0.08)',
      }}>
        {/* Logo */}
        <div style={{ textAlign: 'center', marginBottom: 32 }}>
          <h1 style={{ fontSize: 28, fontWeight: 700 }}>
            <span style={{ color: '#2B658B' }}>Uni</span>
            <span style={{ color: '#F09418' }}>Board</span>
          </h1>
          <p style={{ color: '#5C6B8A', fontSize: 14, marginTop: 4 }}>
            Admin Portal
          </p>
        </div>

        <form onSubmit={handleLogin}>
          {/* Email */}
          <div style={{ marginBottom: 16 }}>
            <label style={{
              display: 'block',
              fontSize: 13,
              fontWeight: 600,
              color: '#1A1A2E',
              marginBottom: 6
            }}>
              Email Address
            </label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="admin@uniboard.lk"
              required
              style={{
                width: '100%',
                padding: '12px 14px',
                borderRadius: 12,
                border: '1px solid #DDE3F0',
                fontSize: 14,
                outline: 'none',
                background: '#F8F9FA',
                color: '#1A1A2E',
                fontFamily: 'Poppins, sans-serif',
              }}
            />
          </div>

          {/* Password */}
          <div style={{ marginBottom: 24 }}>
            <label style={{
              display: 'block',
              fontSize: 13,
              fontWeight: 600,
              color: '#1A1A2E',
              marginBottom: 6
            }}>
              Password
            </label>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="Enter your password"
              required
              style={{
                width: '100%',
                padding: '12px 14px',
                borderRadius: 12,
                border: '1px solid #DDE3F0',
                fontSize: 14,
                outline: 'none',
                background: '#F8F9FA',
                color: '#1A1A2E',
                fontFamily: 'Poppins, sans-serif',
              }}
            />
          </div>

          {/* Error */}
          {error && (
            <div style={{
              background: '#FFF0F0',
              border: '1px solid #FFCCCC',
              borderRadius: 10,
              padding: '10px 14px',
              color: '#E53935',
              fontSize: 13,
              marginBottom: 16,
            }}>
              {error}
            </div>
          )}

          {/* Button */}
          <button
            type="submit"
            disabled={loading}
            style={{
              width: '100%',
              padding: '14px',
              borderRadius: 12,
              border: 'none',
              background: '#F09418',
              color: 'white',
              fontSize: 15,
              fontWeight: 700,
              cursor: loading ? 'not-allowed' : 'pointer',
              opacity: loading ? 0.7 : 1,
              fontFamily: 'Poppins, sans-serif',
            }}
          >
            {loading ? 'Signing in...' : 'Sign In'}
          </button>
        </form>
      </div>
    </div>
  );
}