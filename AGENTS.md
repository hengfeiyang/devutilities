# AGENTS.md

This file provides guidance to Codex when working with this repository.

## Project Overview
DevUtilities is a native macOS application built with SwiftUI that provides 25 essential developer utilities. Version 2.16.0 unifies AI integrations behind two provider protocol families: OpenAI Compatible and Anthropic Messages, shared by AI Chat and AI Translate.

## Key Tools & Status

All 25 tools are ✅ **Complete**:
1. **Timestamp** - Bidirectional timestamp conversion with timezone support
2. **Unit Converter** - 7 categories (Data, Time, Length, Weight, Temperature, Area, Volume)
3. **Number Base** - Mutual conversion between binary, octal, decimal, hexadecimal, and Base62 number systems
4. **Color** - Professional color format converter with HEX, RGB, RGBA, HSL, HSLA, HSB, and CMYK support and color history
5. **Text Compare** - **NEW** Dedicated side-by-side text comparison with visual diff highlighting
6. **JSON** - Format, validate, escape/unescape, **diff mode with visual CodeMirror editor**
7. **Base64** - Text encoding/decoding with URL-safe variant
8. **Hex String** - Bidirectional hex-to-string conversion with UTF-8/UTF-16/ASCII encoding support
9. **Regex** - Pattern matching with capture groups and common patterns
10. **UUID** - Multiple versions (v1, v4, v5, v7) with bulk generation
11. **Random String** - Cryptographically secure random string generation with customizable character sets, presets, and requirements
12. **URL** - Encoding/decoding and comprehensive URL parsing
13. **IP Lookup** - Dual IP detection and geolocation queries
14. **HTTP Client** - Full HTTP client with SSE streaming and JSON tree view
15. **QR Code** - Generation and scanning with multiple sizes and error correction
16. **SQL** - **Enhanced with diff mode** using native ParquetViewer library for minimal and beautify modes
17. **HTML** - **Enhanced with diff mode** for side-by-side HTML comparison and proper indentation
18. **JWT** - **HMAC and RSA algorithms** with CryptoKit security
19. **Parquet** - Unified Rust-based ParquetViewer API for Parquet/Arrow file reading
20. **Crypto** - **Complete cryptographic suite** with hash functions, symmetric and asymmetric encryption
21. **AI Chat** - **Enhanced** OpenAI-compatible + Anthropic Messages routing, Textual Markdown rendering, one-click copy code snippets, reasoning streams, and custom model support
22. **AI Translate** - Professional translation with shared two-protocol routing, 3 modes, 19 languages, **OpenAI TTS** (13 voices), macOS TTS, and word mode
23. **Currency** - Real-time currency conversion with 38 currencies, 24-hour caching, 30-day price history, and trend indicators
24. **Struct Converter** - Convert JSON/TOML/YAML/SQL DDL into typed code structures for TypeScript, Python, Go, Java, Rust, Swift, and PHP
25. **Data Converter** - **NEW** Convert between JSON, YAML, TOML, and CSV data formats with order preservation, nested-to-CSV flattening, and CSV type inference

## Architecture & Technical Stack
- **Platform**: macOS 14.0+ SwiftUI
- **Navigation**: NavigationSplitView with sidebar search
- **Dependencies**: CodeMirror-SwiftUI via SPM, Textual via SPM, Yams via SPM (YAML), ParquetViewer (Rust FFI)
- **Security**: CryptoKit for JWT HMAC operations, Security framework for RSA operations
- **TTS**: OpenAI TTS (real-time PCM streaming via AVAudioPlayerNode) + AVFoundation for native macOS TTS

## Build Commands
```bash
# Open in Xcode
open DevUtilities.xcodeproj

# Build and run
xcodebuild -project DevUtilities.xcodeproj -scheme DevUtilities build

# Using MCP tools
mcp__XcodeBuildMCP__build_run_macos
```

## Recent Updates (v2.16.0)
- **Two Protocol Families**: Providers explicitly select OpenAI Compatible or Anthropic Messages
- **Unified Router**: `Services/AIChatRouter.swift` routes both AI Chat and AI Translate; OpenAI Responses remains a model endpoint choice, not a third provider protocol
- **Anthropic Native Mapping**: Claude requests use `/messages`, `x-api-key`, `anthropic-version`, top-level system prompts, Anthropic image blocks, and Messages SSE events
- **Current Model Catalog**: GPT-5.6 Sol/Terra/Luna, DeepSeek V4, Qwen 3.8/3.7, Kimi K3, GLM 5.2, Gemini 3.6 Flash, and Claude Fable/Opus/Sonnet 5
- **Migration**: Providers without a stored protocol default to OpenAI Compatible; legacy `useResponsesAPI` models migrate to `chatEndpoint = responses`
- **Capabilities**: Image input, image generation, and web search are tracked independently and enforced before OpenAI Responses tools run

## Recent Updates (v2.15.0)
- **Spotlight Integration**: 11 commands built on App Intents run inline in Spotlight on macOS 26 — results render in place and are copied to the clipboard automatically
- **Command List**: Convert Timestamp, Convert Number Base, Convert Unit, Encode/Decode Base64, URL Encode/Decode, Decode JWT, Hash Text, Generate UUID, Generate Random String
- **Implementation**: `Services/QuickToolService.swift` (shared conversion logic) + `Services/ToolIntents.swift` (intents, enums, `AppShortcutsProvider`; provider capped at 10 entries — Decode JWT registered as a plain intent)

## Recent Updates (v2.14.1)
- **Concise Tool Names**: Shortened recognizable tool labels to their core technology or format name, including Base64, JWT, JSON, SQL, HTML, UUID, Crypto, URL, and Parquet
- **Consistent Naming**: Removed redundant and inconsistent suffixes such as Encode/Decode, Encoder/Decoder, Formatter, Generator, Viewer, and Tools
- **Clearer Labels**: Renamed Base Converter to Number Base, HTTP Request to HTTP Client, and IP Query to IP Lookup
- **Website and Documentation Sync**: Updated the website tool index, dedicated tool pages, release notes, and project documentation to match the app
- **Stable Identity**: Kept `ToolType` raw values, Swift type names, and website URLs unchanged so saved preferences and existing links continue to work

## Recent Updates (v2.14.0)
- **Data Converter**: NEW tool for converting between data interchange formats — JSON, YAML, TOML, and CSV
- **Bidirectional Any-to-Any**: Pick any source and target format with a from/to picker and a one-click swap button
- **Shared `DataValue` Model**: New order-preserving value tree (`DevUtilities/Models/DataValue.swift`) shared by the Data Converter and the Struct Converter; objects keep author key order and dates are stored verbatim
- **Order-Preserving JSON**: Custom JSON scanner (replaces `JSONSerialization`) so keys round-trip in source order rather than being reordered
- **YAML via Yams**: Added the Yams SPM dependency; YAML parses/serializes through `Yams.Node` to preserve key order and quoting. The Struct Converter's hand-rolled YAML parser was retired in favor of the shared pipeline
- **TOML Tables**: TOML emitter handles top-level scalars, `[table]` sections, and `[[array of tables]]`; date literals stay unquoted
- **CSV Flatten/Unflatten**: Nested objects/arrays flatten to dotted-key columns (`address.city`, `tags.0`) with an ordered union header; RFC-4180 quoting; a configurable "Infer types" toggle coerces cells like `123`/`true` or keeps them as strings
- **Struct Converter Refactor**: JSON/TOML/YAML inputs now parse to `DataValue` and feed a unified `StructSchemaInferrer`; struct output is unchanged (fields stay alphabetized, ISO-8601 strings still promote to a date type)

## Recent Updates (v2.13.0)
- **Struct Converter**: NEW tool for converting between data structures and code types (closes GitHub issue #17)
- **Four Input Formats**: JSON, TOML, YAML, and SQL DDL (CREATE TABLE statements)
- **Seven Output Languages**: TypeScript (interface), Python (dataclass), Go (struct with JSON tags), Java (POJO with getters/setters), Rust (serde struct), Swift (Codable struct), PHP (typed class)
- **Type Inference**: Detects strings, integers, doubles, booleans, ISO 8601 dates, arrays, nested objects, and nullable fields automatically from sample data
- **Nested Struct Generation**: Walks nested objects and arrays-of-objects to emit a sub-type for every level, naming children from the field name (with simple singularization for arrays)
- **Smart Field Naming**: Per-language conventions — camelCase for TypeScript/Swift/PHP, snake_case for Python/Rust, PascalCase for Go/Java fields — with serde/CodingKeys/JSON tags preserving original keys
- **SQL DDL Parser**: Parses CREATE TABLE blocks (multi-statement supported), maps SQL column types (INT/VARCHAR/DECIMAL/TIMESTAMP/...) to language-native types, respects NOT NULL for nullability
- **JSON Format Pattern**: Two-column layout matching the JSON UX with sample data, real-time conversion, copy button, and persistent state

## Recent Updates (v2.12.0)
- **AI Chat — Textual Markdown Rendering**: Migrated from MarkdownUI to Textual; better code highlighting, tables, nested lists, smoother streaming
- **AI Chat — Copy Code Snippets**: One-click Copy button on every code block in chat responses
- **AI Chat — OpenAI Responses API**: `useResponsesAPI` flag on `ModelCapabilities`; routes through `ResponsesAPI.sendChatMessage` with SSE streaming and reasoning support
- **AI Translate — OpenAI TTS**: `OpenAITTSService` streams raw PCM from `/audio/speech` into `AVAudioPlayerNode`; playback starts ~200ms; 13 voice options
- **TTS Settings**: `AIUISettings` stores `ttsMode`/`openAITTSVoice`/`macOSTTSVoiceID`; configurable in Settings → AI → Text-to-Speech

## Recent Updates (v2.11.1)
- **AI Chat Stop Fix**: Stop button now preserves partial streamed output instead of discarding it; `onError` handler detects `CancellationError` and keeps message with `isStreaming = false`
- **Model List Sync**: `ProviderManager.syncBuiltInModels()` runs on startup to reconcile stored built-in models with current code defaults — removes deprecated models (e.g. gpt-4.1), adds new ones, preserves user's `isActive` state and custom models

## Recent Updates (v2.11.0)
- **Text Compare Tool**: NEW dedicated tool for side-by-side text comparison with visual diff highlighting
- **Enhanced Diff Modes**: Added diff functionality to JSON, HTML, and SQL formatters
- **CodeDiffEditor Extensions**: Added html() and sql() methods to CodeDiffEditor component
- **Unified Comparison Pattern**: Implemented reusable `updateComparisonStatus()` across all diff views
- **Real-time Status Updates**: All diff views show instant "same" or "different" status with visual indicators
- **Character & Line Metrics**: Both sides display character count and line count for detailed analysis
- **Auto-formatting**: Diff modes automatically format content for optimal comparison
- **Sample Data**: Each diff mode includes meaningful sample data pairs
- **State Persistence**: All comparison views save content between sessions
- **23 Essential Tools**: Complete developer toolkit with comprehensive diff capabilities

## Recent Updates (v2.10.0)
- **Currency**: NEW tool for real-time currency conversion with comprehensive features
- **38 Currencies Supported**: Major global currencies including USD, EUR, GBP, JPY, CNY, KRW, INR, and 33 others
- **24-Hour Caching**: Smart exchange rate caching to minimize API calls and improve performance
- **30-Day Price History**: Incremental daily snapshots building a complete 30-day historical view
- **24-Hour Trend Indicators**: Visual up/down arrows with percentage change vs yesterday
- **Flexible Number Input**: Supports both formatted (1,000,000) and plain (1000000) number formats
- **Optimized Performance**: History loads only when currency pair changes, instant conversion on amount changes
- **Two-Column Layout**: Clean UI with currency pickers, swap button, and sample amount shortcuts
- **Offline Mode**: Uses cached data when network unavailable with clear offline indicators
- **State Persistence**: Remembers your last conversion settings between sessions
- **22 Essential Tools**: Complete developer toolkit with all essential utilities

## Recent Updates (v2.9.0)
- **Random String**: NEW tool for cryptographically secure random string generation
- **Customizable Character Sets**: Support for uppercase, lowercase, numbers, and symbols
- **Preset Templates**: 5 built-in presets (Strong Password, API Key, Hex String, PIN Code, Readable Code)
- **Advanced Requirements**: Optional requirements for minimum uppercase, numbers, or symbols
- **Bulk Generation**: Generate up to 20 random strings at once
- **Length Control**: Configurable string length from 1 to 100 characters
- **Secure Randomness**: Uses SecRandomCopyBytes for cryptographically secure random generation

## Recent Updates (v2.8.2)
- **Text-to-Speech (TTS)**: Integrated native macOS TTS in AI Translate for both input and output text
- **Multi-language TTS**: Support for all 19 translation languages with proper voice selection
- **Animated Speaker Icons**: Visual feedback with wave animation during speech playback
- **Smart Text Sanitization**: Prevents SSML parsing errors by escaping special characters
- **Thread-safe Implementation**: Eliminates priority inversion warnings with internal state tracking
- **One-click Playback**: Speaker buttons next to input text and translated output
- **Error Handling**: Comprehensive validation for empty text, missing voices, and edge cases

## Recent Updates (v2.8.1)
- **Base62 Support**: Enhanced Number Base with Base62 number system (0-9, A-Z, a-z)
- **Five Base Systems**: Complete support for binary (base 2), octal (base 8), decimal (base 10), hexadecimal (base 16), and Base62 (base 62)
- **Real-time Conversion**: Automatic conversion across all five number bases as you type
- **Custom Algorithms**: Implemented custom toBase62 and fromBase62 conversion functions
- **Comprehensive Validation**: Character set validation for Base62 (alphanumeric)
- **State Persistence**: Saves and restores Base62 values between sessions

## Recent Updates (v2.8.0)
- **Color**: NEW professional color format converter for HEX, RGB, RGBA, HSL, HSLA, HSB, and CMYK
- **Multi-format Support**: Real-time conversion between 7 different color format standards
- **Visual Preview**: Large color preview box with system color picker integration
- **Color History**: Automatically tracks up to 22 recently used colors with visual swatches
- **Editable Formats**: Direct editing of any color format with instant synchronization
- **Copy to Clipboard**: One-click copying for each color format
- **State Persistence**: Saves and restores color state and history between sessions
- **20 Essential Tools**: Complete toolkit with all essential developer utilities

## Recent Updates (v2.7.0)
- **Number Base**: NEW tool for mutual conversion between binary (base 2), octal (base 8), decimal (base 10), and hexadecimal (base 16) number systems
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
- **Hex String**: NEW tool for bidirectional hex-to-string conversion
- **Encoding Support**: UTF-8, UTF-16, and ASCII encoding options
- **Enhanced Developer Tools**: Now 17 complete utilities for developers
- **Real-time Conversion**: Instant hex encoding/decoding as you type

## Previous Updates (v2.1.0)
- **Timestamp history**: Added timestamp convert history
- **IP Lookup**: Fixed ip query for China

## Previous Updates (v2.0.0)
- **Custom AI Models**: Added support for custom AI model configuration with flexible API settings
- **Model Management**: Enhanced model selection interface with custom model addition and configuration
- **API Flexibility**: Support for custom API endpoints, headers, and authentication methods
- **User Experience**: Improved model selector UI with better organization of built-in and custom models
- **Configuration Persistence**: Reliable storage and retrieval of custom model configurations

## Previous Updates (v1.14.2)
- **SQL Enhancement**: Major upgrade using native ParquetViewer library for SQL formatting
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
- **DeepSeek Integration**: Added deepseek-v4-flash and deepseek-v4-pro models with OpenAI API compatibility
- **Reasoning Process**: DeepSeek shows transparent "deepthink" Chain of Thought reasoning
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
- **Crypto**: New comprehensive cryptographic utility suite addressing GitHub issues #13 and #14
- **Hash Functions**: MD5, CRC32, SHA-1, SHA-256, SHA-384, SHA-512 with real-time computation
- **Symmetric Encryption**: AES-GCM-256 encrypt/decrypt with key generation and Base64 encoding
- **Asymmetric Encryption**: RSA-2048/4096 encrypt/decrypt using Security framework
- **Unified Interface**: Three-tab design (Hash/Symmetric/Asymmetric) with consistent UX patterns
- **API Authentication**: Perfect for generating tokens for third-party interface calls

## Previous Updates (v1.11.1)
- **JWT**: Enhanced with RSA algorithm support (RS256, RS384, RS512)
- **RSA Cryptography**: Implemented using iOS Security framework for key management and signing
- **Dynamic UI**: Interface adapts to show appropriate fields (secret key for HMAC, RSA keys for RSA)
- **Key Management**: Support for PEM-formatted RSA keys with auto-population sample keys
- **Algorithm Detection**: Real-time detection of JWT algorithm type for verification

## Previous Updates (v1.10.3)
- **Parquet**: Simplified with unified ParquetViewer API
- **Dependency Cleanup**: Removed DuckDB-swift and arrow-swift dependencies  
- **Architecture**: Single Rust-based backend for both Parquet and Arrow files
- **Performance**: Faster loading with direct JSON output from ParquetViewer
- **UI Simplification**: Removed SQL editor, focusing on core file viewing functionality

## Previous Updates (v1.10.2)
- **JSON**: Enhanced with visual CodeMirror diff editor
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
2. AGENTS.md (this file - project guidance)
3. DESIGN.md (technical design document)
4. website/README.md (website repository documentation)
5. website/index.html (main website page)
6. website/release-notes.html (release notes page)
7. website/ai-translate.html (AI Translate feature page)

This ensures consistency across all documentation and user-facing materials.
