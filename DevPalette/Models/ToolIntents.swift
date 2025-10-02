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

import AppIntents
import Foundation

// MARK: - JSON Formatter Intent
struct OpenJSONFormatterIntent: AppIntent {
    nonisolated(unsafe) static var title: LocalizedStringResource = "JSON Formatter"
    nonisolated(unsafe) static var description = IntentDescription("Open JSON Formatter in DevPalette")
    nonisolated(unsafe) static var openAppWhenRun: Bool = true
        
    static var parameterSummary: some ParameterSummary {
        Summary("Open JSON Formatter")
    }

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            NotificationCenter.default.post(
                name: .openTool,
                object: nil,
                userInfo: ["tool": ToolType.jsonFormatter]
            )
        }
        
        return .result(dialog: "Opening JSON Formatter in DevPalette")
    }
}

// MARK: - Base64 Intent
struct OpenBase64Intent: AppIntent {
    nonisolated(unsafe) static var title: LocalizedStringResource = "Base64 Encoder/Decoder"
    nonisolated(unsafe) static var description = IntentDescription("Open Base64 Encoder/Decoder in DevPalette")
    nonisolated(unsafe) static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            NotificationCenter.default.post(
                name: .openTool,
                object: nil,
                userInfo: ["tool": ToolType.base64]
            )
        }
        
        return .result(dialog: "Opening Base64 Encoder/Decoder in DevPalette")
    }
}

// MARK: - UUID Generator Intent
struct OpenUUIDGeneratorIntent: AppIntent {
    nonisolated(unsafe) static var title: LocalizedStringResource = "UUID Generator"
    nonisolated(unsafe) static var description = IntentDescription("Open UUID Generator in DevPalette")
    nonisolated(unsafe) static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            NotificationCenter.default.post(
                name: .openTool,
                object: nil,
                userInfo: ["tool": ToolType.uuidGenerator]
            )
        }
        
        return .result(dialog: "Opening UUID Generator in DevPalette")
    }
}

// MARK: - Timestamp Converter Intent
struct OpenTimestampConverterIntent: AppIntent {
    nonisolated(unsafe) static var title: LocalizedStringResource = "Timestamp Converter"
    nonisolated(unsafe) static var description = IntentDescription("Open Timestamp Converter in DevPalette")
    nonisolated(unsafe) static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            NotificationCenter.default.post(
                name: .openTool,
                object: nil,
                userInfo: ["tool": ToolType.timestampConverter]
            )
        }
        
        return .result(dialog: "Opening Timestamp Converter in DevPalette")
    }
}

// MARK: - URL Tools Intent
struct OpenURLToolsIntent: AppIntent {
    nonisolated(unsafe) static var title: LocalizedStringResource = "URL Tools"
    nonisolated(unsafe) static var description = IntentDescription("Open URL Tools in DevPalette")
    nonisolated(unsafe) static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            NotificationCenter.default.post(
                name: .openTool,
                object: nil,
                userInfo: ["tool": ToolType.urlTools]
            )
        }
        
        return .result(dialog: "Opening URL Tools in DevPalette")
    }
}

// MARK: - Regex Test Intent
struct OpenRegexTestIntent: AppIntent {
    nonisolated(unsafe) static var title: LocalizedStringResource = "Regex Test"
    nonisolated(unsafe) static var description = IntentDescription("Open Regex Test in DevPalette")
    nonisolated(unsafe) static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            NotificationCenter.default.post(
                name: .openTool,
                object: nil,
                userInfo: ["tool": ToolType.regexTest]
            )
        }
        
        return .result(dialog: "Opening Regex Test in DevPalette")
    }
}

// MARK: - JWT Intent
struct OpenJWTIntent: AppIntent {
    nonisolated(unsafe) static var title: LocalizedStringResource = "JWT Encoder/Decoder"
    nonisolated(unsafe) static var description = IntentDescription("Open JWT Encoder/Decoder in DevPalette")
    nonisolated(unsafe) static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            NotificationCenter.default.post(
                name: .openTool,
                object: nil,
                userInfo: ["tool": ToolType.jwt]
            )
        }
        
        return .result(dialog: "Opening JWT Encoder/Decoder in DevPalette")
    }
}

// MARK: - HTTP Request Intent
struct OpenHTTPRequestIntent: AppIntent {
    nonisolated(unsafe) static var title: LocalizedStringResource = "HTTP Request"
    nonisolated(unsafe) static var description = IntentDescription("Open HTTP Request in DevPalette")
    nonisolated(unsafe) static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            NotificationCenter.default.post(
                name: .openTool,
                object: nil,
                userInfo: ["tool": ToolType.httpRequest]
            )
        }
        
        return .result(dialog: "Opening HTTP Request in DevPalette")
    }
}

// MARK: - QR Code Intent
struct OpenQRCodeIntent: AppIntent {
    nonisolated(unsafe) static var title: LocalizedStringResource = "QR Code"
    nonisolated(unsafe) static var description = IntentDescription("Open QR Code generator in DevPalette")
    nonisolated(unsafe) static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            NotificationCenter.default.post(
                name: .openTool,
                object: nil,
                userInfo: ["tool": ToolType.qrCode]
            )
        }
        
        return .result(dialog: "Opening QR Code generator in DevPalette")
    }
}

// MARK: - Crypto Tools Intent
struct OpenCryptoToolsIntent: AppIntent {
    nonisolated(unsafe) static var title: LocalizedStringResource = "Crypto Tools"
    nonisolated(unsafe) static var description = IntentDescription("Open Crypto Tools in DevPalette")
    nonisolated(unsafe) static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            NotificationCenter.default.post(
                name: .openTool,
                object: nil,
                userInfo: ["tool": ToolType.cryptoTools]
            )
        }
        
        return .result(dialog: "Opening Crypto Tools in DevPalette")
    }
}

// MARK: - AI Chat Intent
struct OpenAIChatIntent: AppIntent {
    nonisolated(unsafe) static var title: LocalizedStringResource = "AI Chat"
    nonisolated(unsafe) static var description = IntentDescription("Open AI Chat in DevPalette")
    nonisolated(unsafe) static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            NotificationCenter.default.post(
                name: .openTool,
                object: nil,
                userInfo: ["tool": ToolType.aiChat]
            )
        }
        
        return .result(dialog: "Opening AI Chat in DevPalette")
    }
}