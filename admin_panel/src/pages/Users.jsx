import { useState, useEffect } from 'react';
import { db } from '../firebase';
import { collection, getDocs } from 'firebase/firestore';

export default function Users() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState('all');
  const [search, setSearch] = useState('');

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    setLoading(true);
    try {
      const snap = await getDocs(collection(db, 'users'));
      setUsers(snap.docs.map(d => ({ id: d.id, ...d.data() })));
    } catch (e) {
      console.error(e);
    }
    setLoading(false);
  };

  const filteredUsers = users.filter(user => {
    const matchesFilter = filter === 'all' || user.role === filter;
    const matchesSearch = search === '' ||
      user.name?.toLowerCase().includes(search.toLowerCase()) ||
      user.email?.toLowerCase().includes(search.toLowerCase());
    return matchesFilter && matchesSearch;
  });

  return (
    <div>
      <div style={{ marginBottom: 24 }}>
        <h1 style={{ fontSize: 22, fontWeight: 700, color: '#1A1A2E' }}>
          User Management
        </h1>
        <p style={{ color: '#5C6B8A', fontSize: 13, marginTop: 4 }}>
          View all registered students and landlords
        </p>
      </div>

      {/* Search and filter */}
      <div style={{ display: 'flex', gap: 12, marginBottom: 20 }}>
        <input
          type="text"
          placeholder="Search by name or email..."
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
        {['all', 'student', 'landlord'].map(f => (
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

      {/* Users table */}
      {loading ? (
        <p style={{ color: '#5C6B8A' }}>Loading users...</p>
      ) : (
        <div style={{
          background: 'white',
          borderRadius: 16,
          border: '1px solid #DDE3F0',
          overflow: 'hidden',
        }}>
          <table style={{ width: '100%', borderCollapse: 'collapse' }}>
            <thead>
              <tr style={{ background: '#F8F9FA' }}>
                {['Name', 'Email', 'Phone', 'Role', 'University'].map(h => (
                  <th key={h} style={{
                    padding: '12px 16px',
                    textAlign: 'left',
                    fontSize: 12,
                    fontWeight: 600,
                    color: '#5C6B8A',
                    borderBottom: '1px solid #DDE3F0',
                  }}>
                    {h}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filteredUsers.length === 0 ? (
                <tr>
                  <td colSpan={5} style={{
                    padding: 40,
                    textAlign: 'center',
                    color: '#5C6B8A',
                    fontSize: 14,
                  }}>
                    No users found
                  </td>
                </tr>
              ) : (
                filteredUsers.map(user => (
                  <tr key={user.id} style={{
                    borderBottom: '1px solid #F5F5F5',
                  }}>
                    <td style={{ padding: '12px 16px' }}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                        <div style={{
                          width: 32, height: 32,
                          borderRadius: '50%',
                          background: user.role === 'landlord' ? '#F09418' : '#2B658B',
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center',
                          color: 'white',
                          fontSize: 13,
                          fontWeight: 700,
                          flexShrink: 0,
                        }}>
                          {user.name?.[0]?.toUpperCase() || 'U'}
                        </div>
                        <span style={{ fontSize: 13, fontWeight: 500, color: '#1A1A2E' }}>
                          {user.name || 'N/A'}
                        </span>
                      </div>
                    </td>
                    <td style={{ padding: '12px 16px', fontSize: 13, color: '#5C6B8A' }}>
                      {user.email || 'N/A'}
                    </td>
                    <td style={{ padding: '12px 16px', fontSize: 13, color: '#5C6B8A' }}>
                      {user.phone || 'N/A'}
                    </td>
                    <td style={{ padding: '12px 16px' }}>
                      <span style={{
                        padding: '3px 10px',
                        borderRadius: 20,
                        fontSize: 11,
                        fontWeight: 600,
                        background: user.role === 'landlord' ? '#FFF8EC' : '#E3EDF4',
                        color: user.role === 'landlord' ? '#854F0B' : '#2B658B',
                        textTransform: 'capitalize',
                      }}>
                        {user.role || 'N/A'}
                      </span>
                    </td>
                    <td style={{ padding: '12px 16px', fontSize: 13, color: '#5C6B8A' }}>
                      {user.university || 'N/A'}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}