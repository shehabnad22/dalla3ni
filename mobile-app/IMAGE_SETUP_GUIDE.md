# دليل إعداد الأيقونات وشاشة البداية

## 📱 الأيقونات (App Icons)

### 1. إعداد الأيقونة الرئيسية

يجب وضع الأيقونة المرفقة في المجلدات التالية:

```
mobile-app/android/app/src/main/res/
├── mipmap-mdpi/
│   └── ic_launcher.png (48x48 px)
├── mipmap-hdpi/
│   └── ic_launcher.png (72x72 px)
├── mipmap-xhdpi/
│   └── ic_launcher.png (96x96 px)
├── mipmap-xxhdpi/
│   └── ic_launcher.png (144x144 px)
└── mipmap-xxxhdpi/
    └── ic_launcher.png (192x192 px)
```

**ملاحظة:** الأيقونة المرفقة (shopping bag with speed lines) يجب تحويلها إلى هذه الأحجام.

### 2. إعداد Adaptive Icon (Android 8.0+)

لإنشاء Adaptive Icon، تحتاج إلى:

1. **Foreground Image** (الأيقونة نفسها):
   - الحجم: 108x108 dp (432x432 px للـ xxxhdpi)
   - يجب أن تكون الأيقونة في وسط الصورة مع padding مناسب
   - الخلفية شفافة

2. **Background Color**:
   - تم ضبطه على `#6C63FF` في `pubspec.yaml`

ضع الملفات في:
```
mobile-app/android/app/src/main/res/
├── mipmap-anydpi-v26/
│   ├── ic_launcher.xml
│   └── ic_launcher_round.xml
├── mipmap-mdpi/
│   └── ic_launcher_foreground.png (108x108 px)
├── mipmap-hdpi/
│   └── ic_launcher_foreground.png (162x162 px)
├── mipmap-xhdpi/
│   └── ic_launcher_foreground.png (216x216 px)
├── mipmap-xxhdpi/
│   └── ic_launcher_foreground.png (324x324 px)
└── mipmap-xxxhdpi/
    └── ic_launcher_foreground.png (432x432 px)
```

### 3. استخدام flutter_launcher_icons

بعد وضع الأيقونة في `assets/icon.png`، قم بتشغيل:

```bash
cd mobile-app
flutter pub get
flutter pub run flutter_launcher_icons
```

سيتم إنشاء جميع الأحجام تلقائياً.

---

## 🎨 شاشة البداية (Splash Screen)

### 1. إعداد صورة Splash Screen

ضع صورة شاشة البداية المرفقة (motorcycle icon) في:

```
mobile-app/assets/splash_screen.png
```

**المواصفات:**
- الحجم الموصى به: 1080x1920 px (9:16 aspect ratio)
- الخلفية: برتقالي (#FF6B35) كما في الصورة المرفقة
- التنسيق: PNG مع خلفية شفافة أو خلفية برتقالية

### 2. إعداد Android Native Splash

تم تكوين `flutter_native_splash` في `pubspec.yaml`:

```yaml
flutter_native_splash:
  color: "#FF6B35"
  image: assets/splash_screen.png
  android: true
  ios: true
```

بعد وضع الصورة، قم بتشغيل:

```bash
cd mobile-app
flutter pub get
flutter pub run flutter_native_splash:create
```

### 3. إعداد Drawable Resources

تم إنشاء `launch_background.xml` في:
```
mobile-app/android/app/src/main/res/drawable/launch_background.xml
```

إذا كنت تريد استخدام صورة مباشرة بدلاً من asset، ضعها في:
```
mobile-app/android/app/src/main/res/drawable-nodpi/splash_screen.png
```

---

## 📝 خطوات التنفيذ

### الخطوة 1: إضافة الصور

1. انسخ الأيقونة المرفقة إلى `mobile-app/assets/icon.png`
2. انسخ صورة شاشة البداية إلى `mobile-app/assets/splash_screen.png`

### الخطوة 2: إنشاء الأيقونات

```bash
cd mobile-app
flutter pub get
flutter pub run flutter_launcher_icons
```

### الخطوة 3: إنشاء Splash Screen

```bash
flutter pub run flutter_native_splash:create
```

### الخطوة 4: اختبار

```bash
flutter run
```

---

## ✅ التحقق

بعد إضافة الصور وتشغيل الأوامر:

1. **الأيقونة:**
   - يجب أن تظهر الأيقونة الجديدة على الشاشة الرئيسية
   - تحقق من جميع أحجام الشاشات

2. **Splash Screen:**
   - يجب أن تظهر صورة شاشة البداية عند فتح التطبيق
   - يجب أن تبقى لمدة 2-3 ثوانٍ قبل الانتقال إلى شاشة اختيار الدور

3. **النصوص:**
   - جميع النصوص يجب أن تُحمّل من `assets/texts.json`
   - تحقق من أن جميع الأزرار والعناوين تستخدم النصوص الصحيحة

---

## 🔧 استكشاف الأخطاء

### الأيقونة لا تظهر:
- تأكد من تشغيل `flutter pub run flutter_launcher_icons`
- احذف التطبيق وأعد تثبيته
- تحقق من أن `pubspec.yaml` يحتوي على إعدادات `flutter_launcher_icons`

### Splash Screen لا تظهر:
- تأكد من وضع الصورة في `assets/splash_screen.png`
- قم بتشغيل `flutter pub run flutter_native_splash:create`
- تحقق من `launch_background.xml` في `res/drawable/`

### النصوص لا تظهر:
- تأكد من أن `assets/texts.json` موجود
- تحقق من أن `TextService.loadTexts()` يتم استدعاؤه في `main()`
- تحقق من console للأخطاء

