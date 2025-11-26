import React, { useState } from 'react';
import Sidebar from './components/Sidebar';
import DashboardPage from './pages/DashboardPage';
import OrdersPage from './pages/OrdersPage';
import DriversPage from './pages/DriversPage';
import InvoicesPage from './pages/InvoicesPage';
import DisputesPage from './pages/DisputesPage';
import SettlementsPage from './pages/SettlementsPage';
import RatingsPage from './pages/RatingsPage';
import AuditLogsPage from './pages/AuditLogsPage';
import './App.css';

function App() {
  const [currentPage, setCurrentPage] = useState('dashboard');

  const renderPage = () => {
    switch (currentPage) {
      case 'dashboard': return <DashboardPage />;
      case 'orders': return <OrdersPage />;
      case 'drivers': return <DriversPage />;
      case 'invoices': return <InvoicesPage />;
      case 'disputes': return <DisputesPage />;
      case 'settlements': return <SettlementsPage />;
      case 'ratings': return <RatingsPage />;
      case 'audit': return <AuditLogsPage />;
      default: return <DashboardPage />;
    }
  };

  return (
    <div className="app">
      <Sidebar currentPage={currentPage} onPageChange={setCurrentPage} />
      <main className="main-content">
        {renderPage()}
      </main>
    </div>
  );
}

export default App;

