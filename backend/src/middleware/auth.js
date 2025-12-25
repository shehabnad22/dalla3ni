const jwt = require('jsonwebtoken');
const { User } = require('../models');

// JWT Authentication Middleware
const authenticate = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'مطلوب token للمصادقة'
      });
    }

    const token = authHeader.substring(7);

    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET || 'dalla3ni-secret');

      // Get user from database
      const user = await User.findByPk(decoded.userId);
      if (!user) {
        return res.status(401).json({
          success: false,
          message: 'المستخدم غير موجود'
        });
      }

      // Check global blocking
      if (user.isBlocked) {
        return res.status(403).json({
          success: false,
          message: 'لقد خالفت معايير الاستخدام وتم حظرك',
          isBlocked: true,
          blockReason: user.blockReason || 'تم الحظر من قبل الإدارة'
        });
      }

      // Check if user is active
      if (!user.isActive) {
        return res.status(403).json({
          success: false,
          message: 'حسابك غير نشط. يرجى التواصل مع الدعم'
        });
      }

      req.user = user;
      req.userId = user.id;
      req.userRole = user.role;
      next();
    } catch (error) {
      if (error.name === 'TokenExpiredError') {
        return res.status(401).json({
          success: false,
          message: 'انتهت صلاحية الـ token',
          code: 'TOKEN_EXPIRED'
        });
      }
      return res.status(401).json({
        success: false,
        message: 'Token غير صحيح'
      });
    }
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

// Admin Only Middleware
const requireAdmin = (req, res, next) => {
  if (req.userRole !== 'admin') {
    return res.status(403).json({
      success: false,
      message: 'هذا الإجراء يتطلب صلاحيات مدير'
    });
  }
  next();
};

// Generate Access Token (short-lived)
const generateAccessToken = (user) => {
  return jwt.sign(
    { userId: user.id, role: user.role },
    process.env.JWT_SECRET || 'dalla3ni-secret',
    { expiresIn: process.env.JWT_EXPIRES_IN || '15m' }
  );
};

// Generate Refresh Token (long-lived)
const generateRefreshToken = (user) => {
  return jwt.sign(
    { userId: user.id, role: user.role, type: 'refresh' },
    process.env.JWT_REFRESH_SECRET || 'dalla3ni-refresh-secret',
    { expiresIn: '7d' }
  );
};

module.exports = {
  authenticate,
  requireAdmin,
  generateAccessToken,
  generateRefreshToken,
};

