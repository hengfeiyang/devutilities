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
struct DevHelperJSONIntent: AppIntent {
    static var title: LocalizedStringResource = "DevHelper JSON"
    static var description = IntentDescription("Open JSON formatter in DevHelper")
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

struct DevHelperBase64Intent: AppIntent {
    static var title: LocalizedStringResource = "DevHelper Base64"
    static var description = IntentDescription("Open Base64 encoder in DevHelper")
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

struct DevHelperUUIDIntent: AppIntent {
    static var title: LocalizedStringResource = "DevHelper UUID"
    static var description = IntentDescription("Open UUID generator in DevHelper")
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

struct DevHelperTimestampIntent: AppIntent {
    static var title: LocalizedStringResource = "DevHelper Timestamp"
    static var description = IntentDescription("Open timestamp converter in DevHelper")
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

struct DevHelperRegexIntent: AppIntent {
    static var title: LocalizedStringResource = "DevHelper Regex"
    static var description = IntentDescription("Open regex test in DevHelper")
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

struct DevHelperJWTIntent: AppIntent {
    static var title: LocalizedStringResource = "DevHelper JWT"
    static var description = IntentDescription("Open JWT encoder/decoder in DevHelper")
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

struct DevHelperHTTPIntent: AppIntent {
    static var title: LocalizedStringResource = "DevHelper HTTP"
    static var description = IntentDescription("Open HTTP request tool in DevHelper")
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

struct DevHelperCryptoIntent: AppIntent {
    static var title: LocalizedStringResource = "DevHelper Crypto"
    static var description = IntentDescription("Open crypto tools in DevHelper")
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

struct DevHelperURLIntent: AppIntent {
    static var title: LocalizedStringResource = "DevHelper URL"
    static var description = IntentDescription("Open URL tools in DevHelper")
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

struct DevHelperQRIntent: AppIntent {
    static var title: LocalizedStringResource = "DevHelper QR"
    static var description = IntentDescription("Open QR code generator in DevHelper")
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