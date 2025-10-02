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

// Simple intent that can be discovered by Spotlight
struct DevPaletteJSONIntent: AppIntent {
    static var title: LocalizedStringResource = "DevPalette JSON"
    static var description = IntentDescription("Open JSON formatter in DevPalette")
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult {
        await MainActor.run {
            NotificationCenter.default.post(
                name: .openTool,
                object: nil,
                userInfo: ["tool": ToolType.jsonFormatter]
            )
        }
        return .result(dialog: "Opening JSON Formatter")
    }
}

struct DevPaletteBase64Intent: AppIntent {
    static var title: LocalizedStringResource = "DevPalette Base64"
    static var description = IntentDescription("Open Base64 encoder in DevPalette")
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult {
        await MainActor.run {
            NotificationCenter.default.post(
                name: .openTool,
                object: nil,
                userInfo: ["tool": ToolType.base64]
            )
        }
        return .result(dialog: "Opening Base64 Encoder")
    }
}

struct DevPaletteUUIDIntent: AppIntent {
    static var title: LocalizedStringResource = "DevPalette UUID"
    static var description = IntentDescription("Open UUID generator in DevPalette")
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult {
        await MainActor.run {
            NotificationCenter.default.post(
                name: .openTool,
                object: nil,
                userInfo: ["tool": ToolType.uuidGenerator]
            )
        }
        return .result(dialog: "Opening UUID Generator")
    }
}

struct DevPaletteTimestampIntent: AppIntent {
    static var title: LocalizedStringResource = "DevPalette Timestamp"
    static var description = IntentDescription("Open timestamp converter in DevPalette")
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult {
        await MainActor.run {
            NotificationCenter.default.post(
                name: .openTool,
                object: nil,
                userInfo: ["tool": ToolType.timestampConverter]
            )
        }
        return .result(dialog: "Opening Timestamp Converter")
    }
}

struct DevPaletteRegexIntent: AppIntent {
    static var title: LocalizedStringResource = "DevPalette Regex"
    static var description = IntentDescription("Open regex test in DevPalette")
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult {
        await MainActor.run {
            NotificationCenter.default.post(
                name: .openTool,
                object: nil,
                userInfo: ["tool": ToolType.regexTest]
            )
        }
        return .result(dialog: "Opening Regex Test")
    }
}

struct DevPaletteJWTIntent: AppIntent {
    static var title: LocalizedStringResource = "DevPalette JWT"
    static var description = IntentDescription("Open JWT encoder/decoder in DevPalette")
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult {
        await MainActor.run {
            NotificationCenter.default.post(
                name: .openTool,
                object: nil,
                userInfo: ["tool": ToolType.jwt]
            )
        }
        return .result(dialog: "Opening JWT Tool")
    }
}

struct DevPaletteHTTPIntent: AppIntent {
    static var title: LocalizedStringResource = "DevPalette HTTP"
    static var description = IntentDescription("Open HTTP request tool in DevPalette")
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult {
        await MainActor.run {
            NotificationCenter.default.post(
                name: .openTool,
                object: nil,
                userInfo: ["tool": ToolType.httpRequest]
            )
        }
        return .result(dialog: "Opening HTTP Request")
    }
}

struct DevPaletteCryptoIntent: AppIntent {
    static var title: LocalizedStringResource = "DevPalette Crypto"
    static var description = IntentDescription("Open crypto tools in DevPalette")
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult {
        await MainActor.run {
            NotificationCenter.default.post(
                name: .openTool,
                object: nil,
                userInfo: ["tool": ToolType.cryptoTools]
            )
        }
        return .result(dialog: "Opening Crypto Tools")
    }
}

struct DevPaletteURLIntent: AppIntent {
    static var title: LocalizedStringResource = "DevPalette URL"
    static var description = IntentDescription("Open URL tools in DevPalette")
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult {
        await MainActor.run {
            NotificationCenter.default.post(
                name: .openTool,
                object: nil,
                userInfo: ["tool": ToolType.urlTools]
            )
        }
        return .result(dialog: "Opening URL Tools")
    }
}

struct DevPaletteQRIntent: AppIntent {
    static var title: LocalizedStringResource = "DevPalette QR"
    static var description = IntentDescription("Open QR code generator in DevPalette")
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult {
        await MainActor.run {
            NotificationCenter.default.post(
                name: .openTool,
                object: nil,
                userInfo: ["tool": ToolType.qrCode]
            )
        }
        return .result(dialog: "Opening QR Code Generator")
    }
}