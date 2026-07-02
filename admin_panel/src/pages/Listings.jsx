import { useState, useEffect } from 'react';
import { db } from '../firebase';
import { collection, getDocs, doc, updateDoc } from 'firebase/firestore';

export default function Listings() {
  const [listings, setListings] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState('all');
  const [search, setSearch] = useState('');

  useEffect(() => {
    fetchListings();
  }, []);

  const fetchListings = async () => {
    setLoading(true);
    try {
      const snap = await getDocs(collection(db, 'listings'));
      setListings(snap.docs.map(d => ({ id: d.id, ...d.data() })));
    } catch (e) {
      console.error(e);
    }
    setLoading(false);
  };

  const handleVerify = async (listing) => {
    try {
      await updateDoc(doc(db, 'listings', listing.id), {
        isVerified: !listing.isVerified,
      });
      fetchListings();
    } catch (e) {
      console.error(e);
    }
  };

  const filteredListings = listings.filter(l => {
    const matchesFilter = filter === 'all' ||
      (filter === 'verified' && l.isVerified) ||
      (filter === 'pending' && !l.isVerified);
    const matchesSearch = search === '' ||
      l.title?.toLowerCase().includes(search.toLowerCase()) ||
      l.location?.toLowerCase().includes(search.toLowerCase());
    return matchesFilter && matchesSearch;
  });

  return (
    <div>
      <div style={{ marginBottom: 24 }}>
        <h1 style={{ fontSize: 22, fontWeight: 700, color: '#1A1A2E' }}>
          Listings Management
        </h1>
        <p style={{ color: '#5C6B8A', fontSize: 13, marginTop: 4 }}>
          View and verify all boarding listings
        </p>
      </div>

      {/* Search and filter */}
      <div style={{ display: 'flex', gap: 12, marginBottom: 20 }}>
        <input
          type="text"
          placeholder="Search by title or location..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          style={{
            flex: 1,
            padding: '10px 14px',
            borderRadius: 10,
            border: '1px solid #DDE3F0',
            fontSize: 13,
            outline: 'none',
            fontFamily: 'Poppins, sans-serif',
          }}
        />
        {['all', 'verified', 'pending'].map(f => (
          <button
            key={f}
            onClick={() => setFilter(f)}
            style={{
              padding: '10px 16px',
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

      {/* Listings grid */}
      {loading ? (
        <p style={{ color: '#5C6B8A' }}>Loading listings...</p>
      ) : filteredListings.length === 0 ? (
        <div style={{
          background: 'white',
          borderRadius: 16,
          padding: 40,
          textAlign: 'center',
          border: '1px solid #DDE3F0',
        }}>
          <p style={{ fontSize: 40, marginBottom: 12 }}>🏠</p>
          <p style={{ color: '#5C6B8A', fontSize: 15 }}>No listings found</p>
        </div>
      ) : (
        <div style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(2, 1fr)',
          gap: 16,
        }}>
          {filteredListings.map(listing => (
            <div key={listing.id} style={{
              background: 'white',
              borderRadius: 16,
              overflow: 'hidden',
              border: '1px solid #DDE3F0',
            }}>
              {/* Color header */}
              <div style={{
                height: 60,
                background: listing.roomType === 'Single'
                  ? '#F09418'
                  : listing.roomType === 'Double'
                    ? '#3B8B65'
                    : '#2B658B',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                padding: '0 14px',
              }}>
                <span style={{
                  background: 'rgba(255,255,255,0.9)',
                  padding: '3px 10px',
                  borderRadius: 8,
                  fontSize: 11,
                  fontWeight: 600,
                  color: '#1A1A2E',
                }}>
                  {listing.roomType}
                </span>
                <span style={{
                  background: listing.isVerified ? '#EAF3DE' : '#FFF8EC',
                  padding: '3px 10px',
                  borderRadius: 8,
                  fontSize: 11,
                  fontWeight: 600,
                  color: listing.isVerified ? '#27500A' : '#854F0B',
                }}>
                  {listing.isVerified ? 'Verified' : 'Pending'}
                </span>
              </div>

              <div style={{ padding: 14 }}>
                <h3 style={{ fontSize: 14, fontWeight: 600, color: '#1A1A2E', margin: '0 0 4px' }}>
                  {listing.title}
                </h3>
                <p style={{ fontSize: 12, color: '#5C6B8A', margin: '0 0 4px' }}>
                  📍 {listing.location}
                </p>
                <p style={{ fontSize: 12, color: '#5C6B8A', margin: '0 0 12px' }}>
                  🎓 {listing.university}
                </p>
                <div style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                }}>
                  <span style={{ fontSize: 15, fontWeight: 700, color: '#F09418' }}>
                    LKR {listing.pricePerSlot?.toLocaleString()}/mo
                  </span>
                  <button
                    onClick={() => handleVerify(listing)}
                    style={{
                      padding: '6px 14px',
                      borderRadius: 8,
                      border: '1px solid',
                      borderColor: listing.isVerified ? '#F09595' : '#97C459',
                      background: listing.isVerified ? '#FCEBEB' : '#EAF3DE',
                      color: listing.isVerified ? '#A32D2D' : '#27500A',
                      fontSize: 12,
                      fontWeight: 600,
                      cursor: 'pointer',
                      fontFamily: 'Poppins, sans-serif',
                    }}
                  >
                    {listing.isVerified ? 'Unverify' : 'Verify'}
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}