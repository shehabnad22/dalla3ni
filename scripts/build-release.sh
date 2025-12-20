#!/bin/bash

# Build Release APK and AAB for Dalla3ni

echo "========================================"
echo "Building Dalla3ni Release Builds"
echo "========================================"
echo

cd mobile-app

# Check if keystore exists
if [ ! -f "android/dalla3ni-release-key.jks" ]; then
    echo "❌ Keystore not found!"
    echo "Please run: scripts/create-keystore.sh first"
    exit 1
fi

# Check if key.properties exists
if [ ! -f "android/key.properties" ]; then
    echo "❌ key.properties not found!"
    exit 1
fi

echo "Step 1: Cleaning previous builds..."
flutter clean
echo

echo "Step 2: Getting dependencies..."
flutter pub get
echo

echo "Step 3: Building Release APK..."
flutter build apk --release
if [ $? -ne 0 ]; then
    echo "❌ APK build failed!"
    exit 1
fi
echo

echo "Step 4: Building Release App Bundle (AAB)..."
flutter build appbundle --release
if [ $? -ne 0 ]; then
    echo "❌ AAB build failed!"
    exit 1
fi
echo

# Create builds directory
mkdir -p ../builds

# Copy APK
cp build/app/outputs/flutter-apk/app-release.apk ../builds/dalla3ni-release.apk
echo "✅ APK copied to: builds/dalla3ni-release.apk"

# Copy AAB
cp build/app/outputs/bundle/release/app-release.aab ../builds/dalla3ni-release.aab
echo "✅ AAB copied to: builds/dalla3ni-release.aab"

echo
echo "========================================"
echo "✅ Build Complete!"
echo "========================================"
echo
echo "Files:"
echo "  - builds/dalla3ni-release.apk"
echo "  - builds/dalla3ni-release.aab"
echo

