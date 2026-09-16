#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

echo "Building YTGlass (release)…"
swift build -c release

APP="YTGlass.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

cp .build/release/YTGlass "$APP/Contents/MacOS/YTGlass"
cp Info.plist "$APP/Contents/Info.plist"

if [ -f Sources/YTGlass/Resources/AppIcon.icns ]; then
    cp Sources/YTGlass/Resources/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"
fi

codesign --force --deep --sign - "$APP"

echo "Built $(pwd)/$APP"
