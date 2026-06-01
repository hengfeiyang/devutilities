# DevUtilities - App Store Submission Guide v2.13.0

## Basic App Information

**App Name:** DevUtilities

**Subtitle:** JSON to Struct, Diff, AI, JWT

**Bundle ID:** com.hengfeiyang.devutilities

**Version:** 2.13.0 (Build 76)

**Category:** Developer Tools

**Minimum OS:** macOS 14.0+

**Copyright:** Copyright © 2026 Hengfei Yang. All rights reserved.

---

## App Description

### Short Description (170 chars max)
24 developer tools: NEW Struct Converter (JSON/TOML/YAML/SQL → TS, Go, Rust, Swift…), JSON diff, JWT, UUID, Base64, Regex, Parquet, AI chat, AI translate, crypto.

### Full Description

DevUtilities is a native macOS application providing 24 essential utilities for software developers. Built entirely with Swift and native macOS technologies, it offers a clean, fast interface with real-time processing.

Core Features:

- Struct Converter — NEW. Turn JSON, TOML, YAML, or SQL CREATE TABLE into typed code for TypeScript, Python, Go, Java, Rust, Swift, and PHP. Walks nested objects, infers types, applies per-language naming, and emits proper tags (serde, JSON, CodingKeys).
- AI Chat — Intelligent assistant with Markdown UI, one-click code block copy, DeepSeek reasoning, OpenAI Responses API, and custom model support
- AI Translate — Professional translation with OpenAI Text-to-Speech (13 voices), real-time streaming, and 19 languages
- JSON Formatter — Format, validate, escape/unescape, and diff mode with visual CodeMirror editor
- Text Compare — Side-by-side text comparison with visual diff highlighting and real-time status
- JWT Encoder/Decoder — HMAC and RSA algorithms (RS256, RS384, RS512) with CryptoKit security
- UUID Generator — Multiple versions (v1, v4, v5, v7) with bulk generation
- Regex Test — Pattern matching with capture groups and common patterns
- Base64 Encode/Decode — Text encoding with URL-safe variant
- Hex String Converter — Bidirectional hex-to-string with UTF-8/UTF-16/ASCII
- Color Picker — Professional color format converter for HEX, RGB, RGBA, HSL, HSLA, HSB, and CMYK
- Parquet Viewer — Unified Rust-based API for Parquet and Arrow files
- Crypto Tools — Complete suite with MD5, SHA, AES-GCM-256, AES-SIV-256, and RSA-2048/4096 encryption
- SQL Formatter — Minimal and beautify modes with diff comparison
- HTML Formatter — Proper indentation with diff comparison
- Timestamp Converter — Bidirectional conversion with timezone support
- Unit Converter — 7 categories (Data, Time, Length, Weight, Temperature, Area, Volume)
- Base Converter — Binary, octal, decimal, hexadecimal, and Base62
- Random String Generator — Cryptographically secure with presets and requirements
- Currency Converter — Real-time conversion with 38 currencies and 30-day history
- URL Tools — Encoding/decoding and comprehensive parsing
- IP Query — Geolocation with dual network detection
- HTTP Request — Full HTTP client with SSE streaming and JSON tree view
- QR Code — Generation and scanning with multiple formats

Key Benefits:

- Generate typed structs in 7 languages from a sample JSON, TOML, YAML, or SQL DDL — no more hand-translating API payloads
- Side-by-side diff for Text, JSON, HTML, and SQL
- Enhanced AI Chat with beautiful Markdown rendering and one-click copy for code blocks
- OpenAI TTS for AI Translate — ultra-low latency voice playback in 13 voices
- Cryptographically secure random string and key generation
- Parquet and Arrow file viewer — rare on macOS
- All tools work offline (except AI, currency, and IP features)
- Customizable sidebar with drag-and-drop tool ordering
- Quick search to jump between 24 tools instantly
- Native macOS performance — no Electron, no web views

Perfect for developers who need a reliable Swiss Army knife of utilities without switching context.

---

## What's New in This Version

Version 2.13.0:

Struct Converter — NEW Tool:
- Convert sample data into typed code structures in seconds
- Four input formats: JSON, TOML, YAML, and SQL CREATE TABLE (multi-statement supported)
- Seven output languages: TypeScript (interface), Python (dataclass), Go (struct with JSON tags), Java (POJO with getters/setters), Rust (serde struct), Swift (Codable struct), PHP (typed class)
- Smart type inference: detects strings, integers, doubles, booleans, ISO 8601 dates, arrays, nested objects, and nullable fields automatically
- Walks nested objects and arrays-of-objects to emit a sub-type for every level, with simple singularization for array names
- Per-language naming conventions: camelCase for TypeScript/Swift/PHP, snake_case for Python/Rust, PascalCase for Go/Java fields — with serde/CodingKeys/JSON tags preserving original keys
- SQL DDL parser maps SQL types (INT/VARCHAR/DECIMAL/TIMESTAMP/...) to language-native types and respects NOT NULL for nullability
- Two-column layout matching the JSON Formatter UX with sample data, real-time conversion, copy button, and persistent state
- Closes GitHub issue #17

Crypto Tools:
- Added AES-SIV-256 alongside the existing AES-GCM-256 for deterministic authenticated encryption

AI Chat:
- Updated DeepSeek model names and IDs
- Refreshed token usage tracking for more accurate session reporting

Quality Improvements:
- Layout refinements to ContentView for better navigation
- Built-in provider list synced with current model defaults

---

## Keywords

(max 100 characters)

```
struct,interface,typescript,golang,rust,serde,codable,toml,yaml,ddl,base64,jwt,regex,parquet,hex
```

**Character count:** 99 / 100

**Why these keywords (not in app name or subtitle):**
- `struct`, `interface`, `codable`, `serde` — high-intent code-generation searches matching the new Struct Converter
- `typescript`, `golang`, `rust` — language-specific searches for type generation
- `toml`, `yaml`, `ddl` — input-format searches for the converter
- `base64`, `jwt`, `regex`, `parquet`, `hex` — proven high-intent developer terms retained from prior releases

**Keywords intentionally excluded:**
- `devutils` — same as app name, already indexed
- `json`, `diff`, `text`, `compare`, `uuid` — covered in subtitle
- `converter`, `developer`, `tools` — broad and highly competitive

---

## Screenshots

**Required Sizes:** 1280x800, 1440x900, 2560x1600, or 2880x1800

**Recommended Order for Submission:**
1. `14_struct_converter.png` — NEW Struct Converter (lead with new feature)
2. `01_ai_chat.png` — AI Chat with Markdown UI and code copy
3. `13_text_compare.png` — Text Compare (matches subtitle keyword)
4. `05_json_formatter.png` — JSON Formatter with diff mode
5. `03_ai_translate.png` — AI Translate with OpenAI TTS
6. `06_uuid_generator.png` — UUID Generator
7. `04_timestamp_converter.png` — Timestamp Converter
8. `00_hero_main_interface.png` — Main interface showing 24 tools

**Note:** Lead with the new Struct Converter to maximize "What's New" impact, then follow with high-converting search-intent tools.

---

## App Preview Video (Optional but Recommended)

Create a 15-30 second video showing:
- Struct Converter: paste JSON → switch language to Go/Rust/Swift → copy generated struct
- Struct Converter: paste SQL CREATE TABLE → emit typed Java POJO
- AI Chat with rich Markdown response and code copy button
- Text Compare with side-by-side visual diff
- JSON Formatter diff mode
- Quick navigation between tools using sidebar search

---

## Support Information

**Support URL:** https://github.com/hengfeiyang/devutilities/issues

**Marketing URL:** https://hengfeiyang.github.io/devutilities

**Privacy Policy URL:** https://hengfeiyang.github.io/devutilities/privacy_policy.html

---

## Review Information

### Notes for Review:

```
Thank you for reviewing DevUtilities v2.13.0!

WHAT'S NEW IN THIS VERSION:
This release adds the Struct Converter — a new tool that turns JSON,
TOML, YAML, or SQL CREATE TABLE into typed code for TypeScript, Python,
Go, Java, Rust, Swift, and PHP. Crypto Tools also gain AES-SIV-256.

HOW TO TEST STRUCT CONVERTER:
1. Launch DevUtilities
2. Open "Struct Converter" from the sidebar
3. Default sample data is pre-filled — observe right-pane output
4. Switch input format: JSON / TOML / YAML / SQL DDL
5. Switch output language: TypeScript, Python, Go, Java, Rust, Swift, PHP
6. Try a nested JSON like:
   {"user":{"id":1,"name":"Ada","tags":["a","b"],"createdAt":"2026-01-01T00:00:00Z"}}
   Verify nested sub-type generated, ISO 8601 detected as Date type
7. Try SQL: CREATE TABLE users (id INT NOT NULL, email VARCHAR(255), created_at TIMESTAMP);
   Verify column types map to language-native types and NOT NULL is respected
8. Click Copy — generated code lands in clipboard

HOW TO TEST AES-SIV-256 (CRYPTO TOOLS):
1. Open Crypto Tools → Symmetric tab
2. Choose AES-SIV-256
3. Generate a key, encrypt sample plaintext, decrypt to verify roundtrip

OTHER TOOLS (24 total):
All 24 tools remain fully functional. Key tools to spot-check:
- AI Chat: Markdown rendering, code block copy
- AI Translate: OpenAI TTS playback (requires user's OpenAI API key)
- Text Compare: side-by-side diff with CodeMirror highlighting
- JSON/HTML/SQL Formatters: diff mode for comparison
- JWT Encoder/Decoder: HMAC and RSA signing
- Parquet Viewer: drag & drop Parquet/Arrow files
- UUID Generator: v1, v4, v5, v7 with bulk generation

PRIVACY & DATA HANDLING:
- Struct Converter runs entirely on-device. No data leaves the Mac.
- AI Chat and AI Translate use the user's own API keys
- We do not collect, store, or have access to chat messages, translations,
  generated structs, or API keys
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
- Feature names used (e.g., "ai_chat", "ai_translate", "struct_converter", "jwt_tool")

**What We DO NOT Collect:**
- ❌ Personal information (name, email, phone)
- ❌ Device identifiers (UDID, serial, MAC address)
- ❌ IP addresses or location data
- ❌ User content (text you type, files, translations, chat messages, sample data, generated code)
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
- CryptoKit: AES-GCM-256, AES-SIV-256, SHA-256/384/512, HMAC
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

- [ ] Version set to 2.13.0 in Xcode
- [ ] Build number set to 76
- [ ] Struct Converter screenshot included as lead
- [ ] Subtitle updated: "JSON to Struct, Diff, AI, JWT"
- [ ] Keywords updated (99 chars, confirmed)
- [ ] Privacy policy up to date
- [ ] TestFlight testing completed for Struct Converter (all 4 inputs × 7 outputs) and AES-SIV-256
- [ ] Export compliance declared (AES-SIV-256 added to disclosure)
- [ ] Review notes written (above)
- [ ] Support URL active
- [ ] All 24 tools verified functional

---

## Build and Upload Instructions

### 1. Update Version in Xcode
```
Target → General → Identity
Version: 2.13.0
Build: 76
```

### 2. Archive and Upload
```
Product → Archive
Xcode Organizer → Validate App → Distribute App → App Store Connect → Upload
```

### 3. Submit in App Store Connect
1. Create new version 2.13.0
2. Paste subtitle, description, keywords, and What's New from this guide
3. Select build 76
4. Submit for Review

---

## Post-Submission Marketing

- Announce on Twitter/X and Hacker News (Show HN): "DevUtilities 2.13 turns JSON/TOML/YAML/SQL into typed code for 7 languages"
- Update GitHub releases with v2.13.0 tag (closes issue #17)
- Update website with Struct Converter highlight
- Demo GIF: paste JSON → switch language across TS/Go/Rust/Swift → copy
- Emphasize: "No more hand-translating API payloads into structs"

---

## ASO Change Summary vs v2.12.0

| Field | v2.12.0 | v2.13.0 | Reason |
|-------|---------|---------|--------|
| Subtitle | AI • Timestamp • Base64 • JWT • UUID • Parquet | JSON to Struct, Diff, AI, JWT | Leads with the new Struct Converter — a uniquely searchable, intent-driven feature |
| Keywords | base64,decode,encode,jwt,regex,parquet,sql,html,formatter,unix,timestamp,color,crypto,qr,ip,hex | struct,interface,typescript,golang,rust,serde,codable,toml,yaml,ddl,base64,jwt,regex,parquet,hex | Captures struct/code-generation intent across 7 target languages while retaining proven high-intent terms |

**Expected improvement:** Strong discovery for `json to struct`, `json to typescript`, `sql to struct`, `yaml to go`, and `serde struct generator` — niches with low competition and high install intent.

---

## Notes

- Based on commit `b907ec6` (update screenshot)
- Previous version: 2.12.0 (Build 72)
- New tool: Struct Converter (4 inputs × 7 output languages)
- Crypto: AES-SIV-256 added
- Tool count: 23 → 24
- Created: 2026-05-09
