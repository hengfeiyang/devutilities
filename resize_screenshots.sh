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
declare -A screenshots=(
    ["website/images/hero-screenshot.png"]="01_hero_main_interface"
    ["website/images/screenshots/aitranslate.png"]="02_ai_translate_feature"
    ["website/images/screenshots/aichat.png"]="03_ai_chat_assistant"
    ["website/images/screenshots/json.png"]="04_json_formatter_diff"
    ["website/images/screenshots/crypto.png"]="05_crypto_tools"
    ["website/images/screenshots/http.png"]="06_http_request_client"
    ["website/images/screenshots/customize.png"]="07_customization_settings"
)

# Optional screenshots
declare -A optional_screenshots=(
    ["website/images/screenshots/jwt.png"]="08_jwt_encoder_decoder"
    ["website/images/screenshots/timestamp.png"]="09_timestamp_converter"
    ["website/images/screenshots/uuid.png"]="10_uuid_generator"
    ["website/images/screenshots/hex.png"]="11_hex_string_converter"
    ["website/images/screenshots/sql.png"]="12_sql_formatter"
)

echo -e "${YELLOW}Resizing priority screenshots (1-7)...${NC}"
echo ""

# Process priority screenshots
for source in "${!screenshots[@]}"; do
    output_name="${screenshots[$source]}.png"

    if [ -f "$source" ]; then
        # Get original dimensions
        orig_width=$(sips -g pixelWidth "$source" | tail -n1 | awk '{print $2}')
        orig_height=$(sips -g pixelHeight "$source" | tail -n1 | awk '{print $2}')

        echo -e "Processing: ${BLUE}$(basename "$source")${NC}"
        echo "  Original: ${orig_width} x ${orig_height}"

        # Resize maintaining aspect ratio, then crop to exact dimensions
        # First, scale to cover target dimensions
        sips -Z $TARGET_WIDTH "$source" --out "$OUTPUT_DIR/temp_$output_name" > /dev/null 2>&1

        # Then crop to exact target dimensions (center crop)
        sips -c $TARGET_HEIGHT $TARGET_WIDTH "$OUTPUT_DIR/temp_$output_name" \
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

# Ask if user wants to process optional screenshots
echo ""
echo -e "${YELLOW}Process optional screenshots (8-12)? [y/N]${NC}"
read -r response

if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo ""
    echo -e "${YELLOW}Resizing optional screenshots (8-12)...${NC}"
    echo ""

    for source in "${!optional_screenshots[@]}"; do
        output_name="${optional_screenshots[$source]}.png"

        if [ -f "$source" ]; then
            orig_width=$(sips -g pixelWidth "$source" | tail -n1 | awk '{print $2}')
            orig_height=$(sips -g pixelHeight "$source" | tail -n1 | awk '{print $2}')

            echo -e "Processing: ${BLUE}$(basename "$source")${NC}"
            echo "  Original: ${orig_width} x ${orig_height}"

            sips -Z $TARGET_WIDTH "$source" --out "$OUTPUT_DIR/temp_$output_name" > /dev/null 2>&1
            sips -c $TARGET_HEIGHT $TARGET_WIDTH "$OUTPUT_DIR/temp_$output_name" \
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
fi

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
echo -e "${YELLOW}Open $OUTPUT_DIR folder now? [y/N]${NC}"
read -r open_response

if [[ "$open_response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    open "$OUTPUT_DIR"
fi

echo ""
echo -e "${GREEN}Done! 🎉${NC}"
echo ""
