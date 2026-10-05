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

/// Reads text through Realtime WebSocket audio output (24 kHz PCM16, mono).
/// No microphone capture or conversation history is sent.
@MainActor
final class OpenAITTSService: NSObject {
    static let shared = OpenAITTSService()

    private var engine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var speakingTask: Task<Void, Never>?
    private var realtimeClient: RealtimeTTSClient?
    private var finishCallback: (() -> Void)?
    private var finishFired = false
    /// Incremented every time speak/stop is called to invalidate stale callbacks.
    private var generation = 0
    private let makeClient: () -> RealtimeTTSClient

    // Float32 playback format matching the OpenAI PCM spec (24 kHz, mono)
    private let playbackFormat = AVAudioFormat(
        commonFormat: .pcmFormatFloat32,
        sampleRate: 24000,
        channels: 1,
        interleaved: false
    )!

    private override init() {
        makeClient = { RealtimeTTSClient() }
        super.init()
    }

    init(makeClient: @escaping () -> RealtimeTTSClient) {
        self.makeClient = makeClient
        super.init()
    }

    // MARK: - Public API

    func speak(
        text: String,
        model: String,
        voice: String,
        apiKey: String,
        baseURL: String,
        onStart: (() -> Void)? = nil,
        onFinish: (() -> Void)? = nil,
        onError: ((Error, Bool) -> Void)? = nil
    ) {
        internalStop(fireCallback: true)
        finishCallback = onFinish
        finishFired = false
        let gen = generation
        let client = makeClient()
        realtimeClient = client

        speakingTask = Task { [self] in
            var hasScheduledAudio = false
            do {
                try await client.stream(text: text, model: model, voice: voice, apiKey: apiKey, baseURL: baseURL) { [self] audio in
                    guard generation == gen, !Task.isCancelled else { throw CancellationError() }
                    if engine == nil {
                        let eng = AVAudioEngine()
                        let node = AVAudioPlayerNode()
                        eng.attach(node)
                        eng.connect(node, to: eng.mainMixerNode, format: playbackFormat)
                        try eng.start()
                        node.play()
                        engine = eng
                        playerNode = node
                    }
                    guard let node = playerNode, let buffer = makePCMBuffer(from: audio, count: audio.count) else {
                        throw RealtimeTTSError.invalidAudio
                    }
                    Self.enqueueBuffer(buffer, on: node)
                    if !hasScheduledAudio { hasScheduledAudio = true; onStart?() }
                }

                guard generation == gen, !Task.isCancelled, let node = playerNode else { return }
                realtimeClient = nil
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
                guard generation == gen else { return }
                fireFinish()
                if !(error is CancellationError), !Task.isCancelled {
                    onError?(error, hasScheduledAudio)
                }
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
        realtimeClient?.cancel()
        realtimeClient = nil
        playerNode?.stop()
        engine?.stop()
        playerNode = nil
        engine = nil
        if fireCallback { fireFinish() }
    }

    private func fireFinish() {
        guard !finishFired else { return }
        finishFired = true
        realtimeClient?.cancel()
        realtimeClient = nil
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

        let dst = buffer.floatChannelData![0]
        for i in 0..<frameCount {
            let offset = data.startIndex + i * 2
            let sample = UInt16(data[offset]) | UInt16(data[offset + 1]) << 8
            dst[i] = Float(Int16(bitPattern: sample)) / 32768.0
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

    /// Schedules a buffer on the player node using the synchronous overload.
    /// Marked nonisolated static so the compiler doesn't suggest the async alternative.
    private nonisolated static func enqueueBuffer(
        _ buffer: AVAudioPCMBuffer, on node: AVAudioPlayerNode
    ) {
        node.scheduleBuffer(buffer, completionHandler: nil)
    }

}
