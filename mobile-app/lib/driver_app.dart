import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// ==================== Driver Main App ====================
class DriverApp extends StatelessWidget {
  const DriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'دلّعني - سائق',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
        useMaterial3: true,
        fontFamily: 'Cairo',
      ),
      builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
      home: const DriverLoginScreen(),
    );
  }
}

// ==================== Driver Login Screen ====================
class DriverLoginScreen extends StatefulWidget {
  const DriverLoginScreen({super.key});

  @override
  State<DriverLoginScreen> createState() => _DriverLoginScreenState();
}

class _DriverLoginScreenState extends State<DriverLoginScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _accountStatus; // null, 'PENDING_REVIEW', 'APPROVED', 'REJECTED'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6C63FF), Color(0xFF4A42D1)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
                  child: const Icon(Icons.motorcycle, size: 50, color: Color(0xFF6C63FF)),
                ),
                const SizedBox(height: 24),
                const Text('دلّعني - سائق', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                const Text('سجّل دخولك للبدء', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 48),
                
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    hintText: 'رقم الهاتف',
                    prefixIcon: const Icon(Icons.phone),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _checkStatus,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF6C63FF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('تسجيل الدخول', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                
                if (_accountStatus != null) ...[
                  const SizedBox(height: 24),
                  _buildStatusCard(),
                ],
                
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    // Navigate to registration
                  },
                  child: const Text('ليس لديك حساب؟ سجّل الآن', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    Color bgColor;
    IconData icon;
    String message;
    
    switch (_accountStatus) {
      case 'PENDING_REVIEW':
        bgColor = Colors.orange;
        icon = Icons.hourglass_empty;
        message = 'طلبك قيد المراجعة\nسيتم التواصل معك قريباً';
        break;
      case 'REJECTED':
        bgColor = Colors.red;
        icon = Icons.cancel;
        message = 'تم رفض طلبك\nيرجى التواصل مع الدعم';
        break;
      case 'APPROVED':
        bgColor = Colors.green;
        icon = Icons.check_circle;
        message = 'حسابك مفعّل!';
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DriverHomeScreen()));
        });
        break;
      default:
        return const SizedBox();
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bgColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: bgColor, size: 32),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: TextStyle(color: bgColor, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Future<void> _checkStatus() async {
    if (_phoneController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('رقم الهاتف غير صحيح')));
      return;
    }
    
    setState(() => _isLoading = true);
    
    // TODO: Call API /auth/driver/status/:phone
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock: Assume approved for demo
    setState(() {
      _isLoading = false;
      _accountStatus = 'APPROVED';
    });
  }
}

// ==================== Driver Home Screen ====================
class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  bool _isOnline = false;
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _incomingRequests = [];
  List<Map<String, dynamic>> _acceptedJobs = [];

  @override
  void initState() {
    super.initState();
    // Listen for push notifications
    _setupNotificationListener();
  }

  void _setupNotificationListener() {
    // TODO: Setup Firebase Cloud Messaging
    // FirebaseMessaging.onMessage.listen((message) { ... });
    // FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
    
    // Mock incoming request for demo
    Future.delayed(const Duration(seconds: 3), () {
      if (_isOnline && mounted) {
        _showIncomingRequest({
          'id': 'order-123',
          'itemsText': '2 شاورما دجاج + بيبسي كبير من مطعم الشام',
          'estimatedPrice': 5.50,
          'deliveryAddress': 'شارع الجامعة، عمارة 15',
          'customerName': 'محمد أحمد',
          'customerPhone': '0791234567',
          'pickupAddress': 'مطعم الشام - وسط البلد',
        });
      }
    });
  }

  void _showIncomingRequest(Map<String, dynamic> order) {
    setState(() => _incomingRequests.add(order));
    
    // Show dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _IncomingOrderDialog(
        order: order,
        onAccept: () {
          Navigator.pop(context);
          _acceptOrder(order);
        },
        onReject: () {
          Navigator.pop(context);
          setState(() => _incomingRequests.remove(order));
        },
      ),
    );
  }

  void _acceptOrder(Map<String, dynamic> order) {
    setState(() {
      _incomingRequests.remove(order);
      order['status'] = 'ASSIGNED';
      order['acceptedAt'] = DateTime.now().toIso8601String();
      _acceptedJobs.add(order);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم قبول الطلب بنجاح!'), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دلّعني - سائق'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        actions: [
          // Online/Offline Toggle
          Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _isOnline ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                    color: _isOnline ? Colors.green : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(_isOnline ? 'متصل' : 'غير متصل', style: const TextStyle(fontSize: 12)),
                Switch(
                  value: _isOnline,
                  onChanged: (v) => setState(() => _isOnline = v),
                  activeColor: Colors.green,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(),
          _buildJobsTab(),
          const DriverWalletScreen(),
          const DriverProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF6C63FF),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: _acceptedJobs.isNotEmpty,
              label: Text('${_acceptedJobs.length}'),
              child: const Icon(Icons.work),
            ),
            label: 'طلباتي',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'المحفظة'),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    if (!_isOnline) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 100, color: Colors.grey[300]),
            const SizedBox(height: 24),
            const Text('أنت غير متصل', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Text('قم بتشغيل الاتصال لاستقبال الطلبات', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => setState(() => _isOnline = true),
              icon: const Icon(Icons.power_settings_new),
              label: const Text('اتصل الآن'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle, size: 60, color: Colors.green),
          ),
          const SizedBox(height: 24),
          const Text('أنت متصل', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('في انتظار طلبات جديدة...', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 32),
          if (_incomingRequests.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active, color: Colors.orange),
                  const SizedBox(width: 12),
                  Text('${_incomingRequests.length} طلب جديد في الانتظار'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildJobsTab() {
    if (_acceptedJobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('لا توجد طلبات حالية', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _acceptedJobs.length,
      itemBuilder: (context, index) {
        final job = _acceptedJobs[index];
        return _JobCard(
          job: job,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => JobDetailsScreen(job: job, onUpdate: (updated) {
                setState(() => _acceptedJobs[index] = updated);
              })),
            );
          },
        );
      },
    );
  }
}

// ==================== Incoming Order Dialog ====================
class _IncomingOrderDialog extends StatefulWidget {
  final Map<String, dynamic> order;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _IncomingOrderDialog({required this.order, required this.onAccept, required this.onReject});

  @override
  State<_IncomingOrderDialog> createState() => _IncomingOrderDialogState();
}

class _IncomingOrderDialogState extends State<_IncomingOrderDialog> {
  int _countdown = 12;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _countdown--);
      if (_countdown <= 0) {
        widget.onReject();
        return false;
      }
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.notifications_active, color: Color(0xFF6C63FF)),
          const SizedBox(width: 8),
          const Expanded(child: Text('طلب جديد!')),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _countdown <= 5 ? Colors.red : Colors.orange,
              shape: BoxShape.circle,
            ),
            child: Text('$_countdown', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.order['itemsText'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _InfoRow(icon: Icons.store, label: 'من', value: widget.order['pickupAddress'] ?? ''),
          _InfoRow(icon: Icons.location_on, label: 'إلى', value: widget.order['deliveryAddress'] ?? ''),
          if (widget.order['estimatedPrice'] != null)
            _InfoRow(icon: Icons.attach_money, label: 'السعر التقديري', value: '${widget.order['estimatedPrice']} دينار'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.onReject,
          child: const Text('رفض', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: widget.onAccept,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C63FF),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32),
          ),
          child: const Text('آخذ الطلب'),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(color: Colors.grey)),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

// ==================== Job Card ====================
class _JobCard extends StatelessWidget {
  final Map<String, dynamic> job;
  final VoidCallback onTap;

  const _JobCard({required this.job, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = job['status'] ?? 'ASSIGNED';
    Color statusColor;
    String statusText;
    
    switch (status) {
      case 'ASSIGNED':
        statusColor = Colors.blue;
        statusText = 'في انتظار الاستلام';
        break;
      case 'PICKED_UP':
        statusColor = Colors.orange;
        statusText = 'تم الاستلام';
        break;
      case 'EN_ROUTE':
        statusColor = Colors.purple;
        statusText = 'في الطريق';
        break;
      case 'DELIVERED':
        statusColor = Colors.green;
        statusText = 'تم التسليم';
        break;
      default:
        statusColor = Colors.grey;
        statusText = status;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  const Spacer(),
                  Text('#${(job['id'] ?? '').toString().substring(0, 8)}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
              const SizedBox(height: 12),
              Text(job['itemsText'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(child: Text(job['deliveryAddress'] ?? '', style: TextStyle(color: Colors.grey[600], fontSize: 13))),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.arrow_forward, size: 16, color: Color(0xFF6C63FF)),
                  const SizedBox(width: 4),
                  const Text('عرض التفاصيل', style: TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== Job Details Screen ====================
class JobDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> job;
  final Function(Map<String, dynamic>) onUpdate;

  const JobDetailsScreen({super.key, required this.job, required this.onUpdate});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  late Map<String, dynamic> _job;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _job = Map.from(widget.job);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('طلب #${(_job['id'] ?? '').toString().substring(0, 8)}'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            _buildStatusCard(),
            const SizedBox(height: 16),
            
            // Customer Info
            _buildCustomerCard(),
            const SizedBox(height: 16),
            
            // Order Details
            _buildOrderCard(),
            const SizedBox(height: 16),
            
            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final status = _job['status'] ?? 'ASSIGNED';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF4A42D1)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text('حالة الطلب', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(_getStatusText(status), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'ASSIGNED': return 'في انتظار الاستلام';
      case 'PICKED_UP': return 'تم الاستلام - في الطريق';
      case 'EN_ROUTE': return 'في الطريق للزبون';
      case 'DELIVERED': return 'تم التسليم';
      case 'COMPLETED': return 'مكتمل';
      default: return status;
    }
  }

  Widget _buildCustomerCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('معلومات الزبون', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF6C63FF).withOpacity(0.1),
                  child: const Icon(Icons.person, color: Color(0xFF6C63FF)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_job['customerName'] ?? 'الزبون', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(_job['customerPhone'] ?? '', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
                // Call Button
                IconButton(
                  onPressed: () => _callCustomer(_job['customerPhone'] ?? ''),
                  icon: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.phone, color: Colors.green),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _callCustomer(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Widget _buildOrderCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('تفاصيل الطلب', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(),
            Text(_job['itemsText'] ?? '', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            
            _DetailRow(icon: Icons.store, label: 'الاستلام من', value: _job['pickupAddress'] ?? ''),
            _DetailRow(icon: Icons.location_on, label: 'التوصيل إلى', value: _job['deliveryAddress'] ?? ''),
            
            if (_job['estimatedPrice'] != null)
              _DetailRow(icon: Icons.attach_money, label: 'السعر التقديري', value: '${_job['estimatedPrice']} دينار'),
            
            if (_job['notes'] != null && _job['notes'].toString().isNotEmpty)
              _DetailRow(icon: Icons.note, label: 'ملاحظات', value: _job['notes']),
            
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('العمولة:', style: TextStyle(color: Colors.grey)),
                Text('${_job['commissionAmount'] ?? 1.5} دينار', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('حصتك:', style: TextStyle(color: Colors.grey)),
                Text('${_job['driverShare'] ?? 0} دينار', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
            
            if (_job['invoiceImageUrl'] != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.receipt, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  const Text('تم رفع الفاتورة ✓', style: TextStyle(color: Colors.green)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final status = _job['status'] ?? 'ASSIGNED';
    
    switch (status) {
      case 'ASSIGNED':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Navigate to Store
            OutlinedButton.icon(
              onPressed: () => _navigateToStore(),
              icon: const Icon(Icons.navigation),
              label: const Text('الملاحة إلى المحل'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            // Upload Invoice
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _uploadInvoice,
              icon: const Icon(Icons.camera_alt),
              label: const Text('رفع صورة الفاتورة (مطلوب)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        );
      
      case 'PICKED_UP':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.delivery_dining, color: Colors.orange, size: 32),
                  SizedBox(width: 12),
                  Expanded(child: Text('توجه إلى الزبون لتسليم الطلب', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _navigateToCustomer(),
              icon: const Icon(Icons.navigation),
              label: const Text('الملاحة إلى الزبون'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _showDeliveryCodeDialog,
              icon: const Icon(Icons.check_circle),
              label: const Text('تأكيد التسليم'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        );
      
      case 'DELIVERED':
      case 'COMPLETED':
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 48),
              SizedBox(height: 12),
              Text('تم إكمال الطلب بنجاح!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
            ],
          ),
        );
      
      default:
        return const SizedBox();
    }
  }

  void _navigateToStore() async {
    // Open Google Maps with pickup address
    final address = Uri.encodeComponent(_job['pickupAddress'] ?? '');
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$address');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _navigateToCustomer() async {
    final address = Uri.encodeComponent(_job['deliveryAddress'] ?? '');
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$address');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _uploadInvoice() async {
    // TODO: Implement actual camera/gallery picker
    setState(() => _isLoading = true);
    
    // Simulate upload
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isLoading = false;
      _job['invoiceImageUrl'] = 'https://example.com/invoice.jpg';
      _job['status'] = 'PICKED_UP';
    });
    
    widget.onUpdate(_job);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم رفع الفاتورة - أنت الآن في الطريق للزبون'), backgroundColor: Colors.green),
    );
  }

  void _showDeliveryCodeDialog() {
    final codeController = TextEditingController();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('كود التسليم'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('اطلب من الزبون كود التسليم المكون من 4 أرقام'),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 8),
              decoration: InputDecoration(
                counterText: '',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                hintText: '----',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (codeController.text.length == 4) {
                Navigator.pop(context);
                _verifyDeliveryCode(codeController.text);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyDeliveryCode(String code) async {
    setState(() => _isLoading = true);
    
    // TODO: Call API to verify code
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock verification (accept any 4-digit code for demo)
    setState(() {
      _isLoading = false;
      _job['status'] = 'DELIVERED';
      _job['deliveredAt'] = DateTime.now().toIso8601String();
      _job['driverShare'] = (_job['estimatedPrice'] ?? 0) + 1.5 - 1.5; // price + delivery - commission
    });
    
    widget.onUpdate(_job);
    
    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 8),
            Text('تم التسليم!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('تم إكمال الطلب بنجاح! 🎉'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('العمولة المضافة:'),
                  Text('${_job['commissionAmount'] ?? 1.5} دينار', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF6C63FF)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== Driver Wallet Screen ====================
class DriverWalletScreen extends StatelessWidget {
  const DriverWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data
    const pendingSettlement = 18.0;
    const completedOrders = 12;
    const totalEarnings = 156.50;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Balance Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF4A42D1)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text('المستحقات المعلقة', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                const Text('$pendingSettlement دينار', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('$completedOrders طلب × 1.5 دينار', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Stats Row
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.check_circle,
                  label: 'طلبات مكتملة',
                  value: '$completedOrders',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.account_balance_wallet,
                  label: 'إجمالي الأرباح',
                  value: '$totalEarnings د',
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Warning
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'يجب تسوية المستحقات يومياً لتجنب إيقاف الحساب',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // History
          const Text('سجل الطلبات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          
          ...List.generate(5, (i) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF6C63FF).withOpacity(0.1),
                child: const Icon(Icons.receipt, color: Color(0xFF6C63FF)),
              ),
              title: Text('طلب #${1000 + i}'),
              subtitle: Text('${DateTime.now().subtract(Duration(hours: i * 3)).day}/11/2025'),
              trailing: const Text('+1.5 د', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            ),
          )),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }
}

// ==================== Driver Profile Screen ====================
class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 24),
          const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFF6C63FF),
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text('أحمد محمد', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified, color: Colors.green, size: 18),
              SizedBox(width: 4),
              Text('سائق معتمد', style: TextStyle(color: Colors.green)),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Colors.amber, size: 20),
              Text(' 4.8 (156 تقييم)', style: TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 24),
          
          _ProfileTile(icon: Icons.phone, title: 'رقم الهاتف', value: '079 123 4567'),
          _ProfileTile(icon: Icons.motorcycle, title: 'رقم اللوحة', value: '12-34567'),
          _ProfileTile(icon: Icons.two_wheeler, title: 'موديل الدراجة', value: 'Honda CG 125'),
          _ProfileTile(icon: Icons.location_on, title: 'المناطق', value: 'وسط البلد، الجبيهة، عبدون'),
          _ProfileTile(icon: Icons.access_time, title: 'ساعات العمل', value: '8:00 ص - 10:00 م'),
          
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit),
              label: const Text('تعديل الملف الشخصي'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ProfileTile({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF6C63FF)),
        ),
        title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

