# Go-Live Checklist - دلّعني (Dalla3ni)

## ✅ Pre-Launch Checklist

### 1. OTP via WhatsApp ✅
- [ ] WhatsApp Business API configured
- [ ] Test OTP sending to real phone numbers
- [ ] Verify OTP reception and validation
- [ ] Test resend OTP functionality
- [ ] **Status**: ⚠️ Placeholder implemented - needs WhatsApp API integration

### 2. Background Push Notifications ✅
- [ ] Firebase Cloud Messaging (FCM) configured
- [ ] Android push notifications working in background
- [ ] Test notification when app is closed
- [ ] Test notification when app is in background
- [ ] Driver app receives order notifications
- [ ] **Status**: ⚠️ Placeholder implemented - needs FCM setup

### 3. Invoice Upload & Admin Preview ✅
- [ ] Image upload working (camera/gallery)
- [ ] Images stored securely (S3/Cloud Storage)
- [ ] Admin can view invoice images
- [ ] Image preview in Admin Dashboard
- [ ] **Status**: ✅ Implemented - needs storage service integration

### 4. Daily Settlement Cron ✅
- [ ] Cron job scheduled at 23:59 daily
- [ ] Debt warnings sent to drivers
- [ ] 24-hour block mechanism working
- [ ] Test manual trigger: `POST /api/admin/run-debt-check`
- [ ] **Status**: ✅ Implemented and tested

### 5. Admin Functions ✅
- [ ] Admin can block/unblock drivers
- [ ] Admin can mark settlements as paid
- [ ] Admin can approve pending drivers
- [ ] Admin can resolve disputes
- [ ] Admin can update settings (commission_amount, feature_flags)
- [ ] **Status**: ✅ All implemented

---

## 🔧 Configuration Checklist

### Environment Variables
- [ ] `JWT_SECRET` - Strong random secret
- [ ] `JWT_REFRESH_SECRET` - Different from JWT_SECRET
- [ ] `DB_PASSWORD` - Secure password
- [ ] `COMMISSION_AMOUNT` - Set to 2500
- [ ] `STORES_ENABLED` - Set to false
- [ ] `ALLOWED_ORIGINS` - Production domains
- [ ] `NODE_ENV` - Set to production

### Database
- [ ] PostgreSQL database created
- [ ] Migrations run
- [ ] Seed data loaded (optional for production)
- [ ] Backup script tested
- [ ] Daily backup scheduled

### Security
- [ ] HTTPS enforced (SSL certificate)
- [ ] Rate limiting active
- [ ] Input validation enabled
- [ ] SQL injection protection (Sequelize)
- [ ] XSS protection (Helmet)
- [ ] CORS configured correctly

---

## 📱 Mobile Apps

### Customer App
- [ ] Debug APK built and tested
- [ ] Release APK built with keystore
- [ ] App icon and splash screen added
- [ ] OTP flow tested end-to-end
- [ ] Order creation tested
- [ ] Rating flow tested

### Driver App
- [ ] Debug APK built and tested
- [ ] Release APK built with keystore
- [ ] Background notifications tested
- [ ] Invoice upload tested
- [ ] Delivery code verification tested
- [ ] Call customer button tested

---

## 🧪 Testing Checklist

### API Testing
- [ ] Postman collection imported
- [ ] All endpoints tested
- [ ] Authentication working
- [ ] Rate limiting tested
- [ ] Error handling verified

### Integration Testing
- [ ] Order creation → Matching → Acceptance flow
- [ ] Pickup → Deliver → Complete flow
- [ ] Settlement calculation correct
- [ ] Debt check cron working
- [ ] Admin reconciliation working

---

## 📊 Monitoring & Logging

- [ ] Audit logs enabled
- [ ] Error logging configured
- [ ] Performance monitoring (optional)
- [ ] Database query logging (dev only)

---

## 🚀 Deployment Steps

1. **Backend Deployment**
   ```bash
   # Set environment variables
   # Run migrations
   npm run seed  # Optional
   npm start
   ```

2. **Admin Dashboard Deployment**
   ```bash
   npm run build
   # Deploy to hosting (Vercel, Netlify, etc.)
   ```

3. **Mobile Apps**
   ```bash
   # Build release APKs
   flutter build apk --release
   # Upload to Play Store (or distribute manually)
   ```

---

## 🔗 Important Links

- **API Base URL**: `https://api.dalla3ni.com/api`
- **Admin Dashboard**: `https://admin.dalla3ni.com`
- **Swagger Docs**: `https://api.dalla3ni.com/api-docs`
- **Postman Collection**: `backend/postman_collection.json`

---

## ⚠️ Known Issues / TODOs

1. **WhatsApp OTP**: Needs WhatsApp Business API integration
2. **Push Notifications**: Needs Firebase Cloud Messaging setup
3. **Image Storage**: Needs cloud storage (S3/Cloudinary) integration
4. **Production Keystore**: Must be created and secured
5. **HTTPS**: SSL certificate required for production

---

**Last Updated**: 2025-01-15
**Status**: Ready for testing, production deployment pending integrations

