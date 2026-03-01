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

import AVFoundation

/// Streams TTS audio from the OpenAI /audio/speech endpoint using PCM format.
///
/// The response is streamed as raw 24 kHz / 16-bit / mono PCM bytes.
/// Each received chunk is immediately converted to Float32 and scheduled on
/// AVAudioPlayerNode, so playback starts within ~200 ms of the first bytes
/// arriving — no sentence splitting or multiple API calls required.
@MainActor
final class OpenAITTSService: NSObject {
    static let shared = OpenAITTSService()

    private var engine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var speakingTask: Task<Void, Never>?
    private var finishCallback: (() -> Void)?
    private var finishFired = false
    /// Incremented every time speak/stop is called to invalidate stale callbacks.
    private var generation = 0

    // Float32 playback format matching the OpenAI PCM spec (24 kHz, mono)
    private let playbackFormat = AVAudioFormat(
        commonFormat: .pcmFormatFloat32,
        sampleRate: 24000,
        channels: 1,
        interleaved: false
    )!

    private override init() { super.init() }

    // MARK: - Public API

    func speak(
        text: String,
        model: String,
        voice: String,
        apiKey: String,
        baseURL: String,
        onStart: (() -> Void)? = nil,
        onFinish: (() -> Void)? = nil
    ) {
        internalStop(fireCallback: false)
        finishCallback = onFinish
        finishFired = false
        let gen = generation

        speakingTask = Task {
            do {
                let url = try buildURL(baseURL: baseURL)
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                // Request raw PCM so we can feed it directly to AVAudioPlayerNode
                let body: [String: String] = [
                    "model": model, "input": text,
                    "voice": voice, "response_format": "pcm"
                ]
                request.httpBody = try JSONEncoder().encode(body)

                let (asyncBytes, response) = try await URLSession.shared.bytes(for: request)
                guard !Task.isCancelled else { return }
                guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }

                // Set up audio engine
                let eng = AVAudioEngine()
                let node = AVAudioPlayerNode()
                eng.attach(node)
                eng.connect(node, to: eng.mainMixerNode, format: playbackFormat)
                try eng.start()
                node.play()
                engine = eng
                playerNode = node

                // Stream PCM bytes into audio buffers
                // 4800 frames = 0.2 s at 24 kHz; each Int16 frame = 2 bytes
                let framesPerBuffer = 4800
                let bytesPerBuffer = framesPerBuffer * 2

                var pending = Data()
                pending.reserveCapacity(bytesPerBuffer * 2)
                var onStartFired = false

                for try await byte in asyncBytes {
                    guard !Task.isCancelled else { break }
                    pending.append(byte)

                    if pending.count >= bytesPerBuffer {
                        let usable = pending.count & ~1   // round down to even bytes
                        if let buf = makePCMBuffer(from: pending, count: usable) {
                            // Use the sync (completion-handler) overload so we return immediately
                            // and keep filling the player queue while audio plays.
                            // The async overload would stall here until the buffer finishes.
                            node.scheduleBuffer(buf, completionHandler: nil)
                            if !onStartFired { onStartFired = true; onStart?() }
                        }
                        pending.removeFirst(usable)
                    }
                }

                guard !Task.isCancelled else { return }

                // Flush remaining bytes (must be even: complete Int16 frames)
                let usable = pending.count & ~1
                if usable > 0, let buf = makePCMBuffer(from: pending, count: usable) {
                    node.scheduleBuffer(buf, completionHandler: nil)
                    if !onStartFired { onStart?() }
                }

                // Schedule a silent sentinel buffer to detect end of playback
                if let sentinel = makeSilentBuffer(frames: 1) {
                    node.scheduleBuffer(sentinel, at: nil, options: [],
                                        completionCallbackType: .dataPlayedBack) { [weak self] _ in
                        Task { @MainActor [weak self] in
                            guard let self, self.generation == gen else { return }
                            self.fireFinish()
                        }
                    }
                } else {
                    fireFinish()
                }

            } catch {
                if !(error is CancellationError) {
                    print("OpenAITTSService error: \(error.localizedDescription)")
                }
                guard generation == gen else { return }
                fireFinish()
            }
        }
    }

    func stop() {
        internalStop(fireCallback: true)
    }

    // MARK: - Private

    private func internalStop(fireCallback: Bool) {
        generation += 1   // invalidates any in-flight sentinel callbacks
        speakingTask?.cancel()
        speakingTask = nil
        playerNode?.stop()
        engine?.stop()
        playerNode = nil
        engine = nil
        if fireCallback { fireFinish() }
    }

    private func fireFinish() {
        guard !finishFired else { return }
        finishFired = true
        playerNode?.stop()
        engine?.stop()
        playerNode = nil
        engine = nil
        let cb = finishCallback
        finishCallback = nil
        cb?()
    }

    /// Converts raw Int16 PCM bytes (little-endian, 24 kHz, mono) to a Float32 AVAudioPCMBuffer.
    private func makePCMBuffer(from data: Data, count: Int) -> AVAudioPCMBuffer? {
        let frameCount = count / 2
        guard frameCount > 0,
              let buffer = AVAudioPCMBuffer(pcmFormat: playbackFormat,
                                            frameCapacity: AVAudioFrameCount(frameCount))
        else { return nil }
        buffer.frameLength = AVAudioFrameCount(frameCount)

        data.withUnsafeBytes { raw in
            let src = raw.bindMemory(to: Int16.self)
            let dst = buffer.floatChannelData![0]
            for i in 0..<frameCount {
                dst[i] = Float(src[i]) / 32768.0
            }
        }
        return buffer
    }

    /// Returns a single-frame silent buffer used as a playback-completion sentinel.
    private func makeSilentBuffer(frames: AVAudioFrameCount) -> AVAudioPCMBuffer? {
        guard let buffer = AVAudioPCMBuffer(pcmFormat: playbackFormat,
                                            frameCapacity: frames) else { return nil }
        buffer.frameLength = frames
        // AVAudioPCMBuffer is zero-initialised (silence) by default
        return buffer
    }

    private func buildURL(baseURL: String) throws -> URL {
        let trimmed = baseURL
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard let url = URL(string: "\(trimmed)/audio/speech") else { throw URLError(.badURL) }
        return url
    }
}
