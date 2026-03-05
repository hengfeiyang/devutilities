# DevUtilities - App Store Submission Guide v2.12.0

## Basic App Information

**App Name:** DevUtilities

**Subtitle:** AI • Timestamp • Base64 • JWT • UUID • Parquet

**Bundle ID:** com.hengfeiyang.devutilities

**Version:** 2.12.0 (Build 72)

**Category:** Developer Tools

**Minimum OS:** macOS 14.0+

**Copyright:** Copyright © 2026 Hengfei Yang. All rights reserved.

---

## App Description

### Short Description (170 chars max)
23 developer tools: JSON, JWT, UUID, Base64, Regex, Parquet viewer, AI chat with Markdown, AI translate with OpenAI TTS, crypto, color picker, timestamp and more.

### Full Description

DevUtilities is a native macOS application providing 23 essential utilities for software developers. Built entirely with Swift and native macOS technologies, it offers a clean, fast interface with real-time processing.

Core Features:

- AI Chat - Intelligent assistant with new Markdown UI, one-click code block copy, DeepSeek reasoning, and custom model support
- AI Translate - Professional translation with OpenAI Text-to-Speech, real-time streaming, and 19 languages
- JSON Formatter - Format, validate, escape/unescape, and diff mode with visual CodeMirror editor
- Text Compare - Side-by-side text comparison with visual diff highlighting and real-time status
- JWT Encoder/Decoder - HMAC and RSA algorithms (RS256, RS384, RS512) with CryptoKit security
- UUID Generator - Multiple versions (v1, v4, v5, v7) with bulk generation
- Regex Test - Pattern matching with capture groups and common patterns
- Base64 Encode/Decode - Text encoding with URL-safe variant
- Hex String Converter - Bidirectional hex-to-string with UTF-8/UTF-16/ASCII
- Color Picker - Professional color format converter for HEX, RGB, RGBA, HSL, HSLA, HSB, and CMYK
- Parquet Viewer - Unified Rust-based API for Parquet and Arrow files
- Crypto Tools - Complete suite with MD5, SHA, AES-GCM-256, and RSA-2048/4096 encryption
- SQL Formatter - Minimal and beautify modes with diff comparison
- HTML Formatter - Proper indentation with diff comparison
- Timestamp Converter - Bidirectional conversion with timezone support
- Unit Converter - 7 categories (Data, Time, Length, Weight, Temperature, Area, Volume)
- Base Converter - Binary, octal, decimal, hexadecimal, and Base62
- Random String Generator - Cryptographically secure with presets and requirements
- Currency Converter - Real-time conversion with 38 currencies and 30-day history
- URL Tools - Encoding/decoding and comprehensive parsing
- IP Query - Geolocation with dual network detection
- HTTP Request - Full HTTP client with SSE streaming and JSON tree view
- QR Code - Generation and scanning with multiple formats

Key Benefits:

- Enhanced AI Chat with beautiful Markdown rendering and one-click copy for code blocks
- OpenAI TTS for AI Translate — ultra-low latency voice playback in 13 voices
- OpenAI Responses API support — compatible with the latest GPT models
- Side-by-side diff for Text, JSON, HTML, and SQL
- Cryptographically secure random string and key generation
- Parquet and Arrow file viewer — rare on macOS
- All tools work offline (except AI, currency, and IP features)
- Customizable sidebar with drag-and-drop tool ordering
- Quick search to jump between 23 tools instantly
- Native macOS performance — no Electron, no web views

Perfect for developers who need a reliable Swiss Army knife of utilities without switching context.

---

## What's New in This Version

Version 2.12.0:

AI Chat — Enhanced Markdown Rendering:
- Migrated to Textual rendering engine for richer, more accurate output
- Improved code block syntax highlighting across all languages
- One-click Copy button on every code block — grab code snippets instantly without selecting text
- Better rendering for tables, nested lists, and inline formatting
- Smoother real-time streaming updates — no more layout flicker during generation
- More accurate display for technical content like diffs, JSON, and shell commands

AI Translate — OpenAI Text-to-Speech:
- New OpenAI TTS engine alongside the existing macOS TTS
- Real-time PCM audio streaming — playback starts in realtime, no waiting
- 13 voice options: alloy, ash, ballad, coral, echo, fable, nova, onyx, sage, shimmer, verse, and more
- Auto mode automatically selects the best available TTS engine
- Configurable in Settings → AI → Text-to-Speech section
- Works alongside existing macOS native voices for flexibility
- Speaker buttons remain on all translation output panels

Quality Improvements:
- Improved chat rendering stability during streaming responses
- Better readability for technical responses with complex Markdown structure

---

## Keywords

(max 100 characters)

```
base64,decode,encode,jwt,regex,parquet,sql,html,formatter,unix,timestamp,color,crypto,qr,ip,hex,toolkit
```

**Character count:** 95 / 100

**Why these keywords (not in app name or subtitle):**
- `base64`, `decode`, `encode`, `hex` — high-intent encoding/decoding searches
- `jwt`, `regex` — focused developer utility terms with clear intent
- `parquet`, `sql`, `html`, `formatter` — structured data and formatting workflow
- `unix`, `timestamp` — timestamp conversion long-tail coverage
- `color`, `crypto`, `qr`, `ip` — additional specific utilities with lower competition

**Keywords intentionally excluded:**
- `devutils` — same as app name, already indexed
- `json`, `diff`, `text`, `compare`, `uuid` — already covered in subtitle
- `converter`, `developer`, `tools` — broad and highly competitive terms

---

## Screenshots

**Required Sizes:** 1280x800, 1440x900, 2560x1600, or 2880x1800

**Recommended Order for Submission:**
1. `01_ai_chat.png` — AI Chat with new Markdown UI and code copy
2. `03_ai_translate.png` — AI Translate with OpenAI TTS
3. `13_text_compare.png` — Text Compare (matches subtitle keyword)
4. `05_json_formatter.png` — JSON Formatter with diff mode
5. `06_uuid_generator.png` — UUID Generator
6. `04_timestamp_converter.png` — Timestamp Converter
7. `00_hero_main_interface.png` — Main interface showing 23 tools

**Note:** Lead with search-intent tools (Text Compare / JSON Diff / UUID / Timestamp) before AI screens to improve conversion from keyword traffic.

---

## App Preview Video (Optional but Recommended)

Create a 15-30 second video showing:
- AI Chat with rich Markdown response (code block, table, list) and code copy button
- AI Translate with OpenAI TTS voice playback in action
- Text Compare with side-by-side visual diff
- JSON Formatter diff mode
- Quick navigation between tools using sidebar search
- Real-time conversion (color picker, base64, timestamp)

---

## Support Information

**Support URL:** https://github.com/hengfeiyang/devutilities/issues

**Marketing URL:** https://hengfeiyang.github.io/devutilities

**Privacy Policy URL:** https://hengfeiyang.github.io/devutilities/privacy_policy.html

---

## Review Information

### Notes for Review:

```
Thank you for reviewing DevUtilities v2.12.0!

WHAT'S NEW IN THIS VERSION:
This update improves AI workflows with a new Markdown UI in AI Chat
including copy-code support, plus OpenAI Text-to-Speech in AI Translate.

HOW TO TEST AI CHAT MARKDOWN UI + COPY CODE:
1. Launch DevUtilities
2. Open AI Chat (requires user's own API key in Settings → AI)
3. Ask: "Show me a Markdown example with a code block, a table, and a list"
4. Observe: code syntax highlighting, properly formatted tables, clean lists
5. Find the copy action on the code section and click it
6. Paste into any editor to verify copied content is complete and formatted
7. During streaming: no flicker or layout jumps while tokens stream in

HOW TO TEST OPENAI TTS IN AI TRANSLATE:
1. Open Settings → AI → Text-to-Speech
2. Set TTS Mode to "OpenAI" (requires OpenAI API key)
3. Select a voice (e.g., nova, alloy, shimmer)
4. Open AI Translate tool
5. Enter text and click Translate
6. Click the speaker icon — playback should start in realtime
7. Test macOS mode by switching TTS Mode to "macOS"
8. Test Auto mode: automatically picks OpenAI if key available, else macOS

OTHER TOOLS (23 total):
All 23 tools remain fully functional. Key tools to spot-check:
- Text Compare: side-by-side diff with CodeMirror highlighting
- JSON/HTML/SQL Formatters: diff mode for comparison
- JWT Encoder/Decoder: HMAC and RSA signing
- Parquet Viewer: drag & drop Parquet/Arrow files
- Crypto Tools: MD5, SHA, AES-GCM, RSA encrypt/decrypt
- UUID Generator: v1, v4, v5, v7 with bulk generation

PRIVACY & DATA HANDLING:
- AI Chat and AI Translate use the user's own API keys
- We do not collect, store, or have access to chat messages, translations,
  or API keys
- TTS audio is generated by OpenAI's API using the user's own key; no audio
  is stored or transmitted to our servers
- Anonymous usage analytics (feature names, navigation) sent to our own
  server: api.devutilities.feiliwu.com
- No third-party analytics services used

TEST ACCOUNT:
Not required. All features accessible without account creation.
AI features require user's own API key (OpenAI, DeepSeek, or compatible).

The application is fully functional and ready for review.
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
- Feature names used (e.g., "ai_chat", "ai_translate", "jwt_tool")

**What We DO NOT Collect:**
- ❌ Personal information (name, email, phone)
- ❌ Device identifiers (UDID, serial, MAC address)
- ❌ IP addresses or location data
- ❌ User content (text you type, files, translations, chat messages)
- ❌ API keys or credentials
- ❌ Audio data (TTS playback is local; OpenAI TTS uses user's own API key)
- ❌ Generated strings, passwords, or keys
- ❌ Comparison or diff content

### App Store Privacy Labels

**Do you collect data from this app?** YES

**Data Types Collected:**

1. **Product Interaction** → YES
   - **Linked to User:** NO
   - **Used for Tracking:** NO
   - **Purpose:** Analytics
   - **Description:** Anonymous feature usage to improve the app

**That's it. Only "Product Interaction", NOT linked to the user.**

---

## Export Compliance

**Does your app use encryption?** YES

**Is your app exempt from export compliance?** YES

**Exemption Reason:** Standard Cryptography (Apple system frameworks only)

**Details:**
- CryptoKit: AES-GCM-256, SHA-256/384/512, HMAC
- Security framework: RSA-2048/4096, SecRandomCopyBytes
- No custom encryption implementation
- ECCN: 5D992 (mass market encryption)

---

## Pricing and Availability

**Price:** Free (or set your price)

**Availability:** All territories

---

## App Review Preparation Checklist

### Before Submission:

- [ ] Version set to 2.12.0 in Xcode
- [ ] Build number set to 72
- [ ] AI Chat screenshot updated to show new Markdown UI + copy code
- [ ] Subtitle updated: "JSON Diff, Text Compare, UUID"
- [ ] Keywords updated (95 chars, confirmed)
- [ ] Privacy policy up to date
- [ ] TestFlight testing completed for AI Chat Markdown UI + copy code, AI Translate OpenAI TTS
- [ ] Export compliance declared
- [ ] Review notes written (above)
- [ ] Support URL active
- [ ] All 23 tools verified functional

---

## Build and Upload Instructions

### 1. Update Version in Xcode
```
Target → General → Identity
Version: 2.12.0
Build: 72
```

### 2. Archive and Upload
```
Product → Archive
Xcode Organizer → Validate App → Distribute App → App Store Connect → Upload
```

### 3. Submit in App Store Connect
1. Create new version 2.12.1
2. Paste subtitle, description, keywords, and What's New from this guide
3. Select build 73
4. Submit for Review

---

## Post-Submission Marketing

- Announce on Twitter/X and Hacker News (Show HN): "AI Chat gets new Markdown UI + copy-code, plus OpenAI TTS in AI Translate"
- Update GitHub releases with v2.12.1 tag
- Update website with new AI feature highlights
- Highlight: "Copy code directly from AI Chat Markdown responses"
- Emphasize low-latency TTS: "Translation → voice in realtime"

---

## ASO Change Summary vs v2.11.0

| Field | v2.11.0 | v2.12.0 | Reason |
|-------|---------|---------|--------|
| Subtitle | JSON • JWT • UUID • Regex • Base64 • Parquet | JSON Diff, Text Compare, UUID | Targets stronger query intent (`json diff`, `text compare`) instead of broad feature listing |
| Keywords | jwt,regex,hex,base64,qr,crypto,color,ip,timestamp,encoder,decoder,formatter,toolkit | base64,decode,encode,jwt,regex,parquet,sql,html,formatter,unix,timestamp,color,crypto,qr,ip,hex | Expands long-tail coverage and removes low-value generic terms |

**Expected improvement:** Better discovery for intent-based searches (`json diff`, `text compare`, `timestamp converter`, `base64 decode`) while retaining coverage for proven terms (`uuid`, `parquet`).

---

## ASO Experiment Set B (Alternative Metadata)

Use this as the next metadata experiment window after Set A (run one set per release cycle, not both at once).

**Subtitle (Set B):** Timestamp, Base64, JWT Tools

**Keywords (Set B, 93 / 100 chars):**
```
json,diff,text,compare,uuid,regex,parquet,sql,html,formatter,decode,encode,unix,crypto,hex,qr
```

**When to use Set B:**
- If Set A still underperforms on `timestamp` and `base64` related queries
- If installs are coming from utility-intent terms rather than compare/diff-intent terms
- If you want broader tool-surface coverage while keeping long-tail specificity

**Expected tradeoff vs Set A:**
- Likely better on `timestamp`, `base64`, `jwt` intent
- Likely weaker on `json diff` / `text compare` headline positioning

---

## Notes

- Based on commit log through `6ac34b2` (feat: add OpenAI TTS with real-time PCM streaming)
- Previous version: 2.11.1 (Build 71)
- Key AI improvements: Textual Markdown renderer, OpenAI TTS, Responses API
- No new tools added; 23 tools remain unchanged
- Created: 2026-03-05
