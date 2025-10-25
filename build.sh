#!/bin/sh

# TrollSpeed TrollStore build script (fixed)
if [ $# -ne 1 ]; then
    echo "Usage: $0 <version>"
    exit 1
fi

VERSION=$1
VERSION=${VERSION#v}

APP_NAME="TrollSpeed"
ENT_PATH="supports/entitlements.plist"

echo "🚀 Building ${APP_NAME} for TrollStore (v${VERSION})"

# Clean + build using xcodebuild
xcodebuild clean build archive \
  -scheme "${APP_NAME}" \
  -project "暗区Troll.xcodeproj" \
  -sdk iphoneos \
  -destination 'generic/platform=iOS' \
  -archivePath "${APP_NAME}" \
  CODE_SIGNING_ALLOWED=NO | xcpretty

# Copy entitlements into archive
cp "${ENT_PATH}" "${APP_NAME}.xcarchive/Products/"

# Go inside archive output
cd "${APP_NAME}.xcarchive/Products" || exit 1

# Rename directory to Payload
mv Applications Payload
cd Payload/${APP_NAME}.app || exit 1

# Add TrollStore persistence file (needed!)
touch _TrollStorePersistenceHelper

# Re-sign with ldid + TrollStore entitlements
echo "🔑 Signing with TrollStore entitlements..."
ldid -S"../../entitlements.plist" "${APP_NAME}"

cd ../../

# Compress into .tipa
zip -qr "${APP_NAME}.tipa" Payload
mkdir -p ../../packages
mv "${APP_NAME}.tipa" "../../packages/${APP_NAME}_${VERSION}.tipa"

echo "✅ ${APP_NAME}_${VERSION}.tipa ready in /packages"
