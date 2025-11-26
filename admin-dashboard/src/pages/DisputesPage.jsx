import React, { useState } from 'react';

export default function DisputesPage() {
  const [disputes, setDisputes] = useState([
    { id: '1', orderId: '1005', customer: 'فاطمة أحمد', driver: 'خالد علي', type: 'تأخر التوصيل', description: 'الطلب تأخر ساعة كاملة', status: 'open', createdAt: '2025-11-26T09:00:00' },
    { id: '2', orderId: '1008', customer: 'عمر سعيد', driver: 'أحمد محمد', type: 'طلب ناقص', description: 'لم يصل المشروب مع الطلب', status: 'investigating', createdAt: '2025-11-25T14:30:00' },
    { id: '3', orderId: '1002', customer: 'ليلى خالد', driver: 'محمود سعيد', type: 'سوء تعامل', description: 'السائق كان غير مهذب', status: 'resolved', createdAt: '2025-11-24T16:00:00', resolution: 'تم تحذير السائق' },
  ]);

  const statusLabels = {
    open: { label: 'مفتوح', class: 'badge-danger' },
    investigating: { label: 'قيد التحقيق', class: 'badge-warning' },
    resolved: { label: 'تم الحل', class: 'badge-success' },
  };

  const handleResolve = (id) => {
    setDisputes(disputes.map(d => d.id === id ? { ...d, status: 'resolved' } : d));
  };

  return (
    <div>
      <h1 className="page-title">النزاعات</h1>

      <div className="stats-grid" style={{ marginBottom: 24 }}>
        <div className="stat-card" style={{ borderRight: '4px solid #e53935' }}>
          <div className="stat-label">نزاعات مفتوحة</div>
          <div className="stat-value">{disputes.filter(d => d.status === 'open').length}</div>
        </div>
        <div className="stat-card" style={{ borderRight: '4px solid #ff9800' }}>
          <div className="stat-label">قيد التحقيق</div>
          <div className="stat-value">{disputes.filter(d => d.status === 'investigating').length}</div>
        </div>
        <div className="stat-card" style={{ borderRight: '4px solid #4caf50' }}>
          <div className="stat-label">تم حلها</div>
          <div className="stat-value">{disputes.filter(d => d.status === 'resolved').length}</div>
        </div>
      </div>

      <div className="card">
        <table>
          <thead>
            <tr>
              <th>#</th>
              <th>رقم الطلب</th>
              <th>الزبون</th>
              <th>السائق</th>
              <th>نوع المشكلة</th>
              <th>الوصف</th>
              <th>الحالة</th>
              <th>إجراءات</th>
            </tr>
          </thead>
          <tbody>
            {disputes.map(dispute => (
              <tr key={dispute.id}>
                <td>#{dispute.id}</td>
                <td>#{dispute.orderId}</td>
                <td>{dispute.customer}</td>
                <td>{dispute.driver}</td>
                <td>{dispute.type}</td>
                <td style={{ maxWidth: 200 }}>{dispute.description}</td>
                <td>
                  <span className={`badge ${statusLabels[dispute.status].class}`}>
                    {statusLabels[dispute.status].label}
                  </span>
                </td>
                <td>
                  {dispute.status !== 'resolved' && (
                    <button className="btn btn-sm btn-success" onClick={() => handleResolve(dispute.id)}>
                      حل النزاع
                    </button>
                  )}
                  <button className="btn btn-sm" style={{ marginRight: 8 }}>تفاصيل</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

