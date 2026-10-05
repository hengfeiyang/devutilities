# DevUtilities - Design Document

## Overview
DevUtilities is a native macOS application built with SwiftUI that provides 25 essential developer utilities in a single, easy-to-use interface. Version 3.0 introduces free download with 18 free tools, a user-started 30-day trial of 7 Pro tools, and a one-time Lifetime Pro purchase after trial expiry. All users with a verified original acquisition on or before October 24, 2026, including free downloads, receive permanent Pro. AI Chat and AI Translate share OpenAI Compatible and Anthropic Messages routing. The app follows Apple's Human Interface Guidelines and provides a consistent, professional experience across all tools.

## Repository and distribution

App code and the static website share one Git repository. `website/` is an ordinary tracked subdirectory; it has no nested Git metadata or submodule registration. Website changes use the same commit and push workflow as app changes. Root `.github/workflows/pages.yml` deploys only the `website/` contents on matching `main` pushes or a manual run. The owner will push the consolidated repository to `hengfeiyang/DevUtilities`, preserving `https://hengfeiyang.github.io/devutilities/`. Switching Pages from the existing branch-root source to GitHub Actions and verifying live deployment remain external steps; local configuration alone does not complete the cutover.

Source builds may customize the Pro checks under the repository license. This does not change the official 3.0 distribution model of free download and one-time Lifetime Pro, or the developer-supplied credentials required by external AI services.

## Architecture

### Project Structure
```
DevUtilities/
├── DevUtilities.xcodeproj/            # Xcode project configuration
│   └── project.xcworkspace/
│       └── xcshareddata/swiftpm/   # SPM package dependencies
├── DevUtilities/
│   ├── DevUtilitiesApp.swift          # Main app entry point
│   ├── ContentView.swift           # Navigation split view
│   ├── Models/
│   │   ├── AccessState.swift       # Free, trial, Legacy Pro, and purchased Pro states (v3.0)
│   │   ├── ToolType.swift          # Tool definitions
│   │   ├── FeatureManager.swift    # Feature preferences management
│   │   ├── TranslationLanguage.swift   # 19 language definitions + TTS mapping
│   │   ├── TranslationMode.swift       # 3 translation modes
│   │   ├── TranslationPrompts.swift    # Prompt generation logic
│   │   ├── RandomStringConfig.swift    # Random string configuration (v2.9.0)
│   │   ├── Currency.swift              # 38 currency definitions with flags (v2.10.0)
│   │   ├── ExchangeRateData.swift      # API response & cache models (v2.10.0)
│   │   ├── StructIR.swift              # Intermediate representation for Struct Converter (v2.13.0)
│   │   └── DataValue.swift             # NEW: Order-preserving shared value tree + DataFormat (v2.14.0)
│   ├── Views/                      # All 25 tool implementations
│   │   ├── MonetizationViews.swift # Trial, purchase, restore, and unified Pro window UI
│   │   ├── TimestampConverterView.swift
│   │   ├── UnitConverterView.swift
│   │   ├── BaseConverterView.swift
│   │   ├── ColorPickerView.swift
│   │   ├── TextCompareView.swift        # NEW: Text comparison tool (v2.11.0)
│   │   ├── JSONFormatterView.swift     # Enhanced with diff mode (v2.11.0)
│   │   ├── Base64View.swift
│   │   ├── HexStringConverterView.swift
│   │   ├── RegexTestView.swift
│   │   ├── UUIDGeneratorView.swift
│   │   ├── RandomStringView.swift       # Random string generator (v2.9.0)
│   │   ├── URLToolsView.swift
│   │   ├── IPQueryView.swift
│   │   ├── HTTPRequestView.swift
│   │   ├── QRCodeView.swift
│   │   ├── SQLFormatterView.swift      # Enhanced with diff mode (v2.11.0)
│   │   ├── HTMLFormatterView.swift     # Enhanced with diff mode (v2.11.0)
│   │   ├── JWTView.swift
│   │   ├── ParquetViewerView.swift
│   │   ├── CryptoToolsView.swift
│   │   ├── AIChatView.swift
│   │   ├── AITranslateView.swift       # AI translation interface
│   │   ├── CurrencyConverterView.swift # Currency converter (v2.10.0)
│   │   ├── StructConverterView.swift   # Struct Converter (v2.13.0)
│   │   ├── DataConverterView.swift      # NEW: Data Converter — JSON/YAML/TOML/CSV (v2.14.0)
│   │   └── FeatureSettingsView.swift   # Feature management interface
│   ├── Components/                 # Shared UI components
│   │   ├── CodeEditor.swift        # CodeMirror integration & diff editor (enhanced v2.11.0)
│   │   ├── TextEditor.swift        # Custom text editor with IME support
│   │   ├── SpeakerButton.swift     # TTS playback button — routes OpenAI/macOS TTS (v2.12.0)
│   │   └── SpeakerMotionView.swift # Animated speaker icon (v2.8.2)
│   ├── Services/                   # Application services
│   │   ├── EntitlementManager.swift # StoreKit 2 and local trial entitlement authority
│   │   ├── ChatManager.swift       # AI chat session management (stop preserves partial output v2.11.1)
│   │   ├── ProviderManager.swift   # API provider configuration and protocol-aware connection tests
│   │   ├── AIChatRouter.swift      # Two-family router + Anthropic Messages transport (v3.0)
│   │   ├── ChatManager.swift       # Chat orchestration + OpenAI Chat/Responses transports
│   │   ├── OpenAITTSService.swift  # Realtime PCM playback and cancellation lifecycle (v3.0)
│   │   ├── RealtimeTTSClient.swift # GA WebSocket protocol, migration, PCM framing (v3.0)
│   │   ├── EventManager.swift      # Analytics and telemetry
│   │   ├── AVSpeechService.swift   # macOS native text-to-speech engine
│   │   ├── RandomStringGenerator.swift # Secure random generation (v2.9.0)
│   │   ├── CurrencyService.swift   # Currency API & caching (v2.10.0)
│   │   ├── StructConverterParsers.swift    # JSON/TOML/YAML → DataValue → IR, SQL DDL → IR (v2.13.0, shared pipeline v2.14.0)
│   │   ├── StructConverterGenerators.swift # IR → Swift/Go/TS/Rust/Python/Java/PHP (v2.13.0)
│   │   └── DataConverter.swift             # NEW: DataValue parsers + serializers for JSON/YAML/TOML/CSV (v2.14.0)
│   ├── Assets.xcassets/            # App icons and assets
│   ├── Preview Content/            # SwiftUI preview assets
│   └── DevUtilities.entitlements      # App sandbox permissions
├── DESIGN.md                       # This design document
├── CLAUDE.md                       # Claude Code guidance
└── README.md                       # User-facing documentation
```

### Technical Stack
- **Platform**: macOS 14.0+
- **Framework**: SwiftUI
- **Language**: Swift 5.0
- **Architecture Pattern**: MVVM (Model-View-ViewModel)
- **Data Binding**: Combine framework with @Published and @State

## App Architecture

### Main Navigation
- **NavigationSplitView**: Primary navigation structure
- **Sidebar**: Tool selection with icons and titles, **search functionality**
- **Detail View**: Selected tool interface
- **Window Configuration**: Resizable with minimum size constraints
- **Search Bar**: Integrated search to filter tools by name

Tool labels use concise, object-oriented names in the sidebar. Recognizable formats and technologies use their canonical names (for example, JSON, Base64, JWT, and UUID), while potentially ambiguous tools retain a descriptive suffix (for example, Unit Converter, HTTP Client, and IP Lookup). `ToolType` raw values remain stable when display names change so persisted feature preferences continue to decode correctly.

### Lifetime Pro Access Layer (v3.0)

- **Single authority**: `EntitlementManager` resolves Legacy Pro, verified Lifetime Pro, trial, and free states and is injected into the SwiftUI environment.
- **Free tools**: Timestamp, Unit Converter, Number Base, Color, Text Compare, JSON, Base64, Hex String, Regex, UUID, Random String, URL, QR Code, SQL, HTML, HTTP Client, Struct Converter, and Data Converter.
- **Pro tools**: AI Chat, AI Translate, Parquet, IP Lookup, Currency, JWT, and Crypto.
- **Trial**: A full 30-day trial begins only after explicit user action. Trial dates persist in Keychain with a UserDefaults fail-safe cache.
- **Trial expiry**: After the 30-day trial, all 7 Pro tools require permanent Pro access. There is no daily allowance.
- **Unified Pro window**: Selecting a locked Pro tool leaves the current tool and sidebar selection unchanged and opens DevUtilities Pro. The window provides trial activation, purchase, and restore according to the current entitlement state.
- **Purchase**: StoreKit 2 verifies the non-consumable product, listens for transaction updates, supports restore, and finishes verified transactions.
- **Early Supporter policy**: Verified original acquisitions strictly before 2026-10-25 00:00 Asia/Shanghai (2026-10-24 16:00 UTC) receive permanent Legacy Pro regardless of price, including all of October 24. User-facing copy shows the inclusive date without a timezone label. The fixed cutoff is independent of the storefront transition; cached verified grants survive outages and the cutoff passing. Release remains guarded pending launch validation.
- **Privacy**: Conversion analytics record only product-flow action and tool identifier. They do not include user text, file names, request bodies, secrets, keys, or document contents.

### Tool Integration Pattern
Each tool follows a consistent pattern:
1. **Enum Definition**: Added to `ToolType` enum
2. **Icon Assignment**: SF Symbols icon
3. **View Implementation**: SwiftUI view with consistent styling
4. **Navigation Integration**: Switch case in `ContentView`

### Spotlight / App Intents Layer (v2.15.0)
Quick conversions are exposed system-wide through App Intents:
- **`Services/QuickToolService.swift`**: UI-independent conversion logic (timestamp, Base64, URL, UUID v4/v7, JWT decode, hashes, number bases, random strings, unit conversion). Pure static functions that throw `QuickToolError` with user-readable messages.
- **`Services/ToolIntents.swift`**: 11 `AppIntent` structs plus `AppEnum` wrappers (hash algorithm, UUID version, number base, 44 measurement units across 7 categories). Each intent returns `ReturnsValue<String> & ProvidesDialog` — no custom snippet view — so Spotlight on macOS 26 renders the result inline instead of opening a dialog window. Results are copied to the clipboard by default (per-intent toggle).
- **`AppShortcutsProvider`**: Registers 10 commands as App Shortcuts (system cap is 10 per app); Decode JWT stays a plain intent available in the Shortcuts actions catalog. Parameter summaries put enum parameters before free text ("Generate MD5 hash of …") to match Spotlight's inline typing flow.
- **Deployment note**: The App Intents registry follows the copy of the app in `/Applications`; a stale copy without intents shadows newer builds from DerivedData.

## Tool Specifications

### 1. Timestamp
**File**: `TimestampConverterView.swift`

**Features**:
- Auto-detection of timestamp formats (10/13/16/19 digits)
- Bidirectional conversion (timestamp ↔ human-readable)
- Timezone support (Local/UTC)
- Current timestamp generation
- Real-time conversion

**UI Components**:
- Two-column layout (timestamp input/output)
- Toggle for timezone selection
- Current timestamp button
- Copy functionality

**Implementation Details**:
- Uses `Date` and `DateFormatter` for conversions
- Automatic format detection based on digit count
- TimeInterval calculations for different precisions

### 2. Unit Converter
**File**: `UnitConverterView.swift`

**Features**:
- 7 unit categories: Data, Time, Length, Weight, Temperature, Area, Volume
- Real-time bidirectional conversion
- Swap units functionality
- Special temperature conversion logic
- Comprehensive time unit support (nanoseconds to years)

**UI Components**:
- Segmented picker for categories
- Dropdown menus for unit selection
- Numeric input with real-time updates
- Swap button for quick unit exchange

**Implementation Details**:
- `UnitCategory` enum with associated units
- `UnitData` struct for conversion multipliers
- Special handling for temperature conversions (C/F/K)
- Base unit conversion pattern
- Time conversions from nanoseconds to years

### 3. Number Base
**File**: `BaseConverterView.swift`

**Features**:
- Mutual conversion between binary (base 2), octal (base 8), decimal (base 10), hexadecimal (base 16), and Base62 (base 62)
- Real-time validation of input for each number base
- Automatic conversion when typing in any field
- Clear error messages for invalid input formats
- Copy to clipboard functionality for all results
- Clear all button to reset converter
- State persistence between sessions

**UI Components**:
- Five separate TextEditor areas (one for each number base)
- Copy buttons next to each result
- Error message display for invalid inputs
- Clear All button at bottom

**Implementation Details**:
- Swift `Int(radix:)` for parsing binary, octal, decimal, and hexadecimal
- Custom Base62 conversion algorithms:
  - `toBase62()`: Converts decimal to Base62 using character set "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
  - `fromBase62()`: Converts Base62 back to decimal with character index lookup
- Character set validation for each base (binary: 0-1, octal: 0-7, decimal: 0-9, hex: 0-9 A-F, Base62: 0-9 A-Z a-z)
- Real-time conversion using `onChange` modifiers
- Active field tracking to prevent conversion loops
- UserDefaults integration for state persistence
- Support for uppercase hex output (A-F)
- `NumberBase` enum for field tracking (.binary, .octal, .decimal, .hexadecimal, .base62)

**Validation Rules**:
- Binary: Only 0 and 1 allowed
- Octal: Only digits 0-7 allowed
- Decimal: Only digits 0-9 allowed, no negative numbers
- Hexadecimal: Digits 0-9 and letters A-F (case-insensitive), optional 0x prefix
- Base62: Digits 0-9, uppercase A-Z, lowercase a-z (62 characters total)

### 4. Color
**File**: `ColorPickerView.swift`

**Features**:
- Professional color format converter with real-time conversion between 7 color formats
- Support for HEX (#RRGGBB or #RRGGBBAA), RGB, RGBA, HSL, HSLA, HSB, and CMYK color formats
- Visual color preview box (80x80pt) with system color picker integration
- Color history tracking (up to 22 colors) with visual swatches for quick color reuse
- Editable format fields - edit any format and see instant updates across all formats
- Copy to clipboard functionality for each color format
- State persistence between sessions (saves last selected color and history)
- Real-time color space conversion algorithms

**UI Components**:
- Large color preview box with rounded corners and border
- System ColorPicker integration for precise color selection
- Color history section with clickable color swatches (20x20pt)
- Format conversion section with labeled rows for each color format
- TextField for each format with monospaced font
- Copy buttons next to each format value
- Tip section explaining editable format feature

**Implementation Details**:
- Uses SwiftUI `ColorPicker` for system color panel integration
- Custom color space conversion functions:
  - `rgbToHSL` and `hslToRGB` for HSL color space
  - `rgbToHSB` and `hsbToRGB` for HSB/HSV color space
  - `rgbToCMYK` and `cmykToRGB` for CMYK color space
- Real-time parsing and validation using regex patterns:
  - HEX: `#RRGGBB` or `#RRGGBBAA` format
  - RGB: `rgb(r, g, b)` format with 0-255 range
  - RGBA: `rgba(r, g, b, a)` format with alpha 0-1
  - HSL: `hsl(h, s%, l%)` format
  - HSLA: `hsla(h, s%, l%, a)` format
  - HSB: `hsb(h, s%, b%)` format
  - CMYK: `cmyk(c%, m%, y%, k%)` format
- Color history management with hex string storage
- State update prevention using `isUpdatingFromPicker` flag to avoid conversion loops
- UserDefaults persistence for color value and history array
- NSColor/Color conversion for macOS color space handling
- Scanner-based hex string parsing for robust hex-to-color conversion

**Color Space Conversion Algorithms**:
- RGB to HSL: Lightness-based color representation
- RGB to HSB: Brightness-based color representation (also known as HSV)
- RGB to CMYK: Subtractive color model for print applications
- All conversions maintain color accuracy and handle edge cases (black, white, grays)

### 5. JSON
**File**: `JSONFormatterView.swift`

**Features**:
- Format (pretty print)
- Minify (remove whitespace)
- Validate with detailed feedback
- Escape/Unescape for string embedding
- JSON diff/compare mode with visual CodeMirror diff editor
- Syntax error highlighting
- Real-time syntax highlighting for JSON

**UI Components**:
- Segmented picker for modes (Format/Minify/Validate/Escape/Diff)
- Two-panel layout (input/output) for most modes
- Visual diff editor for diff mode with side-by-side JSON comparison
- Validation status indicator
- Sample JSON button
- CodeMirror integration for enhanced editing experience

**Implementation Details**:
- `JSONSerialization` for parsing and formatting
- Error handling with descriptive messages
- Real-time processing with input validation
- Character count tracking
- CodeMirror-SwiftUI integration for diff visualization
- `CodeDiffEditor` component for visual diff comparison

### 6. Base64
**File**: `Base64View.swift`

**Features**:
- Text encoding/decoding
- URL-safe Base64 variant
- Real-time conversion
- Swap functionality between modes
- Sample data for testing

**UI Components**:
- Tab-based interface (Encode/Decode)
- URL-safe toggle
- Two-panel layout per mode
- Sample and swap buttons

**Implementation Details**:
- `Data.base64EncodedString()` for encoding
- `Data(base64Encoded:)` for decoding
- URL-safe character substitution
- UTF-8 encoding/decoding

### 7. Hex String
**File**: `HexStringConverterView.swift`

**Features**:
- Bidirectional hex-to-string conversion
- Multiple encoding support (UTF-8, UTF-16, ASCII)
- Real-time conversion as user types
- Error handling for invalid hex input
- Swap functionality between modes
- Sample data for testing
- Character validation and formatting
- State persistence between sessions

**UI Components**:
- Tab-based interface (String to Hex/Hex to String)
- Encoding selector dropdown
- Two-panel layout per mode with arrow indicator
- Sample and swap buttons
- Character counters for input/output
- Copy and clear buttons

**Implementation Details**:
- `String.data(using:)` for string-to-hex encoding
- Custom hex-to-data parsing with validation
- Support for UTF-8, UTF-16, and ASCII encodings
- Real-time validation of hex characters (0-9, a-f)
- Even-length requirement for valid hex strings
- UserDefaults integration for state persistence
- Comprehensive error handling with descriptive messages

### 8. Regex
**File**: `RegexTestView.swift`

**Features**:
- Pattern testing with match highlighting
- Capture group display
- Flag support (case-insensitive, multiline, dotall)
- Match replacement functionality
- Common pattern library with descriptions

**UI Components**:
- Pattern input with flag toggles
- Test string area with match highlighting
- Results display with capture groups
- Common patterns button library
- Replace mode interface

**Implementation Details**:
- `NSRegularExpression` for pattern matching
- Real-time highlighting of matches
- Flag handling for regex options
- String replacement with capture group support

### 9. UUID
**File**: `UUIDGeneratorView.swift`

**Features**:
- Multiple UUID versions (V1, V4, V5, V7)
- Bulk generation (1-100 UUIDs)
- Multiple format options
- UUID validation
- Common pattern examples
- UUID v7 timestamp extraction

**UI Components**:
- Version picker
- Format dropdown
- Bulk count stepper
- Scrollable UUID list with individual copy buttons
- Validation section with examples

**Implementation Details**:
- `UUID()` for generation
- Format transformations (hyphens, case, braces)
- Validation using `UUID(uuidString:)`
- Version detection from UUID structure
- UUID v7 timestamp-ordered generation
- Automatic timestamp extraction from v7 UUIDs

### 10. URL
**File**: `URLToolsView.swift`

**Features**:
- URL encoding/decoding
- Complete URL parsing
- Query parameter breakdown
- URL reconstruction
- Component extraction

**UI Components**:
- Three-tab interface (Encoder/Decoder/Parser)
- Component breakdown tables
- Query parameter list
- URL reconstruction display

**Implementation Details**:
- `String.addingPercentEncoding()` for encoding
- `String.removingPercentEncoding()` for decoding
- `URLComponents` for parsing
- Query parameter array management

### 11. IP Lookup
**File**: `IPQueryView.swift`

**Features**:
- Dual IP detection (international vs China networks)
- Current IP address discovery
- IP geolocation query for any IP address
- Smart dual IP display (only when different)
- Comprehensive location information

**UI Components**:
- Two-column layout (My IP / Query IP)
- Dual IP display with clear labeling
- Sample IP buttons for quick testing
- Copy functionality for all IP addresses
- Detailed location breakdown

**Implementation Details**:
- Concurrent API calls using `DispatchGroup`
- ipinfo.io for international IP detection
- Baidu API for China network detection
- User-Agent headers to avoid bot detection
- Comprehensive error handling and validation

### 12. HTTP Client
**File**: `HTTPRequestView.swift`

**Features**:
- Complete HTTP client with all standard methods (GET, POST, PUT, DELETE, PATCH, HEAD, OPTIONS)
- Advanced headers management with add/remove functionality
- Common header shortcuts (Content-Type, Accept, User-Agent)
- Authentication support (None, Basic Auth, Bearer Token)
- Request body support for JSON, XML, form data, and raw text
- TLS verification bypass option for development/testing
- Configurable timeout settings
- Real-time request timer with elapsed time display
- Server-Sent Events (SSE) streaming support with live updates
- Response time measurement and display
- Binary data download with file save dialog
- JSON tree view for structured response exploration
- Request history with timeline display

**UI Components**:
- Split layout with request configuration and response display
- Tabbed request interface (Headers, Auth, Body)
- HTTP method dropdown and URL input field
- Real-time timer and cancel functionality
- Response tabs (Body, Headers) with raw/preview/tree modes
- Status code color indicators (green/orange/red)
- Copy and save functionality throughout
- Sample data buttons for quick testing

**Implementation Details**:
- `URLSession` with custom configuration for requests
- `URLSessionDelegate` for TLS bypass functionality
- Real-time timer using `Timer.scheduledTimer` for elapsed time
- Streaming response handling for SSE content types
- JSON formatting with `JSONSerialization` for preview mode
- Interactive JSON tree view with expand/collapse functionality
- File save functionality using `NSSavePanel`
- Comprehensive error handling for network issues
- Automatic content type detection for response formatting
- Thread-safe UI updates using `DispatchQueue.main.async`

### 13. QR Code
**File**: `QRCodeView.swift`

**Features**:
- QR code generation with multiple size options (Small 128x128, Medium 256x256, Large 512x512, Extra Large 1024x1024, Custom size)
- Configurable error correction levels (L/M/Q/H) for different reliability needs
- Real-time QR code generation as user types
- Copy generated QR code to clipboard functionality
- Save QR code as PNG file with proper filename formatting
- QR code scanning from image files or clipboard
- Image preview for scanning operations
- Automatic URL detection and opening from scan results
- Sample data buttons for quick testing (URL, text, WiFi)

**UI Components**:
- Tabbed interface (Generate/Scan) with segmented picker
- Two-column layouts with visual flow indicators (arrow icons)
- Size picker dropdown with descriptive labels
- Custom size text field for pixel-perfect dimensions
- Dynamic QR code preview with size indicators
- Action buttons positioned below QR code image
- Image preview section for scanning operations
- Scrollable scan result area with copy/open functionality

**Implementation Details**:
- `CoreImage.CIFilter.qrCodeGenerator()` for QR code generation
- `Vision.VNDetectBarcodesRequest` for QR code scanning
- Dynamic scaling calculation based on selected size
- `NSOpenPanel` for file selection with image content types
- `NSSavePanel` with `UniformTypeIdentifiers` for PNG saving
- `NSPasteboard` integration for clipboard operations
- Proper entitlements (`com.apple.security.files.user-selected.read-write`) for file operations
- Real-time UI updates using `onChange` modifiers
- Error handling for image processing and file operations

### 14. SQL
**File**: `SQLFormatterView.swift`

**Features**:
- **Enhanced SQL formatting** using native ParquetViewer Rust library
- **Dual format modes**: minimal and beautify formatting styles
- **High-performance processing** with 95% code reduction from previous version
- Real-time SQL formatting with robust error handling
- Support for complex SQL statements with proper indentation and structure
- Fallback mechanisms for malformed SQL with graceful error recovery

**UI Components**:
- Segmented picker for mode selection (Format/Minify)
- Two-column layout (input/output) with arrow indicator
- Sample SQL buttons for quick testing
- Validation status indicator with error messages
- Character count display for input/output

**Implementation Details**:
- **Native ParquetViewer integration**: Uses `ParquetViewer.formatSql()` with `SqlFormatStyle` enum
- **Rust-based backend**: Leverages high-performance Rust SQL parsing engine
- **Dual formatting modes**: `.minimal` for compact SQL, `.beautify` for readable indentation
- **Error resilience**: Comprehensive do-catch blocks with intelligent fallback to original text
- **FFI bridge**: Seamless Swift-to-Rust communication via C header interface

### 15. HTML
**File**: `HTMLFormatterView.swift`

**Features**:
- HTML formatting with proper tag indentation and structure
- HTML minification by removing unnecessary whitespace
- Basic syntax validation with error reporting
- Real-time processing as user types
- Support for all standard HTML elements
- Copy functionality for formatted results

**UI Components**:
- Segmented picker for mode selection (Format/Minify)
- Two-column layout (input/output) with arrow indicator
- Sample HTML buttons for quick testing
- Validation status indicator with error messages
- Character count display for input/output

**Implementation Details**:
- Custom HTML formatter with tag recognition
- Proper indentation logic for nested elements
- Basic syntax validation using XML/HTML parsing principles
- Real-time processing with input validation
- Error handling with descriptive feedback

### 16. JWT
**File**: `JWTView.swift`

**Features**:
- JWT token decoding with header and payload extraction
- JWT token encoding with custom claims support
- HMAC signature verification and generation
- Algorithm support (HS256, HS384, HS512, none)
- Base64URL encoding/decoding for JWT components
- Real-time processing and validation
- Sample JWT tokens for testing

**UI Components**:
- Tabbed interface (Encode/Decode)
- JWT token input/output areas
- Header and payload display sections
- Algorithm picker for encoding
- Secret key input for HMAC algorithms
- Signature verification status indicator
- Copy functionality throughout

**Implementation Details**:
- Uses `CryptoKit` for HMAC signature generation
- Base64URL encoding/decoding functions
- JSON parsing for header and payload
- Real-time JWT validation and parsing
- Support for common JWT claims (iss, sub, aud, exp, etc.)
- Error handling for malformed tokens
- Secure key handling for signature operations

### 17. Parquet
**File**: `ParquetViewerView.swift`

**Features**:
- Unified Parquet and Arrow file reading using Rust-based ParquetViewer API
- Schema extraction with column details (name, type)
- Data preview with native SwiftUI table (first 50 rows)
- Comprehensive file metadata display (file size, rows, columns, format version)
- Key-value metadata extraction and display
- CSV and JSON export options for data and schema
- Drag and drop file loading with visual feedback
- Support for .parquet, .arrow, .feather, and .ipc file extensions

**UI Components**:
- Tabbed interface (Schema/Data/Metadata)
- Drag and drop zone with animated visual feedback
- File selection button and filename display
- Native SwiftUI table with NSTableView representables for performance
- Schema table with column name, data type, and nullable columns
- Structured metadata table with key-value pairs
- Export buttons for CSV/JSON on each tab
- Loading indicators and error messages

**Implementation Details**:
- Single ParquetViewer Rust library via FFI (Foreign Function Interface)
- Direct JSON parsing from ParquetViewer batch output
- Simplified data flow: ParquetViewer → JSON → SwiftUI display
- Security-scoped resource access for sandboxed file operations
- NSTableView-backed SwiftUI representables for large data performance
- Automatic file type detection based on extension
- Comprehensive metadata extraction including row groups and format version

### 18. Crypto
**File**: `CryptoToolsView.swift`

**Features**:
- **Hash Functions**: MD5, CRC32, SHA-1, SHA-256, SHA-384, SHA-512 with real-time computation
- **Symmetric Encryption**: AES-GCM-256 encrypt/decrypt with key generation and Base64 encoding
- **Asymmetric Encryption**: RSA-2048/4096 encrypt/decrypt using Security framework
- Real-time hash computation as user types
- Key generation functionality for both AES and RSA
- Base64 encoding/decoding for encrypted data
- Sample data buttons for testing all operations
- Perfect for API authentication token generation

**UI Components**:
- Three-tab interface (Hash/Symmetric/Asymmetric)
- Hash selection dropdown with all supported algorithms
- Key generation buttons with secure random generation
- Two-column layout for encrypt/decrypt operations
- Key size selection for RSA (2048/4096 bits)
- Real-time processing indicators
- Copy functionality throughout all tabs
- PEM format support for RSA keys

**Implementation Details**:
- Uses `CryptoKit` for hash functions and AES encryption
- `CommonCrypto` for MD5 and CRC32 legacy support
- iOS Security framework for RSA key generation and operations
- Secure random key generation using `SystemRandomNumberGenerator`
- Base64 encoding for all encrypted outputs
- Error handling for key format validation
- Thread-safe operations with proper error messaging

### 19. AI Chat
**File**: `AIChatView.swift`

**Features** (v3.0):
- **Textual Markdown Rendering**: Migrated from MarkdownUI to Textual for richer output — code syntax highlighting, tables, nested lists, inline formatting
- **Copy Code Snippets**: One-click Copy button on every code block; no text selection needed
- **Two Provider Protocols**: `AIAPIProtocol` exposes OpenAI Compatible and Anthropic Messages; GPT, DeepSeek, Qwen, Kimi, GLM, and Gemini use the first family while Claude uses the second
- **OpenAI Endpoint Choice**: `AIModelV2.chatEndpoint` selects Chat Completions or Responses inside the OpenAI-compatible family
- **Anthropic Messages**: Native `/messages` payloads, top-level system prompts, `x-api-key` authentication, image content blocks, text/thinking SSE deltas, and token usage
- **OpenAI Responses API**: Supports SSE streaming and reasoning/thinking output for models that require or benefit from `/responses`
- **Reasoning Support**: `response.reasoning_summary_text.delta` and `response.reasoning_text.delta` events routed to collapsible thinking section (same path as DeepSeek)
- **Current Model Catalog**: GPT-6.1 Sol (default), GPT-6 Sol/Luna/Astra, DeepSeek V4.1-Flash and V4-Pro, Qwen 3.8/3.7, Kimi K3, GLM 5.2, Gemini 3.6 Flash, Claude Fable 5.1 / Opus 5.5 / Sonnet 5.5, and custom compatible endpoints
- **DeepSeek Vision**: `deepseek-flash` accepts image input through the existing Chat Completions image blocks; `deepseek-v4-pro` remains text-only. Both use a 1,048,576-token context and 393,216-token maximum output
- **Session Management**: Multiple chat sessions with independent model and tool selection
- **Vision Support**: Image upload and analysis
- **Image Generation**: GPT-6 family image generation with Responses API and multi-turn refinement
- **Streaming**: Real-time token-by-token output with smooth layout updates (deferred scroll via `DispatchQueue.main.async`)

**UI Components**:
- **Session Sidebar**: Chat history with session selection and search
- **Message Bubbles**: Textual-rendered Markdown with copy-code buttons on code blocks
- **Thinking Section**: Collapsible reasoning/chain-of-thought view with brain icon
- **Floating Toolbar**: Upload, Web Search, Image Generation mode toggles
- **Text Input**: Auto-expanding with send button and IME support

**Implementation Details**:
- **Markdown**: Textual library replaces MarkdownUI; renders during streaming without layout flicker
- **Unified Router**: `AIChatRouter` is shared by AI Chat and AI Translate and dispatches from provider protocol plus model endpoint
- **Responses API**: `ResponsesAPI` handles `response.output_text.delta` and `response.completed` SSE events; `cancelCurrentRequest()` supports stop
- **Migration**: Missing provider protocol decodes as OpenAI Compatible; legacy `useResponsesAPI` decodes into `chatEndpoint = responses`
- **Model Sync**: startup catalog sync upgrades preset providers, preserves custom models and active states, and retains model UUIDs across known tier migrations. GPT-5.6 Sol/Terra/Luna migrate to GPT-6.1 Sol / GPT-6 Sol / GPT-6 Luna respectively; Astra is added without replacing the default. Older DeepSeek Flash and Claude 5 IDs migrate to their current equivalents
- **API Configuration**: Provider protocol picker, provider presets, and per-model Chat Completions/Responses endpoint picker

### 20. Struct Converter
**Files**: `StructConverterView.swift`, `StructConverterParsers.swift`, `StructConverterGenerators.swift`, `StructIR.swift`

**Features** (v2.13.0):
- **Four Input Formats**: JSON, TOML, YAML (block style), and SQL DDL (CREATE TABLE statements)
- **Seven Output Languages**: TypeScript interface, Python dataclass, Go struct (json tags), Java POJO with getters/setters, Rust struct (serde derives), Swift Codable struct, PHP typed class
- **Type Inference**: Detects strings, integers, doubles, booleans, ISO 8601 dates, arrays, nested objects, and nullable fields from sample data
- **Nested Structs**: Walks every nested object/array-of-objects and emits a sub-type per level; struct names derive from the field name with naive singularization for arrays
- **Smart Field Naming**: Per-language conventions — camelCase for TypeScript/Swift/PHP, snake_case for Python/Rust, PascalCase fields for Go/Java — while serde renames, Swift CodingKeys, and Go struct tags preserve the original keys
- **Deterministic Output**: Fields sorted alphabetically; nested types emitted in dependency order (children before parents)

**Architecture**:
```
Input Text ──▶ StructParserFactory ──▶ StructSchema (IR) ──▶ StructGeneratorFactory ──▶ Output Code
```

- **`StructIR.swift`** — Defines `IRType` (string/integer/double/bool/date/array/object/dictionary/null/anyValue), `StructField`, `StructDef`, `StructSchema`, plus `StructInputFormat` and `StructOutputLanguage` enums and per-format sample inputs.
- **`StructConverterParsers.swift`** — As of v2.14.0, JSON/TOML/YAML inputs parse to the shared `DataValue` tree (via `DataConverter`) and feed a single `StructSchemaInferrer` that handles arrays-of-objects merging, optional-field detection, ISO 8601 date promotion, and alphabetical field ordering. `SQLDDLStructParser` is unchanged: it parses CREATE TABLE blocks via regex, splits columns at top-level commas, maps SQL types (INT/VARCHAR/DECIMAL/TIMESTAMP/...) to IR types, and respects NOT NULL/PRIMARY KEY for non-null fields.
- **`StructConverterGenerators.swift`** — One generator per language. Each implements `StructCodeGenerator` and emits text for the schema. Output is sorted child-first by traversing the IR (`orderedStructs`).

**UI Components**:
- Two segmented pickers (Input Format / Output Language) above the editors
- Root struct name field for renaming the top-level type
- Two-column layout: input editor (CodeMirror highlighted per format) and read-only output editor (CodeMirror highlighted per language)
- Sample/Clear buttons on input, Copy button on output, line/character metrics, status with type count

**Implementation Details**:
- All conversion is synchronous and runs on text changes; sample inputs cover common shapes for each format
- Optional handling: a field is optional if it's `null` in JSON, not present in every element of an array of objects, or lacks NOT NULL in SQL DDL
- Date detection: ISO 8601 regex (`YYYY-MM-DD[THH:MM[:SS][.fff][Z|±HHMM]]`) on string-shaped values
- Array element merging: when parsing arrays of objects, fields present in every element are required; others are optional

### 21. Data Converter
**Files**: `DataConverterView.swift`, `DataConverter.swift`, `DataValue.swift`

**Features** (v2.14.0):
- **Four Formats, Any Direction**: Convert between JSON, YAML, TOML, and CSV with a from/to picker and a one-click swap button (swap also moves the last output back into the input)
- **Order Preservation**: A shared `DataValue` tree stores objects as ordered key/value pairs and dates verbatim, so conversions keep the author's field order and date representation
- **CSV Type Inference**: An "Infer types" toggle coerces CSV cells (`123` → int, `true` → bool, `98.5` → double, empty → null) or keeps every cell as a string
- **Nested ↔ CSV**: Nested objects/arrays flatten to dotted-key columns (`address.city`, `tags.0`) with an ordered union header across rows; reading CSV unflattens dotted keys back into nested objects/arrays (numeric segments become arrays)
- **State Persistence**: Remembers input text, source/target formats, and the coercion toggle between sessions

**Architecture**:
```
Input Text ──▶ DataConverter.parse ──▶ DataValue ──▶ DataConverter.serialize ──▶ Output Text
```

- **`DataValue.swift`** — `indirect enum DataValue` (string/int/double/bool/date/null/array/object-as-ordered-pairs) with a custom `Equatable`, plus the `DataFormat` enum, per-format sample inputs, and `DataConvertError`.
- **`DataConverter.swift`** — `DataConverter` facade (`parse`/`serialize`/`convert`). JSON uses a hand-written order-preserving scanner and pretty-printer (avoids `JSONSerialization` key reordering). YAML routes through Yams `Node` to preserve order and quoting. TOML has a line-based parser (`[table]`, `[[array of tables]]`, dotted/inline) and an emitter that writes scalars, tables, and arrays-of-tables with unquoted date literals. CSV is an RFC-4180 reader/writer with dotted-key flatten/unflatten and a shared `DataScalar.infer` for type coercion.

**UI Components**:
- From/To segmented pickers with a swap button between them
- "Infer types" checkbox shown only when the source format is CSV
- Two-column layout: input editor (CodeMirror highlighted per format) and read-only output editor; Sample/Clear on input, Copy on output; line/character metrics and a status line

**Implementation Details**:
- Conversion is synchronous and runs on every input/format change; identical source and target formats short-circuit to a pass-through
- The `DataValue` model is shared with the Struct Converter, which adds date promotion and alphabetical ordering on its own side so its output is unaffected

## UI Design Principles

### Color Scheme
- **Primary**: System accent color
- **Secondary**: Gray tones for subtle elements
- **Success**: Green for valid states
- **Error**: Red for invalid states
- **Background**: System background colors

### Typography
- **Headers**: `.largeTitle`, `.headline` weights
- **Body**: `.body` with monospace for code/data
- **Captions**: `.caption` for metadata
- **Monospace**: Used for all technical data display

### Layout Patterns
- **Two-Column**: Input/output sections with arrow indicator
- **Tabbed**: Multiple related tools in single view
- **Sidebar**: Main navigation with SF Symbols
- **Split View**: Resizable panels for complex tools

### Interactive Elements
- **Buttons**: Consistent styling with `.bordered` and `.borderedProminent`
- **Text Fields**: Rounded border style
- **Pickers**: Segmented for modes, menu for options
- **Copy Buttons**: Ubiquitous copy-to-clipboard functionality

## Data Models

### ToolType Enum
```swift
enum ToolType: String, CaseIterable, Identifiable {
    case timestampConverter, unitConverter, baseConverter, colorPicker, jsonFormatter, base64,
         hexString, regexTest, uuidGenerator, urlTools, ipQuery, httpRequest,
         qrCode, sqlFormatter, htmlFormatter, jwt, parquetViewer,
         cryptoTools, aiChat, aiTranslate, currencyConverter, textCompare, structConverter

    var title: String { /* Display names */ }
    var iconName: String { /* SF Symbols */ }
}
```

### Supporting Models
- `UnitCategory` and `UnitData` for unit conversions
- `JSONMode` for JSON operations
- `SQLMode` for SQL formatting operations
- `HTMLMode` for HTML formatting operations
- `Base64Tab` for encoding modes
- `HexStringTab` for hex string converter modes
- `JWTTab` and `JWTAlgorithm` for JWT operations
- `UUIDVersion` and `UUIDFormat` for UUID options
- `URLTab` for URL tool modes
- `IPLocationInfo` and `BaiduIPInfo` for IP geolocation data
- `HTTPMethod` and `AuthType` for HTTP request configuration
- `HTTPHeader` and `HTTPResponseData` for request/response handling
- `RequestTab`, `ResponseTab`, and `ResponseViewMode` for HTTP UI state
- `QRCodeTab`, `QRCodeSize`, and `QRCodeCorrectionLevel` for QR code options
- `CryptoTab`, `HashAlgorithm`, and `RSAKeySize` for crypto tool operations
- `ChatMessage`, `MessageRole`, and `ChatState` for AI chat functionality

## Build Configuration

### Target Settings
- **Minimum macOS**: 14.0
- **Bundle Identifier**: com.hengfeiyang.devutilities
- **Version**: 2.8.1 (Build 1)
- **Swift Version**: 5.0
- **App Sandbox**: Enabled
- **Hardened Runtime**: Enabled
- **Network Access**: Enabled (for HTTP and IP Lookup tools)
- **File Access**: User-selected read-write

### Dependencies

#### Framework Dependencies
- **SwiftUI**: UI framework
- **Combine**: Reactive programming
- **Foundation**: Core utilities and networking
- **AppKit**: macOS integration (clipboard access, file dialogs)
- **CoreImage**: QR code generation with CIFilter
- **Vision**: QR code scanning with VNDetectBarcodesRequest
- **UniformTypeIdentifiers**: Modern file type handling
- **CryptoKit**: JWT HMAC signature generation and verification

#### Swift Package Manager Dependencies
- **CodeMirror-SwiftUI**: Code editor integration (github.com/hengfeiyang/CodeMirror-SwiftUI)

#### Custom Native Dependencies
- **ParquetViewer**: Rust-based library for Parquet/Arrow file reading
  - `ParquetViewer.swift`: Swift wrapper and API interface
  - `libparquet_viewer.dylib`: Compiled Rust library 
  - `parquet_viewer.h`: C header for FFI bridge
  - Single unified API for both Parquet and Arrow formats

## Testing Strategy

### Manual Testing
- Each tool has sample data for quick testing
- Real-time feedback for immediate validation
- Error cases handled gracefully

### UI Testing
- SwiftUI Previews for rapid development
- Different window sizes and orientations
- Accessibility compliance

## Future Enhancements

### Planned Features
1. **Preferences**: User customization options
2. **Themes**: Light/dark mode preferences
3. **Export/Import**: Save tool configurations
4. **Shortcuts**: Keyboard shortcuts for common actions
5. **Request History**: Persistent storage for IP queries
6. **Additional IP Services**: More geolocation data providers

### Technical Improvements
- **Performance**: Optimize for large data processing
- **Memory**: Efficient handling of large text inputs
- **Accessibility**: VoiceOver support
- **Localization**: Multi-language support

## TextEditor Component Enhancements (v2.3.1)

### IME Support
The TextEditor component was enhanced to properly support Input Method Editors (IME) for non-English languages like Chinese, Japanese, and Korean.

### Technical Implementation

**Problem**: The previous implementation used SwiftUI's `.onKeyPress` modifier which intercepted keyboard events before IME composition was complete, breaking character input for Asian languages.

**Solution**: Implemented NSTextViewDelegate method `textView(_:doCommandBy:)` with IME awareness:

```swift
func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
    // Check if IME is active (markedRange indicates ongoing composition)
    if textView.hasMarkedText() {
        // Let IME handle the event
        return false
    }

    // Handle Return key when IME is not active
    if commandSelector == #selector(NSResponder.insertNewline(_:)) {
        if let callback = parent.onEnterKey {
            callback()
            return true
        }
    }

    return false
}
```

**Key Features**:
- `hasMarkedText()` detection for IME composition state
- Only processes Enter key when composition is complete
- Optional `onEnterKey` callback for custom behavior
- Backwards compatible with existing code

**Integration**:
- AIChatView now uses `TextEditor(text:onEnterKey:)` instead of `.onKeyPress`
- Seamless message sending on Enter without breaking IME input
- Proper support for candidate selection during composition

## Feature Management System (v2.3.0)

### Overview
The Feature Management System allows users to customize which tools appear in the sidebar and reorganize them according to their preferences. This addresses the growing sidebar length with 20 tools by letting users hide unused features.

### Architecture

**FeatureManager.swift**:
- `@ObservableObject` class managing tool preferences
- `FeaturePreference` struct with `toolType`, `isEnabled`, and `sortOrder`
- UserDefaults persistence with JSON encoding/decoding
- Real-time preference updates with `@Published` properties

**FeatureSettingsView.swift**:
- Modal sheet accessed via gear icon in sidebar header
- 5-column responsive grid layout using `LazyVGrid`
- Drag-and-drop functionality with `Transferable` protocol
- Two-section design: enabled tools (top) and disabled tools (bottom)
- Visual feedback with custom drag previews and opacity changes

### UI Components

**Feature Cards**:
- 80x50pt cards showing tool icon and abbreviated name
- Different visual states for enabled/disabled
- Tap to toggle between sections
- Drag handles for reordering

**Grid Layout**:
- `GridItem(.flexible(), spacing: 0)` for responsive columns
- Automatic flow between enabled and disabled sections
- Placeholder text when disabled section is empty
- Top alignment for items in disabled section

### User Interactions

1. **Access Settings**: Gear icon in sidebar header
2. **Enable/Disable Tools**: Tap any card to move between sections
3. **Reorder Tools**: Drag cards within the same section
4. **Cross-section Drag**: Drag from enabled to disabled (or vice versa)
5. **Reset**: One-click restore to default layout
6. **Persistent**: Automatically saves preferences

### Data Flow

1. **Initialization**: FeatureManager loads preferences from UserDefaults
2. **ContentView Integration**: Uses `featureManager.filteredTools` for sidebar
3. **Real-time Updates**: Changes immediately reflected in sidebar
4. **Persistence**: JSON encoding saves preferences automatically
5. **Migration**: New tools automatically added to enabled section

### Technical Implementation

**ToolType Extensions**:
- Added `Codable` conformance for JSON persistence
- Added `Transferable` conformance for drag-and-drop
- `CodableRepresentation` with plain text content type

**ContentView Updates**:
- `@StateObject` FeatureManager integration
- Filtered tools computation based on enabled preferences
- Sheet presentation for settings modal
- Gear icon button in sidebar header

## Maintenance Guidelines

### Code Organization
- Each tool in separate Swift file
- Consistent naming conventions
- Comprehensive documentation
- SwiftUI best practices

### Adding New Tools
1. Add case to `ToolType` enum
2. Create new SwiftUI view file
3. Add to ContentView switch statement
4. Update this design document
5. Add appropriate tests

### Styling Updates
- Modify shared UI components
- Update color scheme in Assets.xcassets
- Maintain consistency across all tools

## Deployment

## AI Translate (v2.4.0)

Professional translation tool with intelligent translation, text polishing, and summarization powered by AI models.

### Features
- **19 Language Support**: Auto-detect, English, Chinese (Simplified/Traditional), Japanese, Korean, Spanish, French, German, Russian, Arabic, Hindi, Portuguese, Italian, Dutch, Turkish, Vietnamese, Thai, Indonesian
- **Three Operation Modes**:
  - **Translate**: Direct translation with special word mode for detailed dictionary-style explanations
  - **Polishing**: Improve clarity and fluency in the same language
  - **Summarize**: Create concise summaries in target language
- **Word Mode**: Automatic detection of single words with enhanced output (phonetic notation, meanings, examples, etymology)
- **Real-time Streaming**: Live translation results with animated status indicators
- **Smart Language Detection**: Auto-detect system language for default target language
- **Action Buttons**: Retry and copy buttons for quick operations

### Architecture
```
AITranslateView (Main UI)
├── Toolbar
│   ├── Model Selector (reuses AI Chat models)
│   ├── Source Language Picker
│   ├── Swap Button
│   ├── Target Language Picker
│   ├── Mode Selector (Translate/Polishing/Summarize)
│   └── Settings Button
├── Input Area (VSplitView top)
│   ├── TextEditor (min 200pt, max 500pt)
│   ├── Character Count
│   └── Submit Button
└── Output Area (VSplitView bottom)
    ├── Status Badge (overlaid on divider)
    ├── Translated Text (with lineSpacing: 6)
    └── Action Buttons (Retry/Copy)

TranslationPrompts
├── isWord() - Detect single word
├── isChinese() - Check target language
└── generatePrompts() - Generate system/user prompts

Models
├── TranslationLanguage - 19 language enum with system detection
├── TranslationMode - 3 mode enum with status messages
└── TranslationPrompts - Prompt generation logic
```

### Prompt Engineering
Based on openai-translator reference implementation:

**Word Mode (Chinese Target)**:
```
你是一个翻译引擎，请翻译给出的文本，只需要翻译不需要解释。当且仅当文本只有一个单词时，请给出单词原始形态（如果有）、单词的语种、对应的音标或转写、所有含义（含词性）、双语示例，至少三条例句。如果你认为单词拼写错误，请提示我最可能的正确拼写，否则请严格按照下面格式给到翻译结果：
<单词>
[<语种>]· / <音标>
[<词性缩写>] <中文含义>
例句：
<序号><例句>(例句翻译)
词源：
<词源>
```

**Word Mode (Other Languages)**:
```
You are a professional translation engine. Please translate the text into {targetLang} without explanation. When the text has only one word, please act as a professional dictionary, and list the original form of the word (if any), the language of the word, the corresponding phonetic notation or transcription, all senses with parts of speech, bilingual sentence examples (at least 3) and etymology.
```

### UI Details
- **Status Animation**: Only the ✍️ emoji animates left-right (10pt offset, 0.5s duration)
- **Status Badge**: Overlaid on divider with background color
- **Keyboard Shortcuts**: Enter to submit (plain), Shift+Enter for newline
- **Line Spacing**: Output text has 6pt line spacing for readability
- **Flexible Layout**: VSplitView allows user to resize input/output areas

### Integration
- Reuses `AIChatRouter` from AI Chat for OpenAI-compatible and Anthropic Messages streaming
- Reuses `ProviderManager` for model and API key management
- Reuses `AIProviderSettingsView` for configuration
- Shares AI Chat's model system (no duplicate configuration)

## Text-to-Speech (TTS) for AI Translate (v3.0)

### OpenAI Realtime Read-Aloud

- **Transport**: `RealtimeTTSClient` connects to the selected OpenAI provider's base URL via `wss://…/realtime?model=gpt-realtime-2.1-mini`, using the user's Keychain-managed API key. Custom gateways must support Realtime WebSockets; unsupported gateways are not silently redirected to OpenAI
- **GA Protocol**: Wait for `session.created`, send `session.update`, wait for `session.updated`, then send one isolated `response.create`. Output configuration uses `session.audio.output.format = {type: audio/pcm, rate: 24000}` and `response.output_audio.delta` events; no beta headers
- **Read-Aloud Contract**: An empty input context and JSON-quoted passage instruct the model to read the original text without translating, summarizing, answering it, or using tools. This is model-generated speech, not a deterministic verbatim guarantee; multilingual pronunciation, instruction-like passages, and long-text completeness require live validation
- **Privacy**: No microphone capture, input audio, or saved chat context is sent. Selected text is sent only when the user presses Speak. Settings identify OpenAI audio as AI-generated
- **Playback**: Decode Base64 PCM16, retain odd trailing bytes across frames, and schedule little-endian samples through `AVAudioPlayerNode`. `response.done` ends generation, while a played-back sentinel ends the UI state after queued audio drains
- **Lifecycle**: Stop or replacement cancels the Task and closes the socket. Generation tokens prevent stale callbacks; completion fires once. A 30-second idle timeout closes a stalled connection
- **Migration**: Legacy `tts-1`, `tts-1-hd`, and `gpt-4o-mini-tts` aliases/snapshots migrate to `gpt-realtime-2.1-mini`. Existing compatible voice selections remain; `fable`, `nova`, `onyx`, or invalid selections become `marin`. Ten voices: alloy, ash, ballad, cedar, coral, echo, marin, sage, shimmer, verse
- **Fallback**: Auto uses macOS speech if credentials are missing or OpenAI fails before audio starts. Explicit OpenAI mode displays errors. Failures after audio has been queued do not replay the whole passage locally
- **Tests**: `swiftc DevUtilities/Services/RealtimeTTSClient.swift DevUtilities/Services/OpenAITTSService.swift Tests/RealtimeTTSTests.swift -o /tmp/devutilities-realtime-tts-tests` exercises mock WebSocket transport and pre-audio lifecycle paths without credentials or audio output. A successful build/mock test does not establish live API availability or read-aloud fidelity

### Native macOS Engine (introduced v2.8.2)

Native macOS text-to-speech integration for AI Translate, allowing users to listen to both source and translated text.

### Features
- **Native AVFoundation TTS**: Uses macOS built-in speech synthesizer (no external dependencies)
- **19 Language Support**: Automatic voice selection for all translation languages
- **Dual TTS Buttons**: Speaker buttons for both input and output text
- **Animated Feedback**: Wave animation during playback with smooth transitions
- **Smart Text Processing**: SSML character escaping and whitespace validation
- **Thread-safe**: Internal state tracking to avoid priority inversion warnings

### Architecture
```
AVSpeechService (Singleton)
├── AVSpeechSynthesizer (macOS native)
├── Internal state tracking (isCurrentlySpeaking)
├── Text sanitization (escapes XML/SSML chars)
└── Delegate callbacks (onStart/onFinish)

SpeakerButton (SwiftUI Component)
├── SpeakerViewModel (@MainActor)
│   ├── isSpeaking state
│   └── AVSpeechService.shared reference
└── Visual states:
    ├── Idle: speaker.wave.3 icon
    └── Speaking: SpeakerMotionView animation

SpeakerMotionView (Animated Icon)
├── Three layered icons (speaker.wave.1/2/3)
├── Staggered opacity animations (0.2s delay each)
└── Left-aligned ZStack (prevents jitter)

TranslationLanguage Extension
└── ttsLanguageCode property
    └── Maps 19 languages to TTS codes (en-US, zh-CN, etc.)
```

### Implementation Details

**Text Sanitization**:
- Escapes XML/SSML special characters (`&`, `<`, `>`, `"`, `'`)
- Removes control characters to prevent parsing errors
- Filters non-printable characters while preserving whitespace

**Thread Safety**:
- Internal `isCurrentlySpeaking` state instead of querying synthesizer
- Avoids priority inversion by not blocking on lower QoS threads
- Delegate methods update internal state atomically

**Error Prevention**:
- Triple-layer validation (Service, ViewModel, Button)
- Validates text is non-empty after trimming whitespace
- Checks voice availability before speaking
- Graceful fallback with callback execution

**UI Integration**:
- Input speaker button: Next to character count in bottom bar
- Output speaker button: Alongside retry/copy buttons
- Buttons auto-disable when text is empty
- Left-aligned animation prevents icon shifting

### Performance
- Singleton pattern reduces memory overhead
- No network requests (fully offline)
- Instant playback start (< 0.05s)
- Zero external dependencies

### App Store Requirements
- Code signing configuration
- App icon in all required sizes
- Privacy policy for network access
- App Store Connect metadata

### Distribution Options
- Mac App Store
- Direct distribution with notarization
- Developer ID signing for enterprise

---

*This design document should be updated whenever significant changes are made to the app architecture or individual tools.*
