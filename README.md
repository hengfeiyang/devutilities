# DevUtilities

A native macOS application for developers, containing 25 essential tools commonly used in software development.

> This tool was 100% developed by `Claude Code`.

## Features

- **Timestamp** - Bidirectional timestamp conversion with timezone support and multiple format options
- **Unit Converter** - Convert between different units across 7 categories (Data, Time, Length, Weight, Temperature, Area, Volume)
- **Number Base** - Mutual conversion between binary, octal, decimal, hexadecimal, and Base62 with real-time validation
- **Color** - Professional color format converter with support for HEX, RGB, RGBA, HSL, HSLA, HSB, and CMYK formats, including color history
- **Text Compare** - **NEW** Dedicated side-by-side text comparison tool with visual diff highlighting and real-time status
- **JSON** - Format, validate, escape/unescape, and **compare JSON** with visual CodeMirror diff editor
- **Base64** - Text encoding/decoding with URL-safe variant and automatic detection
- **Hex String** - Bidirectional hex-to-string conversion with UTF-8/UTF-16/ASCII encoding support and real-time processing
- **Regex** - Pattern matching with capture groups, flags, and common pattern library
- **UUID** - Multiple versions (v1, v4, v5, v7) with bulk generation and timestamp extraction
- **Random String** - Cryptographically secure random string generation with 5 presets and advanced requirements
- **URL** - Encoding/decoding and comprehensive URL parsing with component breakdown
- **IP Lookup** - Dual IP detection (international vs China networks) and geolocation queries
- **HTTP Client** - Full HTTP client with SSE streaming, JSON tree view, and request history
- **QR Code** - Generation and scanning with multiple sizes, error correction, and file operations
- **SQL** - Enhanced SQL formatting with **diff mode** using native ParquetViewer library for minimal and beautify modes
- **HTML** - Format and minify HTML with **diff mode** for side-by-side comparison and proper indentation
- **JWT** - Complete JWT support with HMAC and RSA algorithms using CryptoKit security
- **Parquet** - Unified Rust-based ParquetViewer API for Parquet/Arrow file reading with schema inspection
- **Crypto** - Comprehensive cryptographic suite with hash functions (MD5, CRC32, SHA-1/256/384/512), symmetric encryption (AES-GCM-256), and asymmetric encryption (RSA-2048/4096)
- **AI Chat** - Intelligent AI assistant with enhanced Markdown rendering, one-click copy for code snippets, OpenAI Responses API support, DeepSeek reasoning models, and custom model configuration
- **AI Translate** - Professional translation tool with 3 modes (Translate, Polishing, Summarize), 19 language support, OpenAI TTS with 13 voices, and special word mode
- **Currency** - Real-time currency conversion with 38 currencies, 24-hour caching, 30-day price history, 24-hour trend indicators, and flexible number input formats
- **Struct Converter** - Convert JSON, TOML, YAML, and SQL DDL into typed code structures for TypeScript, Python, Go, Java, Rust, Swift, and PHP
- **Data Converter** - **NEW** Convert between JSON, YAML, TOML, and CSV data formats with order preservation, nested-to-CSV flattening, and CSV type inference

## Key Features

- **Spotlight Commands** - **NEW** 11 App Intents commands run inline in Spotlight (macOS 26) with results copied to the clipboard automatically; also available in Shortcuts and Siri
- **Customizable Tool Management** - Enable/disable tools and organize them with drag-and-drop interface
- **Search Functionality** - Quickly find tools using the search bar in the sidebar
- **Selectable Results** - Copy results directly from the output areas
- **Modern UI** - Clean, intuitive interface designed for macOS
- **Real-time Conversion** - Instant results as you type
- **Text-to-Speech** - OpenAI TTS (13 voices) and native macOS TTS for AI Translate

## Version

Current version: 2.15.0

## What's New in v2.15.0

- **Spotlight Integration**: 11 commands built on App Intents — run conversions directly in Spotlight without opening the app (macOS 26 Tahoe)
- **11 Commands, 9 Tools**: Convert Timestamp (smart two-way, `now` supported), Convert Number Base, Convert Unit (all 7 categories), Encode/Decode Base64, URL Encode/Decode, Decode JWT, Hash Text (MD5/CRC32/SHA-1/256/384/512), Generate UUID (v4/v7), Generate Random String
- **Inline Results**: Results render in place under the Spotlight bar and are copied to the clipboard automatically
- **Shortcuts & Siri**: Every command is a native App Intent, automatable in the Shortcuts app and callable through Siri
- **Shared Service Layer**: New `QuickToolService` extracts UI-independent conversion logic shared by tool views and intents
- **Cleanup**: Removed stale `NSUserActivityTypes` entries from Info.plist left over from an earlier Spotlight experiment

## What's New in v2.14.1

- **Concise Tool Names**: Shortened sidebar labels such as Base64, JWT, JSON, UUID, Crypto, and Parquet
- **Consistent Naming**: Removed mixed suffixes such as “Encode/Decode,” “Encoder/Decoder,” “Formatter,” “Generator,” and “Tools” where the format or technology already identifies the tool
- **Clearer Network Labels**: Renamed HTTP Request to HTTP Client and IP Query to IP Lookup
- **Website Sync**: Updated tool cards, dedicated tool pages, documentation, and release metadata to use the same names as the app

## What's New in v2.14.0

- **Data Converter**: NEW tool for converting between JSON, YAML, TOML, and CSV
- **Bidirectional**: Choose any source and target format with a from/to picker and one-click swap
- **Order Preserving**: A new shared `DataValue` model keeps object key order across conversions; JSON is parsed with a custom order-preserving scanner
- **YAML via Yams**: YAML parsing/serialization uses the Yams library through `Node` to preserve order and quoting
- **CSV Flatten/Unflatten**: Nested data flattens to dotted-key columns (`address.city`, `tags.0`) with an ordered union header and RFC-4180 quoting; an "Infer types" toggle coerces `123`/`true` or keeps cells as strings
- **Struct Converter** now shares the same parsing pipeline (output unchanged)

## What's New in v2.13.0

- **Struct Converter**: NEW tool that turns sample data into typed code (closes #17)
- **Four Input Formats**: JSON, TOML, YAML, and SQL DDL (CREATE TABLE)
- **Seven Output Languages**: TypeScript interface, Python dataclass, Go struct (with JSON tags), Java POJO with getters/setters, Rust struct (with serde derives), Swift Codable struct, PHP typed class
- **Type Inference**: Automatically detects strings, numbers, booleans, ISO 8601 dates, arrays, nested objects, and nullable fields
- **Nested Struct Generation**: Walks nested objects and arrays-of-objects to emit a sub-type for every level
- **Per-language Naming**: camelCase for TypeScript/Swift/PHP, snake_case for Python/Rust, PascalCase fields for Go/Java — with serde/CodingKeys/JSON tags preserving original keys
- **SQL DDL Parser**: Handles multi-statement input, maps SQL column types to language-native types, respects NOT NULL for nullability

## What's New in v2.12.0

- **AI Chat — Enhanced Markdown Rendering**: Migrated to Textual rendering engine with improved code syntax highlighting, tables, and nested lists
- **AI Chat — Copy Code Snippets**: One-click Copy button on every code block — grab code without selecting text
- **AI Chat — OpenAI Responses API**: Support for the new Responses API with streaming, reasoning, and GPT-5.2-pro compatibility
- **AI Translate — OpenAI TTS**: Real-time PCM streaming TTS with 13 voices (alloy, nova, shimmer, etc.)
- **TTS Settings**: Configure TTS mode (Auto/OpenAI/macOS), voice selection, and macOS premium voice in Settings → AI

## What's New in v2.11.1

- **AI Chat Stop Fix**: Clicking stop now preserves partial output already received instead of clearing it
- **Model List Sync**: Built-in model list automatically syncs on startup, removing deprecated models (e.g. gpt-4.1) added in previous versions

## What's New in v2.11.0

- **Text Compare Tool**: NEW dedicated tool for side-by-side text comparison with visual diff highlighting
- **Enhanced JSON**: Added diff mode with visual CodeMirror diff editor for comparing two JSON documents
- **Enhanced HTML**: Added diff mode for side-by-side HTML comparison with syntax highlighting
- **Enhanced SQL**: Added diff mode for comparing SQL queries with automatic formatting
- **Unified Diff Experience**: All formatters now share consistent diff interface with real-time status updates
- **Optimized Comparison Logic**: Extracted reusable `updateComparisonStatus()` pattern across all diff views
- **Sample Data**: Each diff mode includes meaningful sample data to demonstrate functionality
- **Character & Line Metrics**: Display detailed metrics for both sides of comparison
- **State Persistence**: All diff modes remember content between sessions

## What's New in v2.10.0

- **Currency**: NEW tool for real-time currency conversion with comprehensive features
- **38 Currencies Supported**: Major global currencies including USD, EUR, GBP, JPY, CNY, KRW (Korean Won), INR (Indian Rupee), and 33 others
- **24-Hour Smart Caching**: Intelligent exchange rate caching to minimize API calls while keeping data fresh
- **30-Day Price History**: Incremental daily snapshots automatically build a complete 30-day historical view
- **24-Hour Trend Indicators**: Visual up/down arrows with percentage change compared to yesterday
- **Flexible Number Input**: Supports both formatted numbers (1,000,000) and plain numbers (1000000)
- **Optimized Performance**: History loads only when currency pair changes, providing instant conversion on amount changes
- **Clean Two-Column Layout**: Intuitive UI with currency pickers, swap button, and quick amount shortcuts (1, 100, 1K, 10K)
- **Offline Mode**: Continues working with cached data when network is unavailable, with clear indicators
- **State Persistence**: Automatically remembers your last conversion settings between app sessions

## What's New in v2.9.0

- **Random String**: NEW tool for secure random string generation with cryptographic security
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

## What's New in v2.8.1

- **Base62 Support**: Enhanced Number Base with Base62 number system support (0-9, A-Z, a-z)
- **Five Base Systems**: Now supports conversion between binary, octal, decimal, hexadecimal, and Base62
- **Real-time Conversion**: All five number bases convert simultaneously as you type
- **Comprehensive Validation**: Each base has specific character validation rules

## What's New in v2.8.0

- **Color**: NEW professional color format converter with real-time conversion between HEX, RGB, RGBA, HSL, HSLA, HSB, and CMYK formats
- **Color History**: Built-in color history tracking to quickly access and reuse previously selected colors
- **Visual Color Preview**: Large color preview box with system color panel integration for precise color selection
- **Format Flexibility**: Edit any color format directly - changes instantly reflect across all other formats
- **20 Essential Tools**: Comprehensive toolkit covering all essential developer utilities
