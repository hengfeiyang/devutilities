# DevUtilities

A native macOS application for developers, containing 21 essential tools commonly used in software development.

> This tool was 100% developed by `Claude Code`.

## Features

- **Timestamp Converter** - Bidirectional timestamp conversion with timezone support and multiple format options
- **Unit Converter** - Convert between different units across 7 categories (Data, Time, Length, Weight, Temperature, Area, Volume)
- **Base Converter** - Mutual conversion between binary, octal, decimal, hexadecimal, and Base62 with real-time validation
- **Color Picker** - **NEW** Professional color format converter with support for HEX, RGB, RGBA, HSL, HSLA, HSB, and CMYK formats, including color history
- **JSON Formatter** - Format, validate, escape/unescape, and compare JSON data with visual CodeMirror diff editor
- **Base64 Encode/Decode** - Text encoding/decoding with URL-safe variant and automatic detection
- **Hex String Converter** - Bidirectional hex-to-string conversion with UTF-8/UTF-16/ASCII encoding support and real-time processing
- **Regex Test** - Pattern matching with capture groups, flags, and common pattern library
- **UUID Generator** - Multiple versions (v1, v4, v5, v7) with bulk generation and timestamp extraction
- **Random String Generator** - **NEW** Cryptographically secure random string generation with 5 presets and advanced requirements
- **URL Tools** - Encoding/decoding and comprehensive URL parsing with component breakdown
- **IP Query** - Dual IP detection (international vs China networks) and geolocation queries
- **HTTP Request** - Full HTTP client with SSE streaming, JSON tree view, and request history
- **QR Code** - Generation and scanning with multiple sizes, error correction, and file operations
- **SQL Formatter** - **Enhanced SQL formatting** using native ParquetViewer library with minimal and beautify modes and proper indentation
- **HTML Formatter** - Format and minify HTML with proper tag indentation and structure validation
- **JWT Encoder/Decoder** - Complete JWT support with HMAC and RSA algorithms using CryptoKit security
- **Parquet Viewer** - Unified Rust-based ParquetViewer API for Parquet/Arrow file reading with schema inspection
- **Crypto Tools** - Comprehensive cryptographic suite with hash functions (MD5, CRC32, SHA-1/256/384/512), symmetric encryption (AES-GCM-256), and asymmetric encryption (RSA-2048/4096)
- **AI Chat** - Intelligent AI assistant with custom model support, DeepSeek reasoning models, flexible API configuration, and enhanced user experience
- **AI Translate** - **NEW TTS** Professional translation tool with 3 modes (Translate, Polishing, Summarize), 19 language support, text-to-speech playback, special word mode, and real-time streaming

## Key Features

- **Customizable Tool Management** - **NEW** Enable/disable tools and organize them with drag-and-drop interface
- **Search Functionality** - Quickly find tools using the search bar in the sidebar
- **Selectable Results** - Copy results directly from the output areas
- **Modern UI** - Clean, intuitive interface designed for macOS
- **Real-time Conversion** - Instant results as you type
- **Text-to-Speech** - **NEW** Native macOS TTS for AI Translate with multi-language voice support

## Version

Current version: 2.9.0

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
