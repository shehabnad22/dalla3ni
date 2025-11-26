import React, { useState, useEffect } from 'react';

const API_URL = 'http://localhost:3000/api';

const statusLabels = {
  pending: { label: 'معلق', class: 'badge-warning' },
  matching: { label: 'جاري البحث', class: 'badge-info' },
  accepted: { label: 'مقبول', class: 'badge-info' },
  picked_up: { label: 'تم الاستلام', class: 'badge-info' },
  delivered: { label: 'تم التوصيل', class: 'badge-success' },
  cancelled: { label: 'ملغي', class: 'badge-danger' },
};

export default function OrdersPage() {
  const [orders, setOrders] = useState([]);
  const [filter, setFilter] = useState('all');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Mock data for now
    setOrders([
      { id: '1001', customer: 'محمد أحمد', driver: 'أحمد علي', itemsText: '2 شاورما + بيبسي', status: 'delivered', price: 5.50, createdAt: '2025-11-26T10:30:00' },
      { id: '1002', customer: 'سارة خالد', driver: null, itemsText: 'بيتزا كبيرة', status: 'matching', price: 8.00, createdAt: '2025-11-26T11:15:00' },
      { id: '1003', customer: 'علي حسن', driver: 'محمود سعيد', itemsText: 'وجبة برجر', status: 'picked_up', price: 4.50, createdAt: '2025-11-26T11:45:00' },
    ]);
    setLoading(false);
  }, []);

  const filteredOrders = filter === 'all' ? orders : orders.filter(o => o.status === filter);

  return (
    <div>
      <h1 className="page-title">الطلبات</h1>

      <div className="filters">
        <select value={filter} onChange={e => setFilter(e.target.value)}>
          <option value="all">جميع الطلبات</option>
          <option value="pending">معلقة</option>
          <option value="matching">جاري البحث</option>
          <option value="accepted">مقبولة</option>
          <option value="picked_up">تم الاستلام</option>
          <option value="delivered">تم التوصيل</option>
          <option value="cancelled">ملغية</option>
        </select>
        <input type="date" />
        <input type="text" placeholder="بحث برقم الطلب..." />
      </div>

      <div className="card">
        <table>
          <thead>
            <tr>
              <th>#</th>
              <th>الزبون</th>
              <th>الطلب</th>
              <th>السائق</th>
              <th>السعر</th>
              <th>الحالة</th>
              <th>التاريخ</th>
              <th>إجراءات</th>
            </tr>
          </thead>
          <tbody>
            {filteredOrders.map(order => (
              <tr key={order.id}>
                <td>#{order.id}</td>
                <td>{order.customer}</td>
                <td style={{ maxWidth: 200, overflow: 'hidden', textOverflow: 'ellipsis' }}>{order.itemsText}</td>
                <td>{order.driver || <span className="text-muted">-</span>}</td>
                <td>{order.price?.toFixed(2)} د</td>
                <td>
                  <span className={`badge ${statusLabels[order.status]?.class}`}>
                    {statusLabels[order.status]?.label}
                  </span>
                </td>
                <td>{new Date(order.createdAt).toLocaleString('ar')}</td>
                <td>
                  <button className="btn btn-sm btn-primary">عرض</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

