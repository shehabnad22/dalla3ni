# بناء APK للإنتاج - دلّعني

## ✅ حالة التطبيق

- ✅ **مربوط بالباك إند**: التطبيق مربوط بـ `https://dalla3ni-backend-v2-2.onrender.com`
- ✅ **جاهز للإنتاج**: لا يوجد كود debug
- ✅ **API Calls**: جميع الـ API calls تستخدم `AppConfig.baseUrl`

## 📱 بناء APK للإنتاج

### الطريقة 1: بناء APK مباشرة (للتجربة)

```bash
cd mobile-app
flutter build apk --release
```

الـ APK سيكون في: `mobile-app/build/app/outputs/flutter-apk/app-release.apk`

### الطريقة 2: بناء APK مع تحديد URL الباك إند

```bash
cd mobile-app
flutter build apk --release --dart-define=API_BASE_URL=https://dalla3ni-backend-v2-2.onrender.com
```

### الطريقة 3: بناء App Bundle للنشر على Google Play

```bash
cd mobile-app
flutter build appbundle --release
```

الـ AAB سيكون في: `mobile-app/build/app/outputs/bundle/release/app-release.aab`

## 🔐 التوقيع (Signing) - مهم للنشر على Google Play

### 1. إنشاء Keystore

```bash
keytool -genkey -v -keystore ~/dalla3ni-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias dalla3ni
```

### 2. إنشاء ملف `key.properties`

في `mobile-app/android/key.properties`:

```
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=dalla3ni
storeFile=../dalla3ni-key.jks
```

### 3. تحديث `build.gradle.kts`

أضف في `android` block:

```kotlin
signingConfigs {
    create("release") {
        val keystorePropertiesFile = rootProject.file("key.properties")
        val keystoreProperties = Properties()
        keystoreProperties.load(FileInputStream(keystorePropertiesFile))
        
        keyAlias = keystoreProperties["keyAlias"] as String
        keyPassword = keystoreProperties["keyPassword"] as String
        storeFile = file(keystoreProperties["storeFile"] as String)
        storePassword = keystoreProperties["storePassword"] as String
    }
}

buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
    }
}
```

## 📋 متطلبات النشر على Google Play

### 1. معلومات التطبيق
- ✅ **اسم التطبيق**: دلّعني
- ✅ **Package Name**: `com.example.dalla3ni` (يجب تغييره لشيء فريد مثل `com.dalla3ni.app`)
- ✅ **Version**: `1.0.0+1`
- ✅ **Min SDK**: 21 (Android 5.0+)
- ✅ **Target SDK**: 34 (Android 14)

### 2. الأذونات المطلوبة
- ✅ **Location**: للعثور على موقع المستخدم
- ✅ **Camera**: لالتقاط صور الفواتير
- ✅ **Storage**: لحفظ الصور

### 3. الأيقونات والصور
- ✅ **App Icon**: موجود في `assets/icon.png.png`
- ✅ **Splash Screen**: موجود في `assets/splash_screen.png`

### 4. تغيير Package Name (مهم!)

في `android/app/build.gradle.kts`:

```kotlin
defaultConfig {
    applicationId = "com.dalla3ni.app" // غيّر من com.example.dalla3ni
    // ...
}
```

## 🚀 خطوات النشر على Google Play

1. **إنشاء حساب Google Play Developer** ($25 لمرة واحدة)
2. **إنشاء تطبيق جديد** في Google Play Console
3. **رفع App Bundle** (AAB) وليس APK
4. **ملء معلومات التطبيق** (الوصف، الصور، إلخ)
5. **إرسال للمراجعة**

## ⚠️ ملاحظات مهمة

1. **تغيير Package Name**: يجب تغيير `com.example.dalla3ni` إلى شيء فريد
2. **Keystore**: احفظه في مكان آمن - لا يمكن استبداله!
3. **Version Code**: يجب زيادته مع كل تحديث
4. **Privacy Policy**: مطلوب إذا كان التطبيق يجمع بيانات

## 🔗 روابط مهمة

- **Backend URL**: https://dalla3ni-backend-v2-2.onrender.com
- **Admin Panel**: https://dalla3ni-admin-v2-osdy.onrender.com
- **API Docs**: https://dalla3ni-backend-v2-2.onrender.com/api-docs

## ✅ التحقق من الربط

للتأكد من أن التطبيق مربوط بالباك إند:

1. افتح التطبيق
2. حاول تسجيل الدخول
3. تحقق من أن الطلبات تظهر في Admin Panel

