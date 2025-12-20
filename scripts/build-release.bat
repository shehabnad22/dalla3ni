@echo off
REM Build Release APK and AAB for Dalla3ni

echo ========================================
echo Building Dalla3ni Release Builds
echo ========================================
echo.

cd mobile-app

REM Check if keystore exists
if not exist "android\dalla3ni-release-key.jks" (
    echo ❌ Keystore not found!
    echo Please run: scripts\create-keystore.bat first
    pause
    exit /b 1
)

REM Check if key.properties exists
if not exist "android\key.properties" (
    echo ❌ key.properties not found!
    pause
    exit /b 1
)

echo Step 1: Cleaning previous builds...
call flutter clean
echo.

echo Step 2: Getting dependencies...
call flutter pub get
echo.

echo Step 3: Building Release APK...
call flutter build apk --release
if %ERRORLEVEL% NEQ 0 (
    echo ❌ APK build failed!
    pause
    exit /b 1
)
echo.

echo Step 4: Building Release App Bundle (AAB)...
call flutter build appbundle --release
if %ERRORLEVEL% NEQ 0 (
    echo ❌ AAB build failed!
    pause
    exit /b 1
)
echo.

REM Create builds directory
if not exist "..\builds" mkdir ..\builds

REM Copy APK
copy "build\app\outputs\flutter-apk\app-release.apk" "..\builds\dalla3ni-release.apk"
echo ✅ APK copied to: builds\dalla3ni-release.apk

REM Copy AAB
copy "build\app\outputs\bundle\release\app-release.aab" "..\builds\dalla3ni-release.aab"
echo ✅ AAB copied to: builds\dalla3ni-release.aab

echo.
echo ========================================
echo ✅ Build Complete!
echo ========================================
echo.
echo Files:
echo   - builds\dalla3ni-release.apk
echo   - builds\dalla3ni-release.aab
echo.
pause

