const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const { User, Driver } = require('../models');

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
        email: `${phone}@dalla3ni.app`, // Placeholder email
        password: Math.random().toString(36), // Random password (not used for OTP auth)
        role: 'customer',
        isVerified: true,
      });
    }

    // Clear OTP
    otpStore.delete(phone);

    // Generate JWT
    const token = jwt.sign(
      { userId: user.id, role: user.role },
      process.env.JWT_SECRET || 'dalla3ni-secret',
      { expiresIn: '30d' }
    );

    res.json({
      success: true,
      message: 'تم التحقق بنجاح',
      token,
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

    // Validation
    if (!fullName || !phone || !idPhoto || !bikePhoto || !plateNumber || !areaTags?.length) {
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
      plateNumber,
      bikeModel: bikeModel || null,
      workingAreas: areaTags,
      workStartTime: availabilityStart,
      workEndTime: availabilityEnd,
      isApproved: false, // PENDING_REVIEW
      isAvailable: false,
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

    let status = 'PENDING_REVIEW';
    if (user.Driver?.isApproved) status = 'APPROVED';
    else if (user.Driver?.isBlocked) status = 'REJECTED';

    res.json({
      success: true,
      status,
      isApproved: user.Driver?.isApproved || false,
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

module.exports = router;

