@echo off
REM Create Keystore for Dalla3ni Android App
REM This script creates a keystore file for signing release builds

cd mobile-app\android

echo Creating keystore file...
echo.

keytool -genkey -v -keystore dalla3ni-release-key.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias dalla3ni -storepass dalla3ni2025 -keypass dalla3ni2025 -dname "CN=Dalla3ni, OU=Development, O=Dalla3ni, L=Amman, ST=Amman, C=JO"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ Keystore created successfully!
    echo Location: mobile-app\android\dalla3ni-release-key.jks
    echo.
    echo ⚠️  IMPORTANT: Keep this keystore file safe!
    echo    - Password: dalla3ni2025
    echo    - Alias: dalla3ni
    echo    - Do NOT commit this file to Git!
) else (
    echo.
    echo ❌ Failed to create keystore
    exit /b 1
)

cd ..\..
pause

