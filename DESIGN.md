# DevPalette - Design Document

## Overview
DevPalette is a native macOS application built with SwiftUI that provides 18 essential developer utilities in a single, easy-to-use interface. The app follows Apple's Human Interface Guidelines and provides a consistent, professional experience across all tools.

## Architecture

### Project Structure
```
DevPalette/
├── DevPalette.xcodeproj/            # Xcode project configuration
│   └── project.xcworkspace/
│       └── xcshareddata/swiftpm/   # SPM package dependencies
├── DevPalette/
│   ├── DevPaletteApp.swift          # Main app entry point
│   ├── ContentView.swift           # Navigation split view
│   ├── Models/
│   │   ├── ToolType.swift          # Tool definitions
│   │   ├── FeatureManager.swift    # Feature preferences management
│   │   ├── TranslationLanguage.swift   # NEW: 19 language definitions
│   │   ├── TranslationMode.swift       # NEW: 3 translation modes
│   │   └── TranslationPrompts.swift    # NEW: Prompt generation logic
│   ├── Views/                      # All 18 tool implementations
│   │   ├── TimestampConverterView.swift
│   │   ├── UnitConverterView.swift
│   │   ├── JSONFormatterView.swift
│   │   ├── Base64View.swift
│   │   ├── HexStringConverterView.swift
│   │   ├── RegexTestView.swift
│   │   ├── UUIDGeneratorView.swift
│   │   ├── URLToolsView.swift
│   │   ├── IPQueryView.swift
│   │   ├── HTTPRequestView.swift
│   │   ├── QRCodeView.swift
│   │   ├── SQLFormatterView.swift
│   │   ├── HTMLFormatterView.swift
│   │   ├── JWTView.swift
│   │   ├── ParquetViewerView.swift
│   │   ├── CryptoToolsView.swift
│   │   ├── AIChatView.swift
│   │   ├── AITranslateView.swift       # NEW: AI translation interface
│   │   └── FeatureSettingsView.swift   # Feature management interface
│   ├── Components/                 # Shared UI components
│   │   ├── CodeEditor.swift        # CodeMirror integration & diff editor
│   │   └── TextEditor.swift        # Custom text editor with IME support
│   ├── Assets.xcassets/            # App icons and assets
│   ├── Preview Content/            # SwiftUI preview assets
│   └── DevPalette.entitlements      # App sandbox permissions
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

### Tool Integration Pattern
Each tool follows a consistent pattern:
1. **Enum Definition**: Added to `ToolType` enum
2. **Icon Assignment**: SF Symbols icon
3. **View Implementation**: SwiftUI view with consistent styling
4. **Navigation Integration**: Switch case in `ContentView`

## Tool Specifications

### 1. Timestamp Converter
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

### 3. JSON Formatter
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

### 4. Base64 Encode/Decode
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

### 5. Hex String Converter
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

### 6. Regex Test
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

### 7. UUID Generator
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

### 8. URL Tools
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

### 9. IP Query
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

### 10. HTTP Request
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

### 11. QR Code
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

### 12. SQL Formatter
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

### 13. HTML Formatter
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

### 14. JWT Encoder/Decoder
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

### 15. Parquet Viewer
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

### 16. Crypto Tools
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

### 17. AI Chat
**File**: `AIChatView.swift`

**Features**:
- **Enhanced UI/UX**: Refined user interface with improved model selection and navigation
- **Multi-Model Support**: GPT-5, GPT-4.1, GPT-5 variants, O3/O4 Deep Research, Gemini 2.5 models, DeepSeek integration
- **Model Selection Fix**: Fixed model selector display to properly update when selecting different models
- **Duplicate Icon Fix**: Removed duplicate chevron icons in dropdown menus for cleaner interface
- **Intelligent Assistant**: AI-powered chat interface for development questions and guidance
- **Image Generation**: Automatic GPT-5/GPT-4.1 image generation with OpenAI Responses API
- **Multi-Turn Image Generation**: Context-aware image refinement using previous_response_id
- **Tool Selection Interface**: Floating toolbar with Chat, Web Search, and Image Generation modes
- **Session Management**: Multiple chat sessions with independent tool selection persistence
- **Vision Support**: Image upload and analysis capabilities
- **Real-time Chat**: Streaming responses with proper message history
- **Code Review**: Context-aware code analysis and suggestions
- **Technical Guidance**: Expert-level responses for programming challenges and best practices

**UI Components**:
- **Session Sidebar**: Chat history with session selection and search
- **Message Interface**: Scrollable conversation view with user and assistant messages
- **Floating Toolbar**: Overlay tool selection (➕ Upload, 🌐 Web Search, 📷 Image Generation)
- **Text Input**: Auto-expanding input area with toolbar and send button overlays
- **Image Preview**: Drag-and-drop image upload with preview thumbnails
- **Tool Indicators**: Visual feedback for active tool selection (blue highlighting)

**Tool Selection System**:
- **Chat Mode (default)**: Regular conversation interface
- **Web Search Mode**: Enable web search capabilities (placeholder for future implementation)
- **Image Generation Mode**: Force image generation regardless of keywords
- **Session Persistence**: Each chat session remembers its last selected tool
- **Visual Feedback**: Immediate UI updates with blue highlighting for active tools

**Implementation Details**:
- **Model Architecture**: AIModel enum with chat/image model types and capabilities
- **Session Management**: ChatSession model with selectedTool persistence via JSON storage
- **Responses API Integration**: GPT-5/GPT-4.1 image generation with previous_response_id support
- **Multi-Turn Logic**: Automatic detection and chaining of image refinement requests
- **Image Storage**: Local caching of generated images with base64 processing
- **SwiftUI Reactivity**: Observable ChatManager with computed property tool access
- **Tool State Management**: Session-specific tool selection with immediate visual updates
- **API Configuration**: 60-second timeout for complex image generation requests

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
    case timestampConverter, unitConverter, jsonFormatter, base64,
         hexString, regexTest, uuidGenerator, urlTools, ipQuery, httpRequest,
         qrCode, sqlFormatter, htmlFormatter, jwt, parquetViewer,
         cryptoTools, aiChat

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
- **Bundle Identifier**: com.devpalette.DevPalette
- **Version**: 2.3.1 (Build 1)
- **Swift Version**: 5.0
- **App Sandbox**: Enabled
- **Hardened Runtime**: Enabled
- **Network Access**: Enabled (for HTTP and IP Query tools)
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
The Feature Management System allows users to customize which tools appear in the sidebar and reorganize them according to their preferences. This addresses the growing sidebar length with 17 tools by letting users hide unused features.

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
- Reuses `ChatCompletionsAPI` from AI Chat for streaming
- Reuses `ProviderManager` for model and API key management
- Reuses `AIProviderSettingsView` for configuration
- Shares AI Chat's model system (no duplicate configuration)

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
