import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const Dalla3niApp());
}

class Dalla3niApp extends StatelessWidget {
  const Dalla3niApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'دلّعني - Dalla3ni',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Cairo',
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const SplashScreen(),
    );
  }
}

// ==================== Onboarding Screen ====================
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

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
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.delivery_dining,
                  size: 60,
                  color: Color(0xFF6C63FF),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'دلّعني',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'خدمة التوصيل السريع',
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const Text(
                      'اختر نوع حسابك',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _RoleButton(
                      icon: Icons.person,
                      title: 'زبون',
                      subtitle: 'اطلب توصيل سريع',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CustomerRegisterScreen()),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _RoleButton(
                      icon: Icons.motorcycle,
                      title: 'سائق ميتور',
                      subtitle: 'انضم كسائق توصيل',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DriverRegisterScreen()),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF6C63FF), size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== Customer Register Screen ====================
class CustomerRegisterScreen extends StatefulWidget {
  const CustomerRegisterScreen({super.key});

  @override
  State<CustomerRegisterScreen> createState() => _CustomerRegisterScreenState();
}

class _CustomerRegisterScreenState extends State<CustomerRegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل زبون جديد'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _step == 0 ? _buildInfoStep() : _buildOtpStep(),
      ),
    );
  }

  Widget _buildInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('أدخل بياناتك', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 32),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'الاسم الكامل',
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'رقم الهاتف',
            prefixIcon: const Icon(Icons.phone),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: () => setState(() => _step = 1),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C63FF),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('إرسال رمز التحقق', style: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }

  Widget _buildOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('أدخل رمز التحقق', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('تم إرسال رمز التحقق إلى ${_phoneController.text}', style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (i) => _OtpBox()),
        ),
        const SizedBox(height: 24),
        TextButton(onPressed: () {}, child: const Text('إعادة إرسال الرمز')),
        const Spacer(),
        ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CustomerHomeScreen()));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C63FF),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('تأكيد', style: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }
}

class _OtpBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      child: TextField(
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

// ==================== Driver Register Screen ====================
class DriverRegisterScreen extends StatefulWidget {
  const DriverRegisterScreen({super.key});

  @override
  State<DriverRegisterScreen> createState() => _DriverRegisterScreenState();
}

class _DriverRegisterScreenState extends State<DriverRegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _plateController = TextEditingController();

  int _currentStep = 0;
  String? _idImagePath;
  String? _motorImagePath;
  List<String> _selectedAreas = [];
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 22, minute: 0);

  final List<String> _availableAreas = [
    'وسط البلد', 'الزرقاء', 'المدينة الرياضية', 'طبربور', 'الجبيهة',
    'صويلح', 'ماركا', 'الهاشمي', 'أبو نصير', 'شفا بدران',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل سائق جديد'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 3) {
            setState(() => _currentStep++);
          } else {
            _submitRegistration();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) setState(() => _currentStep--);
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(_currentStep == 3 ? 'إرسال الطلب' : 'التالي'),
                ),
                const SizedBox(width: 12),
                if (_currentStep > 0) TextButton(onPressed: details.onStepCancel, child: const Text('رجوع')),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('البيانات الشخصية'),
            isActive: _currentStep >= 0,
            content: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'الاسم الكامل',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'رقم الهاتف',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('الوثائق'),
            isActive: _currentStep >= 1,
            content: Column(
              children: [
                _DocumentUploadCard(title: 'صورة الهوية', icon: Icons.badge, imagePath: _idImagePath, onTap: () => _pickImage('id')),
                const SizedBox(height: 16),
                _DocumentUploadCard(title: 'صورة الميتور', icon: Icons.motorcycle, imagePath: _motorImagePath, onTap: () => _pickImage('motor')),
                const SizedBox(height: 16),
                TextField(
                  controller: _plateController,
                  decoration: InputDecoration(
                    labelText: 'رقم لوحة الميتور',
                    prefixIcon: const Icon(Icons.confirmation_number),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('مناطق العمل'),
            isActive: _currentStep >= 2,
            content: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableAreas.map((area) {
                final isSelected = _selectedAreas.contains(area);
                return FilterChip(
                  label: Text(area),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) _selectedAreas.add(area);
                      else _selectedAreas.remove(area);
                    });
                  },
                  selectedColor: const Color(0xFF6C63FF).withOpacity(0.2),
                  checkmarkColor: const Color(0xFF6C63FF),
                );
              }).toList(),
            ),
          ),
          Step(
            title: const Text('ساعات العمل'),
            isActive: _currentStep >= 3,
            content: Column(
              children: [
                ListTile(
                  title: const Text('من الساعة'),
                  trailing: Text(_startTime.format(context)),
                  onTap: () async {
                    final time = await showTimePicker(context: context, initialTime: _startTime);
                    if (time != null) setState(() => _startTime = time);
                  },
                ),
                ListTile(
                  title: const Text('إلى الساعة'),
                  trailing: Text(_endTime.format(context)),
                  onTap: () async {
                    final time = await showTimePicker(context: context, initialTime: _endTime);
                    if (time != null) setState(() => _endTime = time);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _pickImage(String type) {
    setState(() {
      if (type == 'id') _idImagePath = 'selected';
      else _motorImagePath = 'selected';
    });
  }

  void _submitRegistration() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تم إرسال الطلب'),
        content: const Text('سيتم مراجعة طلبك والتواصل معك قريباً'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}

class _DocumentUploadCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? imagePath;
  final VoidCallback onTap;

  const _DocumentUploadCard({required this.title, required this.icon, required this.imagePath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: imagePath != null ? const Color(0xFF6C63FF) : Colors.grey[300]!, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(imagePath != null ? Icons.check_circle : icon, color: imagePath != null ? const Color(0xFF6C63FF) : Colors.grey, size: 32),
            const SizedBox(width: 16),
            Expanded(child: Text(imagePath != null ? '$title ✓' : title, style: TextStyle(fontSize: 16, color: imagePath != null ? const Color(0xFF6C63FF) : Colors.grey[700]))),
            const Icon(Icons.camera_alt, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// ==================== Customer Home Screen ====================
class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دلّعني'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('مرحباً بك 👋', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('ماذا تريد أن نوصّل لك اليوم؟', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            const SizedBox(height: 32),
            Expanded(
              child: InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WriteOrderScreen())),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [Color(0xFF6C63FF), Color(0xFF4A42D1)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit_note, size: 80, color: Colors.white),
                      SizedBox(height: 16),
                      Text('اكتب طلبك', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                      SizedBox(height: 8),
                      Text('اكتب ما تريد ونوصّله لك', style: TextStyle(fontSize: 16, color: Colors.white70)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: const Color(0xFF6C63FF),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'طلباتي'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }
}

// ==================== Write Order Screen ====================
class WriteOrderScreen extends StatefulWidget {
  const WriteOrderScreen({super.key});

  @override
  State<WriteOrderScreen> createState() => _WriteOrderScreenState();
}

class _WriteOrderScreenState extends State<WriteOrderScreen> {
  final _orderController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اكتب طلبك'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('ماذا تريد؟', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('اكتب طلبك بالتفصيل', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            TextField(
              controller: _orderController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'مثال: 2 شاورما دجاج + بيبسي كبير من مطعم الشام...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            const Text('عنوان التوصيل', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                hintText: 'أدخل عنوان التوصيل بالتفصيل',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.my_location, color: Color(0xFF6C63FF)),
                  onPressed: () {
                    // TODO: Get current location
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('السعر التقديري (اختياري)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '0.00',
                prefixIcon: const Icon(Icons.attach_money),
                suffixText: 'دينار',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            const Text('ملاحظات إضافية', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'أي تعليمات خاصة للسائق...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submitOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('تأكيد الطلب', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  void _submitOrder() {
    if (_orderController.text.isEmpty || _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى كتابة الطلب والعنوان')),
      );
      return;
    }

    // Show matching screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MatchingDriverScreen()),
    );
  }
}

// ==================== Matching Driver Screen ====================
class MatchingDriverScreen extends StatefulWidget {
  const MatchingDriverScreen({super.key});

  @override
  State<MatchingDriverScreen> createState() => _MatchingDriverScreenState();
}

class _MatchingDriverScreenState extends State<MatchingDriverScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Simulate finding a driver after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OrderTrackingScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RotationTransition(
                turns: _controller,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: const Icon(Icons.motorcycle, size: 60, color: Color(0xFF6C63FF)),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'جاري البحث عن سائق...',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text(
                'نبحث عن أقرب سائق متاح في منطقتك',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 48),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('إلغاء الطلب', style: TextStyle(color: Colors.white70, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== Order Tracking Screen ====================
class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  String _status = 'accepted'; // accepted, picked_up, arriving, delivered
  final String _deliveryCode = '1234'; // Generated code for customer

  @override
  void initState() {
    super.initState();
    // Simulate order progress
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => _status = 'picked_up');
    });
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) setState(() => _status = 'arriving');
    });
    Future.delayed(const Duration(seconds: 15), () {
      if (mounted) {
        setState(() => _status = 'delivered');
        _showDeliveryCodeScreen();
      }
    });
  }

  void _showDeliveryCodeScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerDeliveryCodeScreen(deliveryCode: _deliveryCode),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تتبع الطلب'),
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            // Driver info card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFF6C63FF).withOpacity(0.1),
                    child: const Icon(Icons.person, size: 35, color: Color(0xFF6C63FF)),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('أحمد محمد', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 18),
                            Text(' 4.8', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.phone, color: Color(0xFF6C63FF))),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.chat, color: Color(0xFF6C63FF))),
                ],
              ),
            ),
            // Delivery Code Card (shown when arriving)
            if (_status == 'arriving' || _status == 'delivered')
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green),
                ),
                child: Column(
                  children: [
                    const Text('كود التسليم', style: TextStyle(fontSize: 16, color: Colors.green)),
                    const SizedBox(height: 8),
                    Text(
                      _deliveryCode,
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 8, color: Colors.green),
                    ),
                    const SizedBox(height: 8),
                    const Text('أعطِ هذا الكود للسائق عند الاستلام', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            // Status timeline
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _StatusItem(title: 'تم قبول الطلب', subtitle: 'السائق في الطريق للمحل', isCompleted: true, isActive: _status == 'accepted'),
                  _StatusItem(title: 'جاري الاستلام', subtitle: 'السائق يستلم طلبك', isCompleted: _status != 'accepted', isActive: _status == 'picked_up'),
                  _StatusItem(title: 'في الطريق إليك', subtitle: 'الطلب في الطريق', isCompleted: _status == 'arriving' || _status == 'delivered', isActive: _status == 'arriving'),
                  _StatusItem(title: 'تم التوصيل', subtitle: 'استمتع!', isCompleted: _status == 'delivered', isActive: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isActive;

  const _StatusItem({required this.title, required this.subtitle, required this.isCompleted, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted || isActive ? const Color(0xFF6C63FF) : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: isCompleted ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
            ),
            Container(width: 2, height: 50, color: isCompleted ? const Color(0xFF6C63FF) : Colors.grey[300]),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isActive ? const Color(0xFF6C63FF) : Colors.black)),
              Text(subtitle, style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}

// ==================== Customer Delivery Code Screen ====================
class CustomerDeliveryCodeScreen extends StatefulWidget {
  final String deliveryCode;
  const CustomerDeliveryCodeScreen({super.key, required this.deliveryCode});

  @override
  State<CustomerDeliveryCodeScreen> createState() => _CustomerDeliveryCodeScreenState();
}

class _CustomerDeliveryCodeScreenState extends State<CustomerDeliveryCodeScreen> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  bool _codeVerified = false;

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _verifyCode() {
    final enteredCode = _controllers.map((c) => c.text).join();
    if (enteredCode == widget.deliveryCode) {
      setState(() => _codeVerified = true);
      // Show rating screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RateDriverScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الكود غير صحيح'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Cannot go back
      child: Scaffold(
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
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(Icons.delivery_dining, size: 50, color: Color(0xFF6C63FF)),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'السائق وصل! 🎉',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'أعطِ السائق كود التسليم',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.deliveryCode,
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 8),
                    ),
                  ),
                  const SizedBox(height: 48),
                  const Text(
                    'أو أدخل الكود الذي أعطاك إياه السائق',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (i) => Container(
                      width: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      child: TextField(
                        controller: _controllers[i],
                        focusNode: _focusNodes[i],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        onChanged: (v) {
                          if (v.isNotEmpty && i < 3) {
                            _focusNodes[i + 1].requestFocus();
                          }
                          if (_controllers.every((c) => c.text.isNotEmpty)) {
                            _verifyCode();
                          }
                        },
                      ),
                    )),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _verifyCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF6C63FF),
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('تأكيد الاستلام', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== Rate Driver Screen ====================
class RateDriverScreen extends StatefulWidget {
  const RateDriverScreen({super.key});

  @override
  State<RateDriverScreen> createState() => _RateDriverScreenState();
}

class _RateDriverScreenState extends State<RateDriverScreen> {
  int _rating = 0;
  final _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Cannot close without rating
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                const Icon(Icons.check_circle, size: 80, color: Colors.green),
                const SizedBox(height: 24),
                const Text(
                  'تم التوصيل بنجاح! 🎉',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('كيف كانت تجربتك مع السائق؟', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                const SizedBox(height: 32),
                // Driver Avatar
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFF6C63FF).withOpacity(0.1),
                  child: const Icon(Icons.person, size: 45, color: Color(0xFF6C63FF)),
                ),
                const SizedBox(height: 8),
                const Text('أحمد محمد', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                // Star Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) => GestureDetector(
                    onTap: () => setState(() => _rating = i + 1),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        i < _rating ? Icons.star : Icons.star_border,
                        size: 48,
                        color: Colors.amber,
                      ),
                    ),
                  )),
                ),
                const SizedBox(height: 8),
                Text(
                  _rating == 0 ? 'اضغط للتقييم' : _getRatingText(_rating),
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                // Comment
                TextField(
                  controller: _commentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'أضف تعليق (اختياري)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const Spacer(),
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _rating > 0 ? _submitRating : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('إرسال التقييم', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'يجب إرسال التقييم لإغلاق الطلب',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1: return 'سيء 😞';
      case 2: return 'مقبول 😐';
      case 3: return 'جيد 🙂';
      case 4: return 'جيد جداً 😊';
      case 5: return 'ممتاز! 🌟';
      default: return '';
    }
  }

  void _submitRating() {
    // TODO: Submit rating to backend
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const CustomerHomeScreen()),
      (route) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('شكراً لتقييمك!'), backgroundColor: Colors.green),
    );
  }
}
