#!/bin/bash

# Simple DMG Creation Script for DevHelper
set -e

APP_NAME="DevHelper"
APP_VERSION="1.12.0"
DMG_NAME="${APP_NAME}_v${APP_VERSION}"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Creating simple DMG for $APP_NAME v$APP_VERSION${NC}"

# Use the already built app
APP_PATH="build/DerivedData/Build/Products/Release/DevHelper.app"

if [ ! -d "$APP_PATH" ]; then
    echo "App not found. Building first..."
    xcodebuild -project "$APP_NAME.xcodeproj" -scheme "$APP_NAME" -configuration Release -derivedDataPath build/DerivedData build
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
rm -f "$DMG_NAME.dmg"

# Create the DMG directly as compressed
hdiutil create -srcfolder "$DMG_DIR" -volname "$APP_NAME v$APP_VERSION" -fs HFS+ -format UDZO -imagekey zlib-level=9 "$DMG_NAME.dmg"

# Get final DMG size
DMG_SIZE=$(du -sh "$DMG_NAME.dmg" | cut -f1)

echo -e "${GREEN}✅ Simple DMG created successfully!${NC}"
echo -e "${GREEN}📄 File: $PWD/$DMG_NAME.dmg${NC}"
echo -e "${GREEN}📏 Size: $DMG_SIZE${NC}"
echo -e "${YELLOW}💡 Users can drag $APP_NAME.app to Applications folder to install${NC}"

# Show the DMG in Finder
open .
