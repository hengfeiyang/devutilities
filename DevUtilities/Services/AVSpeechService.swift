// Copyright 2025 Hengfei Yang.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import AVFoundation

/// Service for Text-to-Speech using AVFoundation
final class AVSpeechService: NSObject, AVSpeechSynthesizerDelegate, @unchecked Sendable {
    static let shared = AVSpeechService()

    private let synthesizer = AVSpeechSynthesizer()
    private var onFinish: (() -> Void)?
    private var onStart: (() -> Void)?
    private var isCurrentlySpeaking = false  // Track state internally

    private override init() {
        super.init()
        synthesizer.delegate = self
    }

    /// Speak the given text in the specified language
    func speak(
        text: String,
        language: String,
        rate: Float = 0.5,
        volume: Float = 1.0,
        onStart: (() -> Void)? = nil,
        onFinish: (() -> Void)? = nil
    ) {
        // Trim and validate text
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else {
            print("AVSpeechService: Cannot speak empty text")
            onFinish?()
            return
        }

        // Sanitize text to prevent SSML parsing errors
        let sanitizedText = sanitizeForSpeech(trimmedText)

        // Always stop without checking state to avoid priority inversion
        // stopSpeaking is safe to call even when not speaking
        synthesizer.stopSpeaking(at: .immediate)

        // Check if voice is available for the language
        guard let voice = AVSpeechSynthesisVoice(language: language) else {
            print("AVSpeechService: No voice available for language: \(language)")
            onFinish?()
            return
        }

        self.onStart = onStart
        self.onFinish = onFinish

        let utterance = AVSpeechUtterance(string: sanitizedText)
        utterance.voice = voice
        utterance.rate = rate  // 0.0 - 1.0 (0.5 is normal speed)
        utterance.volume = volume  // 0.0 - 1.0

        synthesizer.speak(utterance)
    }

    /// Sanitize text to prevent SSML parsing errors
    private func sanitizeForSpeech(_ text: String) -> String {
        var sanitized = text

        // Escape XML/SSML special characters
        sanitized = sanitized.replacingOccurrences(of: "&", with: "")
        sanitized = sanitized.replacingOccurrences(of: "<", with: "")
        sanitized = sanitized.replacingOccurrences(of: ">", with: "")
        sanitized = sanitized.replacingOccurrences(of: "\"", with: "")
        sanitized = sanitized.replacingOccurrences(of: "'", with: "")

        // Remove control characters that might cause issues
        sanitized = sanitized.components(separatedBy: .controlCharacters).joined()

        // Remove any remaining non-printable characters except standard whitespace
        sanitized = sanitized.filter { char in
            let scalar = char.unicodeScalars.first!
            return CharacterSet.whitespacesAndNewlines.contains(scalar) ||
                   !CharacterSet.controlCharacters.contains(scalar)
        }

        return sanitized
    }

    /// Stop speaking immediately
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        isCurrentlySpeaking = false
    }

    /// Pause speaking at word boundary
    func pause() {
        synthesizer.pauseSpeaking(at: .word)
    }

    /// Resume speaking
    func resume() {
        synthesizer.continueSpeaking()
    }

    /// Check if currently speaking
    var isSpeaking: Bool {
        return isCurrentlySpeaking
    }

    // MARK: - AVSpeechSynthesizerDelegate

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        isCurrentlySpeaking = true
        onStart?()
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isCurrentlySpeaking = false
        onFinish?()
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        isCurrentlySpeaking = false
        onFinish?()
    }
}

// MARK: - Voice Utilities

extension AVSpeechService {
    /// Get all available voices
    static func getAvailableVoices() -> [AVSpeechSynthesisVoice] {
        return AVSpeechSynthesisVoice.speechVoices()
    }

    /// Get voices for a specific language
    static func getVoices(for language: String) -> [AVSpeechSynthesisVoice] {
        return AVSpeechSynthesisVoice.speechVoices().filter {
            $0.language.hasPrefix(String(language.prefix(2)))
        }
    }

    /// Get default voice for a language
    static func getDefaultVoice(for language: String) -> AVSpeechSynthesisVoice? {
        return AVSpeechSynthesisVoice(language: language)
    }
}
