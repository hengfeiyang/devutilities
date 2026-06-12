# DevUtilities - App Store Submission Guide v2.14.0

## Basic App Information

**App Name:** DevUtilities

**Subtitle:** JSON YAML TOML CSV Converter

**Bundle ID:** com.hengfeiyang.devutilities

**Version:** 2.14.0 (Build 77)

**Category:** Developer Tools

**Minimum OS:** macOS 14.0+

**Copyright:** Copyright © 2026 Hengfei Yang. All rights reserved.

---

## App Description

### Short Description (170 chars max)
25 developer tools: NEW Data Converter (JSON/YAML/TOML/CSV), Struct Converter, JSON diff, JWT, UUID, Base64, Regex, Parquet, AI chat, AI translate, crypto.

### Full Description

DevUtilities is a native macOS application providing 25 essential utilities for software developers. Built entirely with Swift and native macOS technologies, it offers a clean, fast interface with real-time processing.

Core Features:

- Data Converter — NEW. Convert between JSON, YAML, TOML, and CSV in any direction. Preserves key order, flattens nested data to dotted-key CSV columns, and optionally infers types when reading CSV back.
- Struct Converter — Turn JSON, TOML, YAML, or SQL CREATE TABLE into typed code for TypeScript, Python, Go, Java, Rust, Swift, and PHP. Walks nested objects, infers types, applies per-language naming, and emits proper tags (serde, JSON, CodingKeys).
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

- Convert config and data files between JSON, YAML, TOML, and CSV without losing key order — no more alphabetized diffs
- Flatten nested API responses into spreadsheet-ready CSV with one click
- Generate typed structs in 7 languages from a sample JSON, TOML, YAML, or SQL DDL
- Side-by-side diff for Text, JSON, HTML, and SQL
- Enhanced AI Chat with beautiful Markdown rendering and one-click copy for code blocks
- OpenAI TTS for AI Translate — ultra-low latency voice playback in 13 voices
- Cryptographically secure random string and key generation
- Parquet and Arrow file viewer — rare on macOS
- All tools work offline (except AI, currency, and IP features)
- Customizable sidebar with drag-and-drop tool ordering
- Quick search to jump between 25 tools instantly
- Native macOS performance — no Electron, no web views

Perfect for developers who need a reliable Swiss Army knife of utilities without switching context.

---

## What's New in This Version

Version 2.14.0:

Data Converter — NEW Tool:
- Convert between JSON, YAML, TOML, and CSV in any direction with a from/to picker and one-click swap button
- Order-preserving conversion: objects keep their original key order instead of being alphabetized — powered by a custom JSON scanner and Yams-backed YAML pipeline
- TOML output handles top-level scalars, [table] sections, and [[array of tables]]; date literals stay unquoted
- Nested objects and arrays flatten to dotted-key CSV columns (address.city, tags.0) with an ordered union header and RFC-4180 quoting
- "Infer types" toggle when reading CSV: coerce cells like 123 or true into native types, or keep everything as strings
- Two-column layout matching the JSON Formatter UX with sample data, real-time conversion, copy button, and persistent state

Struct Converter:
- Refactored onto the same shared, order-preserving data pipeline as the Data Converter; YAML input now parses via Yams for better spec coverage
- Generated struct output is unchanged (fields stay alphabetized, ISO 8601 strings still promote to a date type)

---

## Keywords

(max 100 characters)

```
struct,typescript,golang,rust,serde,codable,base64,jwt,regex,parquet,hex,diff,uuid,crypto,unix,ddl
```

**Character count:** 98 / 100

**Why these keywords (not in app name or subtitle):**
- `struct`, `serde`, `codable`, `typescript`, `golang`, `rust`, `ddl` — code-generation searches matching the Struct Converter
- `diff`, `uuid`, `crypto`, `unix` — high-intent searches for Text/JSON Compare, UUID Generator, Crypto Tools, and Timestamp Converter, freed up by the new subtitle
- `base64`, `jwt`, `regex`, `parquet`, `hex` — proven high-intent developer terms retained from prior releases

**Keywords intentionally excluded:**
- `devutils` — same as app name, already indexed
- `json`, `yaml`, `toml`, `csv`, `converter` — covered in the new subtitle
- `developer`, `tools` — broad and highly competitive

---

## Screenshots

**Required Sizes:** 1280x800, 1440x900, 2560x1600, or 2880x1800

**Recommended Order for Submission:**
1. `15_data_converter.png` — NEW Data Converter (lead with new feature)
2. `14_struct_converter.png` — Struct Converter
3. `01_ai_chat.png` — AI Chat with Markdown UI and code copy
4. `05_json_formatter.png` — JSON Formatter with diff mode
5. `13_text_compare.png` — Text Compare
6. `03_ai_translate.png` — AI Translate with OpenAI TTS
7. `04_timestamp_converter.png` — Timestamp Converter
8. `00_hero_main_interface.png` — Main interface showing 25 tools

**Note:** Lead with the new Data Converter to maximize "What's New" impact, then follow with high-converting search-intent tools.

---

## App Preview Video (Optional but Recommended)

Create a 15-30 second video showing:
- Data Converter: paste JSON → switch target to YAML/TOML/CSV → swap direction → copy
- Data Converter: nested JSON flattened into dotted-key CSV columns
- Struct Converter: paste JSON → emit Go/Rust/Swift structs
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
Thank you for reviewing DevUtilities v2.14.0!

WHAT'S NEW IN THIS VERSION:
This release adds the Data Converter — a new tool that converts between
JSON, YAML, TOML, and CSV in any direction while preserving key order.
The Struct Converter was refactored onto the same shared parsing pipeline.

HOW TO TEST DATA CONVERTER:
1. Launch DevUtilities
2. Open "Data Converter" from the sidebar
3. Default sample data is pre-filled — observe right-pane output
4. Use the From/To pickers to switch between JSON, YAML, TOML, and CSV
5. Click the swap button to reverse direction
6. Verify key order is preserved, e.g. paste:
   {"zebra":1,"apple":2,"mango":3}
   and confirm YAML/TOML output keeps zebra, apple, mango order
7. Try a nested JSON like:
   {"name":"Ada","address":{"city":"London"},"tags":["a","b"]}
   with target CSV — verify dotted-key columns: address.city, tags.0, tags.1
8. Convert that CSV back to JSON with the "Infer types" toggle on and off —
   numbers/booleans coerce when on, stay strings when off
9. Click Copy — converted output lands in clipboard

HOW TO TEST STRUCT CONVERTER (REFACTORED):
1. Open "Struct Converter"
2. Confirm JSON/TOML/YAML inputs still generate typed structs across all
   seven output languages (TypeScript, Python, Go, Java, Rust, Swift, PHP)

OTHER TOOLS (25 total):
All 25 tools remain fully functional. Key tools to spot-check:
- AI Chat: Markdown rendering, code block copy
- AI Translate: OpenAI TTS playback (requires user's OpenAI API key)
- Text Compare: side-by-side diff with CodeMirror highlighting
- JSON/HTML/SQL Formatters: diff mode for comparison
- JWT Encoder/Decoder: HMAC and RSA signing
- Parquet Viewer: drag & drop Parquet/Arrow files
- UUID Generator: v1, v4, v5, v7 with bulk generation

PRIVACY & DATA HANDLING:
- Data Converter and Struct Converter run entirely on-device. No data
  leaves the Mac.
- AI Chat and AI Translate use the user's own API keys
- We do not collect, store, or have access to chat messages, translations,
  converted data, or API keys
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
- Feature names used (e.g., "ai_chat", "data_converter", "struct_converter", "jwt_tool")

**What We DO NOT Collect:**
- ❌ Personal information (name, email, phone)
- ❌ Device identifiers (UDID, serial, MAC address)
- ❌ IP addresses or location data
- ❌ User content (text you type, files, translations, chat messages, sample data, converted output)
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

- [x] Version set to 2.14.0 in Xcode
- [x] Build number set to 77
- [x] Data Converter screenshot included as lead (15_data_converter.png)
- [ ] Subtitle updated: "JSON YAML TOML CSV Converter"
- [ ] Keywords updated (98 chars, confirmed)
- [ ] Privacy policy up to date
- [ ] TestFlight testing completed for Data Converter (all 4×4 format pairs) and Struct Converter regression
- [ ] Export compliance declared (unchanged from v2.13.0)
- [ ] Review notes written (above)
- [ ] Support URL active
- [ ] All 25 tools verified functional

---

## Build and Upload Instructions

### 1. Update Version in Xcode
```
Target → General → Identity
Version: 2.14.0
Build: 77
```

### 2. Archive and Upload
```
Product → Archive
Xcode Organizer → Validate App → Distribute App → App Store Connect → Upload
```

### 3. Submit in App Store Connect
1. Create new version 2.14.0
2. Paste subtitle, description, keywords, and What's New from this guide
3. Select build 77
4. Submit for Review

---

## Post-Submission Marketing

- Announce on Twitter/X and Hacker News (Show HN): "DevUtilities 2.14 converts JSON/YAML/TOML/CSV in any direction — without reordering your keys"
- Update GitHub releases with v2.14.0 tag
- Update website with Data Converter highlight
- Demo GIF: paste JSON → flip through YAML/TOML/CSV → swap direction → copy
- Emphasize: "Order-preserving conversion — your diffs stay clean"

---

## ASO Change Summary vs v2.13.0

| Field | v2.13.0 | v2.14.0 | Reason |
|-------|---------|---------|--------|
| Subtitle | JSON to Struct, Diff, AI, JWT | JSON YAML TOML CSV Converter | Leads with the new Data Converter — four format names are exactly what users type into search |
| Keywords | struct,interface,typescript,golang,rust,serde,codable,toml,yaml,ddl,base64,jwt,regex,parquet,hex | struct,typescript,golang,rust,serde,codable,base64,jwt,regex,parquet,hex,diff,uuid,crypto,unix,ddl | `toml`/`yaml` moved to subtitle, freeing room to reclaim proven terms `diff`, `uuid`, `crypto`, `unix` from earlier releases |

**Expected improvement:** Strong discovery for `json to yaml`, `yaml to toml`, `json to csv`, `csv to json`, and `toml converter` — high-volume conversion searches with direct install intent.

---

## Notes

- Based on commit `6d1d922` (update screenshot)
- Previous version: 2.13.0 (Build 76)
- New tool: Data Converter (JSON/YAML/TOML/CSV, any-to-any, order-preserving)
- Struct Converter refactored onto shared DataValue pipeline (no output changes)
- Tool count: 24 → 25
- Created: 2026-06-12
