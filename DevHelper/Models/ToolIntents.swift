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
    static var title: LocalizedStringResource = "JSON Formatter"
    static var description = IntentDescription("Open JSON Formatter in DevHelper")
    static var openAppWhenRun: Bool = true
        
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
        
        return .result(dialog: "Opening JSON Formatter in DevHelper")
    }
}

// MARK: - Base64 Intent
struct OpenBase64Intent: AppIntent {
    static var title: LocalizedStringResource = "Base64 Encoder/Decoder"
    static var description = IntentDescription("Open Base64 Encoder/Decoder in DevHelper")
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            NotificationCenter.default.post(
                name: .openTool,
                object: nil,
                userInfo: ["tool": ToolType.base64]
            )
        }
        
        return .result(dialog: "Opening Base64 Encoder/Decoder in DevHelper")
    }
}

// MARK: - UUID Generator Intent
struct OpenUUIDGeneratorIntent: AppIntent {
    static var title: LocalizedStringResource = "UUID Generator"
    static var description = IntentDescription("Open UUID Generator in DevHelper")
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            NotificationCenter.default.post(
                name: .openTool,
                object: nil,
                userInfo: ["tool": ToolType.uuidGenerator]
            )
        }
        
        return .result(dialog: "Opening UUID Generator in DevHelper")
    }
}

// MARK: - Timestamp Converter Intent
struct OpenTimestampConverterIntent: AppIntent {
    static var title: LocalizedStringResource = "Timestamp Converter"
    static var description = IntentDescription("Open Timestamp Converter in DevHelper")
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            NotificationCenter.default.post(
                name: .openTool,
                object: nil,
                userInfo: ["tool": ToolType.timestampConverter]
            )
        }
        
        return .result(dialog: "Opening Timestamp Converter in DevHelper")
    }
}

// MARK: - URL Tools Intent
struct OpenURLToolsIntent: AppIntent {
    static var title: LocalizedStringResource = "URL Tools"
    static var description = IntentDescription("Open URL Tools in DevHelper")
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            NotificationCenter.default.post(
                name: .openTool,
                object: nil,
                userInfo: ["tool": ToolType.urlTools]
            )
        }
        
        return .result(dialog: "Opening URL Tools in DevHelper")
    }
}

// MARK: - Regex Test Intent
struct OpenRegexTestIntent: AppIntent {
    static var title: LocalizedStringResource = "Regex Test"
    static var description = IntentDescription("Open Regex Test in DevHelper")
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            NotificationCenter.default.post(
                name: .openTool,
                object: nil,
                userInfo: ["tool": ToolType.regexTest]
            )
        }
        
        return .result(dialog: "Opening Regex Test in DevHelper")
    }
}

// MARK: - JWT Intent
struct OpenJWTIntent: AppIntent {
    static var title: LocalizedStringResource = "JWT Encoder/Decoder"
    static var description = IntentDescription("Open JWT Encoder/Decoder in DevHelper")
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            NotificationCenter.default.post(
                name: .openTool,
                object: nil,
                userInfo: ["tool": ToolType.jwt]
            )
        }
        
        return .result(dialog: "Opening JWT Encoder/Decoder in DevHelper")
    }
}

// MARK: - HTTP Request Intent
struct OpenHTTPRequestIntent: AppIntent {
    static var title: LocalizedStringResource = "HTTP Request"
    static var description = IntentDescription("Open HTTP Request in DevHelper")
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            NotificationCenter.default.post(
                name: .openTool,
                object: nil,
                userInfo: ["tool": ToolType.httpRequest]
            )
        }
        
        return .result(dialog: "Opening HTTP Request in DevHelper")
    }
}

// MARK: - QR Code Intent
struct OpenQRCodeIntent: AppIntent {
    static var title: LocalizedStringResource = "QR Code"
    static var description = IntentDescription("Open QR Code generator in DevHelper")
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            NotificationCenter.default.post(
                name: .openTool,
                object: nil,
                userInfo: ["tool": ToolType.qrCode]
            )
        }
        
        return .result(dialog: "Opening QR Code generator in DevHelper")
    }
}

// MARK: - Crypto Tools Intent
struct OpenCryptoToolsIntent: AppIntent {
    static var title: LocalizedStringResource = "Crypto Tools"
    static var description = IntentDescription("Open Crypto Tools in DevHelper")
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            NotificationCenter.default.post(
                name: .openTool,
                object: nil,
                userInfo: ["tool": ToolType.cryptoTools]
            )
        }
        
        return .result(dialog: "Opening Crypto Tools in DevHelper")
    }
}

// MARK: - AI Chat Intent
struct OpenAIChatIntent: AppIntent {
    static var title: LocalizedStringResource = "AI Chat"
    static var description = IntentDescription("Open AI Chat in DevHelper")
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            NotificationCenter.default.post(
                name: .openTool,
                object: nil,
                userInfo: ["tool": ToolType.aiChat]
            )
        }
        
        return .result(dialog: "Opening AI Chat in DevHelper")
    }
}