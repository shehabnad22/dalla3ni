# تحديث صورة Splash Screen

## 📸 الصورة المرفقة
الصورة المرفقة تحتوي على:
- **خلفية برتقالية**: `#FF6B35`
- **دائرة بيضاء متوهجة** في الوسط
- **أيقونة دراجة نارية** داخل الدائرة

## 🔄 خطوات التحديث

### 1. استبدال الصورة
1. احفظ الصورة المرفقة باسم `splash_screen.png`
2. ضعها في مجلد `mobile-app/assets/`
3. استبدل الملف القديم

### 2. تحديث الألوان
تم تحديث الألوان في:
- ✅ `lib/config/app_colors.dart` → `#FF6B35`
- ✅ `pubspec.yaml` → `color: "#FF6B35"`

### 3. إعادة بناء Splash Screen
```bash
cd mobile-app
flutter pub get
flutter pub run flutter_native_splash:create
```

### 4. إعادة بناء الأيقونات
```bash
flutter pub run flutter_launcher_icons
```

## ✅ التحقق
بعد التحديث، تأكد من:
- ✅ لون Splash Screen: `#FF6B35` (برتقالي)
- ✅ الأيقونة تظهر بشكل صحيح
- ✅ الألوان متطابقة في التطبيق

