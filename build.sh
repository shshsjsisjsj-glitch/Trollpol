#!/bin/sh

# TrollSpeed TrollStore build (fixed for GitHub Actions)
# By ChatGPT 2025

if [ $# -ne 1 ]; then
    echo "Usage: $0 <version>"
    exit 1
fi

VERSION=$1
VERSION=${VERSION#v}

APP_NAME="TrollSpeed"
ENT_PATH="supports/entitlements.plist"

echo "🚀 Building ${APP_NAME} for TrollStore (v${VERSION})"

# 1️⃣ Clean + build project
xcodebuild clean build archive \
-scheme "${APP_NAME}" \
-project "暗区Troll.xcodeproj" \
-sdk iphoneos \
-destination 'generic/platform=iOS' \
-archivePath "${APP_NAME}" \
CODE_SIGNING_ALLOWED=NO | xcpretty

# 2️⃣ Copy entitlements
cp "${ENT_PATH}" "${APP_NAME}.xcarchive/Products"

# 3️⃣ Enter archive output
cd "${APP_NAME}.xcarchive/Products" || exit 1

# 4️⃣ Rename Applications → Payload
mv Applications Payload

# 5️⃣ Move inside the .app folder
cd Payload/${APP_NAME}.app || exit 1

# 6️⃣ Add TrollStore persistence helper (important)
touch _TrollStorePersistenceHelper

# 7️⃣ Re-sign app with TrollStore entitlements
echo "🔑 Signing app with TrollStore entitlements..."
ldid -S"../../entitlements.plist" "${APP_NAME}"

# 8️⃣ Back to archive root
cd ../../

# 9️⃣ Package into .tipa
zip -qr "${APP_NAME}.tipa" Payload

# 🔟 Move to /packages directory
mkdir -p ../../packages
mv "${APP_NAME}.tipa" "../../packages/${APP_NAME}+TrollStore_${VERSION}.tipa"

echo "✅ Build completed: packages/${APP_NAME}+TrollStore_${VERSION}.tipa"
