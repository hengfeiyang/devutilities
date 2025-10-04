#!/bin/bash
# resize_screenshots.sh
# Resize DevUtilities screenshots for App Store submission
# Target: 2880 x 1800 pixels (16:10 aspect ratio)

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}DevUtilities Screenshot Resize Tool${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Configuration
OUTPUT_DIR="AppStore_Screenshots"
TARGET_WIDTH=2880
TARGET_HEIGHT=1800

# Create output directory
mkdir -p "$OUTPUT_DIR"
echo -e "${GREEN}✓${NC} Created output directory: $OUTPUT_DIR"
echo ""

# Priority screenshots with descriptive names
priority_sources=(
    "screenshots/0-all-features.png"
    "screenshots/1-aichat.png"
    "screenshots/2-ai-custom-models.png"
    "screenshots/3-aitranslate.png"
    "screenshots/4-timestamp.png"
    "screenshots/5-json.png"
    "screenshots/6-uuid.png"
    "screenshots/7-qrcode.png"
)

priority_names=(
    "00_hero_main_interface"
    "01_ai_chat"
    "02_ai_chat_custom_models"
    "03_ai_translate"
    "04_timestamp_converter"
    "05_json_formatter"
    "06_uuid_generator"
    "07_qrcode_generator"
)

# Optional screenshots
optional_sources=(
    "screenshots/8-http.png"
    "screenshots/9-ip.png"
    "screenshots/10-parquet.png"
)

optional_names=(
    "08_http_request_client"
    "09_ip_query"
    "10_parquet_viewer"
)

echo -e "${YELLOW}Resizing priority screenshots (1-7)...${NC}"
echo ""

# Process priority screenshots
for i in "${!priority_sources[@]}"; do
    source="${priority_sources[$i]}"
    output_name="${priority_names[$i]}.png"

    if [ -f "$source" ]; then
        # Get original dimensions
        orig_width=$(sips -g pixelWidth "$source" | tail -n1 | awk '{print $2}')
        orig_height=$(sips -g pixelHeight "$source" | tail -n1 | awk '{print $2}')

        echo -e "Processing: ${BLUE}$(basename "$source")${NC}"
        echo "  Original: ${orig_width} x ${orig_height}"

        # Resize maintaining aspect ratio, then crop to exact dimensions
        # First, scale to match target height (ensures we have enough height to crop width)
        sips --resampleHeight $TARGET_HEIGHT "$source" --out "$OUTPUT_DIR/temp_$output_name" > /dev/null 2>&1

        # Then crop to exact target dimensions (crop from top-left)
        sips --cropToHeightWidth $TARGET_HEIGHT $TARGET_WIDTH --cropOffset 0 0 "$OUTPUT_DIR/temp_$output_name" \
             --out "$OUTPUT_DIR/$output_name" > /dev/null 2>&1

        # Clean up temp file
        rm -f "$OUTPUT_DIR/temp_$output_name"

        # Get final dimensions
        final_width=$(sips -g pixelWidth "$OUTPUT_DIR/$output_name" | tail -n1 | awk '{print $2}')
        final_height=$(sips -g pixelHeight "$OUTPUT_DIR/$output_name" | tail -n1 | awk '{print $2}')

        echo "  Final: ${GREEN}${final_width} x ${final_height}${NC}"
        echo -e "  ${GREEN}✓${NC} Saved as: $output_name"
        echo ""
    else
        echo -e "  ${YELLOW}⚠${NC} Warning: File not found: $source"
        echo ""
    fi
done

# Process optional screenshots
echo ""
echo -e "${YELLOW}Resizing optional screenshots (8-10)...${NC}"
echo ""

for i in "${!optional_sources[@]}"; do
    source="${optional_sources[$i]}"
    output_name="${optional_names[$i]}.png"

    if [ -f "$source" ]; then
        orig_width=$(sips -g pixelWidth "$source" | tail -n1 | awk '{print $2}')
        orig_height=$(sips -g pixelHeight "$source" | tail -n1 | awk '{print $2}')

        echo -e "Processing: ${BLUE}$(basename "$source")${NC}"
        echo "  Original: ${orig_width} x ${orig_height}"

        sips --resampleHeight $TARGET_HEIGHT "$source" --out "$OUTPUT_DIR/temp_$output_name" > /dev/null 2>&1
        sips --cropToHeightWidth $TARGET_HEIGHT $TARGET_WIDTH --cropOffset 0 0 "$OUTPUT_DIR/temp_$output_name" \
             --out "$OUTPUT_DIR/$output_name" > /dev/null 2>&1
        rm -f "$OUTPUT_DIR/temp_$output_name"

        final_width=$(sips -g pixelWidth "$OUTPUT_DIR/$output_name" | tail -n1 | awk '{print $2}')
        final_height=$(sips -g pixelHeight "$OUTPUT_DIR/$output_name" | tail -n1 | awk '{print $2}')

        echo "  Final: ${GREEN}${final_width} x ${final_height}${NC}"
        echo -e "  ${GREEN}✓${NC} Saved as: $output_name"
        echo ""
    else
        echo -e "  ${YELLOW}⚠${NC} Warning: File not found: $source"
        echo ""
    fi
done

# Summary
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✅ Screenshot Processing Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# List all processed files
echo "Processed files:"
ls -1 "$OUTPUT_DIR" | while read -r file; do
    size=$(ls -lh "$OUTPUT_DIR/$file" | awk '{print $5}')
    echo -e "  ${GREEN}✓${NC} $file ($size)"
done

echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Review screenshots: open $OUTPUT_DIR"
echo "2. Verify dimensions: sips -g pixelWidth -g pixelHeight $OUTPUT_DIR/*.png"
echo "3. Check file sizes (should be < 500KB each)"
echo "4. Upload to App Store Connect"
echo ""

# Open folder
echo -e "${YELLOW}Open $OUTPUT_DIR folder now...${NC}"
echo ""
open "$OUTPUT_DIR"

echo ""
echo -e "${GREEN}Done! 🎉${NC}"
echo ""
