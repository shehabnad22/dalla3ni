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
                    // Customer Button
                    _RoleButton(
                      icon: Icons.person,
                      title: 'زبون',
                      subtitle: 'اطلب توصيل سريع',
                      isLocked: false,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CustomerRegisterScreen()),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Driver Button
                    _RoleButton(
                      icon: Icons.motorcycle,
                      title: 'سائق ميتور',
                      subtitle: 'انضم كسائق توصيل',
                      isLocked: false,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DriverRegisterScreen()),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // StoreOwner Button - LOCKED
                    _RoleButton(
                      icon: Icons.store,
                      title: 'صاحب متجر',
                      subtitle: 'سجّل متجرك معنا',
                      isLocked: true,
                      onTap: () => _showLockedDialog(context),
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

  void _showLockedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.lock, color: Colors.orange[700]),
            const SizedBox(width: 8),
            const Text('قريباً'),
          ],
        ),
        content: const Text(
          'سيُفتح التسجيل لأصحاب المتاجر بعد المرحلة الثانية.\n\nترقّبوا التحديثات! 🚀',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isLocked;
  final VoidCallback onTap;

  const _RoleButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isLocked ? Colors.white.withOpacity(0.5) : Colors.white,
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
                  color: isLocked 
                      ? Colors.grey.withOpacity(0.2) 
                      : const Color(0xFF6C63FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon, 
                  color: isLocked ? Colors.grey : const Color(0xFF6C63FF), 
                  size: 28
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isLocked ? Colors.grey : const Color(0xFF2D2D2D),
                          ),
                        ),
                        if (isLocked) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'قريباً',
                              style: TextStyle(fontSize: 10, color: Colors.orange[800]),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      subtitle, 
                      style: TextStyle(fontSize: 14, color: Colors.grey[600])
                    ),
                  ],
                ),
              ),
              Icon(
                isLocked ? Icons.lock : Icons.arrow_forward_ios, 
                color: isLocked ? Colors.grey : Colors.grey[400],
              ),
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
  final _formKey = GlobalKey<FormState>();
  int _step = 0; // 0: info, 1: otp
  bool _isLoading = false;
  String _verificationId = '';

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
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('أدخل بياناتك', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('سنرسل لك رمز التحقق عبر واتساب', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 32),
          TextFormField(
            controller: _nameController,
            validator: (v) => v == null || v.isEmpty ? 'الرجاء إدخال الاسم' : null,
            decoration: InputDecoration(
              labelText: 'الاسم الكامل',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            validator: (v) {
              if (v == null || v.isEmpty) return 'الرجاء إدخال رقم الهاتف';
              if (v.length < 10) return 'رقم الهاتف غير صحيح';
              return null;
            },
            decoration: InputDecoration(
              labelText: 'رقم الهاتف',
              hintText: '07XXXXXXXX',
              prefixIcon: const Icon(Icons.phone),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.chat, color: Colors.green[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'سيصلك رمز التحقق عبر واتساب',
                    style: TextStyle(color: Colors.green[700]),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: _isLoading ? null : _sendOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('إرسال رمز التحقق', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    // TODO: Call WhatsApp API to send OTP
    // For now, simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isLoading = false;
      _step = 1;
      _verificationId = '123456'; // Mock verification ID
    });
  }

  Widget _buildOtpStep() {
    return _OtpVerificationWidget(
      phone: _phoneController.text,
      onVerified: () => _createCustomerAccount(),
      onResend: () => _sendOtp(),
    );
  }

  Future<void> _createCustomerAccount() async {
    // TODO: Call API to create customer account
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const CustomerHomeScreen()),
      (route) => false,
    );
  }
}

// ==================== OTP Verification Widget ====================
class _OtpVerificationWidget extends StatefulWidget {
  final String phone;
  final VoidCallback onVerified;
  final VoidCallback onResend;

  const _OtpVerificationWidget({
    required this.phone,
    required this.onVerified,
    required this.onResend,
  });

  @override
  State<_OtpVerificationWidget> createState() => _OtpVerificationWidgetState();
}

class _OtpVerificationWidgetState extends State<_OtpVerificationWidget> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  int _resendTimer = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        if (_resendTimer > 0) {
          _resendTimer--;
        } else {
          _canResend = true;
        }
      });
      return _resendTimer > 0;
    });
  }

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('أدخل رمز التحقق', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('تم إرسال رمز التحقق إلى ${widget.phone}', style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (i) => SizedBox(
            width: 48,
            child: TextField(
              controller: _controllers[i],
              focusNode: _focusNodes[i],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                counterText: '',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (v) {
                if (v.isNotEmpty && i < 5) {
                  _focusNodes[i + 1].requestFocus();
                }
                if (_controllers.every((c) => c.text.isNotEmpty)) {
                  _verifyOtp();
                }
              },
            ),
          )),
        ),
        const SizedBox(height: 24),
        Center(
          child: _canResend
              ? TextButton(
                  onPressed: () {
                    widget.onResend();
                    setState(() {
                      _resendTimer = 60;
                      _canResend = false;
                    });
                    _startResendTimer();
                  },
                  child: const Text('إعادة إرسال الرمز'),
                )
              : Text(
                  'إعادة الإرسال بعد $_resendTimer ثانية',
                  style: TextStyle(color: Colors.grey[600]),
                ),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: _isLoading ? null : _verifyOtp,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C63FF),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('تأكيد', style: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }

  Future<void> _verifyOtp() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال الرمز كاملاً')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // TODO: Verify OTP with API
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isLoading = false);
    widget.onVerified();
  }
}

// ==================== Driver Register Screen ====================
class DriverRegisterScreen extends StatefulWidget {
  const DriverRegisterScreen({super.key});

  @override
  State<DriverRegisterScreen> createState() => _DriverRegisterScreenState();
}

class _DriverRegisterScreenState extends State<DriverRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _plateController = TextEditingController();
  final _bikeModelController = TextEditingController();

  int _currentStep = 0;
  String? _idImagePath;
  String? _bikeImagePath;
  List<String> _selectedAreas = [];
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 22, minute: 0);
  bool _acceptTerms = false;
  bool _acceptSettlement = false;
  bool _acceptIdStorage = false;
  bool _isLoading = false;

  final List<String> _availableAreas = [
    'وسط البلد', 'جبل عمان', 'جبل الحسين', 'الشميساني',
    'عبدون', 'الرابية', 'خلدا', 'الجبيهة', 'صويلح',
    'طبربور', 'ماركا', 'الهاشمي', 'أبو نصير', 'شفا بدران',
    'المدينة الرياضية', 'الزرقاء', 'السلط',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل سائق جديد'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: _onStepContinue,
          onStepCancel: () {
            if (_currentStep > 0) setState(() => _currentStep--);
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: _isLoading ? null : details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading && _currentStep == 4
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(_currentStep == 4 ? 'إرسال الطلب' : 'التالي'),
                  ),
                  const SizedBox(width: 12),
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('رجوع'),
                    ),
                ],
              ),
            );
          },
          steps: [
            // Step 1: Personal Info
            Step(
              title: const Text('البيانات الشخصية'),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                    decoration: InputDecoration(
                      labelText: 'الاسم الكامل *',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (v) => v == null || v.length < 10 ? 'رقم غير صحيح' : null,
                    decoration: InputDecoration(
                      labelText: 'رقم الهاتف *',
                      hintText: '07XXXXXXXX',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
            // Step 2: Documents
            Step(
              title: const Text('الوثائق'),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              content: Column(
                children: [
                  _DocumentUploadCard(
                    title: 'صورة الهوية الشخصية *',
                    icon: Icons.badge,
                    imagePath: _idImagePath,
                    onTap: () => _pickImage('id'),
                  ),
                  const SizedBox(height: 16),
                  _DocumentUploadCard(
                    title: 'صورة الدراجة النارية *',
                    icon: Icons.motorcycle,
                    imagePath: _bikeImagePath,
                    onTap: () => _pickImage('bike'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _plateController,
                    validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                    decoration: InputDecoration(
                      labelText: 'رقم لوحة الدراجة *',
                      prefixIcon: const Icon(Icons.confirmation_number),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _bikeModelController,
                    decoration: InputDecoration(
                      labelText: 'موديل الدراجة',
                      hintText: 'مثال: Honda CG 125',
                      prefixIcon: const Icon(Icons.two_wheeler),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
            // Step 3: Areas
            Step(
              title: const Text('مناطق العمل'),
              isActive: _currentStep >= 2,
              state: _currentStep > 2 ? StepState.complete : StepState.indexed,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('اختر المناطق التي تعمل بها *', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
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
                  if (_selectedAreas.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'المناطق المختارة: ${_selectedAreas.length}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
            // Step 4: Working Hours
            Step(
              title: const Text('ساعات العمل'),
              isActive: _currentStep >= 3,
              state: _currentStep > 3 ? StepState.complete : StepState.indexed,
              content: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.access_time, color: Color(0xFF6C63FF)),
                    title: const Text('من الساعة'),
                    trailing: Text(_startTime.format(context), style: const TextStyle(fontWeight: FontWeight.bold)),
                    onTap: () async {
                      final time = await showTimePicker(context: context, initialTime: _startTime);
                      if (time != null) setState(() => _startTime = time);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.access_time_filled, color: Color(0xFF6C63FF)),
                    title: const Text('إلى الساعة'),
                    trailing: Text(_endTime.format(context), style: const TextStyle(fontWeight: FontWeight.bold)),
                    onTap: () async {
                      final time = await showTimePicker(context: context, initialTime: _endTime);
                      if (time != null) setState(() => _endTime = time);
                    },
                  ),
                ],
              ),
            ),
            // Step 5: Terms & Conditions
            Step(
              title: const Text('الشروط والأحكام'),
              isActive: _currentStep >= 4,
              content: Column(
                children: [
                  _TermsCheckbox(
                    value: _acceptTerms,
                    title: 'أوافق على الشروط والأحكام',
                    subtitle: 'قراءة الشروط والأحكام',
                    onChanged: (v) => setState(() => _acceptTerms = v ?? false),
                  ),
                  _TermsCheckbox(
                    value: _acceptSettlement,
                    title: 'ألتزم بالتسوية اليومية',
                    subtitle: 'يجب تسوية المستحقات يومياً لتجنب إيقاف الحساب',
                    onChanged: (v) => setState(() => _acceptSettlement = v ?? false),
                  ),
                  _TermsCheckbox(
                    value: _acceptIdStorage,
                    title: 'أسمح بتخزين صورة الهوية',
                    subtitle: 'للتحقق من الهوية وضمان الأمان',
                    onChanged: (v) => setState(() => _acceptIdStorage = v ?? false),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange[700]),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'سيتم مراجعة طلبك من قبل الإدارة والرد خلال 24-48 ساعة',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onStepContinue() {
    // Validation for each step
    if (_currentStep == 0) {
      if (_nameController.text.isEmpty || _phoneController.text.length < 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء إكمال البيانات الشخصية')),
        );
        return;
      }
    } else if (_currentStep == 1) {
      if (_idImagePath == null || _bikeImagePath == null || _plateController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء رفع الصور وإدخال رقم اللوحة')),
        );
        return;
      }
    } else if (_currentStep == 2) {
      if (_selectedAreas.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء اختيار منطقة واحدة على الأقل')),
        );
        return;
      }
    } else if (_currentStep == 4) {
      if (!_acceptTerms || !_acceptSettlement || !_acceptIdStorage) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء الموافقة على جميع الشروط')),
        );
        return;
      }
      _submitRegistration();
      return;
    }

    setState(() => _currentStep++);
  }

  void _pickImage(String type) {
    // TODO: Implement actual image picker
    setState(() {
      if (type == 'id') _idImagePath = 'selected';
      else _bikeImagePath = 'selected';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم اختيار ${type == 'id' ? 'صورة الهوية' : 'صورة الدراجة'}')),
    );
  }

  Future<void> _submitRegistration() async {
    setState(() => _isLoading = true);

    // TODO: Call API to submit driver registration
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 8),
            Text('تم إرسال الطلب'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('شكراً لتسجيلك معنا! 🎉'),
            SizedBox(height: 12),
            Text('حالة الطلب: قيد المراجعة'),
            SizedBox(height: 8),
            Text(
              'سيتم مراجعة طلبك والتواصل معك خلال 24-48 ساعة.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
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

  const _DocumentUploadCard({
    required this.title,
    required this.icon,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: imagePath != null ? const Color(0xFF6C63FF) : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: imagePath != null ? const Color(0xFF6C63FF).withOpacity(0.05) : null,
        ),
        child: Row(
          children: [
            Icon(
              imagePath != null ? Icons.check_circle : icon,
              color: imagePath != null ? const Color(0xFF6C63FF) : Colors.grey,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                imagePath != null ? '$title ✓' : title,
                style: TextStyle(
                  fontSize: 16,
                  color: imagePath != null ? const Color(0xFF6C63FF) : Colors.grey[700],
                  fontWeight: imagePath != null ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            Icon(
              Icons.camera_alt,
              color: imagePath != null ? const Color(0xFF6C63FF) : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

class _TermsCheckbox extends StatelessWidget {
  final bool value;
  final String title;
  final String subtitle;
  final ValueChanged<bool?> onChanged;

  const _TermsCheckbox({
    required this.value,
    required this.title,
    required this.subtitle,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF6C63FF),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
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
                  onPressed: () {},
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
    _controller = AnimationController(duration: const Duration(seconds: 2), vsync: this)..repeat();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OrderTrackingScreen()));
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
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(60)),
                  child: const Icon(Icons.motorcycle, size: 60, color: Color(0xFF6C63FF)),
                ),
              ),
              const SizedBox(height: 32),
              const Text('جاري البحث عن سائق...', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              const Text('نبحث عن أقرب سائق متاح في منطقتك', style: TextStyle(fontSize: 16, color: Colors.white70)),
              const SizedBox(height: 48),
              TextButton(
                onPressed: () => Navigator.pop(context),
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
  String _status = 'accepted';
  final String _deliveryCode = '1234';

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () { if (mounted) setState(() => _status = 'picked_up'); });
    Future.delayed(const Duration(seconds: 10), () { if (mounted) setState(() => _status = 'arriving'); });
    Future.delayed(const Duration(seconds: 15), () {
      if (mounted) {
        setState(() => _status = 'delivered');
        Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerDeliveryCodeScreen(deliveryCode: _deliveryCode)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تتبع الطلب'),
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
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
                        Row(children: [Icon(Icons.star, color: Colors.amber, size: 18), Text(' 4.8', style: TextStyle(color: Colors.grey))]),
                      ],
                    ),
                  ),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.phone, color: Color(0xFF6C63FF))),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.chat, color: Color(0xFF6C63FF))),
                ],
              ),
            ),
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
                    Text(_deliveryCode, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 8, color: Colors.green)),
                    const SizedBox(height: 8),
                    const Text('أعطِ هذا الكود للسائق عند الاستلام', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
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

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _verifyCode() {
    final enteredCode = _controllers.map((c) => c.text).join();
    if (enteredCode == widget.deliveryCode) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RateDriverScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الكود غير صحيح'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF6C63FF), Color(0xFF4A42D1)]),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(50)),
                    child: const Icon(Icons.delivery_dining, size: 50, color: Color(0xFF6C63FF)),
                  ),
                  const SizedBox(height: 32),
                  const Text('السائق وصل! 🎉', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 16),
                  const Text('أعطِ السائق كود التسليم', style: TextStyle(fontSize: 16, color: Colors.white70)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                    child: Text(widget.deliveryCode, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 8)),
                  ),
                  const SizedBox(height: 48),
                  const Text('أو أدخل الكود الذي أعطاك إياه السائق', style: TextStyle(fontSize: 14, color: Colors.white70)),
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
                          if (v.isNotEmpty && i < 3) _focusNodes[i + 1].requestFocus();
                          if (_controllers.every((c) => c.text.isNotEmpty)) _verifyCode();
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
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                const Icon(Icons.check_circle, size: 80, color: Colors.green),
                const SizedBox(height: 24),
                const Text('تم التوصيل بنجاح! 🎉', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('كيف كانت تجربتك مع السائق؟', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                const SizedBox(height: 32),
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFF6C63FF).withOpacity(0.1),
                  child: const Icon(Icons.person, size: 45, color: Color(0xFF6C63FF)),
                ),
                const SizedBox(height: 8),
                const Text('أحمد محمد', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) => GestureDetector(
                    onTap: () => setState(() => _rating = i + 1),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(i < _rating ? Icons.star : Icons.star_border, size: 48, color: Colors.amber),
                    ),
                  )),
                ),
                const SizedBox(height: 8),
                Text(_rating == 0 ? 'اضغط للتقييم' : _getRatingText(_rating), style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 24),
                TextField(
                  controller: _commentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'أضف تعليق (اختياري)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const Spacer(),
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
                Text('يجب إرسال التقييم لإغلاق الطلب', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
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
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const CustomerHomeScreen()), (route) => false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('شكراً لتقييمك!'), backgroundColor: Colors.green));
  }
}
