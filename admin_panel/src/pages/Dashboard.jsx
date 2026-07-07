import { useState, useEffect } from 'react';
import {
  GraduationCap, Home, ClipboardList,
  CalendarCheck, Clock, Bell
} from 'lucide-react';
import { db } from '../firebase';
import { collection, getDocs, query, where } from 'firebase/firestore';

function StatCard({ icon: Icon, label, value, color }) {
  return (
    <div style={{
      background: 'white',
      borderRadius: 16,
      padding: 20,
      border: '1px solid #DDE3F0',
      display: 'flex',
      alignItems: 'center',
      gap: 16,
      boxShadow: '0 2px 8px rgba(0,0,0,0.04)',
    }}>
      <div style={{
        width: 48, height: 48,
        borderRadius: 12,
        background: color + '20',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
      }}>
        <Icon size={24} color={color} />
      </div>
      <div>
        <p style={{ fontSize: 12, color: '#5C6B8A', margin: 0 }}>{label}</p>
        <p style={{ fontSize: 24, fontWeight: 700, color: '#1A1A2E', margin: 0 }}>
          {value}
        </p>
      </div>
    </div>
  );
}

export default function Dashboard() {
  const [stats, setStats] = useState({
    students: 0,
    landlords: 0,
    listings: 0,
    bookings: 0,
    pendingApplications: 0,
    pendingBookings: 0,
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchStats();
  }, []);

  const fetchStats = async () => {
    try {
      const [users, listings, bookings, applications] = await Promise.all([
        getDocs(collection(db, 'users')),
        getDocs(collection(db, 'listings')),
        getDocs(collection(db, 'bookings')),
        getDocs(collection(db, 'landlord_applications')),
      ]);

      const students = users.docs.filter(d => d.data().role === 'student').length;
      const landlords = users.docs.filter(d => d.data().role === 'landlord').length;
      const pendingBookings = bookings.docs.filter(d => d.data().status === 'pending').length;
      const pendingApps = applications.docs.filter(d => d.data().status === 'pending').length;

      setStats({
        students,
        landlords,
        listings: listings.docs.length,
        bookings: bookings.docs.length,
        pendingApplications: pendingApps,
        pendingBookings,
      });
    } catch (e) {
      console.error('Error fetching stats:', e);
    }
    setLoading(false);
  };

  return (
    <div>
      {/* Header */}
      <div style={{ marginBottom: 24 }}>
        <h1 style={{ fontSize: 22, fontWeight: 700, color: '#1A1A2E' }}>
          Dashboard
        </h1>
        <p style={{ color: '#5C6B8A', fontSize: 13, marginTop: 4 }}>
          Welcome back, Admin 👋
        </p>
      </div>

      {/* Stats grid */}
      {loading ? (
        <p style={{ color: '#5C6B8A' }}>Loading stats...</p>
      ) : (
        <>
          <div className="stats-grid" style={{
            marginBottom: 24,
          }}>
            <StatCard icon={GraduationCap} label="Total Students" value={stats.students} color="#2B658B" />
            <StatCard icon={Home} label="Total Landlords" value={stats.landlords} color="#F09418" />
            <StatCard icon={ClipboardList} label="Total Listings" value={stats.listings} color="#3B6D11" />
            <StatCard icon={CalendarCheck} label="Total Bookings" value={stats.bookings} color="#2B658B" />
            <StatCard icon={Clock} label="Pending Applications" value={stats.pendingApplications} color="#F09418" />
            <StatCard icon={Bell} label="Pending Bookings" value={stats.pendingBookings} color="#E53935" />
          </div>

          {/* Alerts */}
          {stats.pendingApplications > 0 && (
            <div style={{
              background: '#FFF8EC',
              border: '1px solid #F09418',
              borderRadius: 12,
              padding: '14px 16px',
              display: 'flex',
              alignItems: 'center',
              gap: 10,
              marginBottom: 12,
            }}>
              <span style={{ fontSize: 18 }}>⚠️</span>
              <p style={{ fontSize: 13, color: '#854F0B', margin: 0 }}>
                <strong>{stats.pendingApplications}</strong> landlord application(s) waiting for review.
                <a href="/applications" style={{ color: '#F09418', marginLeft: 8 }}>
                  Review now →
                </a>
              </p>
            </div>
          )}
        </>
      )}
    </div>
  );
}