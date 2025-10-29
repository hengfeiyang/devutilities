# DevUtilities - App Store Submission Guide v2.8.2

## Basic App Information

**App Name:** DevUtilities

**Subtitle:** 20 Essential Developer Utilities

**Bundle ID:** com.hengfeiyang.devutilities

**Version:** 2.8.2 (Build 62)

**Category:** Developer Tools

**Minimum OS:** macOS 14.0+

**Copyright:** Copyright © 2025 Hengfei Yang. All rights reserved.

---

## App Description

### Short Description (170 chars max)
20 essential developer utilities: AI translate with TTS, color picker, AI chat, JSON formatter, Base64, UUID generator, regex tester, crypto tools, and more in one app.

### Full Description

DevUtilities is a native macOS application providing 20 essential utilities for software developers. Built entirely with Claude Code, it offers a clean, intuitive interface with real-time processing.

Core Features:

- AI Translate - NEW TTS! Professional translation with text-to-speech for all 19 languages
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

Version 2.8.2:

Text-to-Speech (TTS) for AI Translate - NEW!
- Native macOS text-to-speech integrated into AI Translate tool
- Multi-language TTS support for all 19 translation languages
- One-click speaker buttons next to input and output text
- Animated wave icons provide visual feedback during speech playback
- Perfect for language learning, pronunciation practice, and accessibility
- Smart text sanitization prevents SSML parsing errors
- Thread-safe implementation for smooth, reliable playback

Enhanced Translation Experience
- Listen to original text and translations with proper voice selection
- Language-specific voices automatically selected (English, Chinese, Japanese, French, Spanish, etc.)
- Improves language learning by hearing correct pronunciation
- Accessibility feature for users who prefer audio feedback
- Clean, intuitive speaker button UI integrated into translation interface

Technical Improvements
- AVFoundation-based TTS implementation for native macOS quality
- Comprehensive error handling for missing voices and edge cases
- Thread-safe state management eliminates priority inversion warnings
- Optimized performance with no impact on translation speed

Bug Fixes and Performance Improvements
- Enhanced audio playback stability
- Improved text sanitization for special characters
- General stability improvements

---

## Keywords

(max 100 characters)

devutils,timestamp,json,base64,uuid,jwt,crypto,aiTranslate,colorPicker,parquet,ipQuery

---

## Screenshots

**Required Sizes:** 1280x800, 1440x900, 2560x1600, or 2880x1800

**Available Screenshots:** (from website/images/screenshots/)
1. AI Translate with TTS - aitranslate-tts.png (NEW feature - highlight first!)
2. AI Translate feature - aitranslate.png
3. Color Picker - color-picker.png
4. Main interface with sidebar - customize.png (shows 20 tools)
5. JSON Formatter with diff editor - json.png
6. AI Chat with custom models - aichat.png
7. Crypto Tools - crypto.png
8. HTTP Request client - http.png
9. Base Converter - base-converter.png
10. UUID Generator - uuid.png

**Recommended Order for Submission:**
1. aitranslate-tts.png (NEW in v2.8.2 - TTS feature first!)
2. customize.png (main interface showing 20 tools)
3. aitranslate.png (AI translation capabilities)
4. color-picker.png (color tools)
5. json.png (core utility)
6. crypto.png (security tools)
7. base-converter.png (number systems)

**Note:** If aitranslate-tts.png screenshot doesn't exist yet, use existing aitranslate.png and prioritize creating TTS screenshot showing the speaker buttons.

---

## App Preview Video (Optional but Recommended)

Create a 15-30 second video showing:
- NEW Text-to-Speech feature with speaker buttons in AI Translate
- Click speaker button and see animated wave icon during playback
- Translation with multi-language TTS (e.g., English → Chinese with audio)
- Quick navigation between 20 tools using sidebar search
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
Thank you for reviewing DevUtilities v2.8.2!

NEW IN THIS VERSION:
This update adds Text-to-Speech (TTS) support to the AI Translate tool, enhancing language learning and accessibility.

HOW TO TEST THE NEW TEXT-TO-SPEECH FEATURE:
1. Launch DevUtilities
2. Find "AI Translate" in the sidebar (or use search box at top)
3. Configure your AI model (Settings button in top-right):
   - Add your OpenAI API key or use compatible API
   - Or use DeepSeek, GPT-4o, or any OpenAI-compatible model
4. Enter some English text (e.g., "Hello, how are you today?")
5. Click the speaker icon (🔊) next to the input text
   - The icon animates with sound waves during playback
   - Native macOS voice speaks the English text
6. Select target language (e.g., "Chinese Simplified")
7. Click "Translate" button
8. Once translation appears, click the speaker icon next to the output
   - The icon animates during playback
   - Native Chinese voice speaks the translated text
9. Try different languages to hear language-specific voices:
   - Japanese, Korean, Spanish, French, German, etc.

EXAMPLES TO TRY:
- English → Spanish: "Good morning" → "Buenos días" (hear Spanish voice)
- English → Chinese: "Thank you" → "谢谢" (hear Chinese voice)
- English → Japanese: "Hello" → "こんにちは" (hear Japanese voice)
- Click speaker icons to hear pronunciations in both languages

TTS FEATURES:
- Works with all 19 supported translation languages
- Automatic voice selection based on target language
- Animated speaker icons with wave feedback during playback
- Smart text sanitization prevents SSML errors
- Thread-safe implementation for reliable playback
- No audio data is collected or transmitted (uses native macOS TTS)

AI TRANSLATE CAPABILITIES (Existing Features):
- Three modes: Translate, Polish, Summarize
- Word mode: Single words get detailed explanations with phonetic notation
- Real-time streaming translation results
- Support for 19 languages with auto-detect
- Keyboard shortcuts: Enter to submit, Shift+Enter for newline

DATA COLLECTION & PRIVACY:
We collect anonymous usage analytics (feature usage, navigation patterns) to improve the app. No personal information, device IDs, or user content is collected. Users are identified by a randomly generated UUID that cannot be linked to their identity. All analytics are sent to our own server - no third-party analytics services are used.

TTS PRIVACY:
- Text-to-Speech uses native macOS AVFoundation framework
- No audio is recorded, transmitted, or stored
- All speech synthesis happens locally on the user's Mac
- No text content is sent to any server for TTS purposes

AI FEATURES:
The AI Chat and AI Translate features require users to configure their own API keys. We do not collect, store, or have access to API keys, chat messages, or translation content. The app uses standard OpenAI-compatible APIs.

NETWORK USAGE:
The app requires network access for:
- Anonymous usage analytics (our server: api.devutilities.feiliwu.com)
- AI Chat and AI Translate features (user-configured API endpoints)
- IP Query geolocation lookups (ipinfo.io, ip.sb)
- HTTP Request testing tool (user-specified endpoints)
- Update checking (GitHub API)

TTS functionality works completely offline using native macOS voices. All 20 tools work offline (analytics runs in background, never blocks features).

TEST ACCOUNT:
Not required - all features are accessible without account creation. AI features require user's own API key configuration.

The application is fully functional and ready for review. All 20 tools including the new TTS feature have been thoroughly tested.
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
- Feature names used (e.g., "json_formatter", "base64_codec", "ai_translate", "tts_play")

**What We DO NOT Collect:**
- ❌ Personal information (name, email, phone)
- ❌ Device identifiers (UDID, serial, MAC address)
- ❌ IP addresses or location data
- ❌ User content (JSON data, files, text you process, translations, colors)
- ❌ API keys or credentials
- ❌ Chat messages or translations
- ❌ Audio recordings (TTS uses local synthesis only)
- ❌ Voice data or speech patterns

### Privacy Policy Requirements

You **MUST** provide a privacy policy URL. The privacy policy must state:

1. **Anonymous analytics collection** for usage patterns and feature popularity
2. **What is NOT collected**: personal info, device IDs, IP addresses, user content, audio data
3. **TTS Privacy**: Text-to-Speech uses native macOS AVFoundation, no audio recording or transmission
4. User-provided API keys stored locally only (UserDefaults)
5. No third-party analytics services (we use our own server)
6. Network requests explained:
   - **Analytics**: api.devutilities.feiliwu.com for anonymous usage events
   - **AI features**: User's own API endpoints
   - **IP Query**: ipinfo.io and ip.sb for geolocation
   - **HTTP Request**: User-specified endpoints for testing
   - **Update check**: GitHub releases API
   - **TTS**: No network required, uses local macOS voices
7. No advertising, tracking, or data sales
8. Opt-out available (coming soon)

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
- ❌ User Content (photos, videos, audio, messages, files, voice recordings)
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
- [ ] **TTS screenshot created** (aitranslate-tts.png showing speaker buttons - PRIORITY!)
- [ ] Screenshots prepared and optimized (3-10 images, correct sizes)
- [ ] Privacy policy updated with TTS information
- [ ] App Store description finalized (mentions TTS feature)
- [ ] Keywords optimized (100 chars max, includes "tts", "speech")
- [ ] Support URL set up (GitHub, website, or email)
- [ ] Marketing URL set up (optional but recommended)
- [ ] Build uploaded via Xcode/Transporter
- [ ] TestFlight testing completed (test TTS on different macOS versions)
- [ ] Export compliance information filled
- [ ] Cryptography usage declared (CryptoKit usage)
- [ ] Review notes written (includes TTS testing instructions)
- [ ] Contact information up to date
- [ ] Version number updated to 2.8.2 in Xcode
- [ ] Build number updated to 62 (or next available)

---

## Build and Upload Instructions

### 1. Update Version Information

```bash
# Open Xcode
open DevUtilities.xcodeproj

# In Xcode:
# 1. Select DevUtilities target
# 2. General tab > Identity section
# 3. Verify Version is "2.8.2"
# 4. Verify Build is "62" (or next available number)
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
3. Enter version number (2.8.2)
4. Fill in all required fields using this guide
5. Select uploaded build
6. Click "Submit for Review"

---

## Common Review Issues and Solutions

### Possible Rejection Reasons:

**1. Missing Privacy Policy**
- **Solution:** Create and host privacy policy, add URL to App Store Connect

**2. Audio Recording Concerns (TTS)**
- **Solution:** Clarify that TTS is synthesis-only, no recording. All processing is local with AVFoundation.

**3. Network Usage Not Explained**
- **Solution:** Already explained in review notes. Emphasize TTS works offline.

**4. Encryption Export Compliance**
- **Solution:** Declare standard cryptography exemption (5D992)

**5. AI Feature Concerns**
- **Solution:** Clarify that users provide their own API keys, no data collection

**6. HTTP Request Tool Concerns**
- **Solution:** Explain it's a developer testing tool, similar to Postman/curl

**7. TTS Audio Privacy**
- **Solution:** Emphasize no audio recording, transmission, or storage. Local synthesis only.

---

## Testing Recommendations

Before submitting, test:

1. **Fresh Installation:** Test on clean macOS 14.0 system
2. **All 20 Tools:** Verify each tool works correctly, especially AI Translate with TTS
3. **TTS Feature Edge Cases:**
   - [ ] Speaker button appears next to input and output text
   - [ ] Click speaker button plays audio with animated wave icon
   - [ ] Test multiple languages (English, Chinese, Spanish, Japanese, French)
   - [ ] Verify language-specific voices are used correctly
   - [ ] Test with empty text (should show error or disable button)
   - [ ] Test with very long text (should handle gracefully)
   - [ ] Test special characters and punctuation
   - [ ] Click speaker during playback (should stop and restart)
   - [ ] Close app during playback (should clean up properly)
   - [ ] Test on systems with missing voices (graceful degradation)
   - [ ] Verify no priority inversion warnings in console
   - [ ] Check animation smoothness during playback
4. **AI Translate Modes:** Test Translate, Polish, Summarize with TTS
5. **Word Mode:** Single word translation with TTS pronunciation
6. **AI Features:** Test with multiple API providers
7. **Offline Functionality:** Verify TTS works without internet
8. **Permissions:** Ensure app requests appropriate permissions (no microphone needed)
9. **Performance:** Check app launch time and TTS responsiveness
10. **Memory:** Monitor memory usage during TTS playback
11. **Crashes:** No crashes or hangs during TTS or normal use

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
- Announce v2.8.2 with TTS feature on Twitter/X, Product Hunt, Hacker News
- Update GitHub repo with App Store link
- Add release notes to GitHub releases (v2.8.2 tag)
- Update website with "Download from App Store" badge
- Create blog post about TTS feature for language learning
- Highlight accessibility improvements
- Target language learners, educators, and accessibility communities
- Emphasize "Learn pronunciation while translating"
- Share demo video showing TTS in action

---

## Need Help?

- App Store Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- App Store Connect Help: https://help.apple.com/app-store-connect/
- Export Compliance: https://developer.apple.com/documentation/security/complying_with_encryption_export_regulations
- AVFoundation TTS: https://developer.apple.com/documentation/avfoundation/speech_synthesis

---

## Notes

- This guide is based on version 2.8.2 (Build 62)
- Previous version was 2.8.1 (Build 61) with Base62 support
- Main change: Added Text-to-Speech (TTS) to AI Translate
- Update all checklist items before submission
- Keep this guide updated for future versions
- Review dates: Created - 2025-10-26

---

## Quick Reference - What Changed from v2.8.1 to v2.8.2

### Code Changes:
- ✅ Updated `AITranslateView.swift` - Added TTS speaker buttons and playback
- ✅ Created `TTSManager.swift` - Text-to-Speech manager with AVFoundation
- ✅ Updated language voice mappings - 19 languages with proper voice selection
- ✅ Added animated wave icons - Visual feedback during speech playback
- ✅ Implemented thread-safe state management - Eliminates priority inversion
- ✅ Added text sanitization - Prevents SSML parsing errors

### Documentation Changes:
- ✅ Updated `README.md` - Added TTS feature to AI Translate description
- ✅ Updated `CLAUDE.md` - Added v2.8.2 release notes
- ✅ Updated `DESIGN.md` - Added TTS specification
- ✅ Updated `website/README.md` - Updated AI Translate feature list
- ✅ Updated `website/index.html` - Added TTS mention to AI Translate
- ✅ Updated `website/release-notes.html` - Added v2.8.2 release
- ✅ Updated `website/ai-translate.html` - Added TTS feature section

### App Store Changes:
- 📝 Updated subtitle: Added "with TTS" mention
- 📝 Updated keywords: Added "tts", "speech"
- 📝 Updated description: Added TTS feature
- 📝 Updated "What's New": v2.8.2 release notes with TTS
- ✅ Screenshot needed: `aitranslate-tts.png` showing speaker buttons (high priority!)

### Key Features to Highlight:
1. **Native macOS TTS:** AVFoundation-based text-to-speech
2. **Multi-language Support:** 19 languages with proper voice selection
3. **One-click Playback:** Speaker buttons for input and output text
4. **Animated Feedback:** Wave icons during speech playback
5. **Offline Functionality:** No internet required for TTS
6. **Language Learning:** Hear correct pronunciation instantly
7. **Accessibility:** Audio support for visually impaired users
8. **Privacy-Focused:** All synthesis is local, no recording or transmission

### Testing Priority:
1. TTS playback in multiple languages
2. Speaker button UI and animations
3. Error handling for missing voices
4. Thread safety and performance
5. Privacy compliance (no audio recording)
