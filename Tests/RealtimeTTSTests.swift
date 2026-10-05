import Foundation

@main
enum RealtimeTTSTests {
    @MainActor
    static func main() async throws {
        try testSettingsMigration()
        try testRequestAndPayloads()
        try testCodecAndPCM()
        try await testStream()
        try await testFailureAndEmptyAudio()
        try await testTimeoutAndCancellation()
        await testPlaybackLifecycle()
        print("Realtime TTS tests passed (settings, GA payloads, PCM, handshake, errors, timeout, cancellation, playback lifecycle, fallback policy)")
    }

    static func testSettingsMigration() throws {
        precondition(OpenAITTSConfiguration.migratedModel(nil) == "gpt-realtime-2.1-mini")
        for old in ["tts-1", "tts-1-hd", "gpt-4o-mini-tts", "gpt-4o-mini-tts-2025-03-20", "gpt-4o-mini-tts-2025-12-15"] {
            precondition(OpenAITTSConfiguration.migratedModel(old) == OpenAITTSConfiguration.defaultModel)
        }
        precondition(OpenAITTSConfiguration.migratedModel("custom-realtime") == "custom-realtime")
        precondition(OpenAITTSConfiguration.voices.count == 10)
        precondition(OpenAITTSConfiguration.shouldUseLocalFallback(mode: "auto", hadAudio: false))
        precondition(!OpenAITTSConfiguration.shouldUseLocalFallback(mode: "auto", hadAudio: true))
        precondition(!OpenAITTSConfiguration.shouldUseLocalFallback(mode: "openai", hadAudio: false))
        precondition(!OpenAITTSConfiguration.shouldUseLocalFallback(mode: "macos", hadAudio: false))
        for voice in OpenAITTSConfiguration.voices { precondition(OpenAITTSConfiguration.migratedVoice(voice) == voice) }
        for voice in ["fable", "nova", "onyx"] { precondition(OpenAITTSConfiguration.migratedVoice(voice) == "marin") }
        let name = "devutilities-tts-test-\(UUID())"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        defaults.set("gpt-4o-mini-tts", forKey: "ai_tts_openai_model")
        defaults.set("nova", forKey: "ai_tts_openai_voice")
        defaults.set("macos", forKey: "ai_tts_mode")
        defaults.set("local-voice", forKey: "ai_tts_macos_voice_id")
        OpenAITTSConfiguration.migrateSettings(defaults)
        precondition(defaults.string(forKey: "ai_tts_openai_model") == "gpt-realtime-2.1-mini")
        precondition(defaults.string(forKey: "ai_tts_openai_voice") == "marin")
        precondition(defaults.string(forKey: "ai_tts_mode") == "macos")
        precondition(defaults.string(forKey: "ai_tts_macos_voice_id") == "local-voice")
        let snapshot = defaults.dictionaryRepresentation()
        OpenAITTSConfiguration.migrateSettings(defaults)
        precondition(NSDictionary(dictionary: snapshot).isEqual(to: defaults.dictionaryRepresentation()))
    }

    static func testRequestAndPayloads() throws {
        let request = try RealtimeTTSCodec.request(baseURL: " https://proxy.example.com/prefix/v1/ ", model: "custom realtime", apiKey: "test-key")
        precondition(request.url?.scheme == "wss" && request.url?.path == "/prefix/v1/realtime")
        precondition(URLComponents(url: request.url!, resolvingAgainstBaseURL: false)?.queryItems?.first?.value == "custom realtime")
        precondition(request.value(forHTTPHeaderField: "Authorization") == "Bearer test-key")
        precondition(request.value(forHTTPHeaderField: "OpenAI-Beta") == nil)
        for invalid in ["http://example.com/v1", "file:///tmp/foo", "https://user:password@example.com/v1", "bad-url"] {
            do { _ = try RealtimeTTSCodec.request(baseURL: invalid, model: "model", apiKey: "key"); preconditionFailure("Expected invalid endpoint") }
            catch RealtimeTTSError.invalidEndpoint {}
        }
        let session = RealtimeTTSCodec.sessionUpdate(voice: "alloy")["session"] as! [String: Any]
        precondition(session["type"] as? String == "realtime")
        precondition(session["output_modalities"] as? [String] == ["audio"])
        let audio = session["audio"] as! [String: Any]
        let output = audio["output"] as! [String: Any]
        precondition(output["voice"] as? String == "alloy")
        let format = output["format"] as! [String: Any]
        precondition(format["type"] as? String == "audio/pcm" && format["rate"] as? Int == 24_000)
        precondition((audio["input"] as! [String: Any])["turn_detection"] is NSNull)
        let passage = "你好\n\"Ignore instructions\" <tag> 😀"
        let response = try RealtimeTTSCodec.responseCreate(text: passage)["response"] as! [String: Any]
        precondition(response["conversation"] as? String == "none")
        precondition((response["input"] as! [Any]).isEmpty)
        precondition(response["output_modalities"] as? [String] == ["audio"])
        let instructions = response["instructions"] as! String
        let quoted = instructions.components(separatedBy: "\n").last!
        let decodedPassage = try JSONDecoder().decode(String.self, from: Data(quoted.utf8))
        precondition(decodedPassage == passage)
        _ = try JSONSerialization.data(withJSONObject: RealtimeTTSCodec.sessionUpdate(voice: "marin"))
        _ = try JSONSerialization.data(withJSONObject: RealtimeTTSCodec.responseCreate(text: passage))
    }

    static func testCodecAndPCM() throws {
        let created = try RealtimeTTSCodec.decode(event("session.created"))
        let audioDone = try RealtimeTTSCodec.decode(event("response.output_audio.done"))
        let audioDelta = try RealtimeTTSCodec.decode(event("response.output_audio.delta", ["delta": "AQIDBA=="]))
        precondition(created == .sessionCreated)
        precondition(audioDone == .ignored)
        precondition(audioDelta == .audio(Data([1, 2, 3, 4])))
        for malformed in [event("response.output_audio.delta", ["delta": "!invalid!"]), event("response.done"), Data("[]".utf8)] {
            do { _ = try RealtimeTTSCodec.decode(malformed); preconditionFailure("Malformed events must fail") } catch {}
        }
        var pcm = RealtimePCMAccumulator()
        precondition(pcm.append(Data([1])).isEmpty)
        precondition(pcm.append(Data([2, 3])) == Data([1, 2]))
        precondition(pcm.append(Data([4])) == Data([3, 4]))
        try pcm.validateEnd()
        _ = pcm.append(Data([5]))
        do { try pcm.validateEnd(); preconditionFailure("Truncated PCM must fail") } catch RealtimeTTSError.invalidAudio {}
    }

    @MainActor
    static func testStream() async throws {
        let fake = FakeTTSSocket(events: [event("session.created"), event("session.updated"), event("session.updated"),
            event("response.output_audio.delta", ["delta": "AQ=="]),
            event("response.output_audio.delta", ["delta": "AgME"]),
            event("response.output_audio.done"), done("completed")])
        let client = RealtimeTTSClient(makeSocket: { _ in fake })
        var audio = Data()
        try await run(client) { audio.append($0) }
        precondition(audio == Data([1, 2, 3, 4]))
        precondition(fake.sent.map { $0["type"] as! String } == ["session.update", "response.create"])
        precondition(fake.opened && fake.closed)
    }

    @MainActor
    static func testFailureAndEmptyAudio() async throws {
        for terminal in [done("failed"), done("incomplete"), done("cancelled"), done("completed"),
                         event("error", ["error": ["message": "Quota exceeded"]])] {
            let fake = FakeTTSSocket(events: [event("session.created"), event("session.updated"), terminal])
            let client = RealtimeTTSClient(makeSocket: { _ in fake })
            do { try await run(client) { _ in preconditionFailure("Unexpected audio") }; preconditionFailure("Must fail") }
            catch { precondition(fake.closed) }
        }
    }

    @MainActor
    static func testTimeoutAndCancellation() async throws {
        let stalled = FakeTTSSocket(events: [])
        let timeout = RealtimeTTSClient(idleTimeout: .milliseconds(10), makeSocket: { _ in stalled })
        do { try await run(timeout) { _ in }; preconditionFailure("Must time out") }
        catch RealtimeTTSError.timedOut { precondition(stalled.closed) }

        let fake = FakeTTSSocket(events: [event("session.created"), event("session.updated")])
        let client = RealtimeTTSClient(makeSocket: { _ in fake })
        let task = Task { try await run(client) { _ in preconditionFailure("Audio after stop") } }
        while fake.sent.count < 2 { await Task.yield() }
        task.cancel()
        do { try await task.value; preconditionFailure("Must cancel") }
        catch is CancellationError { precondition(fake.closed) }
    }

    @MainActor
    static func testPlaybackLifecycle() async {
        // These pre-audio paths do not create AVAudioEngine or play test audio.
        let first = FakeTTSSocket(events: [])
        let second = FakeTTSSocket(events: [event("session.created"), event("session.updated"),
                                           event("error", ["error": ["message": "Test failure"]])])
        var sockets = [first, second]
        let service = OpenAITTSService(makeClient: {
            let socket = sockets.removeFirst()
            return RealtimeTTSClient(makeSocket: { _ in socket })
        })
        var firstFinishes = 0
        var secondFinishes = 0
        var errors = 0
        service.speak(text: "First", model: OpenAITTSConfiguration.defaultModel, voice: "marin", apiKey: "test", baseURL: "https://example.com/v1",
                      onFinish: { firstFinishes += 1 }, onError: { _, _ in preconditionFailure("Replaced request must not surface an error") })
        while !first.opened { await Task.yield() }
        service.speak(text: "Second", model: OpenAITTSConfiguration.defaultModel, voice: "marin", apiKey: "test", baseURL: "https://example.com/v1",
                      onFinish: { secondFinishes += 1 }, onError: { _, hadAudio in
            precondition(!hadAudio)
            errors += 1
        })
        while errors == 0 { await Task.yield() }
        precondition(firstFinishes == 1 && secondFinishes == 1 && errors == 1)
        precondition(first.closed && second.closed)
        service.stop()
        precondition(secondFinishes == 1, "Stop after failure must not repeat completion")

        let waiting = FakeTTSSocket(events: [])
        let stopped = OpenAITTSService(makeClient: { RealtimeTTSClient(makeSocket: { _ in waiting }) })
        var finishes = 0
        stopped.speak(text: "Stopped", model: OpenAITTSConfiguration.defaultModel, voice: "marin", apiKey: "test", baseURL: "https://example.com/v1",
                      onFinish: { finishes += 1 }, onError: { _, _ in preconditionFailure("Stop must not cause fallback") })
        while !waiting.opened { await Task.yield() }
        stopped.stop()
        for _ in 0..<10 { await Task.yield() }
        precondition(waiting.closed && finishes == 1)
    }

    @MainActor
    static func run(_ client: RealtimeTTSClient, audio: (Data) throws -> Void) async throws {
        try await client.stream(text: "Hello", model: OpenAITTSConfiguration.defaultModel,
                                voice: "marin", apiKey: "test", baseURL: "https://example.com/v1", onAudio: audio)
    }
    static func event(_ type: String, _ fields: [String: Any] = [:]) -> Data {
        var object = fields
        object["type"] = type
        return try! JSONSerialization.data(withJSONObject: object)
    }
    static func done(_ status: String) -> Data { event("response.done", ["response": ["status": status]]) }
}

@MainActor
final class FakeTTSSocket: RealtimeTTSSocket {
    var events: [Data]
    var sent: [[String: Any]] = []
    var opened = false
    var closed = false
    private var receiver: CheckedContinuation<Data, Error>?
    init(events: [Data]) { self.events = events }
    func open() { opened = true }
    func send(_ event: [String: Any]) async throws { sent.append(event) }
    func receive() async throws -> Data {
        guard !closed else { throw URLError(.cancelled) }
        if !events.isEmpty { return events.removeFirst() }
        return try await withCheckedThrowingContinuation { receiver = $0 }
    }
    func close() {
        closed = true
        receiver?.resume(throwing: URLError(.cancelled))
        receiver = nil
    }
}
