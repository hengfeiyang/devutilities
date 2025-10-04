# AI Translate Feature - Product Requirements Document (PRD)

**Version:** 1.0
**Date:** 2025-10-01
**Feature:** AI Translate - Intelligent Translation, Polishing, and Summarization Tool
**Target Version:** DevUtilities v2.4.0

---

## 1. Overview

AI Translate is a new developer utility that provides intelligent text translation, polishing, and summarization powered by AI models. It reuses the existing AI Chat infrastructure (models, API configuration, settings) while providing a dedicated, streamlined interface for translation workflows.

### Key Features
- **Three Operation Modes**: Translate, Polishing, Summarize
- **19 Language Support**: Including Auto-detect, English, Chinese, Japanese, Korean, Hindi, and more
- **Real-time Streaming**: Live response streaming with visual feedback
- **Model Flexibility**: Reuses all AI Chat models (OpenAI, custom models, DeepSeek, etc.)
- **Smart Defaults**: Auto-detect source language, system-detected target language

---

## 2. User Interface Design

### 2.1 Top Toolbar (Left-aligned)

**Layout (Left to Right):**
```
⚙️ | [Model Selector ▾] | [Source Lang ▾] | ⇄ | [Target Lang ▾] | [🌐 Translate] | [✨] | [📝]
```

**Components:**

1. **Settings Icon (⚙️)**
   - Opens AI Chat settings page
   - Allows users to configure API keys, endpoints, custom models
   - Shared configuration with AI Chat feature

2. **Model Selector Dropdown**
   - Lists all available AI models from AI Chat
   - Includes: GPT-4, GPT-5, DeepSeek, custom models
   - Default: User's AI Chat default model
   - State persists across sessions

3. **Source Language Picker**
   - Dropdown with 19 languages + Auto Detect
   - **Default: "Auto Detect"** (always)
   - User can manually select if needed
   - Languages: See Section 3.2

4. **Swap Button (⇄)**
   - Swaps source and target languages
   - Not available when source is "Auto Detect"
   - Visual feedback on click

5. **Target Language Picker**
   - Dropdown with 19 languages (excludes Auto Detect)
   - **Default: System language** (detected from `Locale.current.language`)
   - State persists across sessions
   - Languages: See Section 3.2

6. **Mode Selector (3 buttons)**
   - **Active Mode**: Shows icon + text with black background
     - Examples: "🌐 Translate", "✨ Polishing", "📝 Summarize"
   - **Inactive Modes**: Shows only icon with minimal styling
     - Examples: 🌐, ✨, 📝
   - Clicking switches mode instantly
   - Default mode: Translate

### 2.2 Main Content Area

**Layout: Vertical Split (50/50)**

#### **Top Half: Input Pane**

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  [Large TextEditor - Multi-line input area]            │
│                                                         │
│                                                         │
│                                                         │
│  194                    Press <Enter> to submit,       │
│                         <Shift+Enter> for new line     │
│                                              [🚀 Submit]│
└─────────────────────────────────────────────────────────┘
```

**Elements:**
- **TextEditor**: Multi-line, auto-expanding, supports IME
- **Character Count** (bottom-left): Shows live character count
- **Hint Text** (bottom-center): Keyboard shortcut instructions
- **Submit Button** (bottom-right):
  - Appears only when text is entered
  - Icon: 🚀
  - Keyboard shortcut: Enter (when IME not active)
  - Shift+Enter: New line

#### **Bottom Half: Output Pane**

**Before Submit:**
```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  [Empty - waiting for translation]                     │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

**During Streaming:**
```
┌─────────────────────────────────────────────────────────┐
│  Translating... ✍️    ← (animated left-right motion)   │
│  ─────────────────────────────────────────────────────  │
│  [Streaming text appears here character by character   │
│   as the API response arrives in real-time...]         │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

**After Completion:**
```
┌─────────────────────────────────────────────────────────┐
│  Translated 👍                                          │
│  ─────────────────────────────────────────────────────  │
│  [Complete translated text displayed here]             │
│                                                         │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

**Output Elements:**
- **Status Badge Line**:
  - **During streaming**:
    - "Translating... ✍️" (Translate mode)
    - "Polishing... ✍️" (Polishing mode)
    - "Summarizing... ✍️" (Summarize mode)
    - ✍️ emoji animates left-right continuously (0.5s easeInOut repeat)
  - **After completion**:
    - "Translated 👍" (Translate mode)
    - "Polished 👍" (Polishing mode)
    - "Summarized 👍" (Summarize mode)
    - Static, no animation

- **Separator Line**: Visual divider below status badge

- **Result Text**:
  - Streams in real-time
  - Scrollable when content overflows
  - Selectable/copyable text

---

## 3. Technical Specifications

### 3.1 Architecture

**Reuse Existing Infrastructure:**
- **AIService.swift**: HTTP API calls, streaming logic
- **AIModelManager.swift**: Model configuration and persistence
- **AISettingsView.swift**: Settings modal (shared with AI Chat)
- **AIModel.swift**: Model data structures

**New Components:**
```
DevUtilities/Views/
  ├── AITranslateView.swift          (Main UI)
  ├── TranslationModeSelector.swift  (Mode buttons component)
  └── LanguagePicker.swift           (Language dropdown)

DevUtilities/Models/
  ├── TranslationMode.swift          (3 modes enum)
  ├── TranslationLanguage.swift      (19 languages enum)
  └── TranslationPrompts.swift       (Prompt templates)

DevUtilities/Services/
  └── TranslationService.swift       (Mode-specific prompt generation)

DevUtilities/Utils/
  └── FeatureItem.swift              (Add AI Translate to sidebar)
```

### 3.2 Supported Languages

**19 Languages Total:**

| Code | Display Name | System Locale |
|------|-------------|---------------|
| auto | Auto Detect | N/A |
| en | English | en |
| zh-Hans | 简体中文 | zh |
| zh-Hant | 繁體中文 | zh-Hant |
| ja | 日本語 | ja |
| ko | 한국어 | ko |
| es | Español | es |
| fr | Français | fr |
| de | Deutsch | de |
| ru | Русский | ru |
| ar | العربية | ar |
| hi | हिन्दी | hi |
| pt | Português | pt |
| it | Italiano | it |
| nl | Nederlands | nl |
| tr | Türkçe | tr |
| vi | Tiếng Việt | vi |
| th | ไทย | th |
| id | Bahasa Indonesia | id |

**Default Logic:**
```swift
// Source: Always "Auto Detect"
let defaultSource = TranslationLanguage.auto

// Target: Detect from system
let systemLangCode = Locale.current.language.languageCode?.identifier ?? "en"
let defaultTarget = mapSystemLangToTranslationLang(systemLangCode)
```

### 3.3 Operation Modes & Prompts

Based on reference: `/Users/yanghengfei/code/go/src/github.com/openai-translator/openai-translator/src/common/translate.ts`

#### **Mode 1: Translate**

**Purpose:** Direct translation between languages

**System Prompt (rolePrompt):**
```
You are a professional translation engine, please translate the text, only translate directly, don't explain.
```

**User Prompt (commandPrompt):**
```
Translate from {sourceLang} to {targetLang}. Only reply the result and nothing else:

{inputText}
```

**Note:** When source is "Auto Detect", use:
```
Translate the following text to {targetLang}. Only reply the result and nothing else:

{inputText}
```

#### **Mode 2: Polishing**

**Purpose:** Improve clarity, conciseness, and fluency in the same language

**System Prompt:**
```
You are an expert translator, translate directly without explanation.
```

**User Prompt:**
```
Please edit the following sentences in {sourceLang} to improve clarity, conciseness, and coherence, making them match the expression of native speakers. Only reply the result and nothing else:

{inputText}
```

**Note:** Target language is ignored in this mode (polishes source language)

#### **Mode 3: Summarize**

**Purpose:** Create concise summary in target language

**System Prompt:**
```
You are a professional text summarizer, you can only summarize the text, don't interpret it.
```

**User Prompt:**
```
Please summarize this text in the most concise language and must use {targetLang} language. Only reply the result and nothing else:

{inputText}
```

### 3.4 API Integration

**Request Format:**
```swift
struct TranslationRequest {
    let model: String              // e.g., "gpt-4"
    let messages: [ChatMessage]    // System + User prompts
    let stream: Bool = true        // Always streaming
    let temperature: Double = 0.7  // From AI Chat settings
}
```

**Streaming Response:**
```swift
// Use AIService.streamMessage() with callbacks:
onMessage: { chunk in
    // Append to output text
}
onFinished: { reason in
    // Update status badge: "Translating... ✍️" → "Translated 👍"
}
onError: { error in
    // Show error alert
}
```

**Stop Functionality:**
- User can cancel streaming via stop button (optional enhancement)
- Cancels `URLSessionDataTask` and Swift `Task`

### 3.5 State Management

**View State:**
```swift
@State private var selectedMode: TranslationMode = .translate
@State private var selectedModel: AIModel = defaultModel
@State private var sourceLanguage: TranslationLanguage = .auto
@State private var targetLanguage: TranslationLanguage = detectSystemLanguage()
@State private var inputText: String = ""
@State private var outputText: String = ""
@State private var isTranslating: Bool = false
@State private var characterCount: Int = 0
```

**Persistence:**
- Last used model → UserDefaults
- Last used target language → UserDefaults
- Source language always resets to "Auto Detect"
- Mode resets to "Translate" on app restart

### 3.6 Animation Specifications

**✍️ Writing Animation:**
```swift
@State private var writingOffset: CGFloat = 0

Text("Translating... ✍️")
    .offset(x: writingOffset)
    .onAppear {
        withAnimation(
            .easeInOut(duration: 0.5)
            .repeatForever(autoreverses: true)
        ) {
            writingOffset = 10  // pixels right, then back
        }
    }
    .onDisappear {
        writingOffset = 0
    }
```

**Mode Button Transition:**
- Background color: 0.2s ease-in-out
- Icon/text opacity: 0.15s linear

---

## 4. User Workflows

### 4.1 First-Time User (No AI Configuration)

1. User clicks "AI Translate" in sidebar
2. UI loads with empty state
3. User clicks ⚙️ settings icon
4. AI Chat settings modal opens
5. User configures API key, selects model
6. Settings modal closes
7. User can now use translation

### 4.2 Translation Workflow

1. User selects source language (default: Auto Detect)
2. User selects target language (default: System language)
3. User selects AI model (default: Last used or AI Chat default)
4. User ensures "Translate" mode is active
5. User types or pastes text in input area
6. Submit button appears
7. User clicks Submit or presses Enter
8. Output area shows "Translating... ✍️" with animation
9. Translated text streams in real-time below badge
10. Animation stops, badge changes to "Translated 👍"
11. User can copy result or submit new text

### 4.3 Polishing Workflow

1. User clicks ✨ icon (switches to Polishing mode)
2. Button changes to "✨ Polishing" with black background
3. User enters text to improve
4. Clicks Submit
5. Output shows "Polishing... ✍️" → "Polished 👍"
6. Improved text appears below

### 4.4 Summarize Workflow

1. User clicks 📝 icon (switches to Summarize mode)
2. Button changes to "📝 Summarize" with black background
3. User enters long text to summarize
4. Clicks Submit
5. Output shows "Summarizing... ✍️" → "Summarized 👍"
6. Concise summary appears below

---

## 5. Feature Management Integration

**Sidebar Addition:**
```swift
// In FeatureItem enum
case aiTranslate = "AI Translate"

var icon: String {
    case .aiTranslate: return "translate"  // SF Symbol
}

var view: some View {
    case .aiTranslate: AITranslateView()
}
```

**Default State:**
- Enabled by default
- Position: After AI Chat in sidebar
- Can be disabled in Feature Management settings

---

## 6. Error Handling

**Scenarios:**

1. **No API Configuration**
   - Show alert: "Please configure AI settings first"
   - Provide "Open Settings" button

2. **API Error (401, 403, etc.)**
   - Show error message in output area
   - Display API status code and message

3. **Network Timeout**
   - Show error: "Request timed out. Please try again."

4. **Empty Input**
   - Submit button disabled when input is empty

5. **Streaming Interrupted**
   - Show partial result with warning badge
   - Allow retry

---

## 7. Performance Requirements

- **Initial Load**: < 100ms (reuses existing components)
- **Mode Switch**: < 50ms (instant UI update)
- **Streaming Latency**: Display first token within 1-2s (API dependent)
- **Animation**: 60 FPS for ✍️ writing animation

---

## 8. Testing Checklist

### 8.1 Functional Testing
- [ ] Translation between all 19 language pairs
- [ ] Auto-detect correctly identifies source language
- [ ] Polishing improves text clarity
- [ ] Summarization produces concise output
- [ ] Mode switching updates UI correctly
- [ ] Language swap button works (excludes Auto Detect)
- [ ] Settings icon opens AI Chat settings
- [ ] Model selector shows all available models

### 8.2 UI Testing
- [ ] Status badge animation plays smoothly
- [ ] Status badge updates on completion
- [ ] Active mode shows icon + text
- [ ] Inactive modes show icon only
- [ ] Character count updates in real-time
- [ ] Submit button appears/disappears correctly
- [ ] Keyboard shortcuts work (Enter, Shift+Enter)
- [ ] IME support (Chinese, Japanese, Korean input)

### 8.3 Integration Testing
- [ ] Reuses AI Chat models correctly
- [ ] Shares API configuration with AI Chat
- [ ] Persists user preferences (model, target language)
- [ ] Handles API errors gracefully
- [ ] Streaming response displays correctly

### 8.4 Edge Cases
- [ ] Very long input text (10,000+ characters)
- [ ] Special characters and emojis
- [ ] Multiple rapid mode switches
- [ ] API rate limiting
- [ ] Offline mode (graceful error)

---

## 9. Future Enhancements (Out of Scope for v1)

1. **Translation History**: Save recent translations for quick access
2. **Copy Button**: One-click copy output to clipboard
3. **Text-to-Speech**: Read translated text aloud
4. **Bulk Translation**: Translate multiple paragraphs separately
5. **Custom Prompts**: User-defined prompt templates
6. **Language Detection Display**: Show detected source language
7. **Character Limit Warning**: Visual feedback for very long texts
8. **Export**: Save translations to file
9. **Comparison View**: Side-by-side original and translation

---

## 10. Success Metrics

**Adoption:**
- 50%+ of DevUtilities users try AI Translate within first month
- 20%+ weekly active usage rate

**Engagement:**
- Average 5+ translations per user per session
- 70%+ of users try multiple modes (Translate, Polish, Summarize)

**Quality:**
- < 5% error rate (API failures, UI bugs)
- < 3% user-reported issues with translations

**Performance:**
- 95%+ of requests complete successfully
- < 2s average time to first token

---

## 11. Dependencies

**External:**
- OpenAI API or compatible endpoints
- User-provided API keys
- Internet connection

**Internal:**
- AI Chat feature (for settings, models, API service)
- Feature Management system
- SwiftUI framework (macOS 14.0+)

---

## 12. Release Plan

**Version:** DevUtilities v2.4.0

**Timeline:**
1. Week 1: Core UI implementation (AITranslateView, mode selector, language pickers)
2. Week 1-2: Prompt engineering and API integration
3. Week 2: Animation and polish (✍️ animation, mode transitions)
4. Week 2-3: Testing and bug fixes
5. Week 3: Documentation updates (README, CLAUDE.md, DESIGN.md, website)
6. Week 3: Release

**Rollout:**
- Beta testing with 10-20 users
- Full release after feedback incorporation
- Announce on website and GitHub

---

## 13. Documentation Updates

All files must be updated before release:

1. **README.md**: Add AI Translate to feature list
2. **CLAUDE.md**: Update tool count (17 → 18), add AI Translate description
3. **DESIGN.md**: Add technical architecture section
4. **website/README.md**: Update feature list
5. **website/index.html**: Add AI Translate card
6. **website/release-notes.html**: Create v2.4.0 release notes

---

## 14. Open Questions

None - all design decisions finalized.

---

**End of PRD**
