@echo off
REM Build Script for Dalla3ni APKs (Windows)
REM This script builds debug APKs for Customer and Driver apps

echo 🚀 Building Dalla3ni APKs...

cd mobile-app

REM Build Customer APK
echo 📱 Building Customer APK...
flutter build apk --debug --target=lib/main.dart
if %errorlevel% equ 0 (
    echo ✅ Customer APK built successfully
    if not exist ..\builds mkdir ..\builds
    copy build\app\outputs\flutter-apk\app-debug.apk ..\builds\dalla3ni-customer-debug.apk
) else (
    echo ❌ Customer APK build failed
    exit /b 1
)

REM Build Driver APK
echo 🛵 Building Driver APK...
flutter build apk --debug --target=lib/driver_main.dart
if %errorlevel% equ 0 (
    echo ✅ Driver APK built successfully
    copy build\app\outputs\flutter-apk\app-debug.apk ..\builds\dalla3ni-driver-debug.apk
) else (
    echo ❌ Driver APK build failed
    exit /b 1
)

echo.
echo 🎉 All APKs built successfully!
echo 📦 APKs location: builds\
echo    - dalla3ni-customer-debug.apk
echo    - dalla3ni-driver-debug.apk

pause

