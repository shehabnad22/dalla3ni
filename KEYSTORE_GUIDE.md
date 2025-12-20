# Keystore Guide - دلّعني (Dalla3ni)

## 🔐 إنشاء Keystore للتطبيق

### 1. إنشاء Keystore

```bash
cd mobile-app/android
keytool -genkey -v -keystore dalla3ni-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias dalla3ni
```

### 2. معلومات Keystore

عند السؤال، أدخل:
- **Password**: (اختر كلمة مرور قوية واحفظها)
- **First and Last Name**: Dalla3ni
- **Organization**: Dalla3ni
- **Organizational Unit**: Development
- **City**: Amman
- **State**: Amman
- **Country**: JO

### 3. إعداد key.properties

أنشئ ملف `mobile-app/android/key.properties`:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=dalla3ni
storeFile=../android/dalla3ni-release-key.jks
```

⚠️ **مهم**: لا ترفع ملف `key.properties` إلى Git! أضفه إلى `.gitignore`

### 4. تحديث build.gradle

الملف `mobile-app/android/app/build.gradle` يجب أن يحتوي على:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### 5. بناء APK Release

```bash
cd mobile-app
flutter build apk --release
```

الملف الناتج:
```
build/app/outputs/flutter-apk/app-release.apk
```

### 6. بناء App Bundle (للـ Play Store)

```bash
flutter build appbundle --release
```

الملف الناتج:
```
build/app/outputs/bundle/release/app-release.aab
```

---

## 🔒 أمان Keystore

1. **احفظ كلمة المرور في مكان آمن** (مثل password manager)
2. **لا تشارك Keystore** مع أي شخص
3. **احتفظ بنسخة احتياطية** من Keystore في مكان آمن
4. **استخدم كلمات مرور قوية** (12+ حرف)

---

## 📱 بناء Debug APK (للتطوير)

```bash
cd mobile-app
flutter build apk --debug
```

الملف الناتج:
```
build/app/outputs/flutter-apk/app-debug.apk
```

---

## 🔄 تحديث Keystore

إذا فقدت Keystore أو نسيت كلمة المرور:
1. لا يمكن استعادة Keystore المفقود
2. يجب إنشاء Keystore جديد
3. سيحتاج المستخدمون إلى إعادة تثبيت التطبيق

---

**ملاحظة**: هذا الدليل للتطوير. في الإنتاج، استخدم CI/CD pipeline آمن.

