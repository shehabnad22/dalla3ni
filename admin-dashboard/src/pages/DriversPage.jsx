import React, { useState, useEffect } from 'react';

const API_URL = 'http://localhost:3000/api';

export default function DriversPage() {
  const [drivers, setDrivers] = useState([]);
  const [filter, setFilter] = useState('all');

  useEffect(() => {
    // Mock data
    setDrivers([
      { id: '1', name: 'أحمد محمد', phone: '0791234567', plateNumber: '12-34567', rating: 4.8, totalDeliveries: 156, isAvailable: true, isBlocked: false, isApproved: true, pendingSettlement: 12.5 },
      { id: '2', name: 'محمود سعيد', phone: '0797654321', plateNumber: '98-76543', rating: 4.5, totalDeliveries: 89, isAvailable: false, isBlocked: false, isApproved: true, pendingSettlement: 0 },
      { id: '3', name: 'خالد علي', phone: '0781112223', plateNumber: '55-44332', rating: 3.9, totalDeliveries: 45, isAvailable: false, isBlocked: true, isApproved: true, pendingSettlement: 52.5 },
      { id: '4', name: 'عمر حسن', phone: '0789998887', plateNumber: '11-22334', rating: 0, totalDeliveries: 0, isAvailable: false, isBlocked: false, isApproved: false, pendingSettlement: 0 },
    ]);
  }, []);

  const getStatusBadge = (driver) => {
    if (!driver.isApproved) return <span className="badge badge-warning">بانتظار الموافقة</span>;
    if (driver.isBlocked) return <span className="badge badge-danger">محظور</span>;
    if (driver.isAvailable) return <span className="badge badge-success">متصل</span>;
    return <span className="badge badge-info">غير متصل</span>;
  };

  const filteredDrivers = drivers.filter(d => {
    if (filter === 'all') return true;
    if (filter === 'online') return d.isAvailable;
    if (filter === 'blocked') return d.isBlocked;
    if (filter === 'pending') return !d.isApproved;
    return true;
  });

  const handleApprove = (id) => {
    setDrivers(drivers.map(d => d.id === id ? { ...d, isApproved: true } : d));
  };

  const handleUnblock = (id) => {
    setDrivers(drivers.map(d => d.id === id ? { ...d, isBlocked: false } : d));
  };

  return (
    <div>
      <h1 className="page-title">السائقين</h1>

      <div className="filters">
        <select value={filter} onChange={e => setFilter(e.target.value)}>
          <option value="all">جميع السائقين</option>
          <option value="online">متصلين</option>
          <option value="blocked">محظورين</option>
          <option value="pending">بانتظار الموافقة</option>
        </select>
        <input type="text" placeholder="بحث بالاسم أو الهاتف..." />
      </div>

      <div className="card">
        <table>
          <thead>
            <tr>
              <th>السائق</th>
              <th>رقم اللوحة</th>
              <th>التقييم</th>
              <th>التوصيلات</th>
              <th>المستحقات</th>
              <th>الحالة</th>
              <th>إجراءات</th>
            </tr>
          </thead>
          <tbody>
            {filteredDrivers.map(driver => (
              <tr key={driver.id}>
                <td>
                  <div className="flex">
                    <div className="avatar">{driver.name[0]}</div>
                    <div>
                      <div>{driver.name}</div>
                      <div className="text-muted">{driver.phone}</div>
                    </div>
                  </div>
                </td>
                <td>{driver.plateNumber}</td>
                <td>⭐ {driver.rating}</td>
                <td>{driver.totalDeliveries}</td>
                <td style={{ color: driver.pendingSettlement > 0 ? '#e53935' : '#333' }}>
                  {driver.pendingSettlement.toFixed(2)} د
                </td>
                <td>{getStatusBadge(driver)}</td>
                <td>
                  {!driver.isApproved && (
                    <button className="btn btn-sm btn-success" onClick={() => handleApprove(driver.id)}>
                      موافقة
                    </button>
                  )}
                  {driver.isBlocked && (
                    <button className="btn btn-sm btn-primary" onClick={() => handleUnblock(driver.id)}>
                      رفع الحظر
                    </button>
                  )}
                  <button className="btn btn-sm" style={{ marginRight: 8 }}>عرض</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

