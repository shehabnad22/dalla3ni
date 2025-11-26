import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// ==================== Driver Home Screen ====================
class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  bool _isOnline = false;
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دلّعني - سائق'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        actions: [
          // Online/Offline Toggle
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              children: [
                Text(_isOnline ? 'متصل' : 'غير متصل', style: const TextStyle(fontSize: 14)),
                Switch(
                  value: _isOnline,
                  onChanged: (v) => setState(() => _isOnline = v),
                  activeColor: Colors.greenAccent,
                ),
              ],
            ),
          ),
        ],
      ),
      body: _selectedIndex == 0 
          ? _buildOrdersTab() 
          : _selectedIndex == 1 
              ? const DriverWalletScreen() 
              : const DriverProfileScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        selectedItemColor: const Color(0xFF6C63FF),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'الطلبات'),
          BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'المحفظة'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }

  Widget _buildOrdersTab() {
    if (!_isOnline) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('أنت غير متصل', style: TextStyle(fontSize: 20, color: Colors.grey)),
            SizedBox(height: 8),
            Text('قم بتشغيل الاتصال لاستقبال الطلبات', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    // Mock pending orders
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('طلبات جديدة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _PendingOrderCard(
          orderText: '2 شاورما دجاج + بيبسي من مطعم الشام',
          address: 'شارع الجامعة، عمارة 15',
          distance: '1.2 كم',
          onAccept: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ActiveOrderScreen()));
          },
        ),
      ],
    );
  }
}

class _PendingOrderCard extends StatelessWidget {
  final String orderText;
  final String address;
  final String distance;
  final VoidCallback onAccept;

  const _PendingOrderCard({
    required this.orderText,
    required this.address,
    required this.distance,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                const Text('طلب جديد', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(distance, style: const TextStyle(color: Color(0xFF6C63FF), fontSize: 12)),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(orderText, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.grey, size: 18),
                const SizedBox(width: 4),
                Expanded(child: Text(address, style: TextStyle(color: Colors.grey[600]))),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAccept,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('قبول الطلب', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== Active Order Screen ====================
class ActiveOrderScreen extends StatefulWidget {
  const ActiveOrderScreen({super.key});

  @override
  State<ActiveOrderScreen> createState() => _ActiveOrderScreenState();
}

class _ActiveOrderScreenState extends State<ActiveOrderScreen> {
  String _status = 'accepted'; // accepted -> picked_up -> delivering -> completed
  String? _invoiceImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الطلب الحالي'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Customer Card
            _buildCustomerCard(),
            const SizedBox(height: 16),
            // Order Details
            _buildOrderCard(),
            const SizedBox(height: 16),
            // Status Actions
            _buildStatusActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFF6C63FF).withOpacity(0.1),
              child: const Icon(Icons.person, color: Color(0xFF6C63FF)),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('محمد أحمد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('الزبون', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            // Call Button
            IconButton(
              onPressed: () => _callCustomer('0791234567'),
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.phone, color: Colors.green),
              ),
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
            const Text('تفاصيل الطلب', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const Divider(),
            const Text('2 شاورما دجاج + بيبسي كبير\nمن مطعم الشام - شارع الجامعة'),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.location_on, color: Color(0xFF6C63FF), size: 20),
                SizedBox(width: 8),
                Expanded(child: Text('التوصيل: شارع المدينة، عمارة 15، طابق 3')),
              ],
            ),
            if (_invoiceImage != null) ...[
              const SizedBox(height: 16),
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

  Widget _buildStatusActions() {
    switch (_status) {
      case 'accepted':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('قم بشراء الطلب من المحل', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // Upload Invoice Button
            OutlinedButton.icon(
              onPressed: _uploadInvoice,
              icon: const Icon(Icons.camera_alt),
              label: Text(_invoiceImage == null ? 'رفع صورة الفاتورة (مطلوب)' : 'تم رفع الفاتورة ✓'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: _invoiceImage == null ? const Color(0xFF6C63FF) : Colors.green),
                foregroundColor: _invoiceImage == null ? const Color(0xFF6C63FF) : Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _invoiceImage != null ? () => setState(() => _status = 'picked_up') : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('تم الاستلام - في الطريق للزبون', style: TextStyle(fontSize: 16)),
            ),
          ],
        );

      case 'picked_up':
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
                  Expanded(child: Text('أنت في الطريق للزبون', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showDeliveryCodeDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('وصلت - إدخال كود التسليم', style: TextStyle(fontSize: 16)),
            ),
          ],
        );

      default:
        return const SizedBox();
    }
  }

  void _uploadInvoice() {
    // TODO: Implement image picker
    setState(() => _invoiceImage = 'uploaded');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم رفع صورة الفاتورة'), backgroundColor: Colors.green),
    );
  }

  void _showDeliveryCodeDialog() {
    final codeController = TextEditingController();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
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
                // TODO: Verify code with backend
                Navigator.pop(context);
                _completeOrder();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  void _completeOrder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 8),
            Text('تم التسليم'),
          ],
        ),
        content: const Text('تم إكمال الطلب بنجاح!\nتمت إضافة العمولة إلى محفظتك.'),
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

// ==================== Driver Wallet Screen ====================
class DriverWalletScreen extends StatelessWidget {
  const DriverWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data
    const commission = 1.5; // per order
    const completedOrders = 12;
    const pendingSettlement = commission * completedOrders;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Balance Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF4A42D1)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text('الرصيد المعلق', style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 8),
                Text(
                  '${pendingSettlement.toStringAsFixed(2)} دينار',
                  style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$completedOrders طلب × $commission دينار',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('سجل الطلبات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: completedOrders,
              itemBuilder: (context, index) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF6C63FF),
                    child: Icon(Icons.check, color: Colors.white),
                  ),
                  title: Text('طلب #${1000 + index}'),
                  subtitle: Text('${DateTime.now().subtract(Duration(days: index)).day}/11/2025'),
                  trailing: Text('+$commission د', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange),
                SizedBox(width: 12),
                Expanded(child: Text('يتم تحويل الرصيد أسبوعياً إلى حسابك البنكي')),
              ],
            ),
          ),
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFF6C63FF),
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text('أحمد محمد', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text('سائق معتمد ✓', style: TextStyle(color: Colors.green)),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Colors.amber),
              Text(' 4.8 (156 تقييم)', style: TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 24),
          _ProfileTile(icon: Icons.phone, title: 'رقم الهاتف', value: '079 123 4567'),
          _ProfileTile(icon: Icons.motorcycle, title: 'رقم اللوحة', value: '12-34567'),
          _ProfileTile(icon: Icons.location_on, title: 'المناطق', value: 'وسط البلد، الجبيهة'),
          _ProfileTile(icon: Icons.access_time, title: 'ساعات العمل', value: '8:00 ص - 10:00 م'),
          const Spacer(),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
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
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF6C63FF)),
        title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

