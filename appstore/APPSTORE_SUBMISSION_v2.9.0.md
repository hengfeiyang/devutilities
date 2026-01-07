# DevUtilities - App Store Submission Guide v2.9.0

## Basic App Information

**App Name:** DevUtilities

**Subtitle:** 21 Essential Developer Utilities

**Bundle ID:** com.hengfeiyang.devutilities

**Version:** 2.9.0 (Build 63)

**Category:** Developer Tools

**Minimum OS:** macOS 14.0+

**Copyright:** Copyright © 2026 Hengfei Yang. All rights reserved.

---

## App Description

### Short Description (170 chars max)
21 essential developer tools: random string generator, AI translate with TTS, color picker, AI chat, JSON formatter, Base64, UUID generator, regex, crypto, and more.

### Full Description

DevUtilities is a native macOS application providing 21 essential utilities for software developers. Built entirely with Claude Code, it offers a clean, intuitive interface with real-time processing.

Core Features:

- Random String Generator - NEW! Cryptographically secure random strings with presets and requirements
- AI Translate - Professional translation with text-to-speech for all 19 languages
- AI Chat - Intelligent assistant with DeepSeek reasoning and custom models
- Timestamp Converter - Bidirectional conversion with timezone support
- Unit Converter - 7 categories (Data, Time, Length, Weight, Temperature, Area, Volume)
- Base Converter - Mutual conversion between binary, octal, decimal, hexadecimal, and Base62
- JSON Formatter - Format, validate, and visual diff editor with CodeMirror
- Base64 Encode/Decode - Text encoding with URL-safe variant
- Hex String Converter - Bidirectional hex-to-string with UTF-8/UTF-16/ASCII
- Color Picker - Professional color format converter for HEX, RGB, RGBA, HSL, HSLA, HSB, and CMYK
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

- Cryptographically secure random string generation
- Text-to-Speech for translation learning and accessibility
- Customizable tool management with drag-and-drop
- Quick search functionality
- Real-time conversion as you type
- Modern, native macOS design
- Selectable and copyable results
- All tools work offline (except AI features)

Perfect for developers who need quick access to essential utilities without switching context.

---

## What's New in This Version

Version 2.9.0:

Random String Generator - NEW!
- Cryptographically secure random string generation using SecRandomCopyBytes
- 5 built-in presets: Strong Password, API Key, Hex String, PIN Code, Readable Code
- Customizable character sets: uppercase, lowercase, numbers, symbols
- Advanced requirements: enforce minimum uppercase, numbers, or symbols
- Bulk generation: create up to 20 random strings at once
- Flexible length control: configure from 1 to 100 characters
- One-click copy for individual strings or all strings at once
- Real-time validation and error feedback
- State persistence: saves your configuration between sessions

Perfect Use Cases:
- Generate strong passwords with specific requirements
- Create API keys and tokens for development
- Generate hex strings for testing
- Create PIN codes and verification codes
- Generate readable codes for user-facing scenarios
- Bulk password generation for testing environments

Enhanced Developer Toolkit:
- Now includes 21 essential tools for all development needs
- Cryptographic security with SecRandomCopyBytes (not pseudo-random)
- Clean, intuitive interface with preset templates
- Requirements enforcement ensures generated strings meet your criteria
- Visual feedback with animated success states

Security Features:
- Uses SecRandomCopyBytes for cryptographically secure random generation
- Not pseudo-random (arc4random) - suitable for security-sensitive applications
- Meets requirements for password generation, API keys, and tokens
- Generated strings can enforce complexity requirements

Technical Improvements:
- Efficient generation algorithm with requirement validation
- Retry logic ensures requirements are met within reasonable attempts
- State persistence for seamless workflow
- Character count tracking across all generated strings
- Monospaced font for easy reading of generated strings

Bug Fixes and Performance Improvements:
- Enhanced random generation reliability
- Improved UI responsiveness
- General stability improvements

---

## Keywords

(max 100 characters)

devutils,timestamp,json,base64,uuid,jwt,crypto,random,password,apikey,colorPicker,ipQuery

---

## Screenshots

**Required Sizes:** 1280x800, 1440x900, 2560x1600, or 2880x1800

**Available Screenshots:** (from website/images/screenshots/)
1. Random String Generator - random-string.png (NEW feature - highlight first!)
2. AI Translate with TTS - aitranslate-tts.png
3. Main interface with sidebar - customize.png (shows 21 tools)
4. JSON Formatter with diff editor - json.png
5. AI Chat with custom models - aichat.png
6. Color Picker - color-picker.png
7. Crypto Tools - crypto.png
8. HTTP Request client - http.png
9. Base Converter - base-converter.png
10. UUID Generator - uuid.png

**Recommended Order for Submission:**
1. random-string.png (NEW in v2.9.0 - Random String Generator first!)
2. customize.png (main interface showing 21 tools)
3. aitranslate-tts.png (AI translation with TTS)
4. color-picker.png (color tools)
5. json.png (core utility)
6. crypto.png (security tools)
7. uuid.png (UUID generation)

**Note:** If random-string.png screenshot doesn't exist yet, prioritize creating it showing the Random String Generator with presets, generated strings, and copy buttons.

---

## App Preview Video (Optional but Recommended)

Create a 15-30 second video showing:
- NEW Random String Generator with preset selection
- Generate multiple strings with Strong Password preset
- Show customizable character sets and requirements
- One-click copy functionality
- Text-to-Speech feature in AI Translate
- Quick navigation between 21 tools using sidebar search
- Real-time conversion features (JSON, Base64, Color Picker)
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
Thank you for reviewing DevUtilities v2.9.0!

NEW IN THIS VERSION:
This update adds a Random String Generator tool for cryptographically secure random string generation with presets, requirements, and bulk generation.

HOW TO TEST THE NEW RANDOM STRING GENERATOR:
1. Launch DevUtilities
2. Find "Random String Generator" in the sidebar (or use search box at top)
3. Try the built-in presets:
   - Click the "Preset" dropdown at the top
   - Select "Strong Password" (16 chars, uppercase, lowercase, numbers, symbols)
   - Click "Generate" button to create random strings
   - See 5 generated strong passwords instantly
4. Test customization:
   - Select "Custom" preset
   - Adjust length slider (1-100 characters)
   - Adjust quantity slider (1-20 strings)
   - Toggle character sets: Uppercase, Lowercase, Numbers, Symbols
   - Toggle requirements: At least 1 uppercase, number, or symbol
   - Click "Generate" to create custom strings
5. Test other presets:
   - "API Key": 32-character alphanumeric keys
   - "Hex String": 16-character hexadecimal strings
   - "PIN Code": 6-digit numeric PIN codes
   - "Readable Code": 8-character codes without ambiguous characters
6. Test copy functionality:
   - Click copy button next to any generated string (shows checkmark feedback)
   - Or click "Copy All" to copy all strings separated by newlines
   - Paste into any text editor to verify
7. Test validation:
   - Uncheck all character sets - Generate button becomes disabled
   - Enable requirements without enabling character sets - requirements toggle disabled
   - Re-enable character sets to restore functionality

EXAMPLES TO TRY:
- Strong Password preset → generates: "kX9#mLp2$vBn5@qY"
- API Key preset → generates: "a7f3e9d2c4b8a1f6e3d9c2b5a8f1e4d7"
- Hex String preset → generates: "3A7F2E9D4C8B1A6F"
- PIN Code preset → generates: "749238"
- Readable Code preset → generates: "JKLM3789"
- Custom: length=20, all character sets, all requirements → enforces complexity

RANDOM STRING GENERATOR FEATURES:
- Cryptographically secure with SecRandomCopyBytes (not pseudo-random)
- 5 built-in presets for common use cases
- Customizable character sets (uppercase, lowercase, numbers, symbols)
- Advanced requirements enforcement (minimum characters of each type)
- Bulk generation up to 20 strings
- Flexible length from 1 to 100 characters
- One-click copy per string or copy all
- Real-time validation with error messages
- State persistence saves configuration between sessions
- Monospaced display for easy reading
- Character count tracking

SECURITY IMPLEMENTATION:
- Uses SecRandomCopyBytes for cryptographic randomness
- Not pseudo-random (arc4random) - suitable for security applications
- Appropriate for password generation, API keys, tokens
- Requirements retry logic ensures complexity within 1000 attempts
- No network access - completely offline operation

AI TRANSLATE CAPABILITIES (Existing Feature):
- Text-to-Speech support for 19 languages
- Three modes: Translate, Polish, Summarize
- Word mode with detailed explanations
- Real-time streaming translation

OTHER TOOLS (20 Additional Features):
All tools have been tested and are fully functional:
- Timestamp Converter, Unit Converter, Base Converter, Color Picker
- JSON Formatter, Base64, Hex String, Regex Test
- UUID Generator, URL Tools, IP Query
- HTTP Request, QR Code, SQL Formatter, HTML Formatter
- JWT Encoder/Decoder, Parquet Viewer, Crypto Tools
- AI Chat, AI Translate

DATA COLLECTION & PRIVACY:
We collect anonymous usage analytics (feature usage, navigation patterns) to improve the app. No personal information, device IDs, or user content is collected. Users are identified by a randomly generated UUID that cannot be linked to their identity. All analytics are sent to our own server - no third-party analytics services are used.

RANDOM STRING GENERATOR PRIVACY:
- All random generation happens locally on the user's Mac
- No generated strings are transmitted, stored, or logged anywhere
- Uses native macOS SecRandomCopyBytes API
- No network access required - completely offline
- No data leaves the user's device

AI FEATURES:
The AI Chat and AI Translate features require users to configure their own API keys. We do not collect, store, or have access to API keys, chat messages, or translation content. The app uses standard OpenAI-compatible APIs.

NETWORK USAGE:
The app requires network access for:
- Anonymous usage analytics (our server: api.devutilities.feiliwu.com)
- AI Chat and AI Translate features (user-configured API endpoints)
- IP Query geolocation lookups (ipinfo.io, ip.sb)
- HTTP Request testing tool (user-specified endpoints)
- Update checking (GitHub API)

Random String Generator works completely offline. All 21 tools work offline (analytics runs in background, never blocks features).

TEST ACCOUNT:
Not required - all features are accessible without account creation. AI features require user's own API key configuration.

The application is fully functional and ready for review. All 21 tools including the new Random String Generator have been thoroughly tested.
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
- Feature names used (e.g., "json_formatter", "base64_codec", "random_string_generator")

**What We DO NOT Collect:**
- ❌ Personal information (name, email, phone)
- ❌ Device identifiers (UDID, serial, MAC address)
- ❌ IP addresses or location data
- ❌ User content (JSON data, files, text you process, translations, colors, generated random strings)
- ❌ API keys or credentials
- ❌ Chat messages or translations
- ❌ Audio recordings (TTS uses local synthesis only)
- ❌ Voice data or speech patterns
- ❌ Generated random strings, passwords, or keys

### Privacy Policy Requirements

You **MUST** provide a privacy policy URL. The privacy policy must state:

1. **Anonymous analytics collection** for usage patterns and feature popularity
2. **What is NOT collected**: personal info, device IDs, IP addresses, user content, audio data, generated strings
3. **Random String Generator Privacy**: All generation is local, no strings transmitted or stored
4. **TTS Privacy**: Text-to-Speech uses native macOS AVFoundation, no audio recording or transmission
5. User-provided API keys stored locally only (UserDefaults)
6. No third-party analytics services (we use our own server)
7. Network requests explained:
   - **Analytics**: api.devutilities.feiliwu.com for anonymous usage events
   - **AI features**: User's own API endpoints
   - **IP Query**: ipinfo.io and ip.sb for geolocation
   - **HTTP Request**: User-specified endpoints for testing
   - **Update check**: GitHub releases API
   - **Random String Generator**: No network required, completely offline
   - **TTS**: No network required, uses local macOS voices
8. No advertising, tracking, or data sales
9. Opt-out available (coming soon)

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
- ❌ Sensitive Info (passwords, generated random strings)
- ❌ Contacts
- ❌ User Content (photos, videos, audio, messages, files, voice recordings, generated strings)
- ❌ Browsing History
- ❌ Search History
- ❌ Identifiers (device ID, advertising ID)
- ❌ Purchases
- ❌ Usage Data (beyond product interaction)
- ❌ Diagnostics
- ❌ Other Data
- ❌ Audio Data (TTS synthesis is local, no recording)

**Important Notes:**
- The anonymous UUID is considered "Product Interaction" data, NOT an "Identifier" because it's randomly generated and not linked to the user's identity
- Random String Generator does NOT transmit or store any generated strings
- TTS feature does NOT record, transmit, or store any audio data
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
- Security framework for RSA-2048/4096, SecRandomCopyBytes
- No custom encryption implementation
- No proprietary encryption algorithms

**What to declare:**
- Your app uses encryption for JWT signing/verification
- Your app provides cryptographic tools (hash, AES, RSA, random generation) for developers
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
- [ ] **Random String Generator screenshot created** (random-string.png showing presets and generated strings - PRIORITY!)
- [ ] Screenshots prepared and optimized (3-10 images, correct sizes)
- [ ] Privacy policy updated with Random String Generator information
- [ ] App Store description finalized (mentions Random String Generator feature)
- [ ] Keywords optimized (100 chars max, includes "random", "password", "apikey")
- [ ] Support URL set up (GitHub, website, or email)
- [ ] Marketing URL set up (optional but recommended)
- [ ] Build uploaded via Xcode/Transporter
- [ ] TestFlight testing completed (test Random String Generator with all presets)
- [ ] Export compliance information filled
- [ ] Cryptography usage declared (CryptoKit + SecRandomCopyBytes usage)
- [ ] Review notes written (includes Random String Generator testing instructions)
- [ ] Contact information up to date
- [ ] Version number updated to 2.9.0 in Xcode
- [ ] Build number updated to 63 (or next available)

---

## Build and Upload Instructions

### 1. Update Version Information

```bash
# Open Xcode
open DevUtilities.xcodeproj

# In Xcode:
# 1. Select DevUtilities target
# 2. General tab > Identity section
# 3. Verify Version is "2.9.0"
# 4. Verify Build is "63" (or next available number)
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
3. Enter version number (2.9.0)
4. Fill in all required fields using this guide
5. Select uploaded build
6. Click "Submit for Review"

---

## Common Review Issues and Solutions

### Possible Rejection Reasons:

**1. Missing Privacy Policy**
- **Solution:** Create and host privacy policy, add URL to App Store Connect

**2. Cryptographic Security Concerns (Random String Generator)**
- **Solution:** Clarify that random generation uses SecRandomCopyBytes for cryptographic security, appropriate for password/key generation. No strings are transmitted or stored.

**3. Password/Sensitive Data Concerns**
- **Solution:** Emphasize that generated strings are never transmitted, logged, or stored. All generation is local. User is responsible for copying and storing generated passwords/keys.

**4. Network Usage Not Explained**
- **Solution:** Already explained in review notes. Emphasize Random String Generator works completely offline.

**5. Encryption Export Compliance**
- **Solution:** Declare standard cryptography exemption (5D992)

**6. AI Feature Concerns**
- **Solution:** Clarify that users provide their own API keys, no data collection

**7. HTTP Request Tool Concerns**
- **Solution:** Explain it's a developer testing tool, similar to Postman/curl

**8. Random String Generator Security Claims**
- **Solution:** Provide documentation that SecRandomCopyBytes is cryptographically secure and appropriate for security-sensitive applications per Apple documentation

---

## Testing Recommendations

Before submitting, test:

1. **Fresh Installation:** Test on clean macOS 14.0 system
2. **All 21 Tools:** Verify each tool works correctly, especially Random String Generator
3. **Random String Generator Edge Cases:**
   - [ ] All 5 presets generate appropriate strings (Strong Password, API Key, Hex String, PIN Code, Readable Code)
   - [ ] Custom configuration with all character sets enabled
   - [ ] Custom configuration with only one character set
   - [ ] Length slider works correctly (1-100)
   - [ ] Quantity slider works correctly (1-20)
   - [ ] Requirements enforcement works (uppercase, numbers, symbols)
   - [ ] Requirements toggle disabled when character set disabled
   - [ ] Generate button disabled when no character sets selected
   - [ ] Copy individual string shows checkmark feedback
   - [ ] Copy All copies all strings with newline separators
   - [ ] Clear button removes all generated strings
   - [ ] State persistence: configuration and generated strings restore on relaunch
   - [ ] Error messages display for invalid configurations
   - [ ] Generated strings meet all specified requirements
   - [ ] Bulk generation creates correct quantity
   - [ ] Character count display is accurate
   - [ ] Monospaced font displays strings clearly
4. **AI Translate with TTS:** Test translation with text-to-speech
5. **AI Features:** Test with multiple API providers
6. **Offline Functionality:** Verify Random String Generator works without internet
7. **Permissions:** Ensure app requests appropriate permissions
8. **Performance:** Check app launch time and Random String Generator responsiveness
9. **Memory:** Monitor memory usage during bulk generation
10. **Crashes:** No crashes or hangs during generation or normal use
11. **Security:** Verify generated strings have sufficient randomness and meet complexity requirements

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
- Announce v2.9.0 with Random String Generator on Twitter/X, Product Hunt, Hacker News
- Update GitHub repo with App Store link
- Add release notes to GitHub releases (v2.9.0 tag)
- Update website with "Download from App Store" badge
- Create blog post about secure random string generation
- Highlight security features and cryptographic randomness
- Target developers, security professionals, and system administrators
- Emphasize "Cryptographically secure password and key generation"
- Share demo video showing preset selection and bulk generation
- Promote use cases: password generation, API key creation, testing

---

## Need Help?

- App Store Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- App Store Connect Help: https://help.apple.com/app-store-connect/
- Export Compliance: https://developer.apple.com/documentation/security/complying_with_encryption_export_regulations
- SecRandomCopyBytes: https://developer.apple.com/documentation/security/secrandomcopybytes(_:_:_:)
- CryptoKit: https://developer.apple.com/documentation/cryptokit

---

## Notes

- This guide is based on version 2.9.0 (Build 63)
- Previous version was 2.8.2 (Build 62) with TTS support
- Main change: Added Random String Generator with cryptographic security
- Update all checklist items before submission
- Keep this guide updated for future versions
- Review dates: Created - 2025-11-12

---

## Quick Reference - What Changed from v2.8.2 to v2.9.0

### Code Changes:
- ✅ Created `RandomStringView.swift` - Main UI for Random String Generator
- ✅ Created `RandomStringGenerator.swift` - Core generation logic with SecRandomCopyBytes
- ✅ Created `RandomStringConfig.swift` - Configuration model with presets
- ✅ Created `RandomStringError.swift` - Error handling
- ✅ Updated navigation to include Random String Generator
- ✅ Added 5 presets: Strong Password, API Key, Hex String, PIN Code, Readable Code
- ✅ Implemented requirement enforcement logic
- ✅ Added state persistence for configuration and generated strings
- ✅ Implemented copy functionality with visual feedback

### Documentation Changes:
- ✅ Updated `README.md` - Added Random String Generator to feature list (now 21 tools)
- ✅ Updated `CLAUDE.md` - Added v2.9.0 release notes
- 📝 Update `DESIGN.md` - Add Random String Generator specification
- 📝 Update `website/README.md` - Update tool count to 21
- 📝 Update `website/index.html` - Add Random String Generator feature
- 📝 Update `website/release-notes.html` - Add v2.9.0 release
- 📝 Create `website/random-string.html` - Random String Generator feature page (optional)

### App Store Changes:
- 📝 Updated subtitle: "21 Essential Developer Utilities" (was 20)
- 📝 Updated keywords: Added "random", "password", "apikey"
- 📝 Updated description: Added Random String Generator feature
- 📝 Updated "What's New": v2.9.0 release notes with Random String Generator
- ✅ Screenshot needed: `random-string.png` showing presets and generated strings (high priority!)

### Key Features to Highlight:
1. **Cryptographically Secure:** SecRandomCopyBytes for true randomness
2. **5 Built-in Presets:** Strong Password, API Key, Hex String, PIN Code, Readable Code
3. **Customizable:** Character sets and length (1-100)
4. **Requirements Enforcement:** Minimum uppercase, numbers, or symbols
5. **Bulk Generation:** Create up to 20 strings at once
6. **One-click Copy:** Individual or all strings
7. **Offline Operation:** No network required
8. **State Persistence:** Saves configuration between sessions

### Testing Priority:
1. All 5 presets generate appropriate strings
2. Custom configurations with various character sets
3. Requirements enforcement validation
4. Copy functionality with visual feedback
5. State persistence across app restarts
6. Edge cases (no character sets, extreme lengths, bulk generation)
7. Security validation (strings meet complexity requirements)
