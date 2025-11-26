/// Feature Flags Configuration
/// Toggle features on/off without code changes

class FeatureFlags {
  // Stores feature - DISABLED
  static const bool storesEnabled = false;
  
  // Centers feature - DISABLED
  static const bool centersEnabled = false;
  
  // Active features
  static const bool driverRegistration = true;
  static const bool customerRegistration = true;
  static const bool textOrders = true;
  static const bool invoiceUpload = true;
  static const bool deliveryCode = true;
  static const bool ratings = true;
  static const bool settlements = true;
  static const bool driverWallet = true;
  static const bool pushNotifications = true;
  
  // Future features (disabled)
  static const bool scheduledOrders = false;
  static const bool multiStopDelivery = false;
  static const bool liveTracking = false;
  static const bool chat = false;
  
  // Helper method
  static bool isEnabled(String feature) {
    switch (feature) {
      case 'stores': return storesEnabled;
      case 'centers': return centersEnabled;
      case 'driver_registration': return driverRegistration;
      case 'customer_registration': return customerRegistration;
      case 'text_orders': return textOrders;
      default: return false;
    }
  }
}

