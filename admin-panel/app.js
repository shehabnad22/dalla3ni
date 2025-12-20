// API Configuration
const API_BASE_URL = 'http://localhost:3000/api'; // Change this to your actual API URL
// For production, use: 'https://api.dalla3ni.com/api'
let authToken = localStorage.getItem('admin_token') || '';

// Initialize
document.addEventListener('DOMContentLoaded', async () => {
    // Check backend connection first
    const isConnected = await checkBackendConnection();
    if (!isConnected) {
        showBackendError();
        return;
    }
    
    checkAuth();
    setupNavigation();
});

// Check Backend Connection
async function checkBackendConnection() {
    try {
        const baseUrl = API_BASE_URL.replace('/api', '');
        
        // Create timeout manually for better browser support
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), 5000); // 5 second timeout
        
        const response = await fetch(`${baseUrl}/health`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json',
            },
            signal: controller.signal,
        });
        
        clearTimeout(timeoutId);
        
        if (response.ok) {
            const data = await response.json();
            console.log('✅ Backend is connected:', data);
            hideBackendError();
            updateConnectionStatus(true);
            return true;
        } else {
            console.error('❌ Backend connection failed:', response.status);
            showBackendError();
            updateConnectionStatus(false);
            return false;
        }
    } catch (error) {
        if (error.name === 'AbortError') {
            console.error('❌ Backend connection timeout (5 seconds)');
        } else {
            console.error('❌ Backend connection error:', error);
        }
        showBackendError();
        updateConnectionStatus(false);
        return false;
    }
}

// Show Backend Error
function showBackendError() {
    // Remove existing error if any
    const existingError = document.getElementById('backend-error');
    if (existingError) {
        existingError.remove();
    }
    
    // Create error banner
    const errorBanner = document.createElement('div');
    errorBanner.id = 'backend-error';
    errorBanner.style.cssText = `
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        background: #dc3545;
        color: white;
        padding: 15px;
        text-align: center;
        z-index: 10000;
        font-weight: bold;
        box-shadow: 0 2px 10px rgba(0,0,0,0.2);
    `;
    errorBanner.innerHTML = `
        ⚠️ لا يمكن الاتصال بالـ Backend. تأكد أن الخادم يعمل على http://localhost:3000
        <button onclick="location.reload()" style="margin-left: 20px; padding: 5px 15px; background: white; color: #dc3545; border: none; border-radius: 5px; cursor: pointer;">
            إعادة المحاولة
        </button>
    `;
    document.body.insertBefore(errorBanner, document.body.firstChild);
}

// Hide Backend Error
function hideBackendError() {
    const errorBanner = document.getElementById('backend-error');
    if (errorBanner) {
        errorBanner.remove();
    }
    
    // Update status indicator
    const indicator = document.getElementById('status-indicator');
    if (indicator) {
        indicator.textContent = '✅ متصل';
        indicator.parentElement.style.background = '#d4edda';
        indicator.parentElement.style.color = '#155724';
    }
}

// Update connection status indicator
function updateConnectionStatus(isConnected) {
    const indicator = document.getElementById('status-indicator');
    if (indicator) {
        if (isConnected) {
            indicator.textContent = '✅ متصل';
            indicator.parentElement.style.background = '#d4edda';
            indicator.parentElement.style.color = '#155724';
        } else {
            indicator.textContent = '❌ غير متصل';
            indicator.parentElement.style.background = '#f8d7da';
            indicator.parentElement.style.color = '#721c24';
        }
    }
}

// Check connection periodically
setInterval(async () => {
    const isConnected = await checkBackendConnection();
    updateConnectionStatus(isConnected);
}, 30000); // Check every 30 seconds

// Authentication
function checkAuth() {
    const savedEmail = localStorage.getItem('admin_email');
    const ADMIN_EMAIL = 'shehab.nad22@gmail.com';
    
    // التحقق من البريد المحفوظ
    if (!authToken || savedEmail !== ADMIN_EMAIL) {
        // مسح البيانات القديمة
        localStorage.removeItem('admin_token');
        localStorage.removeItem('admin_email');
        showLoginModal();
    } else {
        loadDashboard();
    }
}

function showLoginModal() {
    // Remove existing modal if any
    const existingModal = document.getElementById('login-modal');
    if (existingModal) {
        existingModal.remove();
    }
    
    const modal = document.createElement('div');
    modal.className = 'modal';
    modal.id = 'login-modal';
    modal.style.display = 'block';
    modal.style.zIndex = '10000';
    modal.innerHTML = `
        <div class="modal-content" style="max-width: 400px;">
            <h2>تسجيل الدخول - لوحة التحكم</h2>
            <form id="login-form">
                <div style="margin-bottom: 16px;">
                    <label style="display: block; margin-bottom: 8px; font-weight: 600;">البريد الإلكتروني:</label>
                    <input type="email" id="login-email" class="form-control" required autocomplete="email">
                </div>
                <div style="margin-bottom: 16px;">
                    <label style="display: block; margin-bottom: 8px; font-weight: 600;">كلمة المرور:</label>
                    <input type="password" id="login-password" class="form-control" required autocomplete="current-password">
                </div>
                <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 8px;">تسجيل الدخول</button>
            </form>
        </div>
    `;
    document.body.appendChild(modal);
    
    document.getElementById('login-form').addEventListener('submit', async (e) => {
        e.preventDefault();
        const email = document.getElementById('login-email').value.trim();
        const password = document.getElementById('login-password').value;
        
        // التحقق من بيانات الدخول المحددة
        const ADMIN_EMAIL = 'shehab.nad22@gmail.com';
        const ADMIN_PASSWORD = 'Ss123456789';
        
        if (email !== ADMIN_EMAIL || password !== ADMIN_PASSWORD) {
            alert('❌ غير مصرح لك بالدخول. بيانات الدخول غير صحيحة.');
            return;
        }
        
        try {
            const response = await fetch(`${API_BASE_URL}/auth/admin/login`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ email, password }),
            });
            
            const data = await response.json();
            if (data.success) {
                authToken = data.accessToken;
                localStorage.setItem('admin_token', authToken);
                localStorage.setItem('admin_email', email); // حفظ البريد للتحقق لاحقاً
                modal.remove();
                loadDashboard();
            } else {
                // حتى لو فشل API، نسمح بالدخول إذا كانت البيانات صحيحة
                // (في حالة عدم وجود حساب admin في قاعدة البيانات)
                authToken = 'admin_' + Date.now(); // Token مؤقت
                localStorage.setItem('admin_token', authToken);
                localStorage.setItem('admin_email', email);
                modal.remove();
                loadDashboard();
            }
        } catch (error) {
            // في حالة عدم توفر API، نسمح بالدخول إذا كانت البيانات صحيحة
            authToken = 'admin_' + Date.now();
            localStorage.setItem('admin_token', authToken);
            localStorage.setItem('admin_email', email);
            modal.remove();
            loadDashboard();
        }
    });
}

function logout() {
    if (confirm('هل أنت متأكد من تسجيل الخروج؟')) {
        authToken = '';
        localStorage.removeItem('admin_token');
        location.reload();
    }
}

// API Helper
async function apiCall(endpoint, options = {}) {
    // التحقق من البريد قبل كل طلب
    const savedEmail = localStorage.getItem('admin_email');
    const ADMIN_EMAIL = 'shehab.nad22@gmail.com';
    
    if (savedEmail !== ADMIN_EMAIL) {
        authToken = '';
        localStorage.removeItem('admin_token');
        localStorage.removeItem('admin_email');
        location.reload();
        return null;
    }
    
    // Check backend connection first
    const isConnected = await checkBackendConnection();
    if (!isConnected) {
        return { success: false, error: 'Backend is not connected' };
    }
    
    try {
        console.log(`API Call: ${endpoint}`, options);
        const response = await fetch(`${API_BASE_URL}${endpoint}`, {
            ...options,
            headers: {
                'Content-Type': 'application/json',
                'Authorization': authToken ? `Bearer ${authToken}` : '',
                ...options.headers,
            },
        });
        
        console.log(`API Response: ${endpoint}`, response.status, response.statusText);
        
        if (response.status === 401) {
            console.warn('Unauthorized - clearing auth');
            authToken = '';
            localStorage.removeItem('admin_token');
            localStorage.removeItem('admin_email');
            // Don't reload, just return error
            return { success: false, error: 'Unauthorized', code: 401 };
        }
        
        if (!response.ok) {
            const errorText = await response.text();
            console.error(`API Error: ${response.status} - ${response.statusText}`, errorText);
            return { success: false, error: `HTTP ${response.status}`, details: errorText };
        }
        
        const data = await response.json();
        console.log(`API Success: ${endpoint}`, data);
        return data;
    } catch (error) {
        console.error('API Call Error:', error);
        showBackendError();
        return { success: false, error: error.message };
    }
}

// Navigation
function setupNavigation() {
    const navItems = document.querySelectorAll('.nav-item');
    navItems.forEach(item => {
        item.addEventListener('click', (e) => {
            e.preventDefault();
            const page = item.getAttribute('data-page');
            showPage(page);
            
            navItems.forEach(nav => nav.classList.remove('active'));
            item.classList.add('active');
        });
    });
}

function showPage(pageId) {
    const pages = document.querySelectorAll('.page');
    pages.forEach(page => page.classList.remove('active'));
    
    const targetPage = document.getElementById(pageId);
    if (targetPage) {
        targetPage.classList.add('active');
        updatePageTitle(pageId);
        loadPageData(pageId);
    }
}

function updatePageTitle(pageId) {
    const titles = {
        'dashboard': 'لوحة التحكم',
        'users': 'المستخدمين',
        'drivers': 'السائقين',
        'orders': 'الطلبات',
        'invoices': 'الفواتير',
        'tracking': 'تتبع الميتور',
        'statistics': 'الإحصائيات',
        'delayed': 'المتأخرين'
    };
    document.getElementById('page-title').textContent = titles[pageId] || 'لوحة التحكم';
}

// Load Page Data
function loadPageData(pageId) {
    switch(pageId) {
        case 'users':
            loadUsers();
            break;
        case 'drivers':
            loadDrivers();
            break;
        case 'orders':
            loadOrders();
            break;
        case 'invoices':
            loadInvoices();
            break;
        case 'tracking':
            loadTracking();
            break;
        case 'statistics':
            loadStatistics();
            break;
        case 'delayed':
            loadDelayed();
            break;
    }
}

// Data will be loaded from API

// Dashboard
async function loadDashboard() {
    try {
        console.log('Loading dashboard...');
        
        // Check if we have auth token
        if (!authToken) {
            console.warn('No auth token - user needs to login');
            document.getElementById('total-users').textContent = 'سجل دخول';
            document.getElementById('total-drivers').textContent = 'سجل دخول';
            document.getElementById('total-orders').textContent = 'سجل دخول';
            return;
        }
        
        const stats = await apiCall('/admin/stats');
        console.log('Dashboard stats:', stats);
        
        if (stats && stats.success) {
            document.getElementById('total-users').textContent = stats.stats.totalUsers || 0;
            document.getElementById('total-drivers').textContent = stats.stats.totalDrivers || 0;
            document.getElementById('total-orders').textContent = stats.stats.totalOrders || 0;
            document.getElementById('delayed-count').textContent = await getDelayedCount();
        } else {
            console.error('Failed to load stats:', stats);
            // Show error message with details
            const errorMsg = stats?.error || 'خطأ في الاتصال';
            document.getElementById('total-users').textContent = errorMsg;
            document.getElementById('total-drivers').textContent = errorMsg;
            document.getElementById('total-orders').textContent = errorMsg;
            
            // If unauthorized, show login prompt
            if (stats?.code === 401) {
                alert('يرجى تسجيل الدخول أولاً');
            }
        }
        
        await loadTopDrivers();
    } catch (error) {
        console.error('Error loading dashboard:', error);
        document.getElementById('total-users').textContent = 'خطأ';
        document.getElementById('total-drivers').textContent = 'خطأ';
        document.getElementById('total-orders').textContent = 'خطأ';
    }
}

async function loadTopDrivers() {
    try {
        const stats = await apiCall('/admin/statistics');
        if (stats && stats.success) {
            const topDrivers = stats.topRatedDrivers.slice(0, 5);
            const container = document.getElementById('top-drivers-list');
            container.innerHTML = topDrivers.map((driver, index) => `
                <div class="ranking-item">
                    <div class="ranking-number">${index + 1}</div>
                    <div class="ranking-info">
                        <h4>${driver.name}</h4>
                        <p>⭐ ${driver.rating} | ${driver.ordersCount} طلب</p>
                    </div>
                </div>
            `).join('');
        }
    } catch (error) {
        console.error('Error loading top drivers:', error);
    }
}

// Users
async function loadUsers() {
    try {
        console.log('Loading users...');
        const sortBy = document.getElementById('sort-users')?.value || 'newest';
        const searchTerm = document.getElementById('search-users')?.value || '';
        
        const data = await apiCall(`/admin/users?sort=${sortBy}&search=${encodeURIComponent(searchTerm)}`);
        console.log('Users data:', data);
        
        if (data && data.success) {
            const tbody = document.getElementById('users-table-body');
            if (data.users && data.users.length > 0) {
                tbody.innerHTML = data.users.map(user => `
                    <tr>
                        <td>${user.name || 'غير معروف'}</td>
                        <td>${user.phone || ''}</td>
                        <td>${formatDateTime(user.registerTime)}</td>
                        <td>${user.ordersCount || 0}</td>
                        <td>
                            <button class="btn btn-primary" onclick="viewUserDetails('${user.id}')">
                                <i class="fas fa-eye"></i> عرض
                            </button>
                        </td>
                    </tr>
                `).join('');
            } else {
                tbody.innerHTML = '<tr><td colspan="5" style="text-align: center; padding: 20px;">لا توجد بيانات</td></tr>';
            }
        } else {
            console.error('Failed to load users:', data);
            const tbody = document.getElementById('users-table-body');
            tbody.innerHTML = '<tr><td colspan="5" style="text-align: center; padding: 20px; color: red;">خطأ في تحميل البيانات</td></tr>';
        }
        
        // Add event listeners (remove old ones first)
        const sortSelect = document.getElementById('sort-users');
        const searchInput = document.getElementById('search-users');
        if (sortSelect) {
            sortSelect.replaceWith(sortSelect.cloneNode(true));
            document.getElementById('sort-users').addEventListener('change', () => loadUsers());
        }
        if (searchInput) {
            searchInput.replaceWith(searchInput.cloneNode(true));
            document.getElementById('search-users').addEventListener('input', () => loadUsers());
        }
    } catch (error) {
        console.error('Error loading users:', error);
        const tbody = document.getElementById('users-table-body');
        if (tbody) {
            tbody.innerHTML = '<tr><td colspan="5" style="text-align: center; padding: 20px; color: red;">خطأ: ' + error.message + '</td></tr>';
        }
    }
}

// Drivers
async function loadDrivers() {
    try {
        console.log('Loading drivers...');
        const data = await apiCall('/admin/drivers');
        console.log('Drivers data:', data);
        
        if (data && data.success) {
            const statusFilter = document.getElementById('driver-status-filter')?.value || 'all';
            
            let filtered = data.drivers || [];
            if (statusFilter === 'online') {
                filtered = filtered.filter(d => d.isAvailable);
            } else if (statusFilter === 'offline') {
                filtered = filtered.filter(d => !d.isAvailable);
            } else if (statusFilter === 'on-delivery') {
                // Filter drivers with active orders
                filtered = filtered; // TODO: Filter by active orders
            }
            
            const tbody = document.getElementById('drivers-table-body');
            if (filtered.length > 0) {
                tbody.innerHTML = filtered.map(driver => {
                    const status = driver.isAvailable ? 'online' : 'offline';
                    return `
                        <tr>
                            <td>${driver.User?.name || 'غير معروف'}</td>
                            <td>${driver.User?.phone || ''}</td>
                            <td><span class="status-badge ${status}">${getStatusText(status)}</span></td>
                            <td>⭐ ${parseFloat(driver.rating) || 0}</td>
                            <td>${driver.totalDeliveries || 0}</td>
                            <td>
                                <button class="btn btn-primary" onclick="viewDriverDetails('${driver.id}')">
                                    <i class="fas fa-eye"></i> عرض
                                </button>
                            </td>
                        </tr>
                    `;
                }).join('');
            } else {
                tbody.innerHTML = '<tr><td colspan="6" style="text-align: center; padding: 20px;">لا يوجد سائقين</td></tr>';
            }
        } else {
            console.error('Failed to load drivers:', data);
            const tbody = document.getElementById('drivers-table-body');
            tbody.innerHTML = '<tr><td colspan="6" style="text-align: center; padding: 20px; color: red;">خطأ في تحميل البيانات</td></tr>';
        }
        
        const filterSelect = document.getElementById('driver-status-filter');
        if (filterSelect) {
            filterSelect.replaceWith(filterSelect.cloneNode(true));
            document.getElementById('driver-status-filter').addEventListener('change', () => loadDrivers());
        }
    } catch (error) {
        console.error('Error loading drivers:', error);
        const tbody = document.getElementById('drivers-table-body');
        if (tbody) {
            tbody.innerHTML = '<tr><td colspan="6" style="text-align: center; padding: 20px; color: red;">خطأ: ' + error.message + '</td></tr>';
        }
    }
}

// Orders
async function loadOrders() {
    try {
        console.log('Loading orders...');
        const statusFilter = document.getElementById('order-status-filter')?.value || 'all';
        const data = await apiCall(`/admin/orders?status=${statusFilter}`);
        console.log('Orders data:', data);
        
        if (data && data.success) {
            const tbody = document.getElementById('orders-table-body');
            if (data.orders && data.orders.length > 0) {
                tbody.innerHTML = data.orders.map(order => `
                    <tr>
                        <td>#${order.id ? order.id.substring(0, 8) : 'N/A'}</td>
                        <td>${order.customer || 'غير معروف'}</td>
                        <td>${order.driver || 'لم يتم التعيين'}</td>
                        <td><span class="status-badge ${order.status ? order.status.toLowerCase() : 'pending'}">${getStatusText(order.status)}</span></td>
                        <td>${formatDateTime(order.time)}</td>
                        <td>
                            <button class="btn btn-primary" onclick="viewOrderDetails('${order.id}')">
                                <i class="fas fa-eye"></i> عرض
                            </button>
                        </td>
                    </tr>
                `).join('');
            } else {
                tbody.innerHTML = '<tr><td colspan="6" style="text-align: center; padding: 20px;">لا توجد طلبات</td></tr>';
            }
        } else {
            console.error('Failed to load orders:', data);
            const tbody = document.getElementById('orders-table-body');
            tbody.innerHTML = '<tr><td colspan="6" style="text-align: center; padding: 20px; color: red;">خطأ في تحميل البيانات</td></tr>';
        }
        
        const filterSelect = document.getElementById('order-status-filter');
        if (filterSelect) {
            filterSelect.replaceWith(filterSelect.cloneNode(true));
            document.getElementById('order-status-filter').addEventListener('change', () => loadOrders());
        }
    } catch (error) {
        console.error('Error loading orders:', error);
        const tbody = document.getElementById('orders-table-body');
        if (tbody) {
            tbody.innerHTML = '<tr><td colspan="6" style="text-align: center; padding: 20px; color: red;">خطأ: ' + error.message + '</td></tr>';
        }
    }
}

// Invoices - Grouped by Location
async function loadInvoices() {
    try {
        const locationFilter = document.getElementById('invoice-location-filter')?.value || 'all';
        const data = await apiCall(`/admin/invoices${locationFilter !== 'all' ? `?location=${encodeURIComponent(locationFilter)}` : ''}`);
        
        if (data && data.success) {
            const grouped = data.invoices;
            
            // Update location filter
            const filter = document.getElementById('invoice-location-filter');
            filter.innerHTML = '<option value="all">الكل</option>' +
                Object.keys(grouped).map(loc => `<option value="${loc}">${loc}</option>`).join('');
            
            const container = document.getElementById('invoices-container');
            container.innerHTML = Object.entries(grouped).map(([location, invoices]) => `
                <div class="location-group">
                    <h3><i class="fas fa-map-marker-alt"></i> ${location} (${invoices.length} فاتورة)</h3>
                    <div class="invoices-list">
                        ${invoices.map(invoice => `
                            <div class="invoice-item" onclick="viewInvoice('${invoice.id}')">
                                <img src="${invoice.image}" alt="فاتورة ${invoice.id}" onerror="this.src='https://via.placeholder.com/300'">
                                <div class="invoice-item-info">
                                    <p><strong>السائق:</strong> ${invoice.driver}</p>
                                    <p><strong>الطلب:</strong> #${invoice.orderId.substring(0, 8)}</p>
                                    <p><strong>الوقت:</strong> ${formatDateTime(invoice.time)}</p>
                                </div>
                            </div>
                        `).join('')}
                    </div>
                </div>
            `).join('');
            
            filter.addEventListener('change', (e) => {
                loadInvoices();
            });
        }
    } catch (error) {
        console.error('Error loading invoices:', error);
    }
}

// Tracking
async function loadTracking() {
    try {
        const data = await apiCall('/admin/tracking');
        
        if (data && data.success) {
            const container = document.getElementById('active-deliveries-list');
            container.innerHTML = data.deliveries.map(delivery => `
                <div class="delivery-item">
                    <h4>${delivery.driver}</h4>
                    <p><strong>الزبون:</strong> ${delivery.customer}</p>
                    <p><strong>رقم الطلب:</strong> #${delivery.orderId.substring(0, 8)}</p>
                    <p><strong>الحالة:</strong> <span class="status-badge picked_up">${getStatusText(delivery.status)}</span></p>
                    ${delivery.driverLocation ? `<p><small>الموقع: ${delivery.driverLocation.lat}, ${delivery.driverLocation.lng}</small></p>` : ''}
                </div>
            `).join('');
            
            // TODO: Initialize map with driver locations
            // This would require a map library like Leaflet or Google Maps
        }
    } catch (error) {
        console.error('Error loading tracking:', error);
    }
}

// Statistics
async function loadStatistics() {
    try {
        const data = await apiCall('/admin/statistics');
        
        if (data && data.success) {
            // Top Users
            document.getElementById('top-users-list').innerHTML = data.topUsers.map((user, index) => `
                <div class="ranking-item">
                    <div class="ranking-number">${index + 1}</div>
                    <div class="ranking-info">
                        <h4>${user.name}</h4>
                        <p>${user.ordersCount} طلب</p>
                    </div>
                </div>
            `).join('');
            
            // Top Rated Drivers
            document.getElementById('top-rated-drivers-list').innerHTML = data.topRatedDrivers.map((driver, index) => `
                <div class="ranking-item">
                    <div class="ranking-number">${index + 1}</div>
                    <div class="ranking-info">
                        <h4>${driver.name}</h4>
                        <p>⭐ ${driver.rating} | ${driver.ordersCount} طلب</p>
                    </div>
                </div>
            `).join('');
        }
    } catch (error) {
        console.error('Error loading statistics:', error);
    }
}

// Delayed Drivers
async function loadDelayed() {
    try {
        const data = await apiCall('/admin/delayed');
        
        if (data && data.success) {
            const tbody = document.getElementById('delayed-table-body');
            tbody.innerHTML = data.delayed.map(item => `
                <tr>
                    <td>${item.driver}</td>
                    <td>${item.phone}</td>
                    <td>${item.order}</td>
                    <td>${item.expectedTime}</td>
                    <td>${item.actualTime}</td>
                    <td><span class="status-badge pending">${item.delay}</span></td>
                    <td>
                        <button class="btn btn-primary" onclick="contactDriver('${item.phone}')">
                            <i class="fas fa-phone"></i> اتصال
                        </button>
                    </td>
                </tr>
            `).join('');
        }
    } catch (error) {
        console.error('Error loading delayed:', error);
    }
}

async function getDelayedCount() {
    try {
        const data = await apiCall('/admin/delayed');
        return data && data.success ? data.delayed.length : 0;
    } catch (error) {
        return 0;
    }
}

// Utility Functions
function formatDateTime(dateString) {
    const date = new Date(dateString);
    return date.toLocaleString('ar-SA', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit'
    });
}

function getStatusText(status) {
    const statuses = {
        'pending': 'قيد الانتظار',
        'accepted': 'مقبول',
        'picked_up': 'تم الاستلام',
        'delivered': 'تم التوصيل',
        'online': 'متصل',
        'offline': 'غير متصل',
        'on-delivery': 'في التوصيل'
    };
    return statuses[status] || status;
}

// Actions
async function viewInvoice(id) {
    try {
        const data = await apiCall(`/admin/invoices`);
        if (data && data.success) {
            let invoice = null;
            for (const location in data.invoices) {
                invoice = data.invoices[location].find(inv => inv.id === id);
                if (invoice) break;
            }
            
            if (invoice) {
                document.getElementById('invoice-details').innerHTML = `
                    <div style="text-align: center;">
                        <img src="${invoice.image}" style="max-width: 100%; border-radius: 8px; margin-bottom: 20px;" onerror="this.src='https://via.placeholder.com/300'">
                        <p><strong>السائق:</strong> ${invoice.driver}</p>
                        <p><strong>المكان:</strong> ${invoice.location}</p>
                        <p><strong>رقم الطلب:</strong> #${invoice.orderId.substring(0, 8)}</p>
                        <p><strong>الوقت:</strong> ${formatDateTime(invoice.time)}</p>
                    </div>
                `;
                document.getElementById('invoice-modal').style.display = 'block';
            }
        }
    } catch (error) {
        console.error('Error loading invoice:', error);
    }
}

function closeModal(modalId) {
    document.getElementById(modalId).style.display = 'none';
}

function refreshData() {
    const activePage = document.querySelector('.page.active')?.id;
    if (activePage) {
        loadPageData(activePage);
    }
    loadDashboard();
    alert('تم تحديث البيانات');
}

function logout() {
    if (confirm('هل أنت متأكد من تسجيل الخروج؟')) {
        // TODO: Clear session and redirect to login
        alert('تم تسجيل الخروج');
    }
}

function viewUserDetails(id) {
    // TODO: Show user details modal
    alert('عرض تفاصيل المستخدم #' + id.substring(0, 8));
}

function viewDriverDetails(id) {
    // TODO: Show driver details modal
    alert('عرض تفاصيل السائق #' + id.substring(0, 8));
}

function viewOrderDetails(id) {
    // TODO: Show order details modal
    alert('عرض تفاصيل الطلب #' + id.substring(0, 8));
}

function contactDriver(phone) {
    window.location.href = `tel:${phone}`;
}

// Close modal when clicking outside
window.onclick = function(event) {
    const modals = document.querySelectorAll('.modal');
    modals.forEach(modal => {
        if (event.target === modal) {
            modal.style.display = 'none';
        }
    });
}

