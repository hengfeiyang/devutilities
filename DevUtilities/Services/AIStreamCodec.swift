// Copyright 2026 Hengfei Yang.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

import Foundation

enum AIStreamEvent: Equatable {
    case text(String)
    case reasoning(String)
    case inputTokens(Int)
    case outputTokens(Int)
    case completed
    case failure(String)
}

enum AnthropicStreamCodec {
    static func decode(dataPayload: String) -> [AIStreamEvent] {
        guard let data = dataPayload.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let type = json["type"] as? String else { return [] }

        switch type {
        case "message_start":
            guard let message = json["message"] as? [String: Any],
                  let usage = message["usage"] as? [String: Any],
                  let inputTokens = usage["input_tokens"] as? Int else { return [] }
            return [.inputTokens(inputTokens)]
        case "content_block_delta":
            guard let delta = json["delta"] as? [String: Any],
                  let deltaType = delta["type"] as? String else { return [] }
            if deltaType == "text_delta", let text = delta["text"] as? String {
                return [.text(text)]
            }
            if deltaType == "thinking_delta", let thinking = delta["thinking"] as? String {
                return [.reasoning(thinking)]
            }
            return []
        case "message_delta":
            guard let usage = json["usage"] as? [String: Any],
                  let outputTokens = usage["output_tokens"] as? Int else { return [] }
            return [.outputTokens(outputTokens)]
        case "message_stop":
            return [.completed]
        case "error":
            let message = (json["error"] as? [String: Any])?["message"] as? String ?? "Unknown error"
            return [.failure(message)]
        default:
            return []
        }
    }
}
