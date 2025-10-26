# TTS语音播放实现方案参考文档（Swift/macOS版本）

基于 macOS AVFoundation 框架的原生语音播放功能实现方案

## 1. 架构设计

### 1.1 TTS管理器（单例模式）
```swift
import AVFoundation

class TTSManager {
    static let shared = TTSManager()
    private let synthesizer = AVSpeechSynthesizer()

    private init() {}  // 防止外部创建实例

    func speak(text: String, language: String, rate: Float = 0.5, volume: Float = 1.0) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = rate
        utterance.volume = volume

        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }

    func pause() {
        synthesizer.pauseSpeaking(at: .word)
    }

    func resume() {
        synthesizer.continueSpeaking()
    }
}
```

### 1.2 语言映射系统
```swift
// 内部语言代码到TTS语言代码的映射
enum LanguageCode: String, CaseIterable {
    case en = "en"
    case zhHans = "zh-Hans"
    case zhHant = "zh-Hant"
    case ja = "ja"
    case ko = "ko"
    case es = "es"
    case fr = "fr"
    case de = "de"
    case ru = "ru"
    case ar = "ar"
    case pt = "pt"
    case it = "it"
    case nl = "nl"
    case tr = "tr"
    case vi = "vi"
    case th = "th"
    case id = "id"
}

let langCodeToTTSLang: [LanguageCode: String] = [
    .en: "en-US",
    .zhHans: "zh-CN",
    .zhHant: "zh-TW",
    .ja: "ja-JP",
    .ko: "ko-KR",
    .es: "es-ES",
    .fr: "fr-FR",
    .de: "de-DE",
    .ru: "ru-RU",
    .ar: "ar-SA",
    .pt: "pt-BR",
    .it: "it-IT",
    .nl: "nl-NL",
    .tr: "tr-TR",
    .vi: "vi-VN",
    .th: "th-TH",
    .id: "id-ID"
]
```

## 2. AVFoundation核心实现

### 2.1 基础语音服务
```swift
import AVFoundation

class AVSpeechService: NSObject, AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()
    private var onFinish: (() -> Void)?
    private var onStart: (() -> Void)?

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(
        text: String,
        language: String,
        rate: Float = 0.5,
        volume: Float = 1.0,
        onStart: (() -> Void)? = nil,
        onFinish: (() -> Void)? = nil
    ) {
        self.onStart = onStart
        self.onFinish = onFinish

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = rate  // 0.0 - 1.0 (0.5为正常语速)
        utterance.volume = volume  // 0.0 - 1.0

        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }

    func pause() {
        synthesizer.pauseSpeaking(at: .word)
    }

    func resume() {
        synthesizer.continueSpeaking()
    }

    var isSpeaking: Bool {
        return synthesizer.isSpeaking
    }

    // MARK: - AVSpeechSynthesizerDelegate

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        onStart?()
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        onFinish?()
    }
}
```

### 2.2 获取可用语音
```swift
extension AVSpeechService {
    // 获取所有可用语音
    static func getAvailableVoices() -> [AVSpeechSynthesisVoice] {
        return AVSpeechSynthesisVoice.speechVoices()
    }

    // 根据语言筛选语音
    static func getVoices(for language: String) -> [AVSpeechSynthesisVoice] {
        return AVSpeechSynthesisVoice.speechVoices().filter {
            $0.language.hasPrefix(language.prefix(2))
        }
    }

    // 获取默认语音
    static func getDefaultVoice(for language: String) -> AVSpeechSynthesisVoice? {
        return AVSpeechSynthesisVoice(language: language)
    }
}
```

## 3. SwiftUI组件实现

### 3.1 SpeakerButton主视图
```swift
import SwiftUI
import AVFoundation

struct SpeakerButton: View {
    let text: String
    let language: String
    var rate: Float = 0.5
    var volume: Float = 1.0

    @StateObject private var viewModel = SpeakerViewModel()

    var body: some View {
        Button(action: {
            if viewModel.isSpeaking {
                viewModel.stopSpeaking()
            } else {
                viewModel.speak(
                    text: text,
                    language: language,
                    rate: rate,
                    volume: volume
                )
            }
        }) {
            HStack(spacing: 4) {
                if viewModel.isSpeaking {
                    SpeakerMotionView()
                } else {
                    Image(systemName: "speaker.wave.2")
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(text.isEmpty)
    }
}

// ViewModel
@MainActor
class SpeakerViewModel: ObservableObject {
    @Published var isSpeaking = false

    private let speechService = AVSpeechService()

    func speak(text: String, language: String, rate: Float, volume: Float) {
        guard !text.isEmpty else { return }

        speechService.speak(
            text: text,
            language: language,
            rate: rate,
            volume: volume,
            onStart: {
                Task { @MainActor in
                    self.isSpeaking = true
                }
            },
            onFinish: {
                Task { @MainActor in
                    self.isSpeaking = false
                }
            }
        )
    }

    func stopSpeaking() {
        speechService.stop()
        isSpeaking = false
    }
}
```

### 3.2 SpeakerMotion动画视图
```swift
import SwiftUI

struct SpeakerMotionView: View {
    @State private var opacity1: Double = 0
    @State private var opacity2: Double = 0
    @State private var opacity3: Double = 0

    var body: some View {
        ZStack {
            Image(systemName: "speaker.wave.1")
                .opacity(opacity1)
            Image(systemName: "speaker.wave.2")
                .opacity(opacity2)
            Image(systemName: "speaker.wave.3")
                .opacity(opacity3)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                opacity1 = 1
            }
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true).delay(0.2)) {
                opacity2 = 1
            }
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true).delay(0.4)) {
                opacity3 = 1
            }
        }
    }
}
```

## 4. 核心功能特性

### 4.1 文本分块处理
```swift
extension String {
    func splitByByteLength(_ maxBytes: Int) -> [String] {
        var chunks: [String] = []
        var currentChunk = ""

        for word in self.components(separatedBy: " ") {
            let testChunk = currentChunk.isEmpty ? word : currentChunk + " " + word

            if testChunk.utf8.count <= maxBytes {
                currentChunk = testChunk
            } else {
                if !currentChunk.isEmpty {
                    chunks.append(currentChunk)
                }
                currentChunk = word
            }
        }

        if !currentChunk.isEmpty {
            chunks.append(currentChunk)
        }

        return chunks
    }
}
```

### 4.2 字符清理
```swift
extension String {
    func removeIncompatibleCharacters() -> String {
        // 移除控制字符，避免TTS解析错误
        // 保留可读字符和标点符号
        return self.filter { char in
            let scalar = char.unicodeScalars.first!
            return !CharacterSet.controlCharacters.contains(scalar) || char.isWhitespace
        }
    }
}
```

### 4.3 中止控制
```swift
// 支持中途停止播放
class TTSController {
    private let synthesizer = AVSpeechSynthesizer()

    func cancel() {
        // 立即停止当前播放
        synthesizer.stopSpeaking(at: .immediate)
    }

    func pauseAtBoundary() {
        // 在单词边界暂停
        synthesizer.pauseSpeaking(at: .word)
    }
}
```

## 5. 最佳实践建议

### 5.1 错误处理
```swift
enum TTSError: LocalizedError {
    case noVoiceAvailable
    case textEmpty
    case synthesizerBusy

    var errorDescription: String? {
        switch self {
        case .noVoiceAvailable:
            return "该语言没有可用的语音"
        case .textEmpty:
            return "文本不能为空"
        case .synthesizerBusy:
            return "语音合成器正在使用中"
        }
    }
}

// 错误处理示例
func speakSafely(text: String, language: String) throws {
    guard !text.isEmpty else {
        throw TTSError.textEmpty
    }

    guard AVSpeechSynthesisVoice(language: language) != nil else {
        throw TTSError.noVoiceAvailable
    }

    TTSManager.shared.speak(text: text, language: language)
}
```

### 5.2 用户体验
```swift
// 播放状态的视觉反馈
enum SpeakerState {
    case idle          // 空闲状态
    case speaking      // 播放中（显示动画图标）
    case paused        // 暂停中
}

// 支持点击停止正在播放的音频
struct TTSButton: View {
    @State private var state: SpeakerState = .idle

    var body: some View {
        Button(action: handleTap) {
            switch state {
            case .idle:
                Image(systemName: "speaker.wave.2")
            case .speaking:
                SpeakerMotionView()
            case .paused:
                Image(systemName: "pause.circle")
            }
        }
    }

    private func handleTap() {
        if state == .speaking {
            // 停止播放
            TTSManager.shared.stop()
            state = .idle
        } else {
            // 开始播放
            state = .speaking
            TTSManager.shared.speak(text: text, language: language)
        }
    }
}

// 长文本自动分段播放
func speakLongText(_ text: String, language: String) {
    let chunks = text.splitByByteLength(5000)

    for (index, chunk) in chunks.enumerated() {
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 2.0) {
            TTSManager.shared.speak(text: chunk, language: language)
        }
    }
}
```

### 5.3 性能优化
```swift
// 复用AVSpeechSynthesizer实例（单例模式）
class TTSManager {
    static let shared = TTSManager()
    private let synthesizer = AVSpeechSynthesizer()

    private init() {}  // 防止外部创建实例
}

// 避免重复播放
extension AVSpeechService {
    func speak(text: String, language: String, rate: Float = 0.5, volume: Float = 1.0) {
        // 如果正在播放，先停止
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = rate
        utterance.volume = volume

        synthesizer.speak(utterance)
    }
}

// 优化语音质量设置
extension AVSpeechUtterance {
    convenience init(qualityText text: String) {
        self.init(string: text)
        self.prefersAssistiveTechnologySettings = false  // 使用高质量语音
    }
}
```

## 6. 部署配置

### 6.1 语音配置
```swift
// TTS配置结构体
struct TTSConfig: Codable {
    var rate: Float = 0.5      // 0.0-1.0 (0.5为正常语速)
    var volume: Float = 1.0    // 0.0-1.0
    var defaultLanguage: String = "en-US"
}

struct VoiceInfo {
    let language: String       // 例如: "en-US", "zh-CN"
    let name: String          // 语音名称
    let quality: String       // 例如: "enhanced", "compact"

    init(from voice: AVSpeechSynthesisVoice) {
        self.language = voice.language
        self.name = voice.name
        self.quality = voice.quality.rawValue
    }
}

// 获取可用语音列表
func getAvailableVoices() -> [AVSpeechSynthesisVoice] {
    return AVSpeechSynthesisVoice.speechVoices()
}

// 根据语言筛选语音
func getVoices(for language: String) -> [AVSpeechSynthesisVoice] {
    return AVSpeechSynthesisVoice.speechVoices().filter {
        $0.language == language
    }
}
```

### 6.2 macOS权限配置
```xml
<!-- Info.plist（如果需要） -->
<!-- AVFoundation TTS不需要特殊权限 -->

<!-- App Sandbox配置（*.entitlements文件） -->
<!-- AVFoundation TTS不需要网络访问权限 -->
<key>com.apple.security.app-sandbox</key>
<true/>
```

## 7. 测试建议

### 7.1 测试用例
```swift
import XCTest
import AVFoundation

class TTSTests: XCTestCase {
    var ttsService: AVSpeechService!

    override func setUp() {
        super.setUp()
        ttsService = AVSpeechService()
    }

    // 测试多语言文本播放
    func testMultiLanguageSupport() {
        let testCases = [
            ("Hello World", "en-US"),
            ("你好世界", "zh-CN"),
            ("こんにちは世界", "ja-JP"),
            ("안녕하세요 세계", "ko-KR")
        ]

        for (text, language) in testCases {
            ttsService.speak(text: text, language: language)
            XCTAssertTrue(ttsService.isSpeaking, "应该正在播放 \(language)")
            ttsService.stop()
        }
    }

    // 测试长文本分段处理
    func testLongTextSplitting() {
        let longText = String(repeating: "Hello ", count: 1000)
        let chunks = longText.splitByByteLength(5000)

        XCTAssertGreaterThan(chunks.count, 1, "长文本应该被分段")
        for chunk in chunks {
            XCTAssertLessThanOrEqual(chunk.utf8.count, 5000, "每个分段不应超过限制")
        }
    }

    // 测试停止功能
    func testStopSpeaking() {
        ttsService.speak(text: "This is a long text that should be stopped", language: "en-US")

        // 等待一小段时间后停止
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.ttsService.stop()
        }

        // 验证停止成功
        Thread.sleep(forTimeInterval: 1.0)
        XCTAssertFalse(ttsService.isSpeaking, "播放应该已停止")
    }

    // 测试获取可用语音
    func testGetAvailableVoices() {
        let voices = AVSpeechService.getAvailableVoices()
        XCTAssertGreaterThan(voices.count, 0, "应该至少有一个可用语音")
    }

    // 测试语言过滤
    func testFilterVoicesByLanguage() {
        let enVoices = AVSpeechService.getVoices(for: "en-US")
        XCTAssertGreaterThan(enVoices.count, 0, "应该有英语语音")

        for voice in enVoices {
            XCTAssertTrue(voice.language.hasPrefix("en"), "所有语音应该是英语")
        }
    }
}
```

### 7.2 性能测试
```swift
// 音频延迟测量
func testAudioLatency() {
    let startTime = Date()
    ttsService.speak(text: "Test", language: "en-US")
    let latency = Date().timeIntervalSince(startTime)

    XCTAssertLessThan(latency, 0.5, "TTS启动延迟应小于0.5秒")
}

// 并发播放处理
func testConcurrentSpeaking() {
    // AVSpeechSynthesizer一次只能播放一个utterance
    ttsService.speak(text: "First", language: "en-US")
    XCTAssertTrue(ttsService.isSpeaking)

    // 第二次调用应该排队或替换
    ttsService.speak(text: "Second", language: "en-US")
    XCTAssertTrue(ttsService.isSpeaking)
}
```

## 8. 实战示例：集成到DevUtilities

### 8.1 在AI翻译工具中添加TTS
```swift
// Views/AITranslateView.swift
struct AITranslateView: View {
    @State private var translatedText = ""
    @State private var targetLanguage = "en-US"

    var body: some View {
        VStack {
            // 原有的翻译界面...

            // 添加播放按钮
            HStack {
                Text(translatedText)
                    .textSelection(.enabled)

                Spacer()

                SpeakerButton(
                    text: translatedText,
                    language: targetLanguage
                )
            }
        }
    }
}
```

### 8.2 创建独立的TTS工具
```swift
// Views/TTSView.swift
struct TTSView: View {
    @State private var inputText = ""
    @State private var selectedLanguage = "en-US"
    @State private var rate: Float = 0.5
    @State private var volume: Float = 1.0
    @State private var availableVoices: [AVSpeechSynthesisVoice] = []

    let languages = ["en-US", "zh-CN", "zh-TW", "ja-JP", "ko-KR", "es-ES", "fr-FR", "de-DE"]

    var body: some View {
        VStack(spacing: 16) {
            // 文本输入区
            TextEditor(text: $inputText)
                .frame(height: 200)
                .border(Color.gray.opacity(0.3))
                .overlay(alignment: .topLeading) {
                    if inputText.isEmpty {
                        Text("输入要朗读的文本...")
                            .foregroundColor(.gray)
                            .padding(8)
                    }
                }

            // 语言选择
            Picker("语言", selection: $selectedLanguage) {
                ForEach(languages, id: \.self) { lang in
                    Text(lang).tag(lang)
                }
            }
            .onChange(of: selectedLanguage) { _, newValue in
                updateAvailableVoices(for: newValue)
            }

            // 语速控制
            VStack(alignment: .leading) {
                HStack {
                    Text("语速")
                    Spacer()
                    Text("\(rate, specifier: "%.2f")")
                        .foregroundColor(.secondary)
                }
                Slider(value: $rate, in: 0.0...1.0)
            }

            // 音量控制
            VStack(alignment: .leading) {
                HStack {
                    Text("音量")
                    Spacer()
                    Text("\(volume, specifier: "%.0f")%")
                        .foregroundColor(.secondary)
                }
                Slider(value: $volume, in: 0.0...1.0)
            }

            // 可用语音列表（可选）
            if !availableVoices.isEmpty {
                VStack(alignment: .leading) {
                    Text("可用语音：\(availableVoices.count)个")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // 播放按钮
            HStack {
                Spacer()
                SpeakerButton(
                    text: inputText,
                    language: selectedLanguage,
                    rate: rate,
                    volume: volume
                )
                .font(.title)
                .help("朗读文本")
                Spacer()
            }
        }
        .padding()
        .onAppear {
            updateAvailableVoices(for: selectedLanguage)
        }
    }

    private func updateAvailableVoices(for language: String) {
        availableVoices = AVSpeechService.getVoices(for: language)
    }
}
```

### 8.3 添加到工具列表
```swift
// Models/Utility.swift
extension Utility {
    static let tts = Utility(
        id: "tts",
        name: "TTS朗读",
        icon: "speaker.wave.2",
        description: "文本转语音工具，支持多语言朗读"
    )
}

// 在 allUtilities 数组中添加
static let allUtilities: [Utility] = [
    // ... 其他工具
    .tts
]
```

---

**总结**:

该Swift/macOS版本方案基于AVFoundation框架提供原生TTS功能：

**优势**：
- ✅ **系统原生**：无需第三方依赖，稳定可靠
- ✅ **离线支持**：完全本地化，无需网络连接
- ✅ **多语言**：支持macOS系统安装的所有语言
- ✅ **零成本**：完全免费，无API限制
- ✅ **简单集成**：SwiftUI组件，易于集成到DevUtilities

**适用场景**：
- 个人开发工具（如DevUtilities）
- 开源项目
- 企业内部应用
- 教育应用

**建议**：
- 对于基本的TTS需求，AVFoundation完全够用
- 如需更高质量或特殊语音，可考虑Azure Speech Service等商业服务
- 保持单例模式以优化性能和内存使用
