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

import Foundation
import SwiftUI

enum ToolType: String, CaseIterable, Identifiable, Codable {
    case aiChat = "ai-chat"
    case aiTranslate = "ai-translate"
    case timestampConverter = "timestamp"
    case unitConverter = "unit"
    case jsonFormatter = "json"
    case sqlFormatter = "sql"
    case htmlFormatter = "html"
    case base64 = "base64"
    case hexString = "hex-string"
    case jwt = "jwt"
    case regexTest = "regex"
    case uuidGenerator = "uuid"
    case cryptoTools = "crypto"
    case urlTools = "url"
    case httpRequest = "http"
    case ipQuery = "ip"
    case qrCode = "qrcode"
    case parquetViewer = "parquet"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .aiChat:
            return "AI Chat"
        case .aiTranslate:
            return "AI Translate"
        case .timestampConverter:
            return "Timestamp Converter"
        case .unitConverter:
            return "Unit Converter"
        case .jsonFormatter:
            return "JSON Formatter"
        case .sqlFormatter:
            return "SQL Formatter"
        case .htmlFormatter:
            return "HTML Formatter"
        case .base64:
            return "Base64 Encode/Decode"
        case .hexString:
            return "Hex String Converter"
        case .jwt:
            return "JWT Encoder/Decoder"
        case .regexTest:
            return "Regex Test"
        case .uuidGenerator:
            return "UUID Generator"
        case .cryptoTools:
            return "Crypto Tools"
        case .urlTools:
            return "URL Tools"
        case .httpRequest:
            return "HTTP Request"
        case .ipQuery:
            return "IP Query"
        case .qrCode:
            return "QR Code"
        case .parquetViewer:
            return "Parquet Viewer"
        }
    }
    
    var iconName: String {
        switch self {
        case .aiChat:
            return "sparkles"
        case .aiTranslate:
            return "translate"
        case .timestampConverter:
            return "clock"
        case .unitConverter:
            return "scalemass"
        case .jsonFormatter:
            return "doc.text"
        case .sqlFormatter:
            return "cylinder.split.1x2"
        case .htmlFormatter:
            return "chevron.left.forwardslash.chevron.right"
        case .base64:
            return "6.circle"
        case .hexString:
            return "textformat.123"
        case .jwt:
            return "key.horizontal"
        case .regexTest:
            return "magnifyingglass"
        case .uuidGenerator:
            return "dice"
        case .cryptoTools:
            return "lock.shield"
        case .urlTools:
            return "link"
        case .httpRequest:
            return "network"
        case .ipQuery:
            return "dot.radiowaves.left.and.right"
        case .qrCode:
            return "qrcode"
        case .parquetViewer:
            return "doc.text.magnifyingglass"
        }
    }
}

extension ToolType: Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .plainText)
    }
}