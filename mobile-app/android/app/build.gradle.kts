plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.dalla3ni.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.dalla3ni.app"
        minSdk = flutter.minSdkVersion // Android 5.0+
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // Enable multidex for smaller APK
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // Enable code shrinking and resource shrinking for smaller APK
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            // Obfuscate code for security
            isDebuggable = false
            // Signing with the debug keys for now, so `flutter run --release` works.
            // TODO: Add your own signing config for production builds
            signingConfig = signingConfigs.getByName("debug")
        }
        debug {
            // Disable obfuscation in debug builds
            isMinifyEnabled = false
            isShrinkResources = false
            isDebuggable = true
        }
    }
}

flutter {
    source = "../.."
}
