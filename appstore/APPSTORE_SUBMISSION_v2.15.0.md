# DevUtilities - App Store Submission Guide v2.15.0

## Basic App Information

**App Name:** DevUtilities

**Subtitle:** Dev Tools in Your Spotlight

**Bundle ID:** com.hengfeiyang.devutilities

**Version:** 2.15.0 (Build 79)

**Category:** Developer Tools

**Minimum OS:** macOS 15.0+
(Note: earlier guides said 14.0+, but `MACOSX_DEPLOYMENT_TARGET` is 15.0 — App Store Connect will show 15.0 automatically. Spotlight inline commands require macOS 26 Tahoe; on macOS 15 the same commands are available through the Shortcuts app and Siri.)

**Copyright:** Copyright © 2026 Hengfei Yang. All rights reserved.

---

## App Description

### Promotional Text (170 chars max)

NEW: 11 Spotlight commands. Press ⌘Space, type "generate uuid" or "convert timestamp" — the result appears inline and lands on your clipboard. The app never opens.

**Character count:** 166 / 170

### Full Description

DevUtilities is a native macOS application providing 25 essential utilities for software developers. Built entirely with Swift and native macOS technologies, it offers a clean, fast interface with real-time processing.

NEW — Spotlight Commands (macOS 26):

Run 11 commands directly in Spotlight without opening the app: convert a timestamp, hash a string, generate a UUID or random string, encode/decode Base64 and URLs, decode a JWT, convert number bases and units. Results render inline under the Spotlight bar and are copied to your clipboard automatically. Every command is a native App Intent, so it also works in the Shortcuts app and through Siri on macOS 15+.

Core Features:

- Spotlight Commands — NEW. 11 inline commands: Convert Timestamp (smart two-way, type "now" for current time), Convert Number Base, Convert Unit (7 categories), Encode/Decode Base64, URL Encode/Decode, Decode JWT, Hash Text (MD5/CRC32/SHA-1/256/384/512), Generate UUID (v4/v7), Generate Random String
- Data Converter — Convert between JSON, YAML, TOML, and CSV in any direction. Preserves key order, flattens nested data to dotted-key CSV columns, and optionally infers types when reading CSV back
- Struct Converter — Turn JSON, TOML, YAML, or SQL CREATE TABLE into typed code for TypeScript, Python, Go, Java, Rust, Swift, and PHP
- AI Chat — Intelligent assistant with Markdown UI, one-click code block copy, DeepSeek reasoning, OpenAI Responses API, and custom model support
- AI Translate — Professional translation with OpenAI Text-to-Speech (13 voices), real-time streaming, and 19 languages
- JSON — Format, validate, escape/unescape, and diff mode with visual CodeMirror editor
- Text Compare — Side-by-side text comparison with visual diff highlighting
- JWT — Encode and decode with HMAC and RSA algorithms (RS256/384/512)
- UUID — Multiple versions (v1, v4, v5, v7) with bulk generation
- Regex — Pattern matching with capture groups and common patterns
- Base64 — Text encoding with URL-safe variant
- Hex String — Bidirectional hex-to-string with UTF-8/UTF-16/ASCII
- Color — Professional converter for HEX, RGB, RGBA, HSL, HSLA, HSB, and CMYK
- Parquet — Unified Rust-based viewer for Parquet and Arrow files
- Crypto — MD5, SHA, AES-GCM-256, AES-SIV-256, and RSA-2048/4096
- SQL — Minimal and beautify modes with diff comparison
- HTML — Proper indentation with diff comparison
- Timestamp — Bidirectional conversion with timezone support and history
- Unit Converter — 7 categories (Data, Time, Length, Weight, Temperature, Area, Volume)
- Number Base — Binary, octal, decimal, hexadecimal, and Base62
- Random String — Cryptographically secure with presets and requirements
- Currency — Real-time conversion with 38 currencies and 30-day history
- URL — Encoding/decoding and comprehensive parsing
- IP Lookup — Geolocation with dual network detection
- HTTP Client — Full HTTP client with SSE streaming and JSON tree view
- QR Code — Generation and scanning with multiple formats

Key Benefits:

- The quick hits never need a window: ⌘Space, type, done — result on your clipboard
- Spotlight quick keys (macOS 26): assign "ts" to Convert Timestamp and it's two keystrokes away
- Automate everything: all 11 commands are Shortcuts actions and Siri-callable
- Convert config files between JSON, YAML, TOML, and CSV without losing key order
- Generate typed structs in 7 languages from sample JSON, TOML, YAML, or SQL DDL
- Side-by-side diff for Text, JSON, HTML, and SQL
- All tools work offline (except AI, currency, and IP features)
- Native macOS performance — no Electron, no web views

Perfect for developers who need a reliable Swiss Army knife of utilities without switching context.

---

## What's New in This Version

Version 2.15.0:

Spotlight Commands — NEW:
- 11 commands run directly in Spotlight on macOS 26 — no app window needed
- Convert Timestamp: smart two-way conversion; paste a Unix timestamp (s/ms/µs/ns auto-detected) or a date string, or type "now"
- Convert Unit: all 7 categories — e.g. "Convert 1024 MB to GB"
- Convert Number Base: binary, octal, decimal, hex, and Base62 at once
- Encode/Decode Base64 (URL-safe supported), URL Encode/Decode
- Decode JWT: pretty-printed header and payload
- Hash Text: MD5, CRC32, SHA-1/256/384/512
- Generate UUID (v4/v7) and Generate Random String (secure, symbols optional)
- Results render inline under the Spotlight bar and are copied to your clipboard automatically (per-command toggle)
- Every command is a native App Intent: automatable in Shortcuts, callable through Siri, quick-key assignable in Spotlight

---

## Keywords

(max 100 characters)

```
json,yaml,toml,csv,base64,jwt,regex,uuid,hash,diff,parquet,struct,unix,crypto,timestamp,spotlight
```

**Character count:** 97 / 100

**Why these keywords (not in app name or subtitle):**
- `json`, `yaml`, `toml`, `csv` — reclaimed from the v2.14 subtitle (which now features Spotlight); these remain the highest-intent conversion searches
- `spotlight` — new differentiator; catches "spotlight" utility searches
- `timestamp`, `hash`, `uuid`, `unix` — exactly what the new commands do; high-intent
- `base64`, `jwt`, `regex`, `diff`, `parquet`, `struct`, `crypto` — proven terms retained from prior releases

**Keywords intentionally excluded:**
- `hex` — dropped to make room for `spotlight` (lowest-converting retained term)
- `developer`, `tools`, `commands` — broad, competitive, or covered by subtitle

---

## Screenshots

**Required Sizes:** 1280x800, 1440x900, 2560x1600, or 2880x1800

**Recommended Order for Submission:**
1. `16_spotlight_commands.png` — NEW Spotlight Commands hero (lead with new feature; already 2880x1800, no resize needed)
2. `00_hero_main_interface.png` — Main interface showing 25 tools
3. `15_data_converter.png` — Data Converter
4. `14_struct_converter.png` — Struct Converter
5. `01_ai_chat.png` — AI Chat with Markdown UI and code copy
6. `05_json_formatter.png` — JSON diff mode
7. `13_text_compare.png` — Text Compare
8. `04_timestamp_converter.png` — Timestamp

**Notes:**
- The Spotlight hero is generated from `screenshots/16-spotlight.svg` (edit SVG → re-render if copy changes)
- Lead with Spotlight to maximize "What's New" impact; the second slot shows the full app so browsers immediately see the 25-tool breadth

---

## App Preview Video (Optional but Recommended)

Create a 15-30 second video showing:
- ⌘Space → type "convert timestamp" → paste a Unix timestamp → result inline → ⌘V into an editor
- ⌘Space → "Generate MD5 hash of hello" → result inline
- ⌘Space → "Convert 1024 MB to GB"
- Quick cut to the app: sidebar with 25 tools, JSON diff mode
- End card: "11 Spotlight commands · 25 tools · one app"

---

## Support Information

**Support URL:** https://github.com/hengfeiyang/devutilities/issues

**Marketing URL:** https://hengfeiyang.github.io/devutilities

**Privacy Policy URL:** https://hengfeiyang.github.io/devutilities/privacy_policy.html

---

## Review Information

### Notes for Review:

```
Thank you for reviewing DevUtilities v2.15.0!

WHAT'S NEW IN THIS VERSION:
This release adds Spotlight Commands — 11 App Intents that run the app's
most-used conversions directly in Spotlight (macOS 26), in the Shortcuts
app, and through Siri. No new tools inside the app; all 25 existing tools
are unchanged.

HOW TO TEST SPOTLIGHT COMMANDS (requires macOS 26 Tahoe):
1. Launch DevUtilities once (registers the App Intents), then quit it
2. Press Cmd+Space and type "Generate UUID" — select the DevUtilities
   action and press Return
3. The UUID appears inline in Spotlight and is copied to the clipboard;
   the app does not open
4. Try "Convert Timestamp": run the action, type 1721200000 as the
   parameter, press Return — UTC and local time render inline
5. Try "Hash Text": Tab through parameters (text, algorithm) — e.g.
   MD5 of "aaa" returns 47bce5c74f589f4867dbd57e9ca9f808

HOW TO TEST ON macOS 15 (no Spotlight actions):
1. Open the Shortcuts app → create a shortcut → search actions for
   "DevUtilities" — 11 actions appear grouped under Converters, Encoders,
   Decoders, Generators
2. Add "Generate UUID" and run — result returns and is copied to clipboard

CLIPBOARD NOTE:
Each command has a "Copy Result to Clipboard" parameter (default ON for
most commands). This is user-visible and toggleable per invocation; the
copy happens locally via NSPasteboard. No clipboard data is transmitted.

OTHER TOOLS (25 total):
All tools remain fully functional and unchanged from v2.14.x. Key tools
to spot-check: JSON diff, Data Converter, Struct Converter, JWT, Parquet
viewer, AI Chat/Translate (require user's own API key).

PRIVACY & DATA HANDLING:
- All Spotlight commands run entirely on-device; no data leaves the Mac
- AI Chat and AI Translate use the user's own API keys
- We do not collect, store, or have access to user content or API keys
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

Unchanged from v2.14.0:

**Data Collection:** Anonymous usage analytics only

**What We Collect:**
- Anonymous usage events (app starts, feature usage, navigation)
- Randomly generated anonymous user ID (UUID, not linked to Apple ID)
- Session ID (temporary), app version, feature names used

**What We DO NOT Collect:**
- ❌ Personal information, device identifiers, IP/location
- ❌ User content (text, files, conversions, chat, Spotlight command inputs/results)
- ❌ API keys, credentials, generated strings/passwords
- ❌ Clipboard contents

### App Store Privacy Labels

**Data Types Collected:** Product Interaction only — not linked to user, not used for tracking, purpose: Analytics.

---

## Export Compliance

Unchanged from v2.14.0:

**Does your app use encryption?** YES
**Is your app exempt?** YES — Standard Cryptography (Apple system frameworks only: CryptoKit, Security framework). ECCN 5D992.

---

## Pricing and Availability

**Price:** $29.99 (unchanged)

**Availability:** All territories

---

## App Review Preparation Checklist

### Before Submission:

- [x] Version set to 2.15.0 in Xcode (MARKETING_VERSION)
- [x] Build number set to 79
- [x] Spotlight hero screenshot created (16_spotlight_commands.png, 2880x1800)
- [ ] Subtitle updated: "Dev Tools in Your Spotlight"
- [ ] Promotional Text updated (166 chars, confirmed)
- [ ] Keywords updated (97 chars, confirmed)
- [ ] Spotlight commands tested on macOS 26: inline run + clipboard copy
- [ ] Shortcuts actions verified (11 actions listed under DevUtilities)
- [ ] Verify /Applications copy is the release build (a stale copy shadows App Intents registration)
- [ ] Export compliance declared (unchanged)
- [ ] Review notes written (above)
- [ ] All 25 tools spot-checked

---

## Build and Upload Instructions

### 1. Verify Version in Xcode
```
Target → General → Identity
Version: 2.15.0
Build: 79
```

### 2. Archive and Upload
```
Product → Archive
Xcode Organizer → Validate App → Distribute App → App Store Connect → Upload
```

### 3. Submit in App Store Connect
1. Create new version 2.15.0
2. Paste subtitle, promotional text, description, keywords, and What's New from this guide
3. Upload screenshots in the recommended order (lead: 16_spotlight_commands.png)
4. Select build 79
5. Submit for Review

---

## Post-Submission Marketing

- Product Hunt launch — Spotlight Commands is the hook: "DevUtilities 2.15 — run dev conversions right in macOS Spotlight"
- Show HN: "DevUtilities 2.15 puts timestamp/UUID/Base64/JWT conversions inline in macOS 26 Spotlight"
- Twitter/X demo GIF: ⌘Space → "Generate MD5 hash of aaa" → inline result → ⌘V
- Update GitHub releases with v2.15.0 tag
- Website already updated (hero badge, §02 feature section, changelog)
- Emphasize: "The app never opens — the result is already on your clipboard"

---

## ASO Change Summary vs v2.14.0

| Field | v2.14.0 | v2.15.0 | Reason |
|-------|---------|---------|--------|
| Subtitle | JSON YAML TOML CSV Converter | Dev Tools in Your Spotlight | Leads with the unique differentiator no competitor has; conversion format terms move back to keywords |
| Keywords | struct,typescript,golang,rust,serde,codable,base64,jwt,regex,parquet,hex,diff,uuid,crypto,unix,ddl | json,yaml,toml,csv,base64,jwt,regex,uuid,hash,diff,parquet,struct,unix,crypto,timestamp,spotlight | Reclaims json/yaml/toml/csv from old subtitle; adds spotlight/timestamp/hash matching the new commands; drops niche code-gen terms (typescript/golang/rust/serde/codable/ddl) that under-performed |
| Promotional Text | (feature list) | Spotlight commands pitch | Updatable without review; use it to A/B the Spotlight message |

**Expected improvement:** Retains high-volume conversion searches (json to yaml, csv to json) via keywords while the subtitle differentiates in browse results. `spotlight` is low-competition with clear intent alignment.

**Risk note:** If conversion-search rankings drop measurably after 2–3 weeks, revert subtitle to "JSON YAML TOML CSV Converter" and swap `spotlight` keyword back to code-gen terms — Promotional Text can carry the Spotlight message alone.

---

## Notes

- Based on commit `1631932` (feat: add Spotlight commands via App Intents)
- Previous version: 2.14.0 (Build 77) / 2.14.1 naming release
- New feature: 11 Spotlight/App Intents commands (no new in-app tools; count stays 25)
- Spotlight hero image is SVG-generated: `screenshots/16-spotlight.svg` → render via `qlmanage -t -s 2880` → center-crop to 2880x1800
- Created: 2026-07-17
