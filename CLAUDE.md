# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.

## Project Overview
DevUtilities is a native macOS application built with SwiftUI that provides 19 essential developer utilities. Version 2.7.0 with base number conversion capabilities.

## Key Tools & Status

All 19 tools are ✅ **Complete**:
1. **Timestamp Converter** - Bidirectional timestamp conversion with timezone support
2. **Unit Converter** - 7 categories (Data, Time, Length, Weight, Temperature, Area, Volume)
3. **Base Converter** - **NEW** Mutual conversion between binary, octal, decimal, and hexadecimal number systems
4. **JSON Formatter** - Format, validate, escape/unescape, **visual CodeMirror diff editor**
5. **Base64 Encode/Decode** - Text encoding/decoding with URL-safe variant
6. **Hex String Converter** - Bidirectional hex-to-string conversion with UTF-8/UTF-16/ASCII encoding support
7. **Regex Test** - Pattern matching with capture groups and common patterns
8. **UUID Generator** - Multiple versions (v1, v4, v5, v7) with bulk generation
9. **URL Tools** - Encoding/decoding and comprehensive URL parsing
10. **IP Query** - Dual IP detection and geolocation queries
11. **HTTP Request** - Full HTTP client with SSE streaming and JSON tree view
12. **QR Code** - Generation and scanning with multiple sizes and error correction
13. **SQL Formatter** - **Enhanced SQL formatting** with native ParquetViewer library support for minimal and beautify modes
14. **HTML Formatter** - Format and minify HTML with proper indentation
15. **JWT Encoder/Decoder** - **HMAC and RSA algorithms** with CryptoKit security
16. **Parquet Viewer** - Unified Rust-based ParquetViewer API for Parquet/Arrow file reading
17. **Crypto Tools** - **Complete cryptographic suite** with hash functions, symmetric and asymmetric encryption
18. **AI Chat** - **Enhanced AI assistant** with custom model support, DeepSeek reasoning models, and flexible API configuration
19. **AI Translate** - Professional translation with 3 modes (Translate, Polishing, Summarize), 19 languages, word mode with detailed explanations

## Architecture & Technical Stack
- **Platform**: macOS 14.0+ SwiftUI
- **Navigation**: NavigationSplitView with sidebar search
- **Dependencies**: CodeMirror-SwiftUI via SPM, ParquetViewer (Rust FFI)
- **Security**: CryptoKit for JWT HMAC operations, Security framework for RSA operations

## Build Commands
```bash
# Open in Xcode
open DevUtilities.xcodeproj

# Build and run
xcodebuild -project DevUtilities.xcodeproj -scheme DevUtilities build

# Using MCP tools
mcp__XcodeBuildMCP__build_run_macos
```

## Recent Updates (v2.7.0)
- **Base Converter**: NEW tool for mutual conversion between binary (base 2), octal (base 8), decimal (base 10), and hexadecimal (base 16) number systems
- **Real-time Validation**: Input validation with clear error messages for invalid number formats (binary accepts only 0-1, octal 0-7, hexadecimal 0-9 A-F)
- **Four Base Support**: Complete support for all common number bases used in programming
- **Copy to Clipboard**: Quick copy functionality for each converted result
- **State Persistence**: Automatically saves and restores conversion state between sessions
- **19 Essential Tools**: Expanded toolkit now includes all essential developer utilities

## Previous Updates (v2.4.0)
- **AI Translate Tool**: Professional translation feature with intelligent translation, polishing, and summarization
- **19 Language Support**: Auto-detect, English, Chinese (Simplified/Traditional), Japanese, Korean, Spanish, French, German, Russian, Arabic, Hindi, Portuguese, Italian, Dutch, Turkish, Vietnamese, Thai, Indonesian
- **Three Operation Modes**:
  - **Translate**: Direct translation with special word mode for detailed explanations (phonetic notation, meanings, examples, etymology)
  - **Polishing**: Improve clarity and fluency in the same language
  - **Summarize**: Create concise summaries in target language
- **Word Mode**: Automatic detection of single words with enhanced dictionary-style output
- **Real-time Streaming**: Live translation results with animated status indicators (✍️ → 👍)
- **Smart Language Detection**: Auto-detect system language for default target language
- **Action Buttons**: Retry and copy buttons for quick operations
- **Keyboard Shortcuts**: Enter to submit, Shift+Enter for newline
- **Flexible Input/Output**: Resizable split view with 500pt max input height
- **Model Integration**: Reuses AI Chat's model system (GPT-4, GPT-5, DeepSeek, custom models)

## Previous Updates (v2.3.1)
- **IME Support Fix**: Fixed TextEditor to properly support Input Method Editors (IME) for non-English languages
- **Keyboard Event Handling**: Enhanced TextEditor component with `onEnterKey` callback that respects IME composition
- **Better Internationalization**: Enter key now only sends messages when IME composition is complete
- **NSTextViewDelegate Integration**: Implemented `textView(_:doCommandBy:)` with `hasMarkedText()` check for IME state detection
- **AI Chat Input Fix**: Removed `.onKeyPress` modifier that was breaking IME events in AIChatView

## Previous Updates (v2.3.0)
- **Feature Management System**: NEW customizable tool organization with enable/disable functionality
- **Grid-based Settings**: Visual 5-column grid interface for managing tools with drag-and-drop reordering
- **Sidebar Customization**: Users can hide unused tools to reduce sidebar scrolling and clutter
- **Persistent Preferences**: Tool preferences saved automatically with UserDefaults JSON storage
- **Intuitive Controls**: Gear icon in sidebar header opens feature management modal with Reset/Done buttons
- **Drag-and-Drop Interface**: Move tools between enabled/disabled sections with visual feedback

## Previous Updates (v2.2.1)
- **Enhanced Text Metrics**: Added line count display to HTML, Base64, Hex String, JSON, and SQL formatter tools
- **Improved User Experience**: All text-based tools now show both character count and line count information
- **Consistent UI**: Unified metrics display across all formatter utilities
- **Better Content Analysis**: Enhanced text content analysis with dual character/line tracking

## Previous Updates (v2.2.0)
- **Hex String Converter**: NEW tool for bidirectional hex-to-string conversion
- **Encoding Support**: UTF-8, UTF-16, and ASCII encoding options
- **Enhanced Developer Tools**: Now 17 complete utilities for developers
- **Real-time Conversion**: Instant hex encoding/decoding as you type

## Previous Updates (v2.1.0)
- **Timestamp history**: Added timestamp convert history
- **IP Query**: Fixed ip query for China

## Previous Updates (v2.0.0)
- **Custom AI Models**: Added support for custom AI model configuration with flexible API settings
- **Model Management**: Enhanced model selection interface with custom model addition and configuration
- **API Flexibility**: Support for custom API endpoints, headers, and authentication methods
- **User Experience**: Improved model selector UI with better organization of built-in and custom models
- **Configuration Persistence**: Reliable storage and retrieval of custom model configurations

## Previous Updates (v1.14.2)
- **SQL Formatter Enhancement**: Major upgrade using native ParquetViewer library for SQL formatting
- **Library Integration**: Replaced complex custom SQL tokenization with efficient Rust-based formatting
- **Dual Format Modes**: Enhanced support for both minimal and beautify SQL formatting styles
- **Performance Improvement**: 95% code reduction while improving reliability and speed
- **Error Handling**: Robust fallback mechanisms for SQL formatting operations

## Previous Updates (v1.14.0)
- **UI Refactoring**: Major UI improvements and code refactoring for better user experience
- **Model Selection Fix**: Fixed model selector display not updating when selecting different models
- **Duplicate Icon Fix**: Removed duplicate chevron icons in dropdown menus for cleaner interface
- **Enhanced Navigation**: Improved navigation layout and component organization
- **Code Cleanup**: Streamlined SwiftUI components and improved code maintainability

## Previous Updates (v1.13.2)
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

## Documentation Update Protocol
When updating the version or adding new features, you must update ALL of these files:
1. README.md (main repository documentation)
2. CLAUDE.md (this file - project guidance)
3. DESIGN.md (technical design document)
4. website/README.md (website repository documentation)
5. website/index.html (main website page)
6. website/release-notes.html (release notes page)

This ensures consistency across all documentation and user-facing materials.
