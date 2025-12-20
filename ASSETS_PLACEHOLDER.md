# Assets Placeholder - دلّعني (Dalla3ni)

## 📱 Mobile App Assets

### الملفات المطلوبة

ضع الملفات التالية في مجلد `mobile-app/assets/`:

1. **icon.png** (1024x1024 px)
   - أيقونة التطبيق الرئيسية
   - يجب أن تكون بصيغة PNG بخلفية شفافة أو ملونة

2. **icon_foreground.png** (512x512 px)
   - الأيقونة الأمامية للـ Adaptive Icon (Android)
   - يجب أن تكون في المنتصف مع هامش 20% من كل جانب

3. **splash.png** (512x512 px)
   - صورة شاشة البداية (Splash Screen)
   - يجب أن تكون في المنتصف على خلفية ملونة

### بعد إضافة الأيقونات

```bash
cd mobile-app
flutter pub get
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash:create
```

### ملاحظات

- جميع الصور يجب أن تكون بصيغة PNG
- الألوان الموصى بها: `#6C63FF` (البنفسجي الرئيسي)
- خلفية Splash Screen: `#6C63FF`

---

**ملاحظة**: حالياً الملفات غير موجودة. سيتم إضافتها لاحقاً.

