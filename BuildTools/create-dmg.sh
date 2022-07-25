#!/bin/sh

# Package a .app into a .dmg, adding the correct icons
# This script requires create-dmg
# get it with `brew install create-dmg`

echo '🗂 Creating iconset folder'
ICONSET_DIR="./AppIcon.iconset"
test -f $ICONSET_DIR && rm $ICONSET_DIR
mkdir -p $ICONSET_DIR

echo '📝 Copying app icons to iconset folder'
FILENAMES=("icon_16x16.png" "icon_16x16@2x.png" "icon_32x32.png" "icon_32x32@2x.png" "icon_128x128.png" "icon_128x128@2x.png" "icon_256x256.png" "icon_256x256@2x.png" "icon_512x512.png" "icon_512x512@2x.png")
for filename in "${FILENAMES[@]}" 
do
    cp "../Transitions/Assets.xcassets/AppIcon.appiconset/$filename" "$ICONSET_DIR"
done

echo '🌠 Creating iconset'
iconutil --convert icns $ICONSET_DIR
ICNS_PATH="./AppIcon.icns"

echo '📦 Create DMG'
VOLNAME="Transitions Installer"
VOLICON=$ICNS_PATH
APP_NAME="Transitions.app"
DMG_NAME="Transitions-Installer.dmg"
APP_RELEASE_PATH="./Transitions.app"
INSTALLER_BACKGROUND="installer_background.png"

test -f "$DMG_NAME" && rm "$DMG_NAME"
create-dmg \
  --volname "$VOLNAME" \
  --volicon "$VOLICON" \
  --window-pos 200 120 \
  --window-size 800 400 \
  --icon-size 100 \
  --icon "$APP_NAME" 200 190 \
  --hide-extension "$APP_NAME" \
  --app-drop-link 600 185 \
  --background "$INSTALLER_BACKGROUND" \
  "$DMG_NAME" \
  "$APP_RELEASE_PATH"

echo '␡ Cleaning up'
rm -r $ICONSET_DIR
rm -r $ICNS_PATH