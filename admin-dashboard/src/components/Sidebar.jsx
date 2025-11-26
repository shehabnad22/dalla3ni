import React from 'react';
import './Sidebar.css';

const menuItems = [
  { id: 'dashboard', label: 'لوحة التحكم', icon: '📊' },
  { id: 'orders', label: 'الطلبات', icon: '📦' },
  { id: 'drivers', label: 'السائقين', icon: '🛵' },
  { id: 'invoices', label: 'الفواتير', icon: '🧾' },
  { id: 'disputes', label: 'النزاعات', icon: '⚠️' },
  { id: 'settlements', label: 'التسويات', icon: '💰' },
  { id: 'ratings', label: 'التقييمات', icon: '⭐' },
  { id: 'audit', label: 'سجل العمليات', icon: '📋' },
];

export default function Sidebar({ currentPage, onPageChange }) {
  return (
    <aside className="sidebar">
      <div className="sidebar-header">
        <div className="logo">🛵</div>
        <h1>دلّعني</h1>
        <span className="subtitle">لوحة الإدارة</span>
      </div>
      
      <nav className="sidebar-nav">
        {menuItems.map(item => (
          <button
            key={item.id}
            className={`nav-item ${currentPage === item.id ? 'active' : ''}`}
            onClick={() => onPageChange(item.id)}
          >
            <span className="nav-icon">{item.icon}</span>
            <span className="nav-label">{item.label}</span>
          </button>
        ))}
      </nav>
      
      <div className="sidebar-footer">
        <div className="admin-info">
          <div className="admin-avatar">م</div>
          <div>
            <div className="admin-name">المدير</div>
            <div className="admin-role">مدير النظام</div>
          </div>
        </div>
      </div>
    </aside>
  );
}

