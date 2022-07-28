#!/bin/sh

# Package a .app into a .dmg, adding the correct icons
# This script requires create-dmg
# get it with `brew install create-dmg`
# This script is meant to be run with fastlane, and assumes a .app is present in the .build folder!

ROOT=$(git rev-parse --show-toplevel)
BUILD_TOOLS="$ROOT/BuildTools"
ICONSET_DIR="$BUILD_TOOLS/AppIcon.iconset"
VOLNAME="Transitions Installer"
APP_NAME="Transitions.app"
DMG_PATH="$ROOT/.build/Transitions-Installer.dmg"
APP_RELEASE_PATH="$ROOT/.build/Transitions.app"
INSTALLER_BACKGROUND="$BUILD_TOOLS/installer_background.png"

echo '🗂 Creating iconset folder'
test -f $ICONSET_DIR && rm $ICONSET_DIR
mkdir -p $ICONSET_DIR

echo '📝 Copying app icons to iconset folder'
FILENAMES=("icon_16x16.png" "icon_16x16@2x.png" "icon_32x32.png" "icon_32x32@2x.png" "icon_128x128.png" "icon_128x128@2x.png" "icon_256x256.png" "icon_256x256@2x.png" "icon_512x512.png" "icon_512x512@2x.png")
for filename in "${FILENAMES[@]}" 
do
    cp "$ROOT/Transitions/Assets.xcassets/AppIcon.appiconset/$filename" "$ICONSET_DIR"
done

echo '🌠 Creating iconset'
iconutil --convert icns $ICONSET_DIR
ICNS_PATH="$BUILD_TOOLS/AppIcon.icns"

echo '📦 Create DMG'

test -f $DMG_PATH && rm $DMG_PATH
create-dmg \
  --volname "$VOLNAME" \
  --volicon $ICNS_PATH \
  --window-pos 200 120 \
  --window-size 800 400 \
  --icon-size 100 \
  --icon "$APP_NAME" 200 190 \
  --hide-extension "$APP_NAME" \
  --app-drop-link 600 185 \
  --background $INSTALLER_BACKGROUND \
  $DMG_PATH \
  $APP_RELEASE_PATH

echo '␡ Cleaning up'
rm -r $ICONSET_DIR
rm -r $ICNS_PATH