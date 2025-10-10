# DevUtilities - App Store Submission Guide

## Basic App Information

**App Name:** DevUtilities

**Subtitle:** 18 Essential Developer Utilities

**Bundle ID:** com.hengfeiyang.devutilities

**Version:** 2.6.0 (Build 56)

**Category:** Developer Tools

**Minimum OS:** macOS 14.0+

**Copyright:** Copyright © 2025 Hengfei Yang. All rights reserved.

---

## App Description

### Short Description (170 chars max)
18 essential developer utilities: AI chat, translation, JSON formatter, Base64, UUID generator, regex tester, crypto tools, and more. All in one native macOS app.

### Full Description

DevUtilities is a native macOS application providing 18 essential utilities for software developers. Built entirely with Claude Code, it offers a clean, intuitive interface with real-time processing.

Core Features:

- AI Chat - Intelligent assistant with DeepSeek reasoning and custom models
- AI Translate - Professional translation with 19 languages, 3 modes, and word explanations
- Timestamp Converter - Bidirectional conversion with timezone support
- Unit Converter - 7 categories (Data, Time, Length, Weight, Temperature, Area, Volume)
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

Version 2.6.0:

- AI Translate: Professional translation with intelligent translation, polishing, and summarization
- 19 Language Support: Auto-detect, English, Chinese, Japanese, Korean, Spanish, French, German, Russian, Arabic, Hindi, and more
- Word Mode: Detailed single-word translation with phonetic notation, meanings, examples, and etymology
- Real-time Streaming: Live translation results with animated status indicators
- Three Modes: Translate, Polishing, and Summarize
- Quick Actions: Retry and copy buttons
- Model Integration: Reuses AI Chat's flexible model system

---

## Keywords

(max 100 characters)

developer,devutils,devutilities,json,base64,uuid,timestamp,regex,jwt,crypto,ai,translate,parquet

---

## Screenshots

**Required Sizes:** 1280x800, 1440x900, 2560x1600, or 2880x1800

**Available Screenshots:** (from website/images/screenshots/)
1. Main interface with sidebar - hero-screenshot.png
2. AI Translate feature - aitranslate.png (NEW feature - highlight this!)
3. JSON Formatter with diff editor - json.png
4. AI Chat with custom models - aichat.png
5. Crypto Tools - crypto.png
6. HTTP Request client - http.png
7. Customization options - customize.png
8. Timestamp Converter - timestamp.png
9. UUID Generator - uuid.png
10. JWT Encoder/Decoder - jwt.png

**Recommended Order for Submission:**
1. hero-screenshot.png (main interface)
2. aitranslate.png (latest feature)
3. aichat.png (AI capabilities)
4. json.png (core utility)
5. crypto.png (security tools)
6. customize.png (customization)
7. http.png (developer tools)

---

## App Preview Video (Optional but Recommended)

Create a 15-30 second video showing:
- Quick navigation between tools using sidebar search
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
DevUtilities is a developer utility application that provides 18 essential tools for software development tasks.

Data Collection: We collect anonymous usage analytics (feature usage, navigation patterns) to improve the app. No personal information, device IDs, or user content is collected. Users are identified by a randomly generated UUID that cannot be linked to their identity. All analytics are sent to our own server - no third-party analytics services are used.

AI Features: The AI Chat and AI Translate features require users to configure their own API keys. We do not collect, store, or have access to API keys, chat messages, or translation content. The app uses standard OpenAI-compatible APIs.

Network Usage: The app requires network access for:
- Anonymous usage analytics (our server: api.devutilities.feiliwu.com)
- AI Chat and AI Translate features (user-configured API endpoints)
- IP Query geolocation lookups (ipinfo.io, ip.sb)
- HTTP Request testing tool (user-specified endpoints)
- Update checking (GitHub API)

All 18 tools work completely offline (analytics runs in background, never blocks features).

Test Account: Not required - all features are accessible without account creation.
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
- Feature names used (e.g., "json_formatter", "base64_codec")

**What We DO NOT Collect:**
- ❌ Personal information (name, email, phone)
- ❌ Device identifiers (UDID, serial, MAC address)
- ❌ IP addresses or location data
- ❌ User content (JSON data, files, text you process)
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
- [ ] Screenshots prepared and optimized (3-10 images, correct sizes)
- [ ] Privacy policy created and hosted online
- [ ] App Store description finalized
- [ ] Keywords optimized (100 chars max)
- [ ] Support URL set up (GitHub, website, or email)
- [ ] Marketing URL set up (optional but recommended)
- [ ] Build uploaded via Xcode/Transporter
- [ ] TestFlight testing completed
- [ ] Export compliance information filled
- [ ] Cryptography usage declared (CryptoKit usage)
- [ ] Review notes written
- [ ] Contact information up to date

---

## Build and Upload Instructions

### 1. Create Archive

```bash
# Open Xcode
open DevUtilities.xcodeproj

# In Xcode:
# 1. Select "Any Mac (Apple Silicon, Intel)" target
# 2. Product > Archive
# 3. Wait for build to complete
```

### 2. Validate Archive

In Xcode Organizer:
1. Select your archive
2. Click "Validate App"
3. Follow prompts for signing and validation
4. Fix any issues found

### 3. Upload to App Store Connect

In Xcode Organizer:
1. Select your archive
2. Click "Distribute App"
3. Choose "App Store Connect"
4. Select "Upload"
5. Follow prompts for signing and upload

### 4. Submit for Review

In App Store Connect (https://appstoreconnect.apple.com):
1. Select your app
2. Click "+" to create new version
3. Enter version number (2.6.0)
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

---

## Testing Recommendations

Before submitting, test:

1. **Fresh Installation:** Test on clean macOS 14.0 system
2. **All Tools:** Verify each of 18 tools works correctly
3. **AI Features:** Test with multiple API providers
4. **Offline Functionality:** Verify tools work without internet (except AI/IP/HTTP)
5. **Permissions:** Ensure app requests appropriate permissions
6. **Performance:** Check app launch time and responsiveness
7. **Memory:** Monitor memory usage with Activity Monitor
8. **Crashes:** No crashes or hangs during normal use

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
- Announce on Twitter/X, Product Hunt, Hacker News
- Update GitHub repo with App Store link
- Add App Store badge to website
- Create blog post about development journey

---

## Need Help?

- App Store Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- App Store Connect Help: https://help.apple.com/app-store-connect/
- Export Compliance: https://developer.apple.com/documentation/security/complying_with_encryption_export_regulations

---

## Notes

- This guide is based on version 2.6.0 (Build 52)
- Update all TODO items before submission
- Keep this guide updated for future versions
- Review dates: Initial creation - 2025-10-03
