import Foundation
import SwiftUI

// MARK: - Event Manager
@MainActor
class EventManager: ObservableObject {
    static let shared = EventManager()
    
    // Dependencies
    private let storage: EventStorageProtocol
    private let networkService: EventNetworkServiceProtocol
    private let batchProcessor: EventBatchProcessorProtocol
    
    // Identity management
    private let userId: UUID
    private let sessionId: UUID
    
    // App info
    private let appVersion: String
    
    // Configuration
    @Published var isEnabled = true
    @Published var isDebugMode = false
    
    // Status
    @Published private(set) var lastEventTime: Date?
    @Published private(set) var totalEventsTracked = 0
    
    private init() {
        // Get app version
        self.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        
        // User ID: Persistent UUID stored in UserDefaults
        if let savedUserIdString = UserDefaults.standard.string(forKey: "DevHelper_UserID"),
           let savedUserId = UUID(uuidString: savedUserIdString) {
            self.userId = savedUserId
        } else {
            self.userId = UUID()
            UserDefaults.standard.set(self.userId.uuidString, forKey: "DevHelper_UserID")
        }
        
        // Session ID: New UUID each app launch
        self.sessionId = UUID()
        
        // Initialize dependencies
        self.storage = EventStorage()
        self.networkService = EventNetworkService()
        self.batchProcessor = EventBatchProcessor(storage: storage, networkService: networkService)
        
        // Load settings
        if UserDefaults.standard.object(forKey: "DevHelper_EventsEnabled") == nil {
            // First time - default to enabled
            self.isEnabled = true
            UserDefaults.standard.set(true, forKey: "DevHelper_EventsEnabled")
        } else {
            self.isEnabled = UserDefaults.standard.bool(forKey: "DevHelper_EventsEnabled")
        }
        
        // Load debug mode
        self.isDebugMode = UserDefaults.standard.bool(forKey: "DevHelper_EventsDebugMode")
        
        // Print initialization status
        print("🚀 [EVENT MANAGER] Initialized")
        print("   Tracking Enabled: \(isEnabled)")
        print("   App Version: \(appVersion)")
        print("   User ID: \(userId.uuidString)")
        print("   Session ID: \(sessionId.uuidString)")
        print("   Debug Mode: \(isDebugMode)")
        
        // Start batch processor
        if isEnabled {
            startEventProcessing()
            print("   Background Processing: Started")
        } else {
            print("   Background Processing: Disabled")
        }
    }
    
    // MARK: - Public API
    
    func reportAppStart() {
        guard isEnabled else { 
            print("🚫 Event tracking disabled - App Start event skipped")
            return 
        }
        
        let event = AppEvent.appStart(
            version: appVersion,
            userId: userId,
            sessionId: sessionId
        )
        
        print("📱 [EVENT] App Start")
        print("   Module: \(event.module)")
        print("   Submodule: \(event.submodule)")
        print("   Version: \(event.version)")
        print("   User ID: \(userId.uuidString.prefix(8))...")
        print("   Session ID: \(sessionId.uuidString.prefix(8))...")
        print("   Timestamp: \(event.timestamp)")
        
        enqueueEvent(event)
    }
    
    func reportModuleSwitch(from: String?, to: String) {
        guard isEnabled else { 
            print("🚫 Event tracking disabled - Module switch event skipped")
            return 
        }
        
        let event = AppEvent.moduleSwitch(
            from: from,
            to: to,
            version: appVersion,
            userId: userId,
            sessionId: sessionId
        )
        
        print("🔀 [EVENT] Module Switch")
        print("   From: \(from ?? "nil")")
        print("   To: \(to)")
        print("   Module: \(event.module)")
        print("   Submodule: \(event.submodule)")
        print("   User ID: \(userId.uuidString.prefix(8))...")
        print("   Session ID: \(sessionId.uuidString.prefix(8))...")
        print("   Timestamp: \(event.timestamp)")
        
        enqueueEvent(event)
    }
    
    func reportSubmoduleSwitch(module: String, from: String?, to: String) {
        guard isEnabled else { 
            print("🚫 Event tracking disabled - Submodule switch event skipped")
            return 
        }
        
        let event = AppEvent.submoduleSwitch(
            module: module,
            from: from,
            to: to,
            version: appVersion,
            userId: userId,
            sessionId: sessionId
        )
        
        print("🔄 [EVENT] Submodule Switch")
        print("   Module: \(module)")
        print("   From: \(from ?? "nil")")
        print("   To: \(to)")
        print("   Event Module: \(event.module)")
        print("   Event Submodule: \(event.submodule)")
        print("   User ID: \(userId.uuidString.prefix(8))...")
        print("   Session ID: \(sessionId.uuidString.prefix(8))...")
        print("   Timestamp: \(event.timestamp)")
        
        enqueueEvent(event)
    }
    
    // MARK: - Settings Management
    
    func setEnabled(_ enabled: Bool) {
        guard enabled != isEnabled else { return }
        
        isEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "DevHelper_EventsEnabled")
        
        if enabled {
            startEventProcessing()
        } else {
            stopEventProcessing()
        }
        
        if isDebugMode {
            print("📊 Event tracking \(enabled ? "enabled" : "disabled")")
        }
    }
    
    func setDebugMode(_ debug: Bool) {
        isDebugMode = debug
        UserDefaults.standard.set(debug, forKey: "DevHelper_EventsDebugMode")
        
        print("🐛 Event debug mode \(debug ? "enabled" : "disabled")")
    }
    
    // MARK: - Status and Diagnostics
    
    func getStatus() async -> EventManagerStatus {
        do {
            let pendingCount = try await storage.getEventCount()
            let networkStatus = (networkService as? EventNetworkService)?.getHealthStatus()
            
            return EventManagerStatus(
                isEnabled: isEnabled,
                userId: userId.uuidString,
                sessionId: sessionId.uuidString,
                appVersion: appVersion,
                pendingEvents: pendingCount,
                totalEventsTracked: totalEventsTracked,
                lastEventTime: lastEventTime,
                networkHealth: networkStatus
            )
        } catch {
            return EventManagerStatus(
                isEnabled: isEnabled,
                userId: userId.uuidString,
                sessionId: sessionId.uuidString,
                appVersion: appVersion,
                pendingEvents: -1,
                totalEventsTracked: totalEventsTracked,
                lastEventTime: lastEventTime,
                networkHealth: nil
            )
        }
    }
    
    func forceSyncNow() async {
        guard isEnabled else { return }
        
        if isDebugMode {
            print("🔄 Force syncing events...")
        }
        
        await batchProcessor.processImmediately()
    }
    
    func clearAllEvents() async {
        do {
            let events = try await storage.loadPendingEvents()
            try await storage.removeEvents(events)
            
            if isDebugMode {
                print("🗑️ Cleared \(events.count) pending events")
            }
        } catch {
            if isDebugMode {
                print("❌ Failed to clear events: \(error)")
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func enqueueEvent(_ event: AppEvent) {
        Task.detached { [weak self] in
            await self?.saveEventAsync(event)
        }
    }
    
    private func saveEventAsync(_ event: AppEvent) async {
        do {
            try await storage.saveEvent(event)
            print("💾 [STORAGE] Event saved locally: \(event.module)/\(event.submodule)")
            
            await MainActor.run {
                self.lastEventTime = event.timestamp
                self.totalEventsTracked += 1
            }
            
        } catch {
            print("❌ [STORAGE] Failed to save event: \(error.localizedDescription)")
        }
    }
    
    private func startEventProcessing() {
        batchProcessor.startProcessing()
        
        if isDebugMode {
            print("▶️ Event processing started")
        }
    }
    
    private func stopEventProcessing() {
        batchProcessor.stopProcessing()
        
        if isDebugMode {
            print("⏸️ Event processing stopped")
        }
    }
}

// MARK: - Event Manager Status
struct EventManagerStatus {
    let isEnabled: Bool
    let userId: String
    let sessionId: String
    let appVersion: String
    let pendingEvents: Int
    let totalEventsTracked: Int
    let lastEventTime: Date?
    let networkHealth: NetworkHealthStatus?
    
    var description: String {
        var lines = [
            "Event Tracking: \(isEnabled ? "Enabled" : "Disabled")",
            "App Version: \(appVersion)",
            "User ID: \(String(userId.prefix(8)))...",
            "Session ID: \(String(sessionId.prefix(8)))...",
            "Total Events: \(totalEventsTracked)",
            "Pending Events: \(pendingEvents >= 0 ? "\(pendingEvents)" : "Unknown")"
        ]
        
        if let lastTime = lastEventTime {
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .medium
            lines.append("Last Event: \(formatter.string(from: lastTime))")
        }
        
        if let health = networkHealth {
            lines.append("Network Health: \(Int(health.healthPercentage * 100))%")
        }
        
        return lines.joined(separator: "\n")
    }
}

// MARK: - Convenience Extensions
extension EventManager {
    /// Report module navigation based on ToolType enum
    func reportModuleNavigation(to toolType: ToolType) {
        let moduleName = toolType.eventModuleName
        reportModuleSwitch(from: nil, to: moduleName)
    }
}

// MARK: - ToolType Extension for Event Names
extension ToolType {
    var eventModuleName: String {
        switch self {
        case .timestampConverter: return "timestamp_converter"
        case .unitConverter: return "unit_converter"
        case .jsonFormatter: return "json_formatter"
        case .base64: return "base64_codec"
        case .regexTest: return "regex_test"
        case .uuidGenerator: return "uuid_generator"
        case .urlTools: return "url_tools"
        case .ipQuery: return "ip_query"
        case .httpRequest: return "http_request"
        case .qrCode: return "qr_code"
        case .sqlFormatter: return "sql_formatter"
        case .htmlFormatter: return "html_formatter"
        case .jwt: return "jwt_codec"
        case .parquetViewer: return "parquet_viewer"
        case .cryptoTools: return "crypto_tools"
        case .aiChat: return "ai_chat"
        }
    }
}