# App Store Screenshot Preparation Guide

## Current Screenshot Status

### Existing Screenshots Analysis

**Location:** `website/images/screenshots/`

**Current Dimensions:** 2048 x 1404 pixels (most screenshots)
**Current Format:** PNG
**File Sizes:** 189KB - 801KB (optimized)

✅ **Good News:** Your existing screenshots are high quality and nearly ready!

⚠️ **Issue:** Apple requires specific aspect ratios:
- Required: 16:10, 16:9, or 4:3 aspect ratios
- Your current: 2048 x 1404 = 1.458:1 ratio (approximately 3:2)
- This may not be accepted by App Store Connect

---

## Apple's Screenshot Requirements for macOS Apps

### Accepted Resolutions (choose ONE set):

1. **1280 x 800** (16:10 ratio) - Minimum
2. **1440 x 900** (16:10 ratio) - Recommended
3. **2560 x 1600** (16:10 ratio) - Retina
4. **2880 x 1800** (16:10 ratio) - High-DPI Retina (Best Quality)

### Requirements:
- **Format:** PNG or JPEG (PNG recommended for UI)
- **Color Space:** RGB
- **Number:** 3-10 screenshots required
- **Order:** First screenshot is the most important (shows first in store)
- **No transparency:** Must have solid background
- **No device frames:** Just the app content

---

## Recommended Screenshots for DevUtilities

### Priority Order (Top 7 Screenshots):

1. **Main Interface / Hero Shot** - Show sidebar with multiple tools visible
   - Current: `hero-screenshot.png` (2000x1276) - needs resizing
   - Purpose: First impression, show app structure

2. **AI Translate** ⭐ NEW FEATURE - Highlight v2.5.0 feature
   - Current: `aitranslate.png` (2048x1404) - needs resizing
   - Purpose: Show latest feature, demonstrate AI capabilities

3. **AI Chat** - Show intelligent assistant with conversation
   - Current: `aichat.png` (2048x1404) - needs resizing
   - Purpose: Demonstrate AI-powered features

4. **JSON Formatter with Diff** - Show visual diff editor
   - Current: `json.png` (2048x1404) - needs resizing
   - Purpose: Core developer tool, visual appeal

5. **Crypto Tools** - Show hash/encryption features
   - Current: `crypto.png` (2048x1404) - needs resizing
   - Purpose: Security features for developers

6. **HTTP Request** - Show API testing capabilities
   - Current: `http.png` (2048x1404) - needs resizing
   - Purpose: Developer workflow integration

7. **Customization** - Show feature management
   - Current: `customize.png` (2048x1404) - needs resizing
   - Purpose: User control and flexibility

### Optional Additional Screenshots (8-10):

8. **JWT Encoder/Decoder** - `jwt.png`
9. **Timestamp Converter** - `timestamp.png`
10. **UUID Generator** - `uuid.png`

---

## Screenshot Preparation Process

### Method 1: Resize Existing Screenshots (Recommended)

Use the provided script to batch resize all screenshots:

```bash
# Navigate to project root
cd /Users/yanghengfei/code/swift/devutilities

# Create output directory for App Store screenshots
mkdir -p AppStore_Screenshots

# Resize to 2880x1800 (highest quality, 16:10 ratio)
for file in website/images/screenshots/*.png; do
    filename=$(basename "$file")
    sips -z 1800 2880 "$file" --out "AppStore_Screenshots/$filename"
done
```

**Note:** This will crop/resize your images. The aspect ratio change from 1.458:1 to 1.6:1 means some content on the sides will be cropped.

### Method 2: Take New Screenshots (Best Quality)

If you want perfect composition without cropping:

#### Step 1: Set Up Display
```bash
# Get current display info
system_profiler SPDisplaysDataType | grep Resolution

# Your Mac should support 2880x1800 or 2560x1600
```

#### Step 2: Resize App Window
1. Launch DevUtilities
2. Resize window to exactly match target dimensions
3. Use a tool like **Rectangle** (free) or **BetterSnapTool** to set exact window size

#### Step 3: Capture Screenshots
```bash
# Take screenshot of specific window (Command+Shift+4, then Space, then click window)
# Or use built-in screenshot tool (Command+Shift+5)

# Save screenshots to AppStore_Screenshots folder
# Name them descriptively:
# 01_hero_main_interface.png
# 02_ai_translate_feature.png
# 03_ai_chat_assistant.png
# etc.
```

### Method 3: Automated Resize with Proper Aspect Ratio (Smart Crop)

This script will intelligently crop and resize:

```bash
#!/bin/bash
# Save as: resize_screenshots.sh

INPUT_DIR="website/images/screenshots"
OUTPUT_DIR="AppStore_Screenshots"
TARGET_WIDTH=2880
TARGET_HEIGHT=1800

mkdir -p "$OUTPUT_DIR"

for file in "$INPUT_DIR"/*.png; do
    filename=$(basename "$file")

    # Get current dimensions
    current_width=$(sips -g pixelWidth "$file" | tail -n1 | awk '{print $2}')
    current_height=$(sips -g pixelHeight "$file" | tail -n1 | awk '{print $2}')

    # Calculate new dimensions maintaining aspect ratio
    width_ratio=$(echo "scale=4; $TARGET_WIDTH / $current_width" | bc)
    height_ratio=$(echo "scale=4; $TARGET_HEIGHT / $current_height" | bc)

    # Use larger ratio to ensure image covers target size
    if (( $(echo "$width_ratio > $height_ratio" | bc -l) )); then
        scale_ratio=$width_ratio
    else
        scale_ratio=$height_ratio
    fi

    new_width=$(echo "$current_width * $scale_ratio" | bc | awk '{print int($1)}')
    new_height=$(echo "$current_height * $scale_ratio" | bc | awk '{print int($1)}')

    # Resize and crop to exact dimensions
    sips -z $new_height $new_width "$file" --out "$OUTPUT_DIR/temp_$filename"

    # Crop to exact target size (center crop)
    sips -c $TARGET_HEIGHT $TARGET_WIDTH "$OUTPUT_DIR/temp_$filename" --out "$OUTPUT_DIR/$filename"

    # Clean up temp file
    rm "$OUTPUT_DIR/temp_$filename"

    echo "✓ Processed: $filename → $TARGET_WIDTH x $TARGET_HEIGHT"
done

echo ""
echo "✅ All screenshots resized to $TARGET_WIDTH x $TARGET_HEIGHT"
echo "📁 Output directory: $OUTPUT_DIR"
```

---

## Quick Resize Script (Simple Method)

Create this script and run it:

```bash
#!/bin/bash
# resize_for_appstore.sh

cd /Users/yanghengfei/code/swift/devutilities
mkdir -p AppStore_Screenshots

# Priority screenshots (resize these first)
priority_files=(
    "hero-screenshot.png"
    "aitranslate.png"
    "aichat.png"
    "json.png"
    "crypto.png"
    "http.png"
    "customize.png"
)

# Resize hero-screenshot from main images folder
if [ -f "website/images/hero-screenshot.png" ]; then
    sips -Z 2880 --resampleHeightWidthMax 1800 2880 \
         "website/images/hero-screenshot.png" \
         --out "AppStore_Screenshots/01_hero.png"
    echo "✓ Resized hero-screenshot.png"
fi

# Resize priority screenshots
counter=2
for file in "${priority_files[@]:1}"; do
    if [ -f "website/images/screenshots/$file" ]; then
        output_name=$(printf "%02d_%s" $counter "${file%.png}.png")
        sips -Z 2880 --resampleHeightWidthMax 1800 2880 \
             "website/images/screenshots/$file" \
             --out "AppStore_Screenshots/$output_name"
        echo "✓ Resized $file → $output_name"
        ((counter++))
    fi
done

echo ""
echo "✅ Screenshots prepared for App Store!"
echo "📁 Location: AppStore_Screenshots/"
echo ""
echo "Next steps:"
echo "1. Review screenshots in AppStore_Screenshots/"
echo "2. Verify dimensions: sips -g pixelWidth -g pixelHeight AppStore_Screenshots/*.png"
echo "3. Upload to App Store Connect"
```

---

## Screenshot Optimization Tips

### Before Uploading:

1. **Review Each Screenshot**
   - Clear, readable text
   - No personal information visible
   - Shows the feature in action with sample data
   - Consistent UI theme (light/dark mode - pick one)

2. **Check Image Quality**
   ```bash
   # Verify dimensions
   sips -g pixelWidth -g pixelHeight AppStore_Screenshots/*.png

   # Check file sizes (should be under 500KB each)
   ls -lh AppStore_Screenshots/
   ```

3. **Optimize File Sizes** (if needed)
   ```bash
   # Use ImageOptim (free Mac app) or command line:
   # Install: brew install pngquant

   for file in AppStore_Screenshots/*.png; do
       pngquant --quality=80-95 --ext .png --force "$file"
   done
   ```

### Screenshot Content Guidelines:

✅ **DO:**
- Show actual app UI with realistic data
- Use high-contrast, readable text
- Highlight key features visually
- Keep interface clean and uncluttered
- Use consistent sample data across screenshots

❌ **DON'T:**
- Include placeholder text like "Lorem ipsum"
- Show empty states (show the app in use)
- Include profanity or offensive content
- Show copyrighted material
- Include personal information (emails, real names)

---

## Recommended Sample Data for Screenshots

### For AI Translate (Screenshot #2):
```
Input: "Hello, world!"
Mode: Translate
Source: English
Target: Chinese (Simplified)
Output: "你好，世界！" with full explanation
```

### For JSON Formatter (Screenshot #4):
```json
{
  "name": "DevUtilities",
  "version": "2.5.0",
  "tools": ["JSON", "Base64", "JWT"],
  "features": {
    "ai_powered": true,
    "customizable": true
  }
}
```

### For JWT (Screenshot #8):
```
Payload:
{
  "sub": "1234567890",
  "name": "John Developer",
  "iat": 1516239022
}
```

### For HTTP Request (Screenshot #6):
```
GET https://api.github.com/users/github
Response: JSON with user data
Status: 200 OK
```

---

## Screenshot Naming Convention

For easy management, name your files:

```
01_hero_main_interface.png          (Main app view)
02_ai_translate_word_mode.png       (NEW feature highlight)
03_ai_chat_assistant.png            (AI capabilities)
04_json_formatter_diff.png          (Core tool)
05_crypto_hash_encrypt.png          (Security features)
06_http_request_api.png             (Developer workflow)
07_customization_settings.png       (User control)
08_jwt_encoder_decoder.png          (Optional)
09_timestamp_converter.png          (Optional)
10_uuid_generator.png               (Optional)
```

---

## Validation Checklist

Before uploading to App Store Connect:

- [ ] All screenshots are exactly 2880x1800 (or chosen standard size)
- [ ] All screenshots are PNG format
- [ ] All screenshots are under 500KB each
- [ ] First screenshot (hero) shows the main interface
- [ ] Second screenshot highlights NEW feature (AI Translate)
- [ ] No personal information visible
- [ ] No placeholder text or lorem ipsum
- [ ] Consistent light/dark mode across all screenshots
- [ ] Text is readable at thumbnail size
- [ ] Sample data is realistic and professional
- [ ] At least 3, maximum 10 screenshots prepared
- [ ] Screenshots are numbered/ordered correctly

---

## Uploading to App Store Connect

### Method 1: Via Web Interface
1. Go to https://appstoreconnect.apple.com
2. Select your app → Version → App Store Screenshots
3. Drag and drop screenshots (will auto-detect resolution)
4. Rearrange order as needed
5. Click Save

### Method 2: Via Transporter App
1. Open Transporter app
2. Add screenshots to metadata package
3. Upload entire package

---

## Quick Start Commands

Run these commands to prepare your screenshots NOW:

```bash
cd /Users/yanghengfei/code/swift/devutilities

# Create output directory
mkdir -p AppStore_Screenshots

# Resize top 7 screenshots (priority)
sips -Z 2880 --resampleHeightWidthMax 1800 2880 \
     website/images/hero-screenshot.png \
     --out AppStore_Screenshots/01_hero.png

sips -Z 2880 --resampleHeightWidthMax 1800 2880 \
     website/images/screenshots/aitranslate.png \
     --out AppStore_Screenshots/02_aitranslate.png

sips -Z 2880 --resampleHeightWidthMax 1800 2880 \
     website/images/screenshots/aichat.png \
     --out AppStore_Screenshots/03_aichat.png

sips -Z 2880 --resampleHeightWidthMax 1800 2880 \
     website/images/screenshots/json.png \
     --out AppStore_Screenshots/04_json.png

sips -Z 2880 --resampleHeightWidthMax 1800 2880 \
     website/images/screenshots/crypto.png \
     --out AppStore_Screenshots/05_crypto.png

sips -Z 2880 --resampleHeightWidthMax 1800 2880 \
     website/images/screenshots/http.png \
     --out AppStore_Screenshots/06_http.png

sips -Z 2880 --resampleHeightWidthMax 1800 2880 \
     website/images/screenshots/customize.png \
     --out AppStore_Screenshots/07_customize.png

# Verify results
echo "Checking dimensions:"
sips -g pixelWidth -g pixelHeight AppStore_Screenshots/*.png

echo ""
echo "✅ Done! Screenshots ready in AppStore_Screenshots/"
```

---

## Notes

- **Aspect Ratio Warning:** Your current screenshots (2048x1404) will be cropped when resized to 16:10 ratio. Some content on the sides may be lost.
- **Best Practice:** If possible, take new screenshots at native 2880x1800 resolution for perfect composition.
- **Alternative:** You can also use 2560x1600 which is still high quality and widely supported.
- **Testing:** After resizing, open each screenshot and verify nothing important was cropped.

---

## Troubleshooting

**Problem:** Screenshots rejected by App Store Connect
- **Solution:** Verify exact dimensions with `sips -g pixelWidth -g pixelHeight file.png`
- **Solution:** Ensure 16:10 aspect ratio (width ÷ height = 1.6)

**Problem:** File size too large (>500KB)
- **Solution:** Use ImageOptim or pngquant to compress
- **Solution:** Save as JPEG with 90% quality instead of PNG

**Problem:** Text not readable
- **Solution:** Take new screenshots at higher resolution
- **Solution:** Use larger font sizes in app settings

**Problem:** Cropping cuts off important UI
- **Solution:** Take new screenshots with app window sized to 16:10 ratio
- **Solution:** Manually adjust composition before taking screenshot

---

## Summary

**Recommended Action:** Run the Quick Start Commands above to resize your existing screenshots, then review them to ensure no important content was cropped. If cropping is an issue, take new screenshots at 2880x1800 resolution.

**Time Estimate:**
- Quick resize: 5 minutes
- New screenshots: 30-60 minutes (if needed)

**Next Step:** After preparing screenshots, update `APP_STORE_SUBMISSION.md` checklist item: "Screenshots prepared and optimized" ✅
