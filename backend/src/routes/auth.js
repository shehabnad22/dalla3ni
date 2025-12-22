const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const { User, Driver } = require('../models');
const { generateAccessToken, generateRefreshToken } = require('../middleware/auth');

// Store OTPs temporarily (in production, use Redis)
const otpStore = new Map();

// Generate 6-digit OTP
const generateOtp = () => Math.floor(100000 + Math.random() * 900000).toString();

// Send OTP via WhatsApp (placeholder - integrate with WhatsApp Business API)
const sendWhatsAppOtp = async (phone, otp) => {
  // TODO: Integrate with WhatsApp Business API
  // For now, log the OTP
  console.log(`📱 WhatsApp OTP to ${phone}: ${otp}`);
  
  // In production, use:
  // - WhatsApp Business API
  // - Twilio WhatsApp
  // - MessageBird
  // - etc.
  
  return true;
};

// Request OTP for Customer
router.post('/customer/request-otp', async (req, res) => {
  try {
    const { phone, name } = req.body;

    if (!phone || !name) {
      return res.status(400).json({ success: false, message: 'الاسم ورقم الهاتف مطلوبان' });
    }

    // Generate OTP
    const otp = generateOtp();
    const expiresAt = Date.now() + 5 * 60 * 1000; // 5 minutes

    // Store OTP
    otpStore.set(phone, { otp, name, expiresAt, role: 'customer' });

    // Send via WhatsApp
    await sendWhatsAppOtp(phone, otp);

    res.json({ 
      success: true, 
      message: 'تم إرسال رمز التحقق عبر واتساب',
      // Remove in production:
      debug_otp: process.env.NODE_ENV === 'development' ? otp : undefined,
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Verify OTP and Create Customer Account
router.post('/customer/verify-otp', async (req, res) => {
  try {
    const { phone, otp } = req.body;

    const stored = otpStore.get(phone);
    
    if (!stored) {
      return res.status(400).json({ success: false, message: 'لم يتم طلب رمز تحقق لهذا الرقم' });
    }

    if (Date.now() > stored.expiresAt) {
      otpStore.delete(phone);
      return res.status(400).json({ success: false, message: 'انتهت صلاحية الرمز' });
    }

    if (stored.otp !== otp) {
      return res.status(400).json({ success: false, message: 'الرمز غير صحيح' });
    }

    // OTP verified - create or get user
    let user = await User.findOne({ where: { phone } });

    if (!user) {
      user = await User.create({
        name: stored.name,
        phone,
        email: `${phone.replace('+', '')}@dalla3ni.app`, // Placeholder email
        password: Math.random().toString(36), // Random password (not used for OTP auth)
        role: 'customer',
        isVerified: true,
        isActive: true,
      });
    } else {
      // Update name if changed
      if (user.name !== stored.name) {
        user.name = stored.name;
        await user.save();
      }
    }

    // Clear OTP
    otpStore.delete(phone);

    // Generate Access & Refresh Tokens
    const accessToken = generateAccessToken(user);
    const refreshToken = generateRefreshToken(user);

    res.json({
      success: true,
      message: 'تم التحقق بنجاح',
      accessToken,
      refreshToken,
      user: {
        id: user.id,
        name: user.name,
        phone: user.phone,
        role: user.role,
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Register Driver (PENDING_REVIEW)
router.post('/driver/register', async (req, res) => {
  try {
    const {
      fullName,
      phone,
      idPhoto,
      bikePhoto,
      plateNumber,
      bikeModel,
      areaTags,
      availabilityStart,
      availabilityEnd,
    } = req.body;

    // Validation - Make plateNumber optional for MVP
    if (!fullName || !phone || !idPhoto || !bikePhoto || !areaTags?.length) {
      return res.status(400).json({ success: false, message: 'جميع الحقول المطلوبة يجب ملؤها' });
    }

    // Check if phone already exists
    const existingUser = await User.findOne({ where: { phone } });
    if (existingUser) {
      return res.status(400).json({ success: false, message: 'رقم الهاتف مسجل مسبقاً' });
    }

    // Create user with driver role
    const user = await User.create({
      name: fullName,
      phone,
      email: `driver_${phone}@dalla3ni.app`,
      password: Math.random().toString(36),
      role: 'driver',
      isVerified: false, // Will be verified after admin approval
    });

    // Create driver profile with PENDING_REVIEW status
    const driver = await Driver.create({
      userId: user.id,
      idImage: idPhoto,
      motorImage: bikePhoto,
      plateNumber: plateNumber || 'N/A',
      bikeModel: bikeModel || null,
      workingAreas: areaTags,
      workStartTime: availabilityStart,
      workEndTime: availabilityEnd,
      isApproved: false, // PENDING_REVIEW
      isAvailable: false,
      accountStatus: 'PENDING_REVIEW',
    });

    res.status(201).json({
      success: true,
      message: 'تم إرسال طلب التسجيل بنجاح. سيتم مراجعته من قبل الإدارة.',
      status: 'PENDING_REVIEW',
      driverId: driver.id,
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Check Driver Application Status
router.get('/driver/status/:phone', async (req, res) => {
  try {
    const user = await User.findOne({ 
      where: { phone: req.params.phone, role: 'driver' },
      include: [{ model: Driver }],
    });

    if (!user) {
      return res.status(404).json({ success: false, message: 'لم يتم العثور على طلب تسجيل' });
    }

    const status = user.Driver?.accountStatus || 'PENDING_REVIEW';

    res.json({
      success: true,
      status,
      isApproved: user.Driver?.isApproved || false,
      accountStatus: status,
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Resend OTP
router.post('/resend-otp', async (req, res) => {
  try {
    const { phone } = req.body;
    
    const stored = otpStore.get(phone);
    if (!stored) {
      return res.status(400).json({ success: false, message: 'لم يتم طلب رمز تحقق لهذا الرقم' });
    }

    // Generate new OTP
    const otp = generateOtp();
    stored.otp = otp;
    stored.expiresAt = Date.now() + 5 * 60 * 1000;
    otpStore.set(phone, stored);

    // Send via WhatsApp
    await sendWhatsAppOtp(phone, otp);

    res.json({ 
      success: true, 
      message: 'تم إعادة إرسال رمز التحقق',
      debug_otp: process.env.NODE_ENV === 'development' ? otp : undefined,
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Refresh Access Token
router.post('/refresh', async (req, res) => {
  try {
    const { refreshToken } = req.body;
    
    if (!refreshToken) {
      return res.status(400).json({ success: false, message: 'Refresh token مطلوب' });
    }

    try {
      const decoded = jwt.verify(
        refreshToken, 
        process.env.JWT_REFRESH_SECRET || 'dalla3ni-refresh-secret'
      );

      if (decoded.type !== 'refresh') {
        return res.status(401).json({ success: false, message: 'Token غير صحيح' });
      }

      const user = await User.findByPk(decoded.userId);
      if (!user || !user.isActive) {
        return res.status(401).json({ success: false, message: 'المستخدم غير موجود أو غير نشط' });
      }

      const newAccessToken = generateAccessToken(user);

      res.json({
        success: true,
        accessToken: newAccessToken,
      });
    } catch (error) {
      return res.status(401).json({ success: false, message: 'Refresh token غير صحيح أو منتهي' });
    }
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Admin Login
router.post('/admin/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    // التحقق من بيانات الدخول المحددة
    const ADMIN_EMAIL = 'shehab.nad22@gmail.com';
    const ADMIN_PASSWORD = 'Ss123456789';

    // Trim and normalize input
    const normalizedEmail = email?.trim();
    const normalizedPassword = password?.trim();

    if (!normalizedEmail || !normalizedPassword) {
      return res.status(400).json({ success: false, message: 'البريد الإلكتروني وكلمة المرور مطلوبان' });
    }

    // Check credentials first
    if (normalizedEmail !== ADMIN_EMAIL || normalizedPassword !== ADMIN_PASSWORD) {
      return res.status(401).json({ success: false, message: 'بيانات الدخول غير صحيحة' });
    }

    // البحث عن المستخدم أو إنشاؤه
    let user = await User.findOne({ where: { email: ADMIN_EMAIL, role: 'admin' } });
    
    if (!user) {
      // إنشاء حساب admin إذا لم يكن موجوداً
      user = await User.create({
        name: 'Shehab Admin',
        email: ADMIN_EMAIL,
        phone: '+963000000000',
        password: ADMIN_PASSWORD, // سيتم تشفيره تلقائياً
        role: 'admin',
        isActive: true,
        isVerified: true,
      });
    } else {
      // تحديث حالة المستخدم إذا كان موجوداً
      if (!user.isActive) {
        user.isActive = true;
        await user.save();
      }
      if (!user.isVerified) {
        user.isVerified = true;
        await user.save();
      }
      
      // التحقق من كلمة المرور (في حالة كانت مشفرة مسبقاً)
      try {
        const isValid = await user.comparePassword(normalizedPassword);
        if (!isValid) {
          // إذا كانت كلمة المرور المشفرة مختلفة، قم بتحديثها
          user.password = ADMIN_PASSWORD; // سيتم تشفيرها تلقائياً
          await user.save();
        }
      } catch (compareError) {
        // إذا فشلت المقارنة، قم بتحديث كلمة المرور
        user.password = ADMIN_PASSWORD;
        await user.save();
      }
    }

    const accessToken = generateAccessToken(user);
    const refreshToken = generateRefreshToken(user);

    res.json({
      success: true,
      message: 'تم تسجيل الدخول بنجاح',
      accessToken,
      refreshToken,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
      },
    });
  } catch (error) {
    console.error('Admin login error:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;

