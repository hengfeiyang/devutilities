import Foundation

// MARK: - Event Storage Protocol
protocol EventStorageProtocol: Sendable {
    func saveEvent(_ event: AppEvent) async throws
    func loadPendingEvents() async throws -> [AppEvent]
    func removeEvent(_ event: AppEvent) async throws
    func removeEvents(_ events: [AppEvent]) async throws
    func clearOldEvents(olderThan date: Date) async throws
    func getEventCount() async throws -> Int
}

// MARK: - UserDefaults-based Event Storage
final class EventStorage: EventStorageProtocol, @unchecked Sendable {
    private let userDefaults = UserDefaults.standard
    private let storageKey = "DevPalette_PendingEvents"
    private let maxEvents = 1000 // Prevent unlimited growth
    private let maxRetries = 3
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    init() {
        // Configure date encoding strategy
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - Public Methods
    
    func saveEvent(_ event: AppEvent) async throws {
        var events = try await loadPendingEvents()
        
        // Add new event
        events.append(event)
        
        // Enforce max events limit (FIFO - remove oldest first)
        if events.count > maxEvents {
            events = Array(events.suffix(maxEvents))
        }
        
        try await saveEvents(events)
    }
    
    func loadPendingEvents() async throws -> [AppEvent] {
        guard let data = userDefaults.data(forKey: storageKey) else {
            return []
        }
        
        do {
            let events = try decoder.decode([AppEvent].self, from: data)
            // Filter out events that have exceeded max retries
            return events.filter { $0.retryCount < maxRetries }
        } catch {
            // If we can't decode, clear corrupted data and start fresh
            userDefaults.removeObject(forKey: storageKey)
            return []
        }
    }
    
    func removeEvent(_ event: AppEvent) async throws {
        var events = try await loadPendingEvents()
        events.removeAll { existingEvent in
            // Match by timestamp, module, and submodule (unique combination)
            existingEvent.timestamp == event.timestamp &&
            existingEvent.module == event.module &&
            existingEvent.submodule == event.submodule
        }
        try await saveEvents(events)
    }
    
    func removeEvents(_ eventsToRemove: [AppEvent]) async throws {
        var events = try await loadPendingEvents()
        
        for eventToRemove in eventsToRemove {
            events.removeAll { existingEvent in
                existingEvent.timestamp == eventToRemove.timestamp &&
                existingEvent.module == eventToRemove.module &&
                existingEvent.submodule == eventToRemove.submodule
            }
        }
        
        try await saveEvents(events)
    }
    
    func clearOldEvents(olderThan date: Date) async throws {
        let events = try await loadPendingEvents()
        let filteredEvents = events.filter { $0.timestamp >= date }
        try await saveEvents(filteredEvents)
    }
    
    func getEventCount() async throws -> Int {
        let events = try await loadPendingEvents()
        return events.count
    }
    
    func incrementRetryCount(for event: AppEvent) async throws {
        var events = try await loadPendingEvents()
        
        for i in 0..<events.count {
            if events[i].timestamp == event.timestamp &&
               events[i].module == event.module &&
               events[i].submodule == event.submodule {
                events[i].retryCount += 1
                break
            }
        }
        
        try await saveEvents(events)
    }
    
    // MARK: - Private Methods
    
    private func saveEvents(_ events: [AppEvent]) async throws {
        do {
            let data = try encoder.encode(events)
            userDefaults.set(data, forKey: storageKey)
        } catch {
            throw EventStorageError.encodingFailed(error)
        }
    }
}

// MARK: - Storage Errors
enum EventStorageError: LocalizedError {
    case encodingFailed(Error)
    case decodingFailed(Error)
    case storageFull
    
    var errorDescription: String? {
        switch self {
        case .encodingFailed(let error):
            return "Failed to encode events: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Failed to decode events: \(error.localizedDescription)"
        case .storageFull:
            return "Event storage is full"
        }
    }
}

// MARK: - Mock Storage for Testing
final class MockEventStorage: EventStorageProtocol, @unchecked Sendable {
    var events: [AppEvent] = []
    var shouldThrowError = false
    
    func saveEvent(_ event: AppEvent) async throws {
        if shouldThrowError { throw EventStorageError.storageFull }
        events.append(event)
    }
    
    func loadPendingEvents() async throws -> [AppEvent] {
        if shouldThrowError { throw EventStorageError.decodingFailed(NSError()) }
        return events
    }
    
    func removeEvent(_ event: AppEvent) async throws {
        if shouldThrowError { throw EventStorageError.encodingFailed(NSError()) }
        events.removeAll { $0.storageKey == event.storageKey }
    }
    
    func removeEvents(_ eventsToRemove: [AppEvent]) async throws {
        if shouldThrowError { throw EventStorageError.encodingFailed(NSError()) }
        for event in eventsToRemove {
            events.removeAll { $0.storageKey == event.storageKey }
        }
    }
    
    func clearOldEvents(olderThan date: Date) async throws {
        if shouldThrowError { throw EventStorageError.encodingFailed(NSError()) }
        events.removeAll { $0.timestamp < date }
    }
    
    func getEventCount() async throws -> Int {
        if shouldThrowError { throw EventStorageError.decodingFailed(NSError()) }
        return events.count
    }
}