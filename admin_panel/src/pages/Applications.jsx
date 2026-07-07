import { useState, useEffect } from 'react';
import { db } from '../firebase';
import {
  collection, getDocs, doc,
  updateDoc, addDoc, serverTimestamp
} from 'firebase/firestore';
import emailjs from '@emailjs/browser';

// ─────────────────────────────────────────────
// EmailJS Configuration
// ─────────────────────────────────────────────
const EMAILJS_SERVICE_ID = 'service_nc0klt5';
const EMAILJS_TEMPLATE_ID = 'template_sgh1w3s';
const EMAILJS_PUBLIC_KEY = 'Xx2dS52oWok0Y3310';

export default function Applications() {
  const [applications, setApplications] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState('all');
  const [otpInput, setOtpInput] = useState({});
  const [sendingOtp, setSendingOtp] = useState({});

  useEffect(() => {
    emailjs.init(EMAILJS_PUBLIC_KEY);
    fetchApplications();
  }, []);

  const fetchApplications = async () => {
    setLoading(true);
    try {
      const snap = await getDocs(collection(db, 'landlord_applications'));
      setApplications(snap.docs.map(d => ({ id: d.id, ...d.data() })));
    } catch (e) {
      console.error(e);
    }
    setLoading(false);
  };

  const filteredApps = applications.filter(app => {
    if (filter === 'all') return true;
    return app.status === filter;
  });

  const handleApprove = async (app) => {
    try {
      await updateDoc(doc(db, 'landlord_applications', app.id), {
        status: 'approved',
        reviewedAt: serverTimestamp(),
      });
      fetchApplications();
      alert(`Application approved for ${app.landlordName}`);
    } catch (e) {
      console.error(e);
    }
  };

  const handleReject = async (app) => {
    if (!confirm(`Reject application from ${app.landlordName}?`)) return;
    try {
      await updateDoc(doc(db, 'landlord_applications', app.id), {
        status: 'rejected',
        reviewedAt: serverTimestamp(),
      });
      fetchApplications();
    } catch (e) {
      console.error(e);
    }
  };

  // ─────────────────────────────────────────────
  // SEND OTP — Saves to Firestore + Sends Email
  // ─────────────────────────────────────────────
  const handleSendOtp = async (app) => {
    const otp = otpInput[app.id];
    if (!otp || otp.length !== 6) {
      alert('Please enter a 6 digit OTP');
      return;
    }
    setSendingOtp(prev => ({ ...prev, [app.id]: true }));
    try {
      // Step 1: Save OTP to Firestore
      const expiresAt = new Date();
      expiresAt.setHours(expiresAt.getHours() + 24);

      await addDoc(collection(db, 'landlord_otps'), {
        email: app.landlordEmail,
        otp: otp,
        isUsed: false,
        createdAt: serverTimestamp(),
        expiresAt: expiresAt,
      });

      // Step 2: Send OTP email via EmailJS
      const templateParams = {
        landlord_name: app.landlordName,
        passcode: otp,
        to_email: app.landlordEmail,
      };

      await emailjs.send(
        EMAILJS_SERVICE_ID,
        EMAILJS_TEMPLATE_ID,
        templateParams,
        EMAILJS_PUBLIC_KEY
      );

      alert(`OTP sent successfully to ${app.landlordEmail}!`);
      setOtpInput(prev => ({ ...prev, [app.id]: '' }));
    } catch (e) {
      console.error('Error sending OTP:', e);
      alert('Failed to send OTP. Please try again.');
    }
    setSendingOtp(prev => ({ ...prev, [app.id]: false }));
  };

  const statusColor = {
    pending: { bg: '#FFF8EC', text: '#854F0B', border: '#F09418' },
    approved: { bg: '#EAF3DE', text: '#27500A', border: '#3B6D11' },
    rejected: { bg: '#FCEBEB', text: '#A32D2D', border: '#F09595' },
  };

  return (
    <div>
      <div style={{ marginBottom: 24 }}>
        <h1 style={{ fontSize: 22, fontWeight: 700, color: '#1A1A2E' }}>
          Landlord Applications
        </h1>
        <p style={{ color: '#5C6B8A', fontSize: 13, marginTop: 4 }}>
          Review and approve landlord verification documents
        </p>
      </div>

      {/* Filter tabs */}
      <div style={{ display: 'flex', gap: 8, marginBottom: 20, flexWrap: 'wrap' }}>
        {['all', 'pending', 'approved', 'rejected'].map(f => (
          <button
            key={f}
            onClick={() => setFilter(f)}
            style={{
              padding: '8px 16px',
              borderRadius: 10,
              border: '1px solid',
              borderColor: filter === f ? '#F09418' : '#DDE3F0',
              background: filter === f ? '#F09418' : 'white',
              color: filter === f ? 'white' : '#5C6B8A',
              fontSize: 13,
              fontWeight: filter === f ? 600 : 400,
              cursor: 'pointer',
              fontFamily: 'Poppins, sans-serif',
              textTransform: 'capitalize',
            }}
          >
            {f}
          </button>
        ))}
      </div>

      {/* Applications list */}
      {loading ? (
        <p style={{ color: '#5C6B8A' }}>Loading applications...</p>
      ) : filteredApps.length === 0 ? (
        <div style={{
          background: 'white',
          borderRadius: 16,
          padding: 40,
          textAlign: 'center',
          border: '1px solid #DDE3F0',
        }}>
          <p style={{ fontSize: 40, marginBottom: 12 }}>📄</p>
          <p style={{ color: '#5C6B8A', fontSize: 15 }}>No applications found</p>
        </div>
      ) : (
        filteredApps.map(app => {
          const colors = statusColor[app.status] || statusColor.pending;
          return (
            <div key={app.id} style={{
              background: 'white',
              borderRadius: 16,
              padding: 20,
              marginBottom: 16,
              border: '1px solid #DDE3F0',
            }}>
              {/* Header */}
              <div style={{
                display: 'flex',
                justifyContent: 'space-between',
                alignItems: 'center',
                marginBottom: 16,
              }}>
                <div>
                  <h3 style={{ fontSize: 16, fontWeight: 600, color: '#1A1A2E', margin: 0 }}>
                    {app.landlordName}
                  </h3>
                  <p style={{ fontSize: 13, color: '#5C6B8A', margin: '4px 0 0' }}>
                    {app.landlordEmail}
                  </p>
                </div>
                <span style={{
                  padding: '4px 12px',
                  borderRadius: 20,
                  fontSize: 12,
                  fontWeight: 600,
                  background: colors.bg,
                  color: colors.text,
                  border: `1px solid ${colors.border}`,
                  textTransform: 'capitalize',
                }}>
                  {app.status}
                </span>
              </div>

              {/* Documents */}
              <div style={{
                display: 'grid',
                gridTemplateColumns: 'repeat(2, 1fr)',
                gap: 8,
                marginBottom: 16,
              }}>
                {[
                  { label: 'NIC Front', url: app.nicFront },
                  { label: 'NIC Back', url: app.nicBack },
                  { label: 'Property Doc', url: app.propertyDoc },
                  { label: 'Police Report', url: app.policeReport },
                ].map(doc => (
                  <a
                    key={doc.label}
                    href={doc.url}
                    target="_blank"
                    rel="noreferrer"
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      gap: 8,
                      padding: '10px 12px',
                      borderRadius: 10,
                      background: '#F5F5F5',
                      textDecoration: 'none',
                      fontSize: 13,
                      color: '#2B658B',
                      fontWeight: 500,
                    }}
                  >
                    📄 {doc.label}
                  </a>
                ))}
              </div>

              {/* Actions for pending */}
              {app.status === 'pending' && (
                <div style={{ display: 'flex', gap: 10 }}>
                  <button
                    onClick={() => handleReject(app)}
                    style={{
                      flex: 1, padding: '10px',
                      borderRadius: 10,
                      border: '1px solid #F09595',
                      background: '#FCEBEB',
                      color: '#A32D2D',
                      fontSize: 13, fontWeight: 600,
                      cursor: 'pointer',
                      fontFamily: 'Poppins, sans-serif',
                    }}
                  >
                    ✕ Reject
                  </button>
                  <button
                    onClick={() => handleApprove(app)}
                    style={{
                      flex: 1, padding: '10px',
                      borderRadius: 10,
                      border: '1px solid #97C459',
                      background: '#EAF3DE',
                      color: '#27500A',
                      fontSize: 13, fontWeight: 600,
                      cursor: 'pointer',
                      fontFamily: 'Poppins, sans-serif',
                    }}
                  >
                    ✓ Approve
                  </button>
                </div>
              )}

              {/* OTP section for approved */}
              {app.status === 'approved' && (
                <div style={{
                  background: '#F5F8FF',
                  border: '1px solid #DDE3F0',
                  borderRadius: 12,
                  padding: 14,
                }}>
                  <p style={{
                    fontSize: 13, fontWeight: 600,
                    color: '#1A1A2E', marginBottom: 10
                  }}>
                    Send OTP to Landlord
                  </p>
                  <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
                    <input
                      type="text"
                      maxLength={6}
                      placeholder="Enter 6 digit OTP"
                      value={otpInput[app.id] || ''}
                      onChange={(e) => setOtpInput(prev => ({
                        ...prev, [app.id]: e.target.value
                      }))}
                      style={{
                        flex: 1,
                        padding: '10px 12px',
                        borderRadius: 10,
                        border: '1px solid #DDE3F0',
                        fontSize: 14, outline: 'none',
                        letterSpacing: 4,
                        fontFamily: 'Poppins, sans-serif',
                      }}
                    />
                    <button
                      onClick={() => handleSendOtp(app)}
                      disabled={sendingOtp[app.id]}
                      style={{
                        padding: '10px 20px',
                        borderRadius: 10,
                        border: 'none',
                        background: sendingOtp[app.id] ? '#ccc' : '#F09418',
                        color: 'white',
                        fontSize: 13, fontWeight: 600,
                        cursor: sendingOtp[app.id] ? 'not-allowed' : 'pointer',
                        fontFamily: 'Poppins, sans-serif',
                      }}
                    >
                      {sendingOtp[app.id] ? 'Sending...' : 'Send OTP'}
                    </button>
                  </div>
                  <p style={{ fontSize: 11, color: '#5C6B8A', marginTop: 8 }}>
                    ✅ OTP will be automatically sent to {app.landlordEmail}
                  </p>
                </div>
              )}
            </div>
          );
        })
      )}
    </div>
  );
}