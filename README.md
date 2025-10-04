# DevUtilities

A native macOS application for developers, containing 18 essential tools commonly used in software development.

> This tool was 100% developed by `Claude Code`.

## Features

- **Timestamp Converter** - Bidirectional timestamp conversion with timezone support and multiple format options
- **Unit Converter** - Convert between different units across 7 categories (Data, Time, Length, Weight, Temperature, Area, Volume)
- **JSON Formatter** - Format, validate, escape/unescape, and compare JSON data with visual CodeMirror diff editor
- **Base64 Encode/Decode** - Text encoding/decoding with URL-safe variant and automatic detection
- **Hex String Converter** - **NEW** Bidirectional hex-to-string conversion with UTF-8/UTF-16/ASCII encoding support and real-time processing
- **Regex Test** - Pattern matching with capture groups, flags, and common pattern library
- **UUID Generator** - Multiple versions (v1, v4, v5, v7) with bulk generation and timestamp extraction
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
- **AI Translate** - **NEW** Professional translation tool with 3 modes (Translate, Polishing, Summarize), 19 language support, special word mode with detailed explanations, and real-time streaming results

## Key Features

- **Customizable Tool Management** - **NEW** Enable/disable tools and organize them with drag-and-drop interface
- **Search Functionality** - Quickly find tools using the search bar in the sidebar
- **Selectable Results** - Copy results directly from the output areas
- **Modern UI** - Clean, intuitive interface designed for macOS
- **Real-time Conversion** - Instant results as you type

## Version

Current version: 2.4.0

## What's New in v2.4.0

- **🌐 AI Translate**: NEW professional translation tool with intelligent translation, text polishing, and summarization
- **🔤 19 Languages Supported**: Auto-detect, English, Chinese (Simplified/Traditional), Japanese, Korean, Spanish, French, German, Russian, Arabic, Hindi, and more
- **📖 Word Mode**: Special detailed mode for single word translation with phonetic notation, meanings, example sentences, and etymology
- **⚡ Real-time Streaming**: See translation results as they're generated with animated status indicators
- **🎯 Three Operation Modes**:
  - **Translate**: Direct translation between languages with word mode for detailed explanations
  - **Polishing**: Improve clarity and fluency in the same language
  - **Summarize**: Create concise summaries in target language
- **🔄 Retry & Copy**: Quick action buttons for retrying translation or copying results
- **🤖 AI Model Integration**: Reuses AI Chat's flexible model system (GPT-4, GPT-5, DeepSeek, custom models)
