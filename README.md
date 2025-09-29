# DevHelper

A native macOS application for developers, containing 17 essential tools commonly used in software development.

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

## Key Features

- **Customizable Tool Management** - **NEW** Enable/disable tools and organize them with drag-and-drop interface
- **Search Functionality** - Quickly find tools using the search bar in the sidebar
- **Selectable Results** - Copy results directly from the output areas
- **Modern UI** - Clean, intuitive interface designed for macOS
- **Real-time Conversion** - Instant results as you type

## Version

Current version: 2.3.0

## What's New in v2.3.0

- **🎛️ Feature Management System**: NEW customizable tool organization system
- **⚙️ Settings Interface**: Gear icon in sidebar opens visual grid-based tool management
- **📱 Grid Layout**: 5-column responsive grid showing all 17 tools with icons and names
- **🔄 Drag-and-Drop**: Move tools between enabled/disabled sections with visual feedback
- **👁️ Hide Unused Tools**: Reduce sidebar clutter by disabling tools you don't need
- **💾 Auto-Save**: Preferences automatically saved and restored between sessions
- **🔄 Reset Option**: One-click restore to default layout with all tools enabled
