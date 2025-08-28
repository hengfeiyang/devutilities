#!/bin/bash

# Simple DMG Creation Script for DevHelper
set -e

APP_NAME="DevHelper"

# Read version from project using xcodebuild
echo -e "${YELLOW}📖 Reading version from project...${NC}"
APP_VERSION=$(xcodebuild -project "$APP_NAME.xcodeproj" -target "$APP_NAME" -showBuildSettings | grep "MARKETING_VERSION" | awk '{print $3}' | head -1)

# Fallback to CFBundleShortVersionString if MARKETING_VERSION not found
if [ -z "$APP_VERSION" ] || [ "$APP_VERSION" = "" ]; then
    echo -e "${YELLOW}⚠️  MARKETING_VERSION not found, trying CFBundleShortVersionString...${NC}"
    APP_VERSION=$(xcodebuild -project "$APP_NAME.xcodeproj" -target "$APP_NAME" -showBuildSettings | grep "CFBundleShortVersionString" | awk '{print $3}' | head -1)
fi

# Last fallback
if [ -z "$APP_VERSION" ] || [ "$APP_VERSION" = "" ]; then
    echo -e "${YELLOW}⚠️  Version not found in build settings, will read from built app...${NC}"
    APP_VERSION="unknown"
fi

DMG_NAME="${APP_NAME}_v${APP_VERSION}"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Creating simple DMG for $APP_NAME v$APP_VERSION${NC}"

# Clean build cache for fresh build
echo -e "${YELLOW}🧹 Cleaning build cache...${NC}"
rm -rf build/DerivedData
xcodebuild -project "$APP_NAME.xcodeproj" -scheme "$APP_NAME" clean

# Build fresh app
echo -e "${YELLOW}🔨 Building fresh app...${NC}"
APP_PATH="build/DerivedData/Build/Products/Release/DevHelper.app"
xcodebuild -project "$APP_NAME.xcodeproj" -scheme "$APP_NAME" -configuration Release -derivedDataPath build/DerivedData build

# Update version from built app if not found earlier
if [ "$APP_VERSION" = "unknown" ] && [ -d "$APP_PATH" ]; then
    APP_VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$APP_PATH/Contents/Info.plist" 2>/dev/null)
    DMG_NAME="${APP_NAME}_v${APP_VERSION}"
    echo -e "${GREEN}📖 Read version from built app: $APP_VERSION${NC}"
fi

echo -e "${GREEN}✅ Found app at: $APP_PATH${NC}"

# Create DMG staging directory
DMG_DIR="build/dmg-simple"
rm -rf "$DMG_DIR"
mkdir -p "$DMG_DIR"

# Copy the app to the staging directory
echo -e "${YELLOW}📦 Preparing DMG contents...${NC}"
cp -R "$APP_PATH" "$DMG_DIR/"

# Create Applications symlink
ln -sf /Applications "$DMG_DIR/Applications"

# Calculate size needed for DMG
echo -e "${YELLOW}📏 Calculating DMG size...${NC}"
SIZE=$(du -sm "$DMG_DIR" | cut -f1)
SIZE=$((SIZE + 20)) # Add padding

echo -e "${YELLOW}💾 Creating DMG (${SIZE}MB)...${NC}"
rm -f "$DMG_NAME.dmg" "build/temp.dmg"

# Create temporary uncompressed DMG
hdiutil create -srcfolder "$DMG_DIR" -volname "$APP_NAME v$APP_VERSION" -fs HFS+ -format UDRW -size ${SIZE}m "build/temp.dmg"

# Mount the DMG
echo -e "${YELLOW}🔧 Mounting DMG to customize window...${NC}"
DEVICE=$(hdiutil attach -readwrite -noverify -noautoopen "build/temp.dmg" | egrep '^/dev/' | sed 1q | awk '{print $1}')
MOUNT_POINT="/Volumes/$APP_NAME v$APP_VERSION"

# Wait for mount
sleep 2

# Set window properties using AppleScript
osascript <<EOF
tell application "Finder"
    tell disk "$APP_NAME v$APP_VERSION"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {80, 80, 600, 450}
        set arrangement of icon view options of container window to not arranged
        set icon size of icon view options of container window to 128
        set position of item "DevHelper.app" of container window to {150, 140}
        set position of item "Applications" of container window to {350, 140}
        close
        open
        update without registering applications
        delay 2
    end tell
end tell
EOF

# Unmount
hdiutil detach "$DEVICE"

# Convert to compressed DMG
echo -e "${YELLOW}📦 Compressing DMG...${NC}"
hdiutil convert "build/temp.dmg" -format UDZO -imagekey zlib-level=9 -o "$DMG_NAME.dmg"

# Clean up
rm -f "build/temp.dmg"

# Get final DMG size
DMG_SIZE=$(du -sh "$DMG_NAME.dmg" | cut -f1)

echo -e "${GREEN}✅ Simple DMG created successfully!${NC}"
echo -e "${GREEN}📄 File: $PWD/$DMG_NAME.dmg${NC}"
echo -e "${GREEN}📏 Size: $DMG_SIZE${NC}"
echo -e "${YELLOW}💡 Users can drag $APP_NAME.app to Applications folder to install${NC}"

# Clean build cache after DMG creation
echo -e "${YELLOW}🧹 Cleaning build cache after DMG creation...${NC}"
rm -rf build
xcodebuild -project "$APP_NAME.xcodeproj" -scheme "$APP_NAME" clean

echo -e "${GREEN}🎉 DMG creation and cleanup completed!${NC}"

# Show the DMG in Finder
open .
