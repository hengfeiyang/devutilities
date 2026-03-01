// Copyright 2026 Hengfei Yang.
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

import SwiftUI
import AVFoundation

/// A button that plays text using Text-to-Speech
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
            if viewModel.isSpeaking {
                SpeakerMotionView()
            } else {
                Image(systemName: "speaker.wave.3")
            }
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        .help(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "No text to speak" : (viewModel.isSpeaking ? "Stop speaking" : "Speak text"))
    }
}

/// ViewModel for managing TTS state
@MainActor
class SpeakerViewModel: ObservableObject {
    @Published var isSpeaking = false

    private let avService = AVSpeechService.shared
    private let openAIService = OpenAITTSService.shared

    private enum ActiveEngine {
        case av, openai
    }
    private var activeEngine: ActiveEngine = .av

    private enum TTSEngine {
        case openai(baseURL: String, apiKey: String, model: String, voice: String)
        case macos(voiceID: String?)
    }

    private func resolveEngine() -> TTSEngine {
        let settings = AIUISettings.shared
        let mode = settings.ttsMode

        if mode == "openai" || mode == "auto" {
            if let info = ProviderManager.shared.getActiveOpenAIForTTS() {
                return .openai(
                    baseURL: info.baseURL,
                    apiKey: info.apiKey,
                    model: settings.openAITTSModel,
                    voice: settings.openAITTSVoice
                )
            }
        }
        return .macos(voiceID: settings.macOSTTSVoiceID)
    }

    func speak(text: String, language: String, rate: Float, volume: Float) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else {
            print("SpeakerViewModel: Cannot speak empty text")
            return
        }

        switch resolveEngine() {
        case .openai(let baseURL, let apiKey, let model, let voice):
            activeEngine = .openai
            openAIService.speak(
                text: trimmedText,
                model: model,
                voice: voice,
                apiKey: apiKey,
                baseURL: baseURL,
                onStart: { [weak self] in
                    Task { @MainActor in self?.isSpeaking = true }
                },
                onFinish: { [weak self] in
                    Task { @MainActor in self?.isSpeaking = false }
                }
            )
            // Set speaking immediately so the UI reflects it while the request is in flight
            isSpeaking = true

        case .macos(let voiceID):
            activeEngine = .av
            avService.speak(
                text: trimmedText,
                language: language,
                rate: rate,
                volume: volume,
                voiceIdentifier: voiceID,
                onStart: { [weak self] in
                    Task { @MainActor in self?.isSpeaking = true }
                },
                onFinish: { [weak self] in
                    Task { @MainActor in self?.isSpeaking = false }
                }
            )
        }
    }

    func stopSpeaking() {
        switch activeEngine {
        case .openai:
            openAIService.stop()
        case .av:
            avService.stop()
        }
        isSpeaking = false
    }
}

#Preview {
    VStack(spacing: 20) {
        SpeakerButton(
            text: "Hello World",
            language: "en-US"
        )
        .font(.system(size: 24))

        SpeakerButton(
            text: "你好世界",
            language: "zh-CN"
        )
        .font(.system(size: 24))
    }
    .padding()
}
