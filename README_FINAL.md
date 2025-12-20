# 🚀 Dalla3ni - Complete Project README

## 📱 تطبيق دلّعني - خدمة التوصيل السريع

مشروع متكامل لتطبيق توصيل يشمل:
- تطبيق موبايل (Flutter) للزبائن والسائقين
- لوحة تحكم إدارية (React)
- API خلفي (Node.js/Express)

---

## 🎯 Quick Start

### 1. إنشاء Keystore (للمرة الأولى فقط)

```bash
# Windows
scripts\create-keystore.bat

# Linux/Mac
chmod +x scripts/create-keystore.sh
./scripts/create-keystore.sh
```

### 2. استبدال الأصول (Assets)

**مهم:** قبل البناء، استبدل:
- `mobile-app/assets/icon.png` - أيقونة التطبيق
- `mobile-app/assets/splash_screen.png` - شاشة البداية

### 3. بناء التطبيق

```bash
# Windows
scripts\build-release.bat

# Linux/Mac
chmod +x scripts/build-release.sh
./scripts/build-release.sh
```

### 4. بناء لوحة التحكم

```bash
# Windows
scripts\build-admin.bat

# Linux/Mac
chmod +x scripts/build-admin.sh
./scripts/build-admin.sh
```

### 5. تشغيل Backend

```bash
cd backend
npm install
npm run dev
```

### 6. تشغيل Admin Dashboard

```bash
cd admin-dashboard
npx serve -s build -p 3001
```

---

## 📁 Project Structure

```
Dalla3ni/
├── mobile-app/          # Flutter mobile app
├── admin-dashboard/     # React admin panel
├── backend/             # Node.js API
├── builds/              # Build outputs
├── scripts/             # Build scripts
└── Documentation/       # All guides
```

---

## 📚 Documentation

- **DELIVERY_SUMMARY.md** - ملخص التسليم
- **BUILD_INSTRUCTIONS.md** - تعليمات البناء
- **DEPLOYMENT_GUIDE.md** - دليل النشر
- **GOOGLE_PLAY_GUIDE.md** - دليل Google Play
- **KEYSTORE_GUIDE.md** - دليل Keystore
- **FINAL_DELIVERY.md** - التسليم النهائي

---

## ✅ Status

- ✅ Project configured
- ✅ Build scripts ready
- ✅ Documentation complete
- ⚠️ Assets need replacement
- ⚠️ Builds need generation

---

**Ready to build! 🚀**

