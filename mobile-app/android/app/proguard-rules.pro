# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep custom classes (but obfuscate internal methods)
-keep class com.dalla3ni.app.** { *; }
-keepclassmembers class com.dalla3ni.app.** {
    public *;
}

# Obfuscate package names
-keepnames class com.dalla3ni.app.**

# Google Play Core (for deferred components - optional feature)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# Flutter deferred components
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# Remove logging in release builds
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# Optimize code
-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-verbose

# Remove debug information
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# ====================================
# HTTP and Network Configuration
# ====================================
# Keep Dart HTTP and IO classes to prevent SocketException
-keep class dart.io.** { *; }
-keep class dart.async.** { *; }
-keep class dart.core.** { *; }
-keepclassmembers class dart.io.** {
    *;
}

# Keep HTTP client classes
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.plugins.**

# Keep native network methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Prevent obfuscation of network-related classes
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Keep Socket and network classes
-keep class java.net.** { *; }
-keep class javax.net.ssl.** { *; }
-keep class java.security.** { *; }

# Keep OkHttp (if used by Flutter plugins)
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# Keep exceptions for better error messages
-keepattributes Exceptions
-keepattributes Signature
-keepattributes *Annotation*

