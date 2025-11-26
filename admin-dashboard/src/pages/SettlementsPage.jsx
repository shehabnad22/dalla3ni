import React, { useState, useEffect } from 'react';

const API_URL = 'http://localhost:3000/api';

export default function SettlementsPage() {
  const [settlements, setSettlements] = useState({ drivers: [], totalPending: 0 });
  const [loading, setLoading] = useState(true);
  const [selectedDate, setSelectedDate] = useState(new Date().toISOString().split('T')[0]);

  useEffect(() => {
    fetchSettlements();
  }, [selectedDate]);

  const fetchSettlements = async () => {
    setLoading(true);
    try {
      const res = await fetch(`${API_URL}/admin/settlements/daily?date=${selectedDate}`);
      const data = await res.json();
      if (data.success) {
        setSettlements(data);
      }
    } catch (error) {
      console.error('Error fetching settlements:', error);
    }
    setLoading(false);
  };

  const markAsPaid = async (driverId, driverName) => {
    if (!window.confirm(`هل تريد تأكيد تسوية ${driverName}؟`)) return;

    try {
      const res = await fetch(`${API_URL}/admin/settlements/${driverId}/pay`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ adminId: 'admin-1' }), // TODO: Get from auth
      });
      const data = await res.json();
      if (data.success) {
        alert('تم التسوية بنجاح');
        fetchSettlements();
      }
    } catch (error) {
      alert('حدث خطأ');
    }
  };

  return (
    <div style={{ padding: '24px', direction: 'rtl', fontFamily: 'Cairo, sans-serif' }}>
      <h1 style={{ marginBottom: '24px' }}>التسويات اليومية</h1>

      {/* Date Picker */}
      <div style={{ marginBottom: '24px', display: 'flex', gap: '16px', alignItems: 'center' }}>
        <label>التاريخ:</label>
        <input
          type="date"
          value={selectedDate}
          onChange={(e) => setSelectedDate(e.target.value)}
          style={{ padding: '8px 16px', borderRadius: '8px', border: '1px solid #ddd' }}
        />
      </div>

      {/* Summary Card */}
      <div style={{
        background: 'linear-gradient(135deg, #6C63FF, #4A42D1)',
        borderRadius: '16px',
        padding: '24px',
        color: 'white',
        marginBottom: '24px',
      }}>
        <div style={{ display: 'flex', justifyContent: 'space-between' }}>
          <div>
            <div style={{ fontSize: '14px', opacity: 0.8 }}>إجمالي المستحقات</div>
            <div style={{ fontSize: '36px', fontWeight: 'bold' }}>{settlements.totalPending?.toFixed(2)} دينار</div>
          </div>
          <div>
            <div style={{ fontSize: '14px', opacity: 0.8 }}>عدد السائقين</div>
            <div style={{ fontSize: '36px', fontWeight: 'bold' }}>{settlements.driversCount || 0}</div>
          </div>
        </div>
      </div>

      {/* Drivers Table */}
      {loading ? (
        <div style={{ textAlign: 'center', padding: '48px' }}>جاري التحميل...</div>
      ) : (
        <table style={{ width: '100%', borderCollapse: 'collapse', background: 'white', borderRadius: '12px', overflow: 'hidden', boxShadow: '0 2px 8px rgba(0,0,0,0.1)' }}>
          <thead>
            <tr style={{ background: '#f5f5f5' }}>
              <th style={{ padding: '16px', textAlign: 'right' }}>السائق</th>
              <th style={{ padding: '16px', textAlign: 'right' }}>الهاتف</th>
              <th style={{ padding: '16px', textAlign: 'right' }}>المبلغ المستحق</th>
              <th style={{ padding: '16px', textAlign: 'right' }}>الحالة</th>
              <th style={{ padding: '16px', textAlign: 'center' }}>إجراء</th>
            </tr>
          </thead>
          <tbody>
            {settlements.drivers?.map((driver) => (
              <tr key={driver.id} style={{ borderBottom: '1px solid #eee' }}>
                <td style={{ padding: '16px' }}>
                  <div style={{ fontWeight: 'bold' }}>{driver.name}</div>
                </td>
                <td style={{ padding: '16px' }}>{driver.phone}</td>
                <td style={{ padding: '16px' }}>
                  <span style={{ 
                    fontWeight: 'bold', 
                    color: parseFloat(driver.pendingSettlement) >= 50 ? '#e53935' : '#333' 
                  }}>
                    {parseFloat(driver.pendingSettlement).toFixed(2)} دينار
                  </span>
                </td>
                <td style={{ padding: '16px' }}>
                  {driver.isBlocked ? (
                    <span style={{ 
                      background: '#ffebee', 
                      color: '#c62828', 
                      padding: '4px 12px', 
                      borderRadius: '20px',
                      fontSize: '12px'
                    }}>
                      محظور ❌
                    </span>
                  ) : (
                    <span style={{ 
                      background: '#e8f5e9', 
                      color: '#2e7d32', 
                      padding: '4px 12px', 
                      borderRadius: '20px',
                      fontSize: '12px'
                    }}>
                      نشط ✓
                    </span>
                  )}
                </td>
                <td style={{ padding: '16px', textAlign: 'center' }}>
                  <button
                    onClick={() => markAsPaid(driver.id, driver.name)}
                    style={{
                      background: '#4CAF50',
                      color: 'white',
                      border: 'none',
                      padding: '8px 24px',
                      borderRadius: '8px',
                      cursor: 'pointer',
                      fontWeight: 'bold',
                    }}
                  >
                    ✓ Mark as Paid
                  </button>
                </td>
              </tr>
            ))}
            {(!settlements.drivers || settlements.drivers.length === 0) && (
              <tr>
                <td colSpan="5" style={{ padding: '48px', textAlign: 'center', color: '#999' }}>
                  لا توجد تسويات معلقة
                </td>
              </tr>
            )}
          </tbody>
        </table>
      )}
    </div>
  );
}

