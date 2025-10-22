# DevUtilities - App Store Submission Guide v2.8.0

## Basic App Information

**App Name:** DevUtilities

**Subtitle:** 20 Essential Developer Utilities

**Bundle ID:** com.hengfeiyang.devutilities

**Version:** 2.8.0 (Build 60)

**Category:** Developer Tools

**Minimum OS:** macOS 14.0+

**Copyright:** Copyright © 2025 Hengfei Yang. All rights reserved.

---

## App Description

### Short Description (170 chars max)
20 essential developer utilities: Color picker, AI chat, translation, JSON formatter, Base64, UUID generator, regex tester, crypto tools, and more in one native app.

### Full Description

DevUtilities is a native macOS application providing 20 essential utilities for software developers. Built entirely with Claude Code, it offers a clean, intuitive interface with real-time processing.

Core Features:

- Color Picker - NEW! Professional color format converter for HEX, RGB, RGBA, HSL, HSLA, HSB, and CMYK
- AI Chat - Intelligent assistant with DeepSeek reasoning and custom models
- AI Translate - Professional translation with 19 languages, 3 modes, and word explanations
- Timestamp Converter - Bidirectional conversion with timezone support
- Unit Converter - 7 categories (Data, Time, Length, Weight, Temperature, Area, Volume)
- Base Converter - Mutual conversion between binary, octal, decimal, and hexadecimal
- JSON Formatter - Format, validate, and visual diff editor with CodeMirror
- Base64 Encode/Decode - Text encoding with URL-safe variant
- Hex String Converter - Bidirectional hex-to-string with UTF-8/UTF-16/ASCII
- Regex Test - Pattern matching with capture groups and common patterns
- UUID Generator - Multiple versions (v1, v4, v5, v7) with bulk generation
- URL Tools - Encoding/decoding and comprehensive parsing
- IP Query - Geolocation with dual network detection
- HTTP Request - Full HTTP client with SSE streaming and JSON tree view
- QR Code - Generation and scanning with multiple formats
- SQL Formatter - Native ParquetViewer library for minimal and beautify modes
- HTML Formatter - Format and minify with proper indentation
- JWT Encoder/Decoder - HMAC and RSA algorithms with CryptoKit security
- Parquet Viewer - Unified Rust-based API for Parquet/Arrow files
- Crypto Tools - Complete suite with hash, symmetric, and asymmetric encryption

Key Benefits:

- Customizable tool management with drag-and-drop
- Quick search functionality
- Real-time conversion as you type
- Modern, native macOS design
- Selectable and copyable results
- All tools work offline (except AI features)

Perfect for developers who need quick access to essential utilities without switching context.

---

## What's New in This Version

Version 2.8.0:

Color Picker - NEW!
- Professional color format converter supporting 7 formats: HEX, RGB, RGBA, HSL, HSLA, HSB, and CMYK
- Real-time conversion between all color formats as you edit
- Large visual color preview with system color picker integration
- Color history tracking up to 22 recently used colors with visual swatches
- One-click copy to clipboard for each color format
- State persistence automatically saves your current color and history
- Perfect for designers, front-end developers, and UI/UX professionals

Enhanced Developer Toolkit
- Now includes 20 essential developer tools
- Improved color workflow for web and app development
- Better navigation with sidebar search

Bug Fixes and Performance Improvements
- Enhanced state management and persistence
- Improved color conversion accuracy
- General stability improvements

---

## Keywords

(max 100 characters)

developer,devutils,json,base64,uuid,timestamp,regex,jwt,crypto,ai,translate,parquet,color,hex,rgb

---

## Screenshots

**Required Sizes:** 1280x800, 1440x900, 2560x1600, or 2880x1800

**Available Screenshots:** (from website/images/screenshots/)
1. Color Picker - color-picker.png (NEW feature - highlight first!)
2. Base Converter - base-converter.png
3. Main interface with sidebar - customize.png (shows 20 tools)
4. AI Translate feature - aitranslate.png
5. JSON Formatter with diff editor - json.png
6. AI Chat with custom models - aichat.png
7. Crypto Tools - crypto.png
8. HTTP Request client - http.png
9. Timestamp Converter - timestamp.png
10. UUID Generator - uuid.png

**Recommended Order for Submission:**
1. color-picker.png (NEW in v2.8.0 - feature first!)
2. customize.png (main interface showing 20 tools)
3. aitranslate.png (AI capabilities)
4. json.png (core utility)
5. crypto.png (security tools)
6. base-converter.png (number systems)
7. http.png (developer tools)

---

## App Preview Video (Optional but Recommended)

Create a 15-30 second video showing:
- NEW Color Picker with real-time format conversion
- Color history and visual swatches
- Quick navigation between 20 tools using sidebar search
- Real-time conversion features (JSON, Base64, etc.)
- AI Translate in action with word mode
- Customization options (drag-and-drop)

---

## Support Information

**Support URL:** https://github.com/hengfeiyang/devutilities/issues

**Marketing URL:** https://hengfeiyang.github.io/devutilities

**Privacy Policy URL:** https://hengfeiyang.github.io/devutilities/privacy_policy.html

---

## Review Information

### Notes for Review:

```
Thank you for reviewing DevUtilities v2.8.0!

NEW IN THIS VERSION:
This update introduces the Color Picker tool (#20), our newest utility for designers and developers working with colors in web and app development.

HOW TO TEST THE NEW COLOR PICKER:
1. Launch DevUtilities
2. Find "Color Picker" in the sidebar (or use search box at top)
3. Click on the large color preview box to open the macOS color picker
4. Select any color and observe instant conversion to all 7 formats:
   - HEX (e.g., #FF5733)
   - RGB (e.g., rgb(255, 87, 51))
   - RGBA (e.g., rgba(255, 87, 51, 1.0))
   - HSL (e.g., hsl(12, 100%, 60%))
   - HSLA (e.g., hsla(12, 100%, 60%, 1.0))
   - HSB (e.g., hsb(12, 80%, 100%))
   - CMYK (e.g., cmyk(0%, 66%, 80%, 0%))
5. Click the copy button next to any format to copy it to clipboard
6. Edit any color format directly - all other formats update instantly
7. Notice the color history below showing your recently used colors
8. Close and reopen the app - your current color and history are restored

EXAMPLES TO TRY:
- Enter "#FF0000" in HEX → see RGB: rgb(255, 0, 0), HSL: hsl(0, 100%, 50%)
- Enter "rgb(0, 128, 255)" in RGB → see HEX: #0080FF, HSL: hsl(210, 100%, 50%)
- Click a color in history to restore it instantly
- Use the system color picker to select custom colors

DATA COLLECTION & PRIVACY:
We collect anonymous usage analytics (feature usage, navigation patterns) to improve the app. No personal information, device IDs, or user content is collected. Users are identified by a randomly generated UUID that cannot be linked to their identity. All analytics are sent to our own server - no third-party analytics services are used.

AI FEATURES:
The AI Chat and AI Translate features require users to configure their own API keys. We do not collect, store, or have access to API keys, chat messages, or translation content. The app uses standard OpenAI-compatible APIs.

NETWORK USAGE:
The app requires network access for:
- Anonymous usage analytics (our server: api.devutilities.feiliwu.com)
- AI Chat and AI Translate features (user-configured API endpoints)
- IP Query geolocation lookups (ipinfo.io, ip.sb)
- HTTP Request testing tool (user-specified endpoints)
- Update checking (GitHub API)

All 20 tools work completely offline (analytics runs in background, never blocks features).

TEST ACCOUNT:
Not required - all features are accessible without account creation.

The application is fully functional and ready for review. All 20 tools have been thoroughly tested.
```

**Demo Account:** Not applicable (no account required)

---

## Privacy Information

### Data Collection Declaration

**Data Collection:** Anonymous usage analytics only

**What We Collect:**
- Anonymous usage events (app starts, feature usage, navigation)
- Randomly generated anonymous user ID (UUID, not linked to Apple ID or personal info)
- Session ID (temporary, resets each app launch)
- App version
- Feature names used (e.g., "json_formatter", "base64_codec", "color_picker")

**What We DO NOT Collect:**
- ❌ Personal information (name, email, phone)
- ❌ Device identifiers (UDID, serial, MAC address)
- ❌ IP addresses or location data
- ❌ User content (JSON data, files, text you process, color values)
- ❌ API keys or credentials
- ❌ Chat messages or translations

### Privacy Policy Requirements

You **MUST** provide a privacy policy URL. The privacy policy must state:

1. **Anonymous analytics collection** for usage patterns and feature popularity
2. **What is NOT collected**: personal info, device IDs, IP addresses, user content
3. User-provided API keys stored locally only (UserDefaults)
4. No third-party analytics services (we use our own server)
5. Network requests explained:
   - **Analytics**: api.devutilities.feiliwu.com for anonymous usage events
   - **AI features**: User's own API endpoints
   - **IP Query**: ipinfo.io and ip.sb for geolocation
   - **HTTP Request**: User-specified endpoints for testing
   - **Update check**: GitHub releases API
6. No advertising, tracking, or data sales
7. Opt-out available (coming soon)

**See PRIVACY_POLICY.md for the complete privacy policy**

### App Store Privacy Labels (Nutrition Labels)

When submitting to App Store Connect, you'll need to fill out the privacy questionnaire. Here's how to answer:

**Do you collect data from this app?** YES

**Data Types Collected:**

1. **Product Interaction** → YES
   - **Data Type:** Product Interaction
   - **Linked to User:** NO
   - **Used for Tracking:** NO
   - **Purpose:** Analytics
   - **Description:** We collect anonymous usage data about which features you use and how you navigate the app

**That's it! Only "Product Interaction" is collected, and it's NOT linked to the user.**

**Data NOT Collected:**
- ❌ Contact Info (name, email, phone, address)
- ❌ Health & Fitness
- ❌ Financial Info
- ❌ Location
- ❌ Sensitive Info
- ❌ Contacts
- ❌ User Content (photos, videos, audio, messages, files)
- ❌ Browsing History
- ❌ Search History
- ❌ Identifiers (device ID, advertising ID)
- ❌ Purchases
- ❌ Usage Data (beyond product interaction)
- ❌ Diagnostics
- ❌ Other Data

**Important Notes:**
- The anonymous UUID is considered "Product Interaction" data, NOT an "Identifier" because it's randomly generated and not linked to the user's identity
- Since data is NOT linked to user identity, your app will show NO privacy label warnings
- This is the most privacy-friendly configuration possible while still collecting analytics

---

## Export Compliance

### Encryption Usage

**Does your app use encryption?** YES

**Is your app exempt from export compliance?** YES

**Exemption Reason:** Standard Cryptography

**Details:**
Your app uses standard cryptographic algorithms available in Apple's system libraries:
- CryptoKit framework for AES-GCM-256, SHA (256/384/512), HMAC
- Security framework for RSA-2048/4096
- No custom encryption implementation
- No proprietary encryption algorithms

**What to declare:**
- Your app uses encryption for JWT signing/verification
- Your app provides cryptographic tools (hash, AES, RSA) for developers
- All encryption is standard and available in public APIs
- ECCN: 5D992 (mass market encryption)

---

## Pricing and Availability

**Price:** Free (or set your price)

**Availability:** All territories

**Pre-order:** No (or set date if planning pre-order)

---

## App Review Preparation Checklist

### Before Submission:

- [ ] App icon ready (✅ already in Assets.xcassets)
- [ ] **Color Picker screenshot created** (color-picker.png - PRIORITY!)
- [ ] Screenshots prepared and optimized (3-10 images, correct sizes)
- [ ] Privacy policy created and hosted online
- [ ] App Store description finalized (updated to 20 tools)
- [ ] Keywords optimized (100 chars max, includes "color", "hex", "rgb")
- [ ] Support URL set up (GitHub, website, or email)
- [ ] Marketing URL set up (optional but recommended)
- [ ] Build uploaded via Xcode/Transporter
- [ ] TestFlight testing completed
- [ ] Export compliance information filled
- [ ] Cryptography usage declared (CryptoKit usage)
- [ ] Review notes written (includes Color Picker testing instructions)
- [ ] Contact information up to date
- [ ] Version number updated to 2.8.0 in Xcode
- [ ] Build number incremented to 60 (or next available)

---

## Build and Upload Instructions

### 1. Update Version Information

```bash
# Open Xcode
open DevUtilities.xcodeproj

# In Xcode:
# 1. Select DevUtilities target
# 2. General tab > Identity section
# 3. Verify Version is "2.8.0"
# 4. Verify Build is "60" (or next available number)
```

### 2. Create Archive

```bash
# In Xcode:
# 1. Select "Any Mac (Apple Silicon, Intel)" target
# 2. Product > Archive
# 3. Wait for build to complete
```

### 3. Validate Archive

In Xcode Organizer:
1. Select your archive
2. Click "Validate App"
3. Follow prompts for signing and validation
4. Fix any issues found

### 4. Upload to App Store Connect

In Xcode Organizer:
1. Select your archive
2. Click "Distribute App"
3. Choose "App Store Connect"
4. Select "Upload"
5. Follow prompts for signing and upload

### 5. Submit for Review

In App Store Connect (https://appstoreconnect.apple.com):
1. Select your app
2. Click "+" to create new version
3. Enter version number (2.8.0)
4. Fill in all required fields using this guide
5. Select uploaded build
6. Click "Submit for Review"

---

## Common Review Issues and Solutions

### Possible Rejection Reasons:

**1. Missing Privacy Policy**
- **Solution:** Create and host privacy policy, add URL to App Store Connect

**2. Network Usage Not Explained**
- **Solution:** Already explained in review notes. Emphasize user control over API keys.

**3. Encryption Export Compliance**
- **Solution:** Declare standard cryptography exemption (5D992)

**4. AI Feature Concerns**
- **Solution:** Clarify that users provide their own API keys, no data collection

**5. HTTP Request Tool Concerns**
- **Solution:** Explain it's a developer testing tool, similar to Postman/curl

**6. Color Picker - No concerns expected**
- **Solution:** Standard utility tool, no special permissions required

---

## Testing Recommendations

Before submitting, test:

1. **Fresh Installation:** Test on clean macOS 14.0 system
2. **All 20 Tools:** Verify each tool works correctly, especially the new Color Picker
3. **Color Picker Edge Cases:**
   - [ ] All 7 color formats (HEX, RGB, RGBA, HSL, HSLA, HSB, CMYK)
   - [ ] System color picker integration
   - [ ] Direct editing of each format
   - [ ] Real-time synchronization between formats
   - [ ] Copy to clipboard functionality
   - [ ] Color history tracking (up to 22 colors)
   - [ ] Click on history color to restore it
   - [ ] State persistence (close/reopen app)
   - [ ] Invalid format input handling
4. **AI Features:** Test with multiple API providers
5. **Offline Functionality:** Verify tools work without internet (except AI/IP/HTTP)
6. **Permissions:** Ensure app requests appropriate permissions
7. **Performance:** Check app launch time and responsiveness
8. **Memory:** Monitor memory usage with Activity Monitor
9. **Crashes:** No crashes or hangs during normal use

---

## Post-Submission

### Expected Timeline:
- **Review time:** 1-3 business days (average)
- **Metadata review:** 24 hours
- **Binary review:** 1-2 days

### After Approval:
1. App goes live automatically or on scheduled date
2. Monitor reviews and ratings
3. Respond to user feedback
4. Plan updates based on user requests

### Marketing:
- Announce v2.8.0 with Color Picker feature on Twitter/X, Product Hunt, Hacker News
- Update GitHub repo with App Store link
- Add release notes to GitHub releases (v2.8.0 tag)
- Update website with "Download from App Store" badge
- Create blog post about Color Picker feature
- Highlight "20 essential tools" milestone
- Target design and front-end developer communities

---

## Need Help?

- App Store Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- App Store Connect Help: https://help.apple.com/app-store-connect/
- Export Compliance: https://developer.apple.com/documentation/security/complying_with_encryption_export_regulations

---

## Notes

- This guide is based on version 2.8.0 (Build 60)
- Previous version was 2.7.0 (Build 53)
- Main change: Added Color Picker tool (20th tool)
- Update all checklist items before submission
- Keep this guide updated for future versions
- Review dates: Created - 2025-10-20

---

## Quick Reference - What Changed from v2.7.0 to v2.8.0

### Code Changes:
- ✅ Added `ColorPickerView.swift` - New Color Picker implementation
- ✅ Updated `ToolType.swift` - Added `.colorPicker` case
- ✅ Updated `ContentView.swift` - Added Color Picker to navigation
- ✅ Updated `EventManager.swift` - Added "color_picker" event tracking
- ✅ Updated `FeatureSettingsView.swift` - Added "Color" abbreviation

### Documentation Changes:
- ✅ Updated `README.md` - 19 → 20 tools, added Color Picker description
- ✅ Updated `CLAUDE.md` - Added v2.8.0 release notes
- ✅ Updated `DESIGN.md` - Added Color Picker specification
- ✅ Updated `website/README.md` - Updated feature list
- ✅ Updated `website/index.html` - Added Color Picker card and slider
- ✅ Updated `website/release-notes.html` - Added v2.8.0 release
- ✅ Created `website/color-picker.html` - Dedicated feature page

### App Store Changes:
- 📝 Updated subtitle: "19 Essential" → "20 Essential"
- 📝 Updated keywords: Added "color", "hex", "rgb"
- 📝 Updated description: Added Color Picker feature
- 📝 Updated "What's New": v2.8.0 release notes with Color Picker
- ✅ Screenshot created: `color-picker.png` (high priority!)

### Key Features to Highlight:
1. **7 Color Formats:** HEX, RGB, RGBA, HSL, HSLA, HSB, CMYK
2. **Real-time Conversion:** Edit any format, others update instantly
3. **Visual Preview:** Large color box with system picker integration
4. **Color History:** Up to 22 recently used colors with swatches
5. **State Persistence:** Saves current color and history
6. **Developer-Friendly:** Perfect for web/app development workflows
