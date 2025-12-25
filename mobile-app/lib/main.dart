import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'splash_screen.dart';
import 'services/text_service.dart';
import 'config/app_config.dart';
import 'config/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load texts.json before app starts
  await TextService.loadTexts();

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
      debugShowCheckedModeBanner: false, // Always false for production
      locale: const Locale('ar'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.cairoTextTheme(Theme.of(context).textTheme),
        fontFamily: GoogleFonts.cairo().fontFamily,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.backgroundLight,
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

// Helper class to check login status
class AuthChecker {
  static Future<Widget> getInitialRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final userType = prefs.getString('user_type') ?? '';
    
    if (isLoggedIn) {
      if (userType == 'customer') {
        return const CustomerHomeScreen();
      } else if (userType == 'driver') {
        // Check driver status
        final driverStatus = prefs.getString('driver_status') ?? 'PENDING_REVIEW';
        if (driverStatus == 'APPROVED') {
          // Navigate to driver home - need to import driver_app
          return const OnboardingScreen(); // Will redirect from splash
        } else {
          return const OnboardingScreen(); // Will redirect from splash
        }
      }
    }
    return const OnboardingScreen();
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
            colors: [AppColors.primary, AppColors.secondary],
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
                  color: AppColors.primary,
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
                    Text(
                      TextService.get('onboarding.selectRole', defaultValue: 'اختر نوع حسابك'),
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Customer Button
                    _RoleButton(
                      icon: Icons.person,
                      title: TextService.get('onboarding.customer.title', defaultValue: 'زبون'),
                      subtitle: TextService.get('onboarding.customer.subtitle', defaultValue: 'اطلب توصيل سريع'),
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
                      title: TextService.get('onboarding.driver.title', defaultValue: 'سائق ميتور'),
                      subtitle: TextService.get('onboarding.driver.subtitle', defaultValue: 'انضم كسائق توصيل'),
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
                      title: TextService.get('onboarding.storeOwner.title', defaultValue: 'صاحب متجر'),
                      subtitle: TextService.get('onboarding.storeOwner.subtitle', defaultValue: 'سجّل متجرك معنا'),
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
            Text(TextService.get('onboarding.storeOwner.comingSoon', defaultValue: 'قريباً')),
          ],
        ),
        content: const Text(
          'سيُفتح التسجيل لأصحاب المتاجر بعد المرحلة الثانية.\n\nترقّبوا التحديثات! 🚀',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(TextService.get('common.ok', defaultValue: 'حسناً')),
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
                child: Icon(icon, color: isLocked ? Colors.grey : AppColors.primary, size: 28),
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
                    Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  ],
                ),
              ),
              Icon(isLocked ? Icons.lock : Icons.arrow_forward_ios, color: isLocked ? Colors.grey : Colors.grey[400]),
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
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل زبون جديد'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Text('أدخل بياناتك', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('سجّل حسابك للبدء في استخدام التطبيق', style: TextStyle(color: Colors.grey[600])),
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
                      if (v.length < 9) return 'رقم الهاتف غير صحيح';
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'رقم الهاتف',
                      hintText: '936XXXXXX',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _isLoading ? null : _registerCustomer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('تسجيل الدخول', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _registerCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();

    if (phone.isEmpty || phone.length < 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال رقم هاتف صحيح')),
      );
      return;
    }
    
    // Standardize phone number format
    // 1. Remove any non-digit characters
    String cleanInput = phone.replaceAll(RegExp(r'\D'), '');
    
    // 2. Handle cases:
    // - Starts with 09... -> Remove 0, add +963
    // - Starts with 9... -> Add +963
    // - Starts with 963... -> Add + (if missing)
    
    String fullPhone;
    if (cleanInput.startsWith('963')) {
      fullPhone = '+$cleanInput';
    } else if (cleanInput.startsWith('09')) {
      fullPhone = '+963${cleanInput.substring(1)}';
    } else if (cleanInput.startsWith('9')) {
      fullPhone = '+963$cleanInput';
    } else {
      // Fallback or invalid? Let backend validation handle it, or assume local without 0
      fullPhone = '+963$cleanInput';
    }

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      
      // Register customer via API
      try {
        final response = await http.post(
          Uri.parse(AppConfig.customerRequestOtp),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'name': name,
            'phone': fullPhone,
          }),
        );
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          
          // For MVP, skip OTP and create user directly
          // In production, verify OTP first
          final verifyResponse = await http.post(
            Uri.parse(AppConfig.customerVerifyOtp),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'phone': fullPhone,
              'otp': data['debug_otp'] ?? '000000', // Match backend field 'debug_otp'
            }),
          );
          
          if (verifyResponse.statusCode == 200) {
            final verifyData = json.decode(verifyResponse.body);
            final userId = verifyData['user']?['id'] ?? '';
            
            // Save user data
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('customer_name', name);
            await prefs.setString('customer_phone', fullPhone);
            await prefs.setString('customer_id', userId);
            await prefs.setBool('is_logged_in', true);
            await prefs.setString('user_type', 'customer');
            await prefs.setString('login_time', DateTime.now().toIso8601String());
            
            // Save tokens
            if (verifyData['accessToken'] != null) {
              await prefs.setString('access_token', verifyData['accessToken']);
            }
            if (verifyData['refreshToken'] != null) {
              await prefs.setString('refresh_token', verifyData['refreshToken']);
            }
          }
        }
      } catch (apiError) {
        if (kDebugMode) {
          debugPrint('API Error: $apiError');
        }
        rethrow;
      }
      
      if (mounted) {
        // Navigate directly to home (no approval needed for customers)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const CustomerHomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Check if phone exists via API
  Future<bool> _checkPhoneExists(String phone) async {
    try {
      // TODO: Replace with real API call when backend is ready
      // final response = await http.get(Uri.parse('http://your-api.com/api/auth/check-phone?phone=${Uri.encodeComponent(phone)}'));
      // if (response.statusCode == 200) {
      //   final data = json.decode(response.body);
      //   return data['exists'] == true;
      // }
      return false; // Allow registration for now
    } catch (e) {
      return false; // Allow registration on error
    }
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
  final _areasController = TextEditingController();

  int _currentStep = 0;
  
  @override
  void initState() {
    super.initState();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _areasController.dispose();
    super.dispose();
  }
  
  String? _idImagePath;
  String? _bikeImagePath;
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
        backgroundColor: AppColors.primary,
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
                      backgroundColor: AppColors.primary,
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
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'مطلوب';
                      if (v.length < 9) return 'رقم الهاتف غير صحيح';
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'رقم الهاتف *',
                      hintText: '936XXXXXX',
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
                ],
              ),
            ),
            // Step 3: Areas
            Step(
              title: const Text('مناطق التواجد الدائم'),
              isActive: _currentStep >= 2,
              state: _currentStep > 2 ? StepState.complete : StepState.indexed,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('مناطق التواجد الدائم *', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('اكتب المناطق التي تتواجد فيها بشكل دائم (مثال: النهضة، السويداء)', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _areasController,
                    validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'اكتب المناطق',
                      hintText: 'مثال: النهضة، السويداء',
                      prefixIcon: const Icon(Icons.location_on),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
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
                    leading: const Icon(Icons.access_time, color: AppColors.primary),
                    title: const Text('من الساعة'),
                    trailing: Text(_startTime.format(context), style: const TextStyle(fontWeight: FontWeight.bold)),
                    onTap: () async {
                      final time = await showTimePicker(context: context, initialTime: _startTime);
                      if (time != null) setState(() => _startTime = time);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.access_time_filled, color: AppColors.primary),
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
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: const SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الشروط والأحكام',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 12),
                            Text(
                              '1. يجب أن تكون جميع المعلومات المقدمة صحيحة ودقيقة.\n'
                              '2. يجب الحفاظ على الوثائق المرفوعة محدثة وصالحة.\n'
                              '3. يجب الالتزام بجميع قوانين المرور والسلامة.\n'
                              '4. يجب تسوية المستحقات المالية يومياً.\n'
                              '5. يحق للإدارة رفض أو إيقاف الحساب في حالة مخالفة الشروط.\n'
                              '6. جميع البيانات الشخصية محمية وفقاً لسياسة الخصوصية.\n'
                              '7. يجب الالتزام بمعايير الخدمة وجودة التوصيل.',
                              style: TextStyle(fontSize: 14, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _TermsCheckbox(
                      value: _acceptTerms,
                      title: 'أوافق على الشروط والأحكام *',
                      subtitle: 'قرأت وفهمت جميع الشروط والأحكام أعلاه',
                      onChanged: (v) => setState(() => _acceptTerms = v ?? false),
                    ),
                    _TermsCheckbox(
                      value: _acceptSettlement,
                      title: 'ألتزم بالتسوية اليومية *',
                      subtitle: 'يجب تسوية المستحقات يومياً لتجنب إيقاف الحساب',
                      onChanged: (v) => setState(() => _acceptSettlement = v ?? false),
                    ),
                    _TermsCheckbox(
                      value: _acceptIdStorage,
                      title: 'أسمح بتخزين صورة الهوية *',
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
                              'سيتم مراجعة طلبك من قبل الإدارة والرد خلال 24-48 ساعة. لن تتمكن من العمل حتى يتم قبول طلبك.',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
      if (_nameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء إدخال الاسم')),
        );
        return;
      }
      final phone = _phoneController.text.trim();
      // Accept phone numbers in different formats: 0936447387, 936447387, +963936447387
      String normalizedPhone = phone;
      if (phone.startsWith('0')) {
        // Convert 0936447387 to +963936447387
        normalizedPhone = '+963${phone.substring(1)}';
      } else if (!phone.startsWith('+963')) {
        // Add +963 prefix if missing
        normalizedPhone = '+963$phone';
      }
      
      // Accept any valid format as per user request
      if (normalizedPhone.length < 9) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء إدخال رقم هاتف صحيح')),
        );
        return;
      }
      
      // Update the controller with normalized phone
      _phoneController.text = normalizedPhone;
    } else if (_currentStep == 1) {
      if (_idImagePath == null || _bikeImagePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء رفع الصور المطلوبة')),
        );
        return;
      }
    } else if (_currentStep == 2) {
      if (_areasController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء إدخال مناطق التواجد الدائم')),
        );
        return;
      }
    } else if (_currentStep == 4) {
      if (!_acceptTerms || !_acceptSettlement || !_acceptIdStorage) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء الموافقة على جميع الشروط الإلزامية')),
        );
        return;
      }
      _submitRegistration();
      return;
    }

    setState(() => _currentStep++);
  }

  Future<void> _pickImage(String type) async {
    try {
      final ImagePicker picker = ImagePicker();
      // Open camera directly (no gallery option)
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          if (type == 'id') {
            _idImagePath = image.path;
          } else {
            _bikeImagePath = image.path;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم التقاط ${type == 'id' ? 'صورة الهوية' : 'صورة الدراجة'}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitRegistration() async {
    final phone = _phoneController.text.trim();
    final name = _nameController.text.trim();
    
    // Normalize phone number: Remove all non-digits first
    String cleanInput = phone.replaceAll(RegExp(r'\D'), '');
    String fullPhone;
    
    // Strict logic:
    // 09... -> +9639...
    // 9... -> +963...
    // 963... -> +963...
    if (cleanInput.startsWith('963')) {
      fullPhone = '+$cleanInput';
    } else if (cleanInput.startsWith('09')) {
      fullPhone = '+963${cleanInput.substring(1)}';
    } else if (cleanInput.startsWith('9')) {
      fullPhone = '+963$cleanInput';
    } else {
      fullPhone = '+963$cleanInput';
    }
    
    // Accept any valid format as per user request
    if (fullPhone.length < 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال رقم هاتف صحيح')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Submit driver registration to API
      try {
        // Parse areas from text field
        final areasList = _areasController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        
        var request = http.MultipartRequest('POST', Uri.parse(AppConfig.driverRegister));
        
        request.fields['fullName'] = name;
        request.fields['phone'] = fullPhone;
        request.fields['plateNumber'] = 'N/A';
        request.fields['areaTags'] = json.encode(areasList);
        request.fields['availabilityStart'] = '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}';
        request.fields['availabilityEnd'] = '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}';
        
        if (_idImagePath != null) {
          request.files.add(await http.MultipartFile.fromPath('idPhoto', _idImagePath!));
        }
        
        if (_bikeImagePath != null) {
          request.files.add(await http.MultipartFile.fromPath('bikePhoto', _bikeImagePath!));
        }
        
        // Add timeout to prevent hanging requests
        final streamedResponse = await request.send().timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw TimeoutException('انتهت مهلة الاتصال بالخادم. يرجى المحاولة مرة أخرى.');
          },
        );
        final response = await http.Response.fromStream(streamedResponse);
        
        if (response.statusCode == 201) {
          final data = json.decode(response.body);
          if (data['success']) {
            // Save driver data
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('driver_name', name);
            await prefs.setString('driver_phone', fullPhone);
            await prefs.setString('driver_id', data['driverId']?.toString() ?? '');
            await prefs.setBool('is_logged_in', true);
            await prefs.setString('user_type', 'driver');
            await prefs.setString('login_time', DateTime.now().toIso8601String());
          }
        } else {
          // Handle non-success status codes
          String errorMessage = 'فشل في تسجيل السائق';
          try {
            final errorData = json.decode(response.body);
            errorMessage = errorData['message'] ?? errorMessage;
          } catch (_) {
            errorMessage = 'خطأ في الخادم (${response.statusCode})';
          }
          throw Exception(errorMessage);
        }
      } catch (apiError) {
        if (kDebugMode) {
          debugPrint('API Error: $apiError');
        }
        rethrow;
      }

      if (!mounted) return;

      setState(() => _isLoading = false);

      // Navigate to pending review screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const DriverAccountPendingScreen()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        
        // Handle different error types with user-friendly Arabic messages
        String errorMessage = 'حدث خطأ غير متوقع';
        
        if (e is SocketException) {
          errorMessage = 'لا يمكن الاتصال بالخادم. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى.';
        } else if (e is TimeoutException) {
          errorMessage = 'انتهت مهلة الاتصال. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى.';
        } else if (e is HttpException) {
          errorMessage = 'خطأ في الاتصال بالخادم. يرجى المحاولة مرة أخرى.';
        } else if (e.toString().contains('Failed host lookup')) {
          errorMessage = 'لا يمكن الوصول إلى الخادم. يرجى التحقق من اتصال الإنترنت.';
        } else if (e.toString().contains('Connection refused')) {
          errorMessage = 'تم رفض الاتصال بالخادم. يرجى المحاولة لاحقاً.';
        } else if (e.toString().isNotEmpty) {
          // Try to extract meaningful error message
          final errorStr = e.toString();
          if (errorStr.contains('message') || errorStr.contains('خطأ') || errorStr.contains('فشل')) {
            errorMessage = errorStr;
          } else {
            errorMessage = 'حدث خطأ: $errorStr';
          }
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  // Check if phone exists via API
  Future<bool> _checkPhoneExists(String phone) async {
    try {
      // TODO: Replace with real API call when backend is ready
      // final response = await http.get(Uri.parse('http://your-api.com/api/auth/check-phone?phone=${Uri.encodeComponent(phone)}'));
      // if (response.statusCode == 200) {
      //   final data = json.decode(response.body);
      //   return data['exists'] == true;
      // }
      return false; // Allow registration for now
    } catch (e) {
      return false; // Allow registration on error
    }
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
            color: imagePath != null ? AppColors.primary : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: imagePath != null ? AppColors.primary.withOpacity(0.05) : null,
        ),
        child: Row(
          children: [
            Icon(
              imagePath != null ? Icons.check_circle : icon,
              color: imagePath != null ? AppColors.primary : Colors.grey,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                imagePath != null ? '$title ✓' : title,
                style: TextStyle(
                  fontSize: 16,
                  color: imagePath != null ? AppColors.primary : Colors.grey[700],
                  fontWeight: imagePath != null ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            Icon(
              Icons.camera_alt,
              color: imagePath != null ? AppColors.primary : Colors.grey,
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
      activeColor: AppColors.primary,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }
}

// ==================== Driver Account Pending Screen ====================
class DriverAccountPendingScreen extends StatelessWidget {
  const DriverAccountPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('طلبك قيد المراجعة'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            const Icon(Icons.hourglass_bottom, size: 80, color: AppColors.primary),
            const SizedBox(height: 24),
            const Text(
              'تم استلام طلبك',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'سيتم مراجعة طلبك خلال 24-48 ساعة',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.indigo[200]!),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ماذا يحدث الآن؟',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 12),
                  Text('• فريقنا يتحقق من صحة البيانات المرسلة'),
                  SizedBox(height: 4),
                  Text('• سيتم التحقق من الوثائق المرفوعة'),
                  SizedBox(height: 4),
                  Text('• سيتم التواصل معك إذا احتجنا معلومات إضافية'),
                  SizedBox(height: 4),
                  Text('• عند الموافقة ستصلك رسالة تأكيد ويمكنك البدء بالعمل'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'لن تتمكن من العمل حتى يتم قبول طلبك من قبل الإدارة',
                      style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // Navigate back to onboarding or login
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('العودة للرئيسية', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== Customer Home Screen ====================
class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _currentIndex = 0;
  String _customerName = 'مستخدم جديد';
  String _customerPhone = '+963';
  String? _customerId;
  List<Map<String, dynamic>> _orders = [];
  bool _isLoadingOrders = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch orders when orders tab is selected
    if (_currentIndex == 1) {
      _fetchOrders();
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _customerName = prefs.getString('customer_name') ?? 'مستخدم جديد';
      _customerPhone = prefs.getString('customer_phone') ?? '+963';
      _customerId = prefs.getString('customer_id');
    });
    // Fetch orders after loading user data
    if (_customerId != null && _customerId!.isNotEmpty) {
      _fetchOrders();
    }
  }

  Future<void> _fetchOrders() async {
    if (_isLoadingOrders) return;
    
    setState(() => _isLoadingOrders = true);
    
    try {
      final customerId = _customerId;
      if (customerId == null || customerId.isEmpty) {
        setState(() {
          _orders = [];
          _isLoadingOrders = false;
        });
        return;
      }

      final url = Uri.parse('${AppConfig.orders}?customerId=$customerId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['orders'] != null) {
          setState(() {
            _orders = List<Map<String, dynamic>>.from(data['orders']);
            _isLoadingOrders = false;
          });
        } else {
          setState(() {
            _orders = [];
            _isLoadingOrders = false;
          });
        }
      } else {
        setState(() {
          _orders = [];
          _isLoadingOrders = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching orders: $e');
      }
      setState(() {
        _orders = [];
        _isLoadingOrders = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دلّعني'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(),
          _buildOrdersTab(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Fetch orders when orders tab is selected
          if (index == 1) {
            _fetchOrders();
          }
        },
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'طلباتي'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return Padding(
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
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
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
    );
  }

  Widget _buildOrdersTab() {
    if (_isLoadingOrders) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_orders.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('طلباتي', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _fetchOrders,
                  tooltip: 'تحديث',
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('لا توجد طلبات بعد', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Text('ابدأ بإنشاء طلبك الأول', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchOrders,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('طلباتي', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _fetchOrders,
                  tooltip: 'تحديث',
                ),
              ],
            ),
            const SizedBox(height: 24),
            ..._orders.map((order) => _buildOrderCard(order)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'] ?? 'REQUESTED';
    final statusText = _getStatusText(status);
    final statusColor = _getStatusColor(status);
    final createdAt = order['createdAt'] != null 
        ? DateTime.tryParse(order['createdAt'].toString())
        : null;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // Navigate to order details or tracking screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderTrackingScreen(
                orderData: {
                  'orderId': order['id']?.toString() ?? '',
                  'order': order['itemsText']?.toString() ?? '',
                  'address': order['deliveryAddress']?.toString() ?? '',
                  'notes': order['notes']?.toString() ?? '',
                  'customerName': _customerName,
                  'customerPhone': _customerPhone,
                  'latitude': order['deliveryLat']?.toString() ?? '',
                  'longitude': order['deliveryLng']?.toString() ?? '',
                },
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (createdAt != null)
                    Text(
                      '${createdAt.day}/${createdAt.month}/${createdAt.year}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                order['itemsText']?.toString() ?? 'لا توجد تفاصيل',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      order['deliveryAddress']?.toString() ?? 'لا يوجد عنوان',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (order['estimatedPrice'] != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'السعر التقديري:',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    Text(
                      '${order['estimatedPrice']} ل.س',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'REQUESTED':
        return 'قيد الانتظار';
      case 'ASSIGNED':
        return 'تم التعيين';
      case 'PICKED_UP':
        return 'تم الاستلام';
      case 'EN_ROUTE':
        return 'في الطريق';
      case 'DELIVERED':
        return 'تم التسليم';
      case 'COMPLETED':
        return 'مكتمل';
      case 'CANCELED':
        return 'ملغي';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'REQUESTED':
        return Colors.orange;
      case 'ASSIGNED':
        return Colors.blue;
      case 'PICKED_UP':
        return Colors.purple;
      case 'EN_ROUTE':
        return Colors.indigo;
      case 'DELIVERED':
        return Colors.green;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('حسابي', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: const Icon(Icons.person, color: AppColors.primary),
              ),
              title: const Text('الاسم', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(_customerName),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.phone, color: AppColors.primary),
              title: const Text('رقم الهاتف', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(_customerPhone),
            ),
          ),
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
  final _notesController = TextEditingController();
  bool _isGettingLocation = false;
  double? _latitude;
  double? _longitude;

  @override
  void dispose() {
    _orderController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);
    
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('يرجى تفعيل خدمة الموقع في إعدادات الهاتف'),
              backgroundColor: Colors.orange,
            ),
          );
          // Open location settings
          await Geolocator.openLocationSettings();
        }
        setState(() => _isGettingLocation = false);
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم رفض إذن الوصول للموقع'),
                backgroundColor: Colors.red,
              ),
            );
            _showLocationDialog(); // Show manual entry dialog
          }
          setState(() => _isGettingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('يرجى تفعيل إذن الموقع من إعدادات التطبيق'),
              backgroundColor: Colors.red,
            ),
          );
          _showLocationDialog(); // Show manual entry dialog
        }
        setState(() => _isGettingLocation = false);
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '${place.street ?? ''} ${place.subLocality ?? ''} ${place.locality ?? ''} ${place.country ?? ''}'.trim();
        
        if (mounted) {
          setState(() {
            _latitude = position.latitude;
            _longitude = position.longitude;
            _addressController.text = address.isNotEmpty ? address : '${position.latitude}, ${position.longitude}';
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديد موقعك بنجاح ✓'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // If no address found, use coordinates
        if (mounted) {
          setState(() {
            _latitude = position.latitude;
            _longitude = position.longitude;
            _addressController.text = '${position.latitude}, ${position.longitude}';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        // Show manual entry dialog as fallback
        _showLocationDialog();
      }
    } finally {
      if (mounted) {
        setState(() => _isGettingLocation = false);
      }
    }
  }

  void _showLocationDialog() {
    final locationController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('أدخل عنوانك يدوياً'),
        content: TextField(
          controller: locationController,
          decoration: const InputDecoration(
            hintText: 'مثال: جبل عمان، شارع الملكة رانيا',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (locationController.text.isNotEmpty) {
                setState(() {
                  _addressController.text = locationController.text;
                  _latitude = null; // Clear GPS coordinates when manual entry
                  _longitude = null;
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اكتب طلبك'),
        backgroundColor: AppColors.primary,
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
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      hintText: 'أدخل عنوان التوصيل أو اضغط على GPS',
                      prefixIcon: const Icon(Icons.location_on),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onTap: () {
                      // Show option to enter manually
                      _showLocationDialog();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: _latitude != null && _longitude != null 
                        ? Colors.green.withOpacity(0.1) 
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _latitude != null && _longitude != null 
                          ? Colors.green 
                          : AppColors.primary,
                    ),
                  ),
                  child: _isGettingLocation
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: Icon(
                            _latitude != null && _longitude != null 
                                ? Icons.check_circle 
                                : Icons.my_location,
                            color: _latitude != null && _longitude != null 
                                ? Colors.green 
                                : AppColors.primary,
                          ),
                          onPressed: _getCurrentLocation,
                          tooltip: 'تحديد الموقع الحالي عبر GPS',
                        ),
                ),
              ],
            ),
            if (_latitude != null && _longitude != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: Colors.green[700]),
                    const SizedBox(width: 4),
                    Text(
                      'تم تحديد الموقع بدقة GPS',
                      style: TextStyle(fontSize: 12, color: Colors.green[700]),
                    ),
                  ],
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
                backgroundColor: AppColors.primary,
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
    if (_orderController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى كتابة تفاصيل الطلب')),
      );
      return;
    }
    
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال عنوان التوصيل')),
      );
      return;
    }

    // Get user data and send order
    SharedPreferences.getInstance().then((prefs) async {
      final customerName = prefs.getString('customer_name') ?? 'مستخدم';
      final customerPhone = prefs.getString('customer_phone') ?? '+963';
      final customerId = prefs.getString('customer_id') ?? '';
      
      setState(() => _isGettingLocation = true);
      
      try {
        // Get or create customer ID
        String finalCustomerId = customerId;
        if (finalCustomerId.isEmpty) {
          // Try to get customer ID from phone
          final prefs = await SharedPreferences.getInstance();
          final savedPhone = prefs.getString('customer_phone') ?? '';
          if (savedPhone.isNotEmpty) {
            // Try to find customer by phone
            // For now, we'll create order without customerId if not found
          }
        }
        
        // Send order to API
        final response = await http.post(
          Uri.parse(AppConfig.orders),
          headers: {
            'Content-Type': 'application/json',
            // Add auth token if available
            // 'Authorization': 'Bearer $token',
          },
          body: json.encode({
            'customerId': finalCustomerId.isNotEmpty ? finalCustomerId : null,
            'itemsText': _orderController.text,
            'deliveryAddress': _addressController.text,
            'deliveryLat': _latitude?.toString(),
            'deliveryLng': _longitude?.toString(),
            'pickupAddress': _addressController.text,
            'notes': _notesController.text,
            'area': 'default',
          }),
        );
        
        String orderId = '';
        if (response.statusCode == 201) {
          final data = json.decode(response.body);
          orderId = data['order']?['id'] ?? '';
          
          // Save order ID
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('last_order_id', orderId);
        } else {
          if (kDebugMode) {
            debugPrint('Order creation failed: ${response.statusCode}');
          }
        }
        
        // Navigate to matching screen
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => MatchingDriverScreen(
                orderData: {
                  'orderId': orderId,
                  'order': _orderController.text,
                  'address': _addressController.text,
                  'notes': _notesController.text,
                  'customerName': customerName,
                  'customerPhone': customerPhone,
                  'latitude': _latitude?.toString() ?? '',
                  'longitude': _longitude?.toString() ?? '',
                },
              ),
            ),
          );
        }
      } catch (e) {
        // If API fails, navigate anyway
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => MatchingDriverScreen(
                orderData: {
                  'order': _orderController.text,
                  'address': _addressController.text,
                  'notes': _notesController.text,
                  'customerName': customerName,
                  'customerPhone': customerPhone,
                  'latitude': _latitude?.toString() ?? '',
                  'longitude': _longitude?.toString() ?? '',
                },
              ),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isGettingLocation = false);
        }
      }
    });
  }
}

// ==================== Matching Driver Screen ====================
class MatchingDriverScreen extends StatefulWidget {
  final Map<String, String>? orderData;
  
  const MatchingDriverScreen({super.key, this.orderData});

  @override
  State<MatchingDriverScreen> createState() => _MatchingDriverScreenState();
}

class _MatchingDriverScreenState extends State<MatchingDriverScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 2), vsync: this)..repeat();
    _findNearestDriver();
  }

  Future<void> _findNearestDriver() async {
    // Get customer location
    final latStr = widget.orderData?['latitude'] ?? '';
    final lngStr = widget.orderData?['longitude'] ?? '';
    final address = widget.orderData?['address'] ?? '';
    
    if (latStr.isEmpty || lngStr.isEmpty) {
      // No GPS coordinates, use address search
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('جارٍ البحث عن أقرب سائق...'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    }
    
    final orderId = widget.orderData?['orderId'];
    if (orderId == null || orderId.isEmpty) {
      if (mounted) {
        // Fallback if no order ID was provided
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => OrderTrackingScreen(orderData: widget.orderData),
            ),
          );
        }
      }
      return;
    }

    // Poll for status update
    bool driverAssigned = false;
    int attempts = 0;
    const maxAttempts = 20; // ~1 minute timeout

    while (!driverAssigned && attempts < maxAttempts && mounted) {
      try {
        final response = await http.get(Uri.parse(AppConfig.orderById(orderId)));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['success'] && data['order'] != null) {
            final order = data['order'];
            if (order['status'] != 'REQUESTED' && order['status'] != 'PENDING') {
              driverAssigned = true;
              break;
            }
          }
        }
      } catch (e) {
        if (kDebugMode) debugPrint('Poll error: $e');
      }
      
      attempts++;
      await Future.delayed(const Duration(seconds: 3));
    }

    if (mounted) {
      if (driverAssigned) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تواصل طلبكم مع السائق بنجاح ✓'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderTrackingScreen(
            orderData: widget.orderData,
          ),
        ),
      );
    }
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
            colors: [AppColors.primary, AppColors.secondary],
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
                  child: const Icon(Icons.motorcycle, size: 60, color: AppColors.primary),
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
  final Map<String, String>? orderData;
  
  const OrderTrackingScreen({super.key, this.orderData});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  String _status = 'accepted';
  String _deliveryCode = '1234';
  String _driverName = 'السائق';
  String _driverPhone = '+963';
  double? _driverLat;
  double? _driverLng;
  Timer? _statusTimer;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _loadOrderStatus();
    _startLocationTracking();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _locationTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadOrderStatus() async {
    final orderId = widget.orderData?['orderId'];
    if (orderId == null || orderId.isEmpty) return;

    try {
      final response = await http.get(Uri.parse(AppConfig.orderById(orderId)));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] && data['order'] != null) {
          final order = data['order'];
          if (mounted) {
            setState(() {
              _status = _mapStatus(order['status']);
              _deliveryCode = order['deliveryCode']?.toString() ?? '1234';
              _driverName = order['Driver']?['User']?['name'] ?? 'السائق';
              _driverPhone = order['Driver']?['User']?['phone'] ?? '+963';
              final lat = order['Driver']?['latitude'];
              final lng = order['Driver']?['longitude'];
              _driverLat = lat != null ? double.tryParse(lat.toString()) : null;
              _driverLng = lng != null ? double.tryParse(lng.toString()) : null;
            });
          }
        }
      }
    } catch (e) {
      // Continue with default status
    }
  }

  void _startLocationTracking() {
    // Poll for status updates every 5 seconds
    _statusTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _loadOrderStatus();
    });
  }

  String _mapStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'REQUESTED':
        return 'accepted';
      case 'ASSIGNED':
        return 'accepted';
      case 'PICKED_UP':
        return 'picked_up';
      case 'EN_ROUTE':
        return 'arriving';
      case 'DELIVERED':
        if (mounted) {
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerDeliveryCodeScreen(deliveryCode: _deliveryCode)));
          });
        }
        return 'delivered';
      default:
        return 'accepted';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تتبع الطلب'),
          backgroundColor: AppColors.primary,
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
                    child: const Icon(Icons.person, size: 35, color: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_driverName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const Row(children: [Icon(Icons.star, color: Colors.amber, size: 18), Text(' 4.8', style: TextStyle(color: Colors.grey))]),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final uri = Uri.parse('tel:${_driverPhone.replaceAll(' ', '')}');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    },
                    icon: const Icon(Icons.phone, color: AppColors.primary),
                    tooltip: 'اتصال',
                  ),
                  IconButton(
                    onPressed: () async {
                      final phone = _driverPhone.replaceAll('+', '').replaceAll(' ', '');
                      final uri = Uri.parse('https://wa.me/$phone');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                    icon: const Icon(Icons.chat, color: AppColors.primary),
                    tooltip: 'واتساب',
                  ),
                  if (_driverLat != null && _driverLng != null)
                    IconButton(
                      onPressed: () async {
                        final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$_driverLat,$_driverLng');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                      icon: const Icon(Icons.location_on, color: Colors.green),
                      tooltip: 'موقع السائق',
                    ),
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
            if (_driverLat != null && _driverLng != null && (_status == 'picked_up' || _status == 'arriving'))
              Container(
                margin: const EdgeInsets.all(16),
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.map, size: 48, color: Colors.grey),
                          const SizedBox(height: 8),
                          const Text('خريطة تتبع السائق', style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$_driverLat,$_driverLng');
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              }
                            },
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('فتح الخريطة'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text('السائق متصل', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
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
                color: isCompleted || isActive ? AppColors.primary : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: isCompleted ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
            ),
            Container(width: 2, height: 50, color: isCompleted ? AppColors.primary : Colors.grey[300]),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isActive ? AppColors.primary : Colors.black)),
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
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
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
            gradient: AppColors.primaryGradient,
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
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(50)),
                    child: const Icon(Icons.delivery_dining, size: 50, color: AppColors.primary),
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
                      foregroundColor: AppColors.primary,
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
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: const Icon(Icons.person, size: 45, color: AppColors.primary),
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
                      backgroundColor: AppColors.primary,
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
      case 1:
        return 'سيء 😞';
      case 2:
        return 'مقبول 😐';
      case 3:
        return 'جيد 🙂';
      case 4:
        return 'جيد جداً 😊';
      case 5:
        return 'ممتاز! 🌟';
      default:
        return '';
    }
  }

  void _submitRating() {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const CustomerHomeScreen()), (route) => false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('شكراً لتقييمك!'), backgroundColor: Colors.green));
  }
}
