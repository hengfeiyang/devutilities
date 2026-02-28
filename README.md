# DevUtilities

A native macOS application for developers, containing 23 essential tools commonly used in software development.

> This tool was 100% developed by `Claude Code`.

## Features

- **Timestamp Converter** - Bidirectional timestamp conversion with timezone support and multiple format options
- **Unit Converter** - Convert between different units across 7 categories (Data, Time, Length, Weight, Temperature, Area, Volume)
- **Base Converter** - Mutual conversion between binary, octal, decimal, hexadecimal, and Base62 with real-time validation
- **Color Picker** - Professional color format converter with support for HEX, RGB, RGBA, HSL, HSLA, HSB, and CMYK formats, including color history
- **Text Compare** - **NEW** Dedicated side-by-side text comparison tool with visual diff highlighting and real-time status
- **JSON Formatter** - Format, validate, escape/unescape, and **compare JSON** with visual CodeMirror diff editor
- **Base64 Encode/Decode** - Text encoding/decoding with URL-safe variant and automatic detection
- **Hex String Converter** - Bidirectional hex-to-string conversion with UTF-8/UTF-16/ASCII encoding support and real-time processing
- **Regex Test** - Pattern matching with capture groups, flags, and common pattern library
- **UUID Generator** - Multiple versions (v1, v4, v5, v7) with bulk generation and timestamp extraction
- **Random String Generator** - Cryptographically secure random string generation with 5 presets and advanced requirements
- **URL Tools** - Encoding/decoding and comprehensive URL parsing with component breakdown
- **IP Query** - Dual IP detection (international vs China networks) and geolocation queries
- **HTTP Request** - Full HTTP client with SSE streaming, JSON tree view, and request history
- **QR Code** - Generation and scanning with multiple sizes, error correction, and file operations
- **SQL Formatter** - Enhanced SQL formatting with **diff mode** using native ParquetViewer library for minimal and beautify modes
- **HTML Formatter** - Format and minify HTML with **diff mode** for side-by-side comparison and proper indentation
- **JWT Encoder/Decoder** - Complete JWT support with HMAC and RSA algorithms using CryptoKit security
- **Parquet Viewer** - Unified Rust-based ParquetViewer API for Parquet/Arrow file reading with schema inspection
- **Crypto Tools** - Comprehensive cryptographic suite with hash functions (MD5, CRC32, SHA-1/256/384/512), symmetric encryption (AES-GCM-256), and asymmetric encryption (RSA-2048/4096)
- **AI Chat** - Intelligent AI assistant with custom model support, DeepSeek reasoning models, flexible API configuration, and enhanced user experience
- **AI Translate** - Professional translation tool with 3 modes (Translate, Polishing, Summarize), 19 language support, text-to-speech playback, special word mode, and real-time streaming
- **Currency Converter** - **NEW** Real-time currency conversion with 38 currencies, 24-hour caching, 30-day price history, 24-hour trend indicators, and flexible number input formats

## Key Features

- **Customizable Tool Management** - **NEW** Enable/disable tools and organize them with drag-and-drop interface
- **Search Functionality** - Quickly find tools using the search bar in the sidebar
- **Selectable Results** - Copy results directly from the output areas
- **Modern UI** - Clean, intuitive interface designed for macOS
- **Real-time Conversion** - Instant results as you type
- **Text-to-Speech** - **NEW** Native macOS TTS for AI Translate with multi-language voice support

## Version

Current version: 2.11.1

## What's New in v2.11.1

- **AI Chat Stop Fix**: Clicking stop now preserves partial output already received instead of clearing it
- **Model List Sync**: Built-in model list automatically syncs on startup, removing deprecated models (e.g. gpt-4.1) added in previous versions

## What's New in v2.11.0

- **Text Compare Tool**: NEW dedicated tool for side-by-side text comparison with visual diff highlighting
- **Enhanced JSON Formatter**: Added diff mode with visual CodeMirror diff editor for comparing two JSON documents
- **Enhanced HTML Formatter**: Added diff mode for side-by-side HTML comparison with syntax highlighting
- **Enhanced SQL Formatter**: Added diff mode for comparing SQL queries with automatic formatting
- **Unified Diff Experience**: All formatters now share consistent diff interface with real-time status updates
- **Optimized Comparison Logic**: Extracted reusable `updateComparisonStatus()` pattern across all diff views
- **Sample Data**: Each diff mode includes meaningful sample data to demonstrate functionality
- **Character & Line Metrics**: Display detailed metrics for both sides of comparison
- **State Persistence**: All diff modes remember content between sessions

## What's New in v2.10.0

- **Currency Converter**: NEW tool for real-time currency conversion with comprehensive features
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

- **Random String Generator**: NEW tool for secure random string generation with cryptographic security
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

- **Base62 Support**: Enhanced Base Converter with Base62 number system support (0-9, A-Z, a-z)
- **Five Base Systems**: Now supports conversion between binary, octal, decimal, hexadecimal, and Base62
- **Real-time Conversion**: All five number bases convert simultaneously as you type
- **Comprehensive Validation**: Each base has specific character validation rules

## What's New in v2.8.0

- **Color Picker**: NEW professional color format converter with real-time conversion between HEX, RGB, RGBA, HSL, HSLA, HSB, and CMYK formats
- **Color History**: Built-in color history tracking to quickly access and reuse previously selected colors
- **Visual Color Preview**: Large color preview box with system color panel integration for precise color selection
- **Format Flexibility**: Edit any color format directly - changes instantly reflect across all other formats
- **20 Essential Tools**: Comprehensive toolkit covering all essential developer utilities
