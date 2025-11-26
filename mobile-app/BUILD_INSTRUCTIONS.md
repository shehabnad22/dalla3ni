# دلّعني - Dalla3ni
## تعليمات البناء

### 1. إنشاء Keystore

```bash
cd android
keytool -genkey -v -keystore dalla3ni-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias dalla3ni
```

عند السؤال، أدخل:
- **Password**: dalla3ni2025
- **First and Last Name**: Dalla3ni
- **Organization**: Dalla3ni
- **Country**: JO

### 2. إضافة الأيقونة و Splash

ضع الصور في مجلد `assets/`:
- `icon.png` - أيقونة التطبيق (1024x1024 px)
- `icon_foreground.png` - الأيقونة الأمامية للـ Adaptive Icon
- `splash.png` - صورة شاشة البداية (512x512 px)

ثم شغّل:
```bash
flutter pub get
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash:create
```

### 3. بناء APK Release

```bash
flutter build apk --release
```

الملف الناتج:
```
build/app/outputs/flutter-apk/app-release.apk
```

### 4. بناء App Bundle (للـ Play Store)

```bash
flutter build appbundle --release
```

الملف الناتج:
```
build/app/outputs/bundle/release/app-release.aab
```

---

## معلومات التطبيق

- **اسم التطبيق**: دلّعني (Dalla3ni)
- **Package Name**: com.dalla3ni.dalla3ni
- **Version**: 1.0.0+1

## الأذونات المطلوبة

- INTERNET
- ACCESS_FINE_LOCATION
- ACCESS_COARSE_LOCATION
- CALL_PHONE
- CAMERA
- READ/WRITE_EXTERNAL_STORAGE

