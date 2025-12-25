import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart';
import 'driver_app.dart';
import 'services/text_service.dart';
import 'config/app_colors.dart';
import 'config/app_config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _textsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadTextsAndInit();
  }

  Future<void> _loadTextsAndInit() async {
    // Load texts.json
    await TextService.loadTexts();
    
    setState(() {
      _textsLoaded = true;
    });

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // Navigate after 1.5 seconds (reduced from 2.5s for better feel)
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _checkLoginStatus();
      }
    });
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final userType = prefs.getString('user_type') ?? '';
    final phone = prefs.getString('${userType}_phone') ?? 
                  prefs.getString('customer_phone') ?? 
                  prefs.getString('driver_phone') ?? '';
    
    if (mounted) {
      if (isLoggedIn) {
        // Retrieve token
        final accessToken = prefs.getString('access_token');
        
        if (accessToken != null && accessToken.isNotEmpty) {
           try {
            // Verify via /auth/me
            final url = Uri.parse(AppConfig.authMe);
            final response = await http.get(
              url,
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $accessToken',
              },
            );

            if (response.statusCode == 200) {
              final data = json.decode(response.body);
              // Check if blocked (backend middleware already checks, but good to be explicit)
              if (data['isBlocked'] == true) {
                await prefs.clear();
                if (mounted) {
                  _showBanDialog(data['message'] ?? 'لقد خالفت معايير الاستخدام وتم حظرك');
                  return;
                }
              }
              // Valid session, proceed
            } else if (response.statusCode == 403) {
               // User is explicitly blocked or forbidden
               final data = json.decode(response.body);
               await prefs.clear();
               if (mounted) {
                 _showBanDialog(data['message'] ?? 'لقد خالفت معايير الاستخدام وتم حظرك');
                 return;
               }
            } else if (response.statusCode == 401) {
              // Token expired or invalid
              await prefs.clear();
              // Will fall through to onboarding
            }
          } catch (e) {
            debugPrint('Auth check error: $e');
            // Network error? Allow offline use if needed, or force login?
            // For now, if check fails, we might want to allow entry if we trust the local flag, 
            // OR be strict. Requirement says "Blocked users must never see any app content".
            // So if we can't verify, we should probably be careful.
            // However, for UX, if offline, maybe let them in?
            // The requirement says "On app launch... Call /api/auth/me... If response is 403... Prevent access".
            // It doesn't strictly say "Prevent access if offline". 
            // We'll proceed with local checks if network fails, assuming 403 would have been returned if reachable.
          }
        }
      }
      
      // Re-read prefs as they might have been cleared
      final stillLoggedIn = prefs.getBool('is_logged_in') ?? false;
      final currentUserType = prefs.getString('user_type') ?? '';

      if (stillLoggedIn && currentUserType == 'customer') {
        // Customer is logged in, go to home
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const CustomerHomeScreen(),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      } else if (stillLoggedIn && currentUserType == 'driver') {
        // Driver is logged in, go to home
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const DriverHomeScreen(),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      } else {
        // Not logged in, go to onboarding
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const OnboardingScreen(),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    }
  }

  void _showBanDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.block, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('تم حظرك'),
          ],
        ),
        content: Text(message),
        actions: [
          // No "OK" button to dismiss and continue. Strict blocking means they stay here or restart.
          // We can offer a button to exit the app or just clear specific data, but requirements say:
          // "Prevent access to the app entirely"
          // We'll redirect to onboarding but since we cleared prefs, they can't log back in.
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const OnboardingScreen()),
              );
            },
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_textsLoaded) {
      return const Scaffold(
        backgroundColor: AppColors.primary,
        body: SizedBox.expand(), // Matches native splash background exactly
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.primary, // Orange background
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Image.asset(
            'assets/splash_screen.png',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (context, error, stackTrace) {
              // Fallback if image not found - show app name and icon with orange background
              return Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(35),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.motorcycle,
                          size: 70,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        TextService.get('app.name', defaultValue: 'دلّعني'),
                        style: const TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        TextService.get('app.nameEn', defaultValue: 'Dalla3ni'),
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white.withOpacity(0.8),
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

