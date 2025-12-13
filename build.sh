#!/bin/bash

set -e

echo "🔨 Building AutoClick..."

# Clean previous build
rm -rf build
mkdir -p build/AutoClick.app/Contents/MacOS
mkdir -p build/AutoClick.app/Contents/Resources

# Copy Info.plist
cp Info.plist build/AutoClick.app/Contents/

# Compile Swift sources
echo "📦 Compiling Swift sources..."
swiftc \
    -o build/AutoClick.app/Contents/MacOS/AutoClick \
    -target arm64-apple-macosx11.0 \
    -sdk $(xcrun --show-sdk-path) \
    -framework Cocoa \
    -framework ApplicationServices \
    -O \
    Sources/AutoClicker.swift \
    Sources/MainViewController.swift \
    Sources/AppDelegate.swift \
    Sources/main.swift

# Sign the app (ad-hoc signing for local use)
echo "🔐 Signing app..."
codesign --force --deep --sign - build/AutoClick.app

echo "✅ Build complete!"
echo ""
echo "📍 App location: build/AutoClick.app"
echo ""
echo "⚠️  IMPORTANT: Before running, grant Accessibility permissions:"
echo "   System Settings → Privacy & Security → Accessibility → Enable AutoClick"
echo ""
echo "🚀 To run: open build/AutoClick.app"
