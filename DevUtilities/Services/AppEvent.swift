import Foundation

// MARK: - Event Types
enum EventType {
    case appStart(version: String)
    case moduleSwitch(from: String?, to: String)
    case submoduleSwitch(module: String, from: String?, to: String)
    case aiChatMessage(messageLength: Int)
    case fileOpen(fileType: String)
    case monetization(action: String, tool: String?)
}

// MARK: - App Event Data Structure
struct AppEvent: Codable {
    let timestamp: Date
    let version: String
    let module: String
    let submodule: String
    let userId: UUID
    let sessionId: UUID
    var retryCount: Int = 0
    
    // Convert to API query parameters
    var queryParameters: [String: String] {
        return [
            "version": version,
            "module": module,
            "submodule": submodule,
            "user_id": userId.uuidString.lowercased(),
            "session_id": sessionId.uuidString.lowercased()
        ]
    }
    
    // Create URL with query parameters
    func buildURL(baseURL: String) -> URL? {
        guard var urlComponents = URLComponents(string: "\(baseURL)/event") else {
            return nil
        }
        
        urlComponents.queryItems = queryParameters.map { key, value in
            URLQueryItem(name: key, value: value)
        }
        
        return urlComponents.url
    }
    
    // Convenience initializers for different event types
    static func appStart(version: String, userId: UUID, sessionId: UUID) -> AppEvent {
        return AppEvent(
            timestamp: Date(),
            version: version,
            module: "app",
            submodule: "start",
            userId: userId,
            sessionId: sessionId
        )
    }
    
    static func moduleSwitch(from: String?, to: String, version: String, userId: UUID, sessionId: UUID) -> AppEvent {
        return AppEvent(
            timestamp: Date(),
            version: version,
            module: to,
            submodule: "enter",
            userId: userId,
            sessionId: sessionId
        )
    }
    
    static func submoduleSwitch(module: String, from: String?, to: String, version: String, userId: UUID, sessionId: UUID) -> AppEvent {
        return AppEvent(
            timestamp: Date(),
            version: version,
            module: module,
            submodule: to,
            userId: userId,
            sessionId: sessionId
        )
    }
    
    static func aiChatMessage(messageLength: Int, version: String, userId: UUID, sessionId: UUID) -> AppEvent {
        return AppEvent(
            timestamp: Date(),
            version: version,
            module: "ai_chat",
            submodule: "message_sent",
            userId: userId,
            sessionId: sessionId
        )
    }
    
    static func fileOpen(fileType: String, version: String, userId: UUID, sessionId: UUID) -> AppEvent {
        return AppEvent(
            timestamp: Date(),
            version: version,
            module: "parquet_viewer",
            submodule: "file_opened",
            userId: userId,
            sessionId: sessionId
        )
    }

    static func monetization(action: String, tool: String?, version: String, userId: UUID, sessionId: UUID) -> AppEvent {
        let sanitizedTool = tool?.replacingOccurrences(of: " ", with: "_").lowercased()
        let submodule = [action, sanitizedTool].compactMap { $0 }.joined(separator: ":")
        return AppEvent(
            timestamp: Date(),
            version: version,
            module: "monetization",
            submodule: submodule,
            userId: userId,
            sessionId: sessionId
        )
    }
}

// MARK: - Event Storage Key
extension AppEvent {
    var storageKey: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return "\(formatter.string(from: timestamp))_\(module)_\(submodule)"
    }
}
