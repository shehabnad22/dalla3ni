#!/bin/bash

# Build Script for Dalla3ni APKs
# This script builds debug APKs for Customer and Driver apps

echo "🚀 Building Dalla3ni APKs..."

cd mobile-app

# Build Customer APK (default)
echo "📱 Building Customer APK..."
flutter build apk --debug --target=lib/main.dart
if [ $? -eq 0 ]; then
    echo "✅ Customer APK built successfully"
    echo "   Location: build/app/outputs/flutter-apk/app-debug.apk"
    cp build/app/outputs/flutter-apk/app-debug.apk ../builds/dalla3ni-customer-debug.apk
else
    echo "❌ Customer APK build failed"
    exit 1
fi

# Build Driver APK
echo "🛵 Building Driver APK..."
flutter build apk --debug --target=lib/driver_main.dart
if [ $? -eq 0 ]; then
    echo "✅ Driver APK built successfully"
    echo "   Location: build/app/outputs/flutter-apk/app-debug.apk"
    cp build/app/outputs/flutter-apk/app-debug.apk ../builds/dalla3ni-driver-debug.apk
else
    echo "❌ Driver APK build failed"
    exit 1
fi

echo ""
echo "🎉 All APKs built successfully!"
echo "📦 APKs location: builds/"
echo "   - dalla3ni-customer-debug.apk"
echo "   - dalla3ni-driver-debug.apk"

