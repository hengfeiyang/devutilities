# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.

## Project Overview
DevHelper is a native macOS application built with SwiftUI that provides 16 essential developer utilities. Version 1.13.2 with comprehensive cryptographic tools and enhanced AI chat assistant.

## Key Tools & Status

All 16 tools are ✅ **Complete**:
1. **Timestamp Converter** - Bidirectional timestamp conversion with timezone support
2. **Unit Converter** - 7 categories (Data, Time, Length, Weight, Temperature, Area, Volume)
3. **JSON Formatter** - Format, validate, escape/unescape, **visual CodeMirror diff editor**
4. **Base64 Encode/Decode** - Text encoding/decoding with URL-safe variant
5. **Regex Test** - Pattern matching with capture groups and common patterns
6. **UUID Generator** - Multiple versions (v1, v4, v5, v7) with bulk generation
7. **URL Tools** - Encoding/decoding and comprehensive URL parsing
8. **IP Query** - Dual IP detection and geolocation queries
9. **HTTP Request** - Full HTTP client with SSE streaming and JSON tree view
10. **QR Code** - Generation and scanning with multiple sizes and error correction
11. **SQL Formatter** - Format and minify SQL with syntax validation
12. **HTML Formatter** - Format and minify HTML with proper indentation
13. **JWT Encoder/Decoder** - **HMAC and RSA algorithms** with CryptoKit security
14. **Parquet Viewer** - Unified Rust-based ParquetViewer API for Parquet/Arrow file reading
15. **Crypto Tools** - **Complete cryptographic suite** with hash functions, symmetric and asymmetric encryption
16. **AI Chat** - **Enhanced AI assistant** with DeepSeek reasoning models, transparent thinking process, and improved stop functionality

## Architecture & Technical Stack
- **Platform**: macOS 14.0+ SwiftUI
- **Navigation**: NavigationSplitView with sidebar search
- **Dependencies**: CodeMirror-SwiftUI via SPM, ParquetViewer (Rust FFI)
- **Security**: CryptoKit for JWT HMAC operations, Security framework for RSA operations

## Build Commands
```bash
# Open in Xcode
open DevHelper.xcodeproj

# Build and run
xcodebuild -project DevHelper.xcodeproj -scheme DevHelper build

# Using MCP tools
mcp__XcodeBuildMCP__build_run_macos
```

## Recent Updates (v1.13.2)
- **DeepSeek Integration**: Added deepseek-chat and deepseek-reasoner models with OpenAI API compatibility
- **Reasoning Process**: DeepSeek reasoner shows transparent "deepthink" Chain of Thought reasoning
- **Collapsible Thinking**: Expandable/collapsible thinking process section with brain icon and smooth animations
- **Stop Functionality**: Improved stop button that immediately cancels streaming responses for all models
- **Task Cancellation**: Proper URLSessionDataTask and Swift Task cancellation architecture
- **Real-time Reasoning**: See AI's internal thinking process as it streams during response generation

## Previous Updates (v1.13.0)
- **AI Chat**: New intelligent AI assistant for development questions and code review
- **Chat Interface**: Interactive conversation with context-aware responses
- **Developer Context**: Specialized knowledge for software development workflows
- **Code Analysis**: Real-time code review and technical guidance
- **Multi-language Support**: Assistance across various programming languages and frameworks
- **Message History**: Persistent chat sessions with conversation management

## Previous Updates (v1.12.0)
- **Crypto Tools**: New comprehensive cryptographic utility suite addressing GitHub issues #13 and #14
- **Hash Functions**: MD5, CRC32, SHA-1, SHA-256, SHA-384, SHA-512 with real-time computation
- **Symmetric Encryption**: AES-GCM-256 encrypt/decrypt with key generation and Base64 encoding
- **Asymmetric Encryption**: RSA-2048/4096 encrypt/decrypt using Security framework
- **Unified Interface**: Three-tab design (Hash/Symmetric/Asymmetric) with consistent UX patterns
- **API Authentication**: Perfect for generating tokens for third-party interface calls

## Previous Updates (v1.11.1)
- **JWT Encoder/Decoder**: Enhanced with RSA algorithm support (RS256, RS384, RS512)
- **RSA Cryptography**: Implemented using iOS Security framework for key management and signing
- **Dynamic UI**: Interface adapts to show appropriate fields (secret key for HMAC, RSA keys for RSA)
- **Key Management**: Support for PEM-formatted RSA keys with auto-population sample keys
- **Algorithm Detection**: Real-time detection of JWT algorithm type for verification

## Previous Updates (v1.10.3)
- **Parquet Viewer**: Simplified with unified ParquetViewer API
- **Dependency Cleanup**: Removed DuckDB-swift and arrow-swift dependencies  
- **Architecture**: Single Rust-based backend for both Parquet and Arrow files
- **Performance**: Faster loading with direct JSON output from ParquetViewer
- **UI Simplification**: Removed SQL editor, focusing on core file viewing functionality

## Previous Updates (v1.10.2)
- **JSON Formatter**: Enhanced with visual CodeMirror diff editor
- **CodeDiffEditor**: New component for side-by-side JSON comparison
- **Improved UX**: Replaced text-based diff with visual highlighting

## Development Notes
- Each tool is self-contained in `Views/` directory
- Consistent UI patterns: two-column layouts, copy buttons, sample data
- Uses `@State` for local view state management
- All tools have real-time processing and validation
- App Sandbox enabled with network and file permissions