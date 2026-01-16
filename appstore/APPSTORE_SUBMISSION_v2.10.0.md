# DevUtilities - App Store Submission Guide v2.10.0

## Basic App Information

**App Name:** DevUtilities

**Subtitle:** 22 Essential Developer Utilities

**Bundle ID:** com.hengfeiyang.devutilities

**Version:** 2.10.0 (Build 68)

**Category:** Developer Tools

**Minimum OS:** macOS 14.0+

**Copyright:** Copyright © 2026 Hengfei Yang. All rights reserved.

---

## App Description

### Short Description (170 chars max)
22 essential developer tools: AI Chat, AI translate, Timestamp converter, JSON formatter, SQL formatter, HTML formatter, color picker, Base64, UUID, regex and more.

### Full Description

DevUtilities is a native macOS application providing 22 essential utilities for software developers. Built entirely with Claude Code, it offers a clean, intuitive interface with real-time processing.

Core Features:

- Currency Converter - NEW! Real-time currency conversion with 38 currencies, historical data, and offline support
- Random String Generator - Cryptographically secure random strings with presets and requirements
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

- Real-time currency conversion with historical insights
- Cryptographically secure random string generation
- Text-to-Speech for translation learning and accessibility
- Customizable tool management with drag-and-drop
- Quick search functionality
- Real-time conversion as you type
- Modern, native macOS design
- Selectable and copyable results
- All tools work offline (except AI features and currency rates)

Perfect for developers who need quick access to essential utilities without switching context.

---

## What's New in This Version

Version 2.10.0:

Currency Converter - NEW!
- Real-time currency conversion with 38 global currencies
- Supported currencies: USD, EUR, GBP, JPY, CNY, KRW, INR, AUD, CAD, CHF, and 30 more
- 24-hour intelligent caching minimizes API calls and improves performance
- 30-day price history with incremental daily snapshots
- Visual trend indicators showing 24-hour changes with percentages
- Up/down arrows indicate currency strength vs previous day
- Flexible number input accepts both formatted (1,000,000) and plain (1000000) formats
- Two-column UI with currency pickers, swap button, and sample amount shortcuts
- Quick amount buttons: 100, 1000, 10000, 100000, 1000000 for instant calculations
- Offline mode uses cached data when network unavailable
- Clear offline indicators with cached timestamp display
- State persistence remembers your last conversion settings
- Optimized performance: history loads only when currency pair changes
- Instant conversion on amount changes without re-fetching data

Perfect Use Cases:
- Check exchange rates for international development projects
- Convert API pricing across different currencies
- Quick currency calculations for remote work and freelancing
- Track exchange rate trends over 30-day period
- Work offline with cached rates during travel
- Convert expenses between home and foreign currencies

Enhanced Developer Toolkit:
- Now includes 22 essential tools for all development needs
- Real-time exchange rate data with professional-grade accuracy
- Clean, intuitive interface with professional design
- Visual feedback with animated loading states
- Historical data analysis with trend indicators

Technical Features:
- Smart caching strategy reduces API load and improves speed
- Incremental history updates (only fetches new days, preserves old data)
- Efficient data management with separate cache for rates and history
- Comprehensive error handling with user-friendly messages
- Network availability detection for seamless offline experience
- Number parsing supports thousands separators and decimal points
- State persistence for seamless workflow across sessions
- Currency symbols and flag emojis for easy identification
- Precision handling for accurate decimal conversions

Performance Improvements:
- Optimized history loading (only when currency pair changes)
- Instant amount conversions without network requests
- Efficient cache management reduces memory footprint
- Fast UI updates with debounced number parsing

Bug Fixes and Stability:
- Enhanced error handling for network failures
- Improved caching reliability
- General stability improvements across all tools

---

## Keywords

(max 100 characters)

devutils,timestamp,json,base64,sql,html,uuid,jwt,crypto,random,currency,converter,parquet
---

## Screenshots

**Required Sizes:** 1280x800, 1440x900, 2560x1600, or 2880x1800

**Available Screenshots:** (from appstore/AppStore_Screenshots/)
1. Currency Converter - 12_currency_converter.png (NEW feature - highlight first!)
2. Random String Generator - random-string.png
3. AI Translate with TTS - aitranslate-tts.png
4. Main interface with sidebar - 00_hero_main_interface.png (shows 22 tools)
5. JSON Formatter with diff editor - 05_json_formatter.png
6. AI Chat with custom models - aichat.png
7. Color Picker - 04_color_picker.png
8. Crypto Tools - 11_crypto_tools.png
9. HTTP Request client - 10_http_request.png
10. Base Converter - 03_base_converter.png
11. UUID Generator - 08_uuid_generator.png

**Recommended Order for Submission:**
1. 12_currency_converter.png (NEW in v2.10.0 - Currency Converter first!)
2. 00_hero_main_interface.png (main interface showing 22 tools)
3. 05_json_formatter.png (popular core utility)
4. 04_color_picker.png (color tools)
5. aitranslate-tts.png (AI translation with TTS)
6. 11_crypto_tools.png (security tools)
7. 08_uuid_generator.png (UUID generation)

**Note:** Prioritize the Currency Converter screenshot as the hero image to showcase the newest feature.

---

## App Preview Video (Optional but Recommended)

Create a 15-30 second video showing:
- NEW Currency Converter with 38 currencies
- Real-time exchange rate conversion
- 30-day historical chart with trend indicators
- Offline mode with cached data
- Quick amount shortcuts and swap button
- Text-to-Speech feature in AI Translate
- Random String Generator with presets
- Quick navigation between 22 tools using sidebar search
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
Thank you for reviewing DevUtilities v2.10.0!

NEW IN THIS VERSION:
This update adds a Currency Converter tool for real-time currency conversion with 38 currencies, 30-day historical data, trend indicators, and offline support.

HOW TO TEST THE NEW CURRENCY CONVERTER:
1. Launch DevUtilities
2. Find "Currency Converter" in the sidebar (or use search box at top)
3. Basic conversion test:
   - Default currencies are USD (from) and EUR (to)
   - Default amount is 100
   - See instant conversion result displayed
   - Result shows: "100.00 USD = 92.45 EUR" (rate varies)
   - Exchange rate shown below: "1 USD = 0.9245 EUR" (rate varies)
4. Test currency switching:
   - Click "From Currency" dropdown
   - Select different currency (e.g., GBP, JPY, CNY)
   - See conversion update instantly
   - Try "To Currency" dropdown and select another currency
5. Test amount input:
   - Enter plain numbers: 1000, 50000, 1000000
   - Enter formatted numbers: 1,000 or 1,000,000.50
   - Use quick amount buttons: 100, 1000, 10000, 100000, 1000000
   - See instant conversion without delay
6. Test swap function:
   - Click the swap icon (⇄) between currency pickers
   - Currencies switch positions
   - Conversion updates to show reverse rate
7. Test 30-day history:
   - Scroll down to see "30-Day Exchange Rate History" section
   - See up to 30 days of historical rates displayed
   - Each row shows: date, rate, and trend indicator
   - Green ↑ with +X% means rate increased vs previous day
   - Red ↓ with -X% means rate decreased vs previous day
   - Gray - means no change or first day
8. Test offline mode:
   - Disconnect from internet (turn off WiFi)
   - Switch between currencies - still works with cached data
   - See "Offline - Using cached data" message
   - Cached timestamp shows when data was last fetched
   - Reconnect internet and see "Online" status return
9. Test state persistence:
   - Set currency pair (e.g., GBP to JPY) and amount (e.g., 5000)
   - Quit the app completely (Command+Q)
   - Relaunch DevUtilities
   - Navigate to Currency Converter
   - See your last settings restored (same currencies and amount)

EXAMPLES TO TRY:
- USD to EUR: 100 USD → ~92.45 EUR
- GBP to USD: 1000 GBP → ~1,275 USD
- JPY to CNY: 10000 JPY → ~485 CNY
- EUR to INR: 100 EUR → ~9,200 INR
- AUD to CAD: 500 AUD → ~440 CAD

SUPPORTED CURRENCIES (38 Total):
Major Fiat: USD, EUR, GBP, JPY, CNY, KRW, INR, AUD, CAD, CHF, HKD, SGD, SEK, NOK, DKK, NZD, PLN, THB, MYR, IDR, PHP, TWD, SAR, AED, TRY, ZAR, BRL, MXN, RUB, ILS, CZK, CLP, ARS, EGP, VND, HUF

CURRENCY CONVERTER FEATURES:
- 38 currencies including major fiat
- Real-time exchange rates from reliable API
- 24-hour intelligent caching reduces API calls
- 30-day historical data with incremental daily updates
- Trend indicators (↑↓) with percentage changes
- Flexible number input (accepts both "1000000" and "1,000,000")
- Quick amount shortcuts for common values
- Swap button for quick currency reversal
- Offline mode with cached data
- State persistence saves your last conversion
- Clean two-column interface
- Currency symbols and flags for easy identification
- Precision decimal handling
- Network error handling with user-friendly messages

DATA SOURCE & CACHING:
- Exchange rates from frankfurter.app (European Central Bank data)
- Rates cached for 24 hours to minimize API usage
- History cached with incremental daily updates (only new days fetched)
- Offline mode automatically activated when network unavailable
- Cache timestamp displayed when working offline
- No user data transmitted (only API currency rates fetched)

PRIVACY & NETWORK USAGE:
- Currency Converter makes network requests to frankfurter.app for exchange rates
- No personal data, conversion amounts, or currency selections transmitted
- Only currency codes and date ranges sent to API
- Cached data stored locally on user's device
- No analytics or tracking for Currency Converter usage
- Works completely offline after initial cache

RANDOM STRING GENERATOR (Existing Feature):
- Cryptographically secure with SecRandomCopyBytes
- 5 built-in presets for common use cases
- Bulk generation up to 20 strings
- Complete offline operation

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
- AI Chat, AI Translate, Random String Generator

DATA COLLECTION & PRIVACY:
We collect anonymous usage analytics (feature usage, navigation patterns) to improve the app. No personal information, device IDs, or user content is collected. Users are identified by a randomly generated UUID that cannot be linked to their identity. All analytics are sent to our own server - no third-party analytics services are used.

CURRENCY CONVERTER PRIVACY:
- Currency conversion amounts are NOT collected or transmitted
- Currency selections are NOT logged or stored remotely
- Only currency codes sent to API (e.g., "USD", "EUR") for rate lookup
- No user behavior tracking within Currency Converter
- All conversions happen locally on user's Mac
- Historical data cached locally only
- No data leaves device except for API rate requests

AI FEATURES:
The AI Chat and AI Translate features require users to configure their own API keys. We do not collect, store, or have access to API keys, chat messages, or translation content. The app uses standard OpenAI-compatible APIs.

NETWORK USAGE:
The app requires network access for:
- Anonymous usage analytics (our server: api.devutilities.feiliwu.com)
- Currency Converter exchange rates (frankfurter.app API)
- AI Chat and AI Translate features (user-configured API endpoints)
- IP Query geolocation lookups (ipinfo.io, ip.sb)
- HTTP Request testing tool (user-specified endpoints)
- Update checking (GitHub API)

Currency Converter works offline with cached data. Random String Generator works completely offline. All 22 tools work offline where applicable (analytics runs in background, never blocks features).

TEST ACCOUNT:
Not required - all features are accessible without account creation. AI features require user's own API key configuration.

The application is fully functional and ready for review. All 22 tools including the new Currency Converter have been thoroughly tested.
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
- Feature names used (e.g., "json_formatter", "base64_codec", "currency_converter")

**What We DO NOT Collect:**
- ❌ Personal information (name, email, phone)
- ❌ Device identifiers (UDID, serial, MAC address)
- ❌ IP addresses or location data
- ❌ User content (JSON data, files, text you process, translations, colors, generated random strings, conversion amounts)
- ❌ API keys or credentials
- ❌ Chat messages or translations
- ❌ Audio recordings (TTS uses local synthesis only)
- ❌ Voice data or speech patterns
- ❌ Generated random strings, passwords, or keys
- ❌ Currency conversion amounts or currency selections
- ❌ Exchange rate queries or conversion history

### Privacy Policy Requirements

You **MUST** provide a privacy policy URL. The privacy policy must state:

1. **Anonymous analytics collection** for usage patterns and feature popularity
2. **What is NOT collected**: personal info, device IDs, IP addresses, user content, audio data, generated strings, conversion amounts
3. **Currency Converter Privacy**: Conversion amounts and selections not collected, only API rate requests
4. **Random String Generator Privacy**: All generation is local, no strings transmitted or stored
5. **TTS Privacy**: Text-to-Speech uses native macOS AVFoundation, no audio recording or transmission
6. User-provided API keys stored locally only (UserDefaults)
7. No third-party analytics services (we use our own server)
8. Network requests explained:
   - **Analytics**: api.devutilities.feiliwu.com for anonymous usage events
   - **Currency rates**: frankfurter.app for exchange rate data (ECB data)
   - **AI features**: User's own API endpoints
   - **IP Query**: ipinfo.io and ip.sb for geolocation
   - **HTTP Request**: User-specified endpoints for testing
   - **Update check**: GitHub releases API
   - **Currency Converter**: frankfurter.app API, no user data transmitted
   - **Random String Generator**: No network required, completely offline
   - **TTS**: No network required, uses local macOS voices
9. No advertising, tracking, or data sales
10. Opt-out available (coming soon)

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
- ❌ Financial Info (currency amounts, conversion values)
- ❌ Location
- ❌ Sensitive Info (passwords, generated random strings, API keys)
- ❌ Contacts
- ❌ User Content (photos, videos, audio, messages, files, voice recordings, generated strings, conversion amounts)
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
- Currency Converter does NOT transmit or store conversion amounts or currency selections
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
- [ ] **Currency Converter screenshot verified** (12_currency_converter.png showing currencies, conversion, and history)
- [ ] Screenshots prepared and optimized (3-10 images, correct sizes)
- [ ] Privacy policy updated with Currency Converter information
- [ ] App Store description finalized (mentions Currency Converter feature)
- [ ] Keywords optimized (100 chars max, includes "currency", "exchange")
- [ ] Support URL set up (GitHub, website, or email)
- [ ] Marketing URL set up (optional but recommended)
- [ ] Build uploaded via Xcode/Transporter
- [ ] TestFlight testing completed (test Currency Converter with all features)
- [ ] Export compliance information filled
- [ ] Cryptography usage declared (CryptoKit + SecRandomCopyBytes usage)
- [ ] Review notes written (includes Currency Converter testing instructions)
- [ ] Contact information up to date
- [ ] Version number updated to 2.10.0 in Xcode
- [ ] Build number updated to 68

---

## Build and Upload Instructions

### 1. Update Version Information

```bash
# Open Xcode
open DevUtilities.xcodeproj

# In Xcode:
# 1. Select DevUtilities target
# 2. General tab > Identity section
# 3. Verify Version is "2.10.0"
# 4. Verify Build is "68"
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
3. Enter version number (2.10.0)
4. Fill in all required fields using this guide
5. Select uploaded build
6. Click "Submit for Review"

---

## Common Review Issues and Solutions

### Possible Rejection Reasons:

**1. Missing Privacy Policy**
- **Solution:** Create and host privacy policy, add URL to App Store Connect

**2. Currency Converter Network Concerns**
- **Solution:** Clarify that only currency codes are sent to API, no user amounts or selections transmitted. Works offline with cached data.

**3. Financial Data Collection Concerns**
- **Solution:** Emphasize that NO financial data (conversion amounts, currency selections) is collected or stored. Only anonymous feature usage analytics.

**4. Cryptographic Security Concerns (Random String Generator)**
- **Solution:** Clarify that random generation uses SecRandomCopyBytes for cryptographic security, appropriate for password/key generation. No strings are transmitted or stored.

**5. Network Usage Not Explained**
- **Solution:** Already explained in review notes. Currency Converter requires network for rate updates but works offline. Random String Generator works completely offline.

**6. Encryption Export Compliance**
- **Solution:** Declare standard cryptography exemption (5D992)

**7. AI Feature Concerns**
- **Solution:** Clarify that users provide their own API keys, no data collection

**8. HTTP Request Tool Concerns**
- **Solution:** Explain it's a developer testing tool, similar to Postman/curl

**9. Currency Rate Source Concerns**
- **Solution:** Provide documentation that frankfurter.app uses European Central Bank (ECB) official exchange rates

---

## Testing Recommendations

Before submitting, test:

1. **Fresh Installation:** Test on clean macOS 14.0 system
2. **All 22 Tools:** Verify each tool works correctly, especially Currency Converter
3. **Currency Converter Comprehensive Tests:**
   - [ ] All 38 currencies display correctly with symbols
   - [ ] Basic conversion accuracy (spot check against external source)
   - [ ] Amount input accepts plain numbers (1000, 50000)
   - [ ] Amount input accepts formatted numbers (1,000 or 1,000,000.50)
   - [ ] Quick amount buttons work (100, 1000, 10000, 100000, 1000000)
   - [ ] From/To currency dropdowns display all currencies
   - [ ] Currency search/filter works in dropdowns (if implemented)
   - [ ] Swap button correctly reverses currencies
   - [ ] Exchange rate displays correctly ("1 USD = X EUR")
   - [ ] Conversion result displays with proper formatting
   - [ ] 30-day history section displays historical rates
   - [ ] History dates are sequential and recent (within 30 days)
   - [ ] Trend indicators show correctly (↑ green for increase, ↓ red for decrease)
   - [ ] Percentage changes calculate accurately
   - [ ] First day shows no trend indicator (or -)
   - [ ] Changing currency pair triggers history reload
   - [ ] Changing amount only updates conversion (no history reload)
   - [ ] Online status displays "Online" when connected
   - [ ] Offline status displays "Offline - Using cached data" when disconnected
   - [ ] Cache timestamp shows when data last fetched
   - [ ] State persistence: currency pair restored on relaunch
   - [ ] State persistence: amount restored on relaunch
   - [ ] Error handling for network failures
   - [ ] Error handling for invalid API responses
   - [ ] Caching works correctly (24-hour TTL)
   - [ ] History incremental updates (only new days fetched)
   - [ ] Large numbers display correctly (millions, billions)
   - [ ] Decimal precision maintained in conversions
   - [ ] UI responsive during API calls (no freezing)
   - [ ] Memory usage stable during extended use
4. **Random String Generator:** Test all presets and custom configurations
5. **AI Translate with TTS:** Test translation with text-to-speech
6. **AI Features:** Test with multiple API providers
7. **Offline Functionality:** Verify Currency Converter and Random String Generator work without internet
8. **Permissions:** Ensure app requests appropriate permissions
9. **Performance:** Check app launch time and Currency Converter responsiveness
10. **Memory:** Monitor memory usage during currency conversions and history loading
11. **Crashes:** No crashes or hangs during conversion or normal use
12. **API Rate Limits:** Verify caching prevents excessive API calls

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
- Announce v2.10.0 with Currency Converter on Twitter/X, Product Hunt, Hacker News
- Update GitHub repo with App Store link
- Add release notes to GitHub releases (v2.10.0 tag)
- Update website with "Download from App Store" badge
- Create blog post about currency conversion for developers
- Highlight 38 currencies, offline mode, and historical data features
- Target developers, freelancers, remote workers, and international teams
- Emphasize "Professional currency converter for developers"
- Share demo video showing conversion, history, and offline mode
- Promote use cases: API pricing conversion, international invoicing, crypto tracking
- Highlight privacy: no conversion amounts collected

---

## Need Help?

- App Store Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- App Store Connect Help: https://help.apple.com/app-store-connect/
- Export Compliance: https://developer.apple.com/documentation/security/complying_with_encryption_export_regulations
- SecRandomCopyBytes: https://developer.apple.com/documentation/security/secrandomcopybytes(_:_:_:)
- CryptoKit: https://developer.apple.com/documentation/cryptokit

---

## Notes

- This guide is based on version 2.10.0 (Build 68)
- Previous version was 2.9.0 (Build 63) with Random String Generator
- Main change: Added Currency Converter with real-time rates and historical data
- Update all checklist items before submission
- Keep this guide updated for future versions
- Review dates: Created - 2026-01-07

---

## Quick Reference - What Changed from v2.9.0 to v2.10.0

### Code Changes:
- ✅ Created `CurrencyConverterView.swift` - Main UI for Currency Converter
- ✅ Created `CurrencyService.swift` - API integration with frankfurter.app
- ✅ Created `Currency.swift` - Currency model with 38 supported currencies
- ✅ Created `ExchangeRate.swift` - Exchange rate and history models
- ✅ Implemented 24-hour caching strategy for rates
- ✅ Implemented 30-day incremental history updates
- ✅ Added trend indicators with percentage calculations
- ✅ Implemented offline mode with cached data
- ✅ Added state persistence for currency selections and amount
- ✅ Implemented number parsing for formatted and plain input
- ✅ Added quick amount shortcuts (100, 1000, 10000, 100000, 1000000)
- ✅ Implemented swap functionality for currency reversal
- ✅ Updated navigation to include Currency Converter

### Documentation Changes:
- ✅ Updated `README.md` - Added Currency Converter to feature list (now 22 tools)
- ✅ Updated `CLAUDE.md` - Added v2.10.0 release notes
- ✅ Updated `DESIGN.md` - Add Currency Converter specification
- ✅ Updated `website/README.md` - Update tool count to 22
- ✅ Updated `website/index.html` - Add Currency Converter feature
- ✅ Updated `website/release-notes.html` - Add v2.10.0 release

### App Store Changes:
- 📝 Updated subtitle: "22 Essential Developer Utilities" (was 21)
- 📝 Updated keywords: Added "currency", "exchange"
- 📝 Updated description: Added Currency Converter feature
- 📝 Updated "What's New": v2.10.0 release notes with Currency Converter
- ✅ Screenshot ready: `12_currency_converter.png` showing conversion and history

### Key Features to Highlight:
1. **38 Currencies:** Major fiat currencies
2. **Real-time Rates:** Live exchange rate data from ECB
3. **24-Hour Caching:** Smart caching reduces API calls
4. **30-Day History:** Complete historical data with trends
5. **Trend Indicators:** Visual arrows with percentage changes
6. **Offline Mode:** Works without internet using cached data
7. **Flexible Input:** Accepts both formatted and plain numbers
8. **State Persistence:** Remembers last conversion settings
9. **Privacy-Focused:** No conversion amounts collected
10. **Clean UI:** Intuitive two-column layout with quick shortcuts

### Testing Priority:
1. All 38 currencies convert correctly
2. Real-time rate updates work
3. 24-hour caching prevents excessive API calls
4. 30-day history displays with correct trends
5. Offline mode works seamlessly
6. State persistence across app restarts
7. Number input handles both formats
8. Swap function works correctly
9. Quick amount buttons update conversion
10. Error handling for network issues
11. Memory usage during extended operation
12. UI responsiveness during API calls

### Privacy Considerations:
- Only currency codes sent to API (e.g., "USD", "EUR")
- Conversion amounts NOT transmitted or logged
- Currency selections NOT tracked remotely
- All conversions happen locally
- Historical data cached locally only
- Works offline with cached data (no network required after initial fetch)
