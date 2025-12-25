// Simple in-memory rate limiter (production: use Redis)
const rateLimitStore = new Map();

const rateLimiter = (windowMs = 15 * 60 * 1000, maxRequests = 100) => {
  return (req, res, next) => {
    const key = req.ip || req.connection.remoteAddress;
    const now = Date.now();
    
    // Clean old entries
    if (rateLimitStore.size > 10000) {
      rateLimitStore.clear();
    }
    
    const record = rateLimitStore.get(key);
    
    if (!record) {
      rateLimitStore.set(key, {
        count: 1,
        resetTime: now + windowMs,
      });
      return next();
    }
    
    // Reset if window expired
    if (now > record.resetTime) {
      record.count = 1;
      record.resetTime = now + windowMs;
      return next();
    }
    
    // Check limit
    if (record.count >= maxRequests) {
      return res.status(429).json({
        success: false,
        message: 'تم تجاوز الحد المسموح من الطلبات. يرجى المحاولة لاحقاً.',
        retryAfter: Math.ceil((record.resetTime - now) / 1000),
      });
    }
    
    record.count++;
    next();
  };
};

// Stricter rate limiter for auth endpoints (increased for admin login)
const authRateLimiter = rateLimiter(15 * 60 * 1000, 20); // 20 requests per 15 minutes

// Standard rate limiter
const standardRateLimiter = rateLimiter(15 * 60 * 1000, 100); // 100 requests per 15 minutes

module.exports = {
  rateLimiter,
  authRateLimiter,
  standardRateLimiter,
};

