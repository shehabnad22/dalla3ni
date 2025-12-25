const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const { User, Driver } = require('../models');
const { generateAccessToken, generateRefreshToken, authenticate } = require('../middleware/auth');
const { uploadMiddleware } = require('../middleware/upload');

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
      debug_otp: otp, // Always return for MVP auto-verification
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
      // Check if user is blocked
      if (user.isBlocked) {
        return res.status(403).json({
          success: false,
          message: 'لقد خالفت معايير الاستخدام وتم حظرك',
          isBlocked: true,
          blockReason: user.blockReason || 'تم الحظر من قبل الإدارة'
        });
      }

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
router.post('/driver/register', uploadMiddleware([
  { name: 'idPhoto', maxCount: 1 },
  { name: 'bikePhoto', maxCount: 1 }
]), async (req, res) => {
  try {
    const {
      fullName,
      phone,
      plateNumber,
      bikeModel,
      areaTags,
      availabilityStart,
      availabilityEnd,
    } = req.body;

    const idPhotoFile = req.files['idPhoto'] ? req.files['idPhoto'][0] : null;
    const bikePhotoFile = req.files['bikePhoto'] ? req.files['bikePhoto'][0] : null;

    // Validation - Make plateNumber optional for MVP
    if (!fullName || !phone || !idPhotoFile || !bikePhotoFile || !areaTags) {
      return res.status(400).json({ success: false, message: 'جميع الحقول المطلوبة يجب ملؤها' });
    }

    let parsedAreaTags = areaTags;
    if (typeof areaTags === 'string') {
      try {
        parsedAreaTags = JSON.parse(areaTags);
      } catch (e) {
        parsedAreaTags = areaTags.split(',').map(s => s.trim());
      }
    }

    // Normalize phone number (remove whitespace, leading 0 if present in +963 format)
    const cleanPhone = phone.toString().trim().replace(/\s+/g, '');
    let finalPhone = cleanPhone;

    // Ensure strict +963 format
    if (finalPhone.startsWith('09')) {
      finalPhone = '+963' + finalPhone.substring(1);
    } else if (finalPhone.startsWith('9')) {
      finalPhone = '+963' + finalPhone;
    } else if (finalPhone.startsWith('+9630')) {
      // Fix double prefix/zero issue if frontend sends +9630...
      finalPhone = '+963' + finalPhone.substring(5); // +96309... -> +9639...
    } else if (finalPhone.startsWith('00963')) {
      finalPhone = '+' + finalPhone.substring(2);
    }

    // Check if phone or email already exists
    const existingUser = await User.findOne({
      where: {
        [require('sequelize').Op.or]: [
          { phone: finalPhone },
          { email: `driver_${finalPhone}@dalla3ni.app` }
        ]
      }
    });

    if (existingUser) {
      // If user exists but has no driver profile, we could allow them to continue...
      // But for now, just return error to be safe/simple
      return res.status(400).json({ success: false, message: 'رقم الهاتف مسجل مسبقاً' });
    }

    // Create user with driver role
    const user = await User.create({
      name: fullName,
      phone: finalPhone,
      email: `driver_${finalPhone}@dalla3ni.app`,
      password: Math.random().toString(36),
      role: 'driver',
      isVerified: false, // Will be verified after admin approval
    });

    // Create driver profile with PENDING_REVIEW status
    const driver = await Driver.create({
      userId: user.id,
      idImage: `uploads/drivers/${idPhotoFile.filename}`,
      motorImage: `uploads/drivers/${bikePhotoFile.filename}`,
      plateNumber: plateNumber || 'N/A',
      bikeModel: bikeModel || null,
      workingAreas: parsedAreaTags,
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
    if (error.name === 'SequelizeUniqueConstraintError') {
      return res.status(400).json({ success: false, message: 'رقم الهاتف أو البريد الإلكتروني مسجل مسبقاً' });
    }
    console.error('Driver Register Error:', error);
    res.status(500).json({ success: false, error: 'حدث خطأ في الخادم أثناء التسجيل: ' + error.message });
  }
});

// Get Current User (Global Auth Check)
router.get('/me', authenticate, async (req, res) => {
  try {
    // User is already attached by middleware and checked for blocking
    const user = req.user;

    res.json({
      success: true,
      user: {
        id: user.id,
        name: user.name,
        phone: user.phone,
        email: user.email,
        role: user.role,
      },
      isBlocked: false // Middleware guarantees this
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

    // Check if user is blocked
    if (user.isBlocked) {
      return res.status(403).json({
        success: false,
        message: 'لقد خالفت معايير الاستخدام وتم حظرك',
        isBlocked: true,
        blockReason: user.blockReason || 'تم الحظر من قبل الإدارة'
      });
    }

    // Check if driver is blocked
    if (user.Driver?.isBlocked) {
      return res.status(403).json({
        success: false,
        message: 'لقد خالفت معايير الاستخدام وتم حظرك',
        isBlocked: true,
        blockReason: user.Driver.blockReason || 'تم الحظر من قبل الإدارة'
      });
    }

    const status = user.Driver?.accountStatus || 'PENDING_REVIEW';

    res.json({
      success: true,
      status,
      isApproved: user.Driver?.isApproved || false,
      accountStatus: status,
      driverId: user.Driver?.id,
      isBlocked: false,
    });
  } catch (error) {
    console.error('Driver status check error:', error);
    res.status(500).json({
      success: false,
      message: 'حدث خطأ أثناء التحقق من حالة السائق',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Driver Login (for approved drivers)
router.post('/driver/login', async (req, res) => {
  try {
    const { phone } = req.body;

    // 1. Input Validation
    if (!phone) {
      return res.status(400).json({
        success: false,
        message: 'رقم الهاتف مطلوب'
      });
    }

    // Normalize phone (remove whitespace)
    const cleanPhone = phone.toString().trim().replace(/\s+/g, '');

    // 2. Database Query
    const user = await User.findOne({
      where: { phone: cleanPhone, role: 'driver' },
      include: [{ model: Driver }],
    });

    // 3. Check User Existence
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'لم يتم العثور على حساب بهذا الرقم'
      });
    }

    // 4. Check Global Blocking (User Level)
    if (user.isBlocked) {
      return res.status(403).json({
        success: false,
        message: 'لقد خالفت معايير الاستخدام وتم حظرك',
        isBlocked: true,
        blockReason: user.blockReason || 'تم الحظر من قبل الإدارة'
      });
    }

    // 5. Check Driver Profile Existence
    if (!user.Driver) {
      // Edge case: User exists but Driver profile was deleted or not created
      return res.status(400).json({
        success: false,
        message: 'لم يتم العثور على ملف السائق. يرجى التسجيل أولاً'
      });
    }

    // 6. Check Driver Blocking (Driver Level)
    if (user.Driver.isBlocked) {
      return res.status(403).json({
        success: false,
        message: 'لقد خالفت معايير الاستخدام وتم حظرك',
        isBlocked: true,
        blockReason: user.Driver.blockReason || 'تم الحظر من قبل الإدارة'
      });
    }

    // 7. Check Approval Status
    if (!user.Driver.isApproved || user.Driver.accountStatus !== 'APPROVED') {
      return res.status(403).json({
        success: false,
        message: 'حسابك قيد المراجعة. سيتم التواصل معك قريباً',
        accountStatus: user.Driver.accountStatus || 'PENDING_REVIEW'
      });
    }

    // 8. Check Active Status
    if (!user.isActive) {
      return res.status(403).json({
        success: false,
        message: 'حسابك غير نشط. يرجى التواصل مع الدعم'
      });
    }

    // 9. Generate Tokens
    const accessToken = generateAccessToken(user);
    const refreshToken = generateRefreshToken(user);

    // 10. Success Response
    res.json({
      success: true,
      message: 'تم تسجيل الدخول بنجاح',
      accessToken,
      refreshToken,
      user: {
        id: user.id,
        name: user.name,
        phone: user.phone,
        role: user.role,
      },
      driver: {
        id: user.Driver.id,
        isAvailable: user.Driver.isAvailable,
        accountStatus: user.Driver.accountStatus,
      },
      driverId: user.Driver.id,
    });

  } catch (error) {
    console.error('Driver login error:', error);
    // Return structured error, never 500 crash dump
    res.status(400).json({
      success: false,
      message: 'حدث خطأ أثناء تسجيل الدخول',
      developer_error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
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

// Check user ban status (for app startup)
router.get('/check-ban/:phone', async (req, res) => {
  try {
    const { phone } = req.params;
    const { role } = req.query; // 'customer' or 'driver'

    if (!phone) {
      return res.status(400).json({
        success: false,
        message: 'رقم الهاتف مطلوب'
      });
    }

    const user = await User.findOne({
      where: { phone, role: role || 'customer' },
      include: role === 'driver' ? [{ model: Driver }] : [],
    });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'المستخدم غير موجود'
      });
    }

    // Check if user is blocked
    if (user.isBlocked) {
      return res.json({
        success: true,
        isBlocked: true,
        message: 'لقد خالفت معايير الاستخدام وتم حظرك',
        blockReason: user.blockReason || 'تم الحظر من قبل الإدارة'
      });
    }

    // For drivers, check driver-level block
    if (role === 'driver' && user.Driver?.isBlocked) {
      return res.json({
        success: true,
        isBlocked: true,
        message: 'لقد خالفت معايير الاستخدام وتم حظرك',
        blockReason: user.Driver.blockReason || 'تم الحظر من قبل الإدارة'
      });
    }

    // User is not blocked
    res.json({
      success: true,
      isBlocked: false,
      user: {
        id: user.id,
        name: user.name,
        phone: user.phone,
        role: user.role,
      }
    });
  } catch (error) {
    console.error('Ban check error:', error);
    res.status(500).json({
      success: false,
      message: 'حدث خطأ أثناء التحقق من حالة المستخدم',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
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
    const normalizedEmail = email?.trim()?.toLowerCase();
    const normalizedPassword = password?.trim();

    if (!normalizedEmail || !normalizedPassword) {
      return res.status(400).json({ success: false, message: 'البريد الإلكتروني وكلمة المرور مطلوبان' });
    }

    // Check credentials first (case-insensitive email)
    if (normalizedEmail !== ADMIN_EMAIL.toLowerCase() || normalizedPassword !== ADMIN_PASSWORD) {
      return res.status(401).json({ success: false, message: 'بيانات الدخول غير صحيحة' });
    }

    // البحث عن المستخدم أو إنشاؤه
    let user = await User.findOne({ where: { email: ADMIN_EMAIL, role: 'admin' } });

    if (!user) {
      // إنشاء حساب admin إذا لم يكن موجوداً
      try {
        user = await User.create({
          name: 'Shehab Admin',
          email: ADMIN_EMAIL,
          phone: '+963000000000',
          password: ADMIN_PASSWORD, // سيتم تشفيره تلقائياً
          role: 'admin',
          isActive: true,
          isVerified: true,
        });
      } catch (createError) {
        console.error('Error creating admin user:', createError);
        // Try to find again in case of race condition
        user = await User.findOne({ where: { email: ADMIN_EMAIL, role: 'admin' } });
        if (!user) {
          throw createError;
        }
      }
    }

    // Ensure user is active and verified
    if (!user.isActive || !user.isVerified) {
      user.isActive = true;
      user.isVerified = true;
      await user.save();
    }

    // Generate tokens
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
    res.status(500).json({
      success: false,
      message: 'حدث خطأ أثناء تسجيل الدخول',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

module.exports = router;

