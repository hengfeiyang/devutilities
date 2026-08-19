# DevUtilities

A native macOS application for developers, containing 25 essential tools commonly used in software development.

> This tool was 100% developed by `Claude Code`.

## Download

[Download on the App Store](https://apps.apple.com/app/devutilities/id6753612551)

## Features

- **AI Chat** - Intelligent AI assistant with OpenAI-compatible and Anthropic Messages protocols, enhanced Markdown rendering, and custom model configuration
- **AI Translate** - Professional translation using the same two-protocol model router, with 3 modes, 19 languages, OpenAI TTS (13 voices), and special word mode
- **Timestamp** - Convert between timestamps and human-readable dates with multiple format support
- **Unit Converter** - Convert between different units (Data, Time, Length, Weight, Temperature, Area, Volume)
- **Number Base** - Mutual conversion between binary, octal, decimal, hexadecimal, and Base62 number systems with real-time validation
- **Color** - Professional color format converter with HEX, RGB, RGBA, HSL, HSLA, HSB, and CMYK support and color history
- **Text Compare** - **NEW** Dedicated side-by-side text comparison with visual diff highlighting and real-time status
- **JSON** - Format, validate, and **compare JSON** with visual CodeMirror diff editor
- **SQL** - Format and minify SQL queries with **diff mode** and syntax validation
- **HTML** - Format and minify HTML with **diff mode** and proper tag indentation
- **Base64** - Encode and decode Base64 strings
- **Hex String** - Bidirectional hex-to-string conversion with UTF-8/UTF-16/ASCII encoding support and real-time processing
- **JWT** - Encode and decode JSON Web Tokens with HMAC and RSA signature support
- **Regex** - Test regular expressions with pattern matching
- **UUID** - Generate UUIDs in various formats including v7 with timestamp extraction
- **Random String** - **NEW** Cryptographically secure random string generation with 5 presets and advanced requirements
- **URL** - URL encoding/decoding and parsing
- **HTTP Client** - Full-featured HTTP client with method selection, headers, auth, response handling, and JSON tree view
- **IP Lookup** - Discover your IP address and query geolocation data for any IP
- **QR Code** - Generate QR codes with multiple sizes and error correction levels, scan QR codes from images
- **Parquet** - Read and explore Parquet / arrow files with schema inspection and data export
- **Crypto** - Comprehensive cryptographic suite with hash functions (MD5, CRC32, SHA-1/256/384/512), symmetric encryption (AES-GCM-256), and asymmetric encryption (RSA-2048/4096)
- **Currency** - Real-time currency conversion with 38 currencies, 24-hour caching, 30-day price history, and 24-hour trend indicators
- **Struct Converter** - Convert JSON, TOML, YAML, and SQL DDL into typed code structures for TypeScript, Python, Go, Java, Rust, Swift, and PHP
- **Data Converter** - **NEW** Convert between JSON, YAML, TOML, and CSV data formats with order preservation, nested-to-CSV flattening, and CSV type inference

## Key Features

- **Customizable Tool Management** - Enable/disable tools and organize them with drag-and-drop interface
- **Search Functionality** - Quickly find tools using the search bar in the sidebar
- **Selectable Results** - Copy results directly from the output areas
- **Modern UI** - Clean, intuitive interface designed for macOS
- **Real-time Conversion** - Instant results as you type
- **Text-to-Speech** - OpenAI TTS (13 voices) and native macOS TTS for AI Translate

## Version

Current version: 2.16.0

## What's New in v2.16.0

- **Two AI Protocol Families**: OpenAI Compatible and Anthropic Messages are explicit provider choices
- **Popular Provider Presets**: OpenAI, DeepSeek, Qwen, Kimi, GLM, Gemini, and Anthropic/Claude
- **Unified Chat + Translate Routing**: Both tools now call the same protocol-aware streaming layer
- **OpenAI Endpoint Choice**: Chat Completions and Responses remain model-level options inside the OpenAI-compatible family
- **Safe Migration**: Existing provider/model settings are upgraded automatically
- **Protocol-aware Testing**: Correct authentication headers and `/models` checks for each family

## What's New in v2.15.0

- **Spotlight Integration**: 11 commands built on App Intents — run conversions directly in Spotlight without opening the app (macOS 26 Tahoe)
- **11 Commands, 9 Tools**: Convert Timestamp, Convert Number Base, Convert Unit, Encode/Decode Base64, URL Encode/Decode, Decode JWT, Hash Text, Generate UUID, Generate Random String
- **Inline Results**: Results render in place under the Spotlight bar and are copied to the clipboard automatically
- **Shortcuts & Siri**: Every command is a native App Intent, automatable in the Shortcuts app and callable through Siri

## What's New in v2.14.1

- **Concise Tool Names**: Shortened sidebar labels such as Base64, JWT, JSON, UUID, Crypto, and Parquet
- **Consistent Naming**: Removed redundant action suffixes when the format or technology already identifies the tool
- **Clearer Network Labels**: Renamed HTTP Request to HTTP Client and IP Query to IP Lookup
- **Website Sync**: Updated the tool index and dedicated tool pages to match the app

## What's New in v2.14.0

- **Data Converter**: NEW tool for converting between JSON, YAML, TOML, and CSV
- **Bidirectional**: Choose any source and target format with a from/to picker and one-click swap
- **Order Preserving**: A shared `DataValue` model keeps object key order across conversions; JSON is parsed with a custom order-preserving scanner
- **YAML via Yams**: YAML parsing/serialization uses the Yams library through `Node` to preserve order and quoting
- **CSV Flatten/Unflatten**: Nested data flattens to dotted-key columns (`address.city`, `tags.0`) with an ordered union header and RFC-4180 quoting; an "Infer types" toggle coerces `123`/`true` or keeps cells as strings

## What's New in v2.13.0

- **Struct Converter**: NEW tool that turns sample data into typed code (closes #17)
- **Four Input Formats**: JSON, TOML, YAML, and SQL DDL (CREATE TABLE)
- **Seven Output Languages**: TypeScript interface, Python dataclass, Go struct (with JSON tags), Java POJO with getters/setters, Rust struct (serde derives), Swift Codable struct, PHP typed class
- **Type Inference**: Detects strings, numbers, booleans, ISO 8601 dates, arrays, nested objects, and nullable fields automatically
- **Nested Struct Generation**: Walks every nested object and array-of-objects, emitting a sub-type per level
- **Per-language Naming**: Idiomatic field names with serde/CodingKeys/JSON tags preserving original keys
- **SQL DDL Parser**: Handles multi-statement input, maps SQL types to language-native types, respects NOT NULL

## What's New in v2.12.0

- **AI Chat — Enhanced Markdown Rendering**: Migrated to Textual engine with better code highlighting, tables, and nested lists
- **AI Chat — Copy Code Snippets**: One-click Copy button on every code block
- **AI Chat — OpenAI Responses API**: Support for Responses API with streaming, reasoning
- **AI Translate — OpenAI TTS**: Real-time PCM streaming TTS, 13 voices
- **TTS Settings**: Configure mode (Auto/OpenAI/macOS), voice, and premium macOS voice in Settings → AI

## What's New in v2.11.1

- **AI Chat Stop Fix**: Clicking stop now preserves partial output already received instead of clearing it
- **Model List Sync**: Built-in model list automatically syncs on startup, removing deprecated models (e.g. gpt-4.1) added in previous versions

## What's New in v2.11.0

- **Text Compare Tool**: NEW dedicated tool for side-by-side text comparison with visual diff highlighting
- **Enhanced JSON**: Added diff mode with visual CodeMirror diff editor for comparing JSON documents
- **Enhanced HTML**: Added diff mode for side-by-side HTML comparison with syntax highlighting
- **Enhanced SQL**: Added diff mode for comparing SQL queries with automatic formatting
- **Unified Diff Experience**: Consistent diff interface across all formatters with real-time status updates
- **Optimized Comparison**: Reusable comparison logic pattern for better code maintainability
- **Sample Data**: Each diff mode includes meaningful sample data pairs
- **Character & Line Metrics**: Detailed metrics display for both sides of comparison

## What's New in v2.10.0

- **Currency**: NEW tool for real-time currency conversion with comprehensive features
- **38 Currencies Supported**: Major global currencies including USD, EUR, GBP, JPY, CNY, KRW (Korean Won), INR (Indian Rupee), and 33 others
- **24-Hour Smart Caching**: Intelligent exchange rate caching to minimize API calls while keeping data fresh
- **30-Day Price History**: Incremental daily snapshots automatically build a complete 30-day historical view
- **24-Hour Trend Indicators**: Visual up/down arrows with percentage change compared to yesterday
- **Flexible Number Input**: Supports both formatted numbers (1,000,000) and plain numbers (1000000)
- **Optimized Performance**: History loads only when currency pair changes, providing instant conversion on amount changes
- **Clean Two-Column Layout**: Intuitive UI with currency pickers, swap button, and quick amount shortcuts
- **Offline Mode**: Continues working with cached data when network is unavailable

## What's New in v2.9.0

- **Random String**: NEW tool for cryptographically secure random string generation
- **Customizable Character Sets**: Choose from uppercase, lowercase, numbers, and symbols
- **5 Built-in Presets**: Strong Password, API Key, Hex String, PIN Code, and Readable Code templates
- **Advanced Requirements**: Enforce minimum requirements for uppercase, numbers, or special characters
- **Bulk Generation**: Create up to 20 random strings simultaneously
- **Flexible Length**: Configure string length from 1 to 100 characters
- **Secure by Design**: Uses SecRandomCopyBytes for cryptographically secure randomness

## What's New in v2.8.2

- **Text-to-Speech (TTS)**: Integrated native macOS TTS in AI Translate for listening to both source and translated text
- **Multi-language TTS**: Supports all 19 translation languages with proper voice selection
- **Animated Speaker Icons**: Visual feedback with smooth wave animations during playback
- **Smart Sanitization**: Prevents audio errors by escaping special characters
- **Thread-safe**: Optimized implementation without performance warnings


## Screenshots

#### customizable features
![DevUtilities](./images/screenshots/customize.png)

#### AI Chat
![DevUtilities AI Chat](./images/screenshots/aichat.png)

![DevUtilities AI Chat custom models](./images/screenshots/aichat-models.png)

#### AI Translate
![DevUtilities AI Translate](./images/screenshots/aitranslate.png)

#### Timestamp
![DevUtilities Timestamp](./images/screenshots/timestamp.png)

#### Unit Converter
![DevUtilities Unit Converter](./images/screenshots/unit.png)

#### Number Base
![DevUtilities Number Base](./images/screenshots/base-converter.png)

#### Color
![DevUtilities Color](./images/screenshots/color-picker.png)

#### Json Formatter
![DevUtilities Json Formatter](./images/screenshots/json.png)

#### SQL
![DevUtilities SQL](./images/screenshots/sql.png)

#### HTML
![DevUtilities HTML](./images/screenshots/html.png)

#### Base64
![DevUtilities Base64 encode](./images/screenshots/base64.png)

#### Hex String
![DevUtilities Hex String](./images/screenshots/hex.png)

#### JWT
![DevUtilities JWT encoder](./images/screenshots/jwt.png)

#### URL
![DevUtilities Url Tools](./images/screenshots/url.png)

#### Regex
![DevUtilities Regex](./images/screenshots/regex.png)

#### UUID
![DevUtilities UUID](./images/screenshots/uuid.png)

#### Http Request
![DevUtilities Http Request](./images/screenshots/http.png)

#### IP Lookup
![DevUtilities IP Lookup](./images/screenshots/ip.png)

#### QR Code
![DevUtilities QR Code](./images/screenshots/qrcode.png)

#### Parquet
![DevUtilities Paruqet data view](./images/screenshots/parquet.png)


#### Crypto
![Crypto](./images/screenshots/crypto.png)
