# 🔧 إصلاح مشكلة Splash Screen

## ❌ المشكلة
```
The file "assets/splash_screen.png" set as the parameter "image" was not found.
```

## ✅ الحل

### الخطوة 1: إضافة صورة Splash Screen

ضع الصورة المرفقة (الدراجة النارية على خلفية برتقالية) في:

```
mobile-app/assets/splash_screen.png
```

**المواصفات المطلوبة:**
- **الاسم**: `splash_screen.png` (يجب أن يكون PNG)
- **الحجم الموصى به**: 1080x1920 px (9:16 aspect ratio)
- **الخلفية**: برتقالي `#FF6B35`
- **التنسيق**: PNG

### الخطوة 2: تفعيل الصورة في pubspec.yaml

بعد إضافة الصورة، افتح `pubspec.yaml` وفك التعليق عن السطور:

```yaml
flutter_native_splash:
  color: "#FF6B35"
  image: assets/splash_screen.png  # ← فك التعليق
  android: true
  ios: true
  android_12:
    color: "#FF6B35"
    image: assets/splash_screen.png  # ← فك التعليق
  fullscreen: true
  android_gravity: center
  ios_content_mode: center
```

### الخطوة 3: إعادة بناء Splash Screen

```bash
cd mobile-app
flutter pub get
flutter pub run flutter_native_splash:create
```

## 📝 ملاحظات

- الملف الحالي `splash_screen.png.jpg` له امتداد خاطئ
- يجب إعادة تسميته إلى `splash_screen.png` أو إضافة ملف جديد
- إذا لم تكن الصورة متوفرة، يمكن استخدام اللون البرتقالي فقط (تم تعطيل الصورة مؤقتاً)

## ✅ بعد إضافة الصورة

بعد إضافة `splash_screen.png` وتفعيلها في `pubspec.yaml`:

```bash
flutter pub run flutter_native_splash:create
flutter clean
flutter run
```

