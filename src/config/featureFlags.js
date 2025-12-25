// Feature Flags Configuration
// Toggle features on/off without code changes

const featureFlags = {
  // Stores feature - DISABLED
  stores_enabled: process.env.STORES_ENABLED === 'true' || false,
  
  // Centers feature - DISABLED  
  centers_enabled: process.env.CENTERS_ENABLED === 'true' || false,
  
  // Commission amount (configurable from Admin)
  commission_amount: parseFloat(process.env.COMMISSION_AMOUNT) || 2500,
  
  // Active features
  driver_registration: true,
  customer_registration: true,
  text_orders: true,
  invoice_upload: true,
  delivery_code: true,
  ratings: true,
  settlements: true,
  driver_wallet: true,
  push_notifications: true,
  
  // Future features (disabled)
  scheduled_orders: false,
  multi_stop_delivery: false,
  live_tracking: false,
  chat: false,
};

// Check if a feature is enabled
const isFeatureEnabled = (featureName) => {
  return featureFlags[featureName] === true;
};

// Middleware to check feature flag
const requireFeature = (featureName) => {
  return (req, res, next) => {
    if (!isFeatureEnabled(featureName)) {
      return res.status(403).json({
        success: false,
        message: 'هذه الميزة غير متاحة حالياً',
        feature: featureName,
      });
    }
    next();
  };
};

module.exports = {
  featureFlags,
  isFeatureEnabled,
  requireFeature,
};

