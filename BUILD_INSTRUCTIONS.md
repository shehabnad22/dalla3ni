# 🔨 تعليمات البناء - Build Instructions

## 📱 بناء تطبيق الموبايل

### المتطلبات
- Flutter SDK 3.0.0+
- Android Studio
- Java JDK
- Keystore file

### الخطوة 1: إنشاء Keystore (للمرة الأولى فقط)

**Windows:**
```bash
scripts\create-keystore.bat
```

**Linux/Mac:**
```bash
chmod +x scripts/create-keystore.sh
./scripts/create-keystore.sh
```

### الخطوة 2: بناء APK و AAB

**Windows:**
```bash
scripts\build-release.bat
```

**Linux/Mac:**
```bash
chmod +x scripts/build-release.sh
./scripts/build-release.sh
```

### الملفات الناتجة
- `builds/dalla3ni-release.apk` - للتثبيت المباشر
- `builds/dalla3ni-release.aab` - لـ Google Play Store

---

## 🖥️ بناء Admin Dashboard

### المتطلبات
- Node.js 16+
- npm

### البناء

**Windows:**
```bash
scripts\build-admin.bat
```

**Linux/Mac:**
```bash
chmod +x scripts/build-admin.sh
./scripts/build-admin.sh
```

### الملفات الناتجة
- `admin-dashboard/build/` - ملفات الإنتاج الجاهزة

### تشغيل محلي

```bash
cd admin-dashboard

# Option 1: serve
npx serve -s build -p 3001

# Option 2: http-server
npx http-server build -p 3001

# Option 3: Python
cd build
python -m http.server 3001
```

**الوصول**: http://localhost:3001

---

## 🔧 البناء اليدوي

### Mobile App

```bash
cd mobile-app

# Clean
flutter clean

# Get dependencies
flutter pub get

# Build APK
flutter build apk --release

# Build AAB
flutter build appbundle --release
```

### Admin Dashboard

```bash
cd admin-dashboard

# Install dependencies
npm install

# Build
npm run build
```

---

## ✅ التحقق من البناء

### APK
```bash
# Check file exists
ls -lh builds/dalla3ni-release.apk

# Verify signature (Android)
jarsigner -verify -verbose -certs builds/dalla3ni-release.apk
```

### AAB
```bash
# Check file exists
ls -lh builds/dalla3ni-release.aab

# Verify (requires bundletool)
# Download bundletool from: https://github.com/google/bundletool
java -jar bundletool.jar build-apks --bundle=builds/dalla3ni-release.aab --output=test.apks
```

---

## 🐛 حل المشاكل

### خطأ: Keystore not found
- تأكد من تشغيل `create-keystore.bat` أو `.sh` أولاً
- تحقق من وجود `mobile-app/android/dalla3ni-release-key.jks`

### خطأ: key.properties not found
- تأكد من وجود `mobile-app/android/key.properties`
- تحقق من محتوى الملف

### خطأ: Build failed
- تحقق من Flutter SDK: `flutter doctor`
- تأكد من تثبيت Android SDK
- راجع الأخطاء في console

---

**جاهز للبناء! 🚀**

