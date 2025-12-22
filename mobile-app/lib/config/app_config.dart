class AppConfig {
  // Base URL Configuration
  // Production: Set via environment variable or build configuration
  // Development: Use localhost/emulator IP
  
  // Get base URL from environment or use default
  // In production builds, this should be set via --dart-define or environment
  static String get baseUrl {
    // Check for production API URL first (set via --dart-define=API_BASE_URL=...)
    const String prodUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (prodUrl.isNotEmpty) {
      return prodUrl;
    }
    
    // Production default - Use Render backend URL
    // This is the LIVE backend URL
    const bool isProduction = bool.fromEnvironment('PRODUCTION', defaultValue: false);
    if (isProduction) {
      // Production: Use Render backend
      return 'https://dalla3ni-backend-v2-2.onrender.com';
    }
    
    // Development defaults
    // For Android emulator: 10.0.2.2
    // For iOS simulator: localhost
    // For real device: use your computer's IP (e.g., 192.168.1.20)
    // Or use production URL for testing: https://dalla3ni-backend-v2-2.onrender.com
    return 'https://dalla3ni-backend-v2-2.onrender.com'; // Using production URL by default
  }
  
  // API Endpoints
  static String get apiBaseUrl => '$baseUrl/api';
  
  // Auth Endpoints
  static String get customerRequestOtp => '$apiBaseUrl/auth/customer/request-otp';
  static String get customerVerifyOtp => '$apiBaseUrl/auth/customer/verify-otp';
  static String get driverRegister => '$apiBaseUrl/auth/driver/register';
  static String driverStatusByPhone(String phone) => '$apiBaseUrl/auth/driver/status/$phone';
  
  // Order Endpoints
  static String get orders => '$apiBaseUrl/orders';
  static String orderById(String id) => '$orders/$id';
  static String orderAssign(String id) => '$orders/$id/assign';
  static String orderAccept(String id) => '$orders/$id/accept';
  static String orderPickup(String id) => '$orders/$id/pickup';
  static String orderEnRoute(String id) => '$orders/$id/enroute';
  static String orderDeliver(String id) => '$orders/$id/deliver';
  static String orderComplete(String id) => '$orders/$id/complete';
  
  // Driver Endpoints
  static String get driverLocation => '$apiBaseUrl/drivers/location';
  
  // Health Check
  static String get health => '$baseUrl/health';
}

