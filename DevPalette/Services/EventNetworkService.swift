import Foundation

// MARK: - Network Service Protocol
protocol EventNetworkServiceProtocol: Sendable {
    func sendEvent(_ event: AppEvent) async throws
    func sendEvents(_ events: [AppEvent]) async throws
    var isNetworkAvailable: Bool { get }
}

// MARK: - Event Network Service
final class EventNetworkService: EventNetworkServiceProtocol, @unchecked Sendable {
    private let baseURL = "https://api.devhelper.feiliwu.com"
    private let session: URLSession
    private let timeout: TimeInterval = 5.0 // 5 second timeout
    private var consecutiveFailures = 0
    private let maxConsecutiveFailures = 5
    
    // Circuit breaker state
    private var isCircuitBreakerOpen: Bool {
        return consecutiveFailures >= maxConsecutiveFailures
    }
    
    var isNetworkAvailable: Bool {
        return !isCircuitBreakerOpen
    }
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        config.timeoutIntervalForResource = timeout * 2
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        // Don't wait for connectivity - fail fast if network unavailable
        config.waitsForConnectivity = false
        
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Public Methods
    
    func sendEvent(_ event: AppEvent) async throws {
        // Check circuit breaker
        guard !isCircuitBreakerOpen else {
            throw EventNetworkError.circuitBreakerOpen
        }
        
        guard let url = event.buildURL(baseURL: baseURL) else {
            throw EventNetworkError.invalidURL
        }
        
        do {
            let (_, response) = try await session.data(from: url)
            
            // Check HTTP status
            guard let httpResponse = response as? HTTPURLResponse else {
                throw EventNetworkError.invalidResponse
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                throw EventNetworkError.httpError(httpResponse.statusCode)
            }
            
            // Success - reset failure counter
            consecutiveFailures = 0
            
            // Optional: Parse response if needed
            // let responseData = try JSONSerialization.jsonObject(with: data)
            
        } catch {
            consecutiveFailures += 1
            
            if error is URLError {
                throw EventNetworkError.networkError(error)
            } else if error is EventNetworkError {
                throw error
            } else {
                throw EventNetworkError.unknown(error)
            }
        }
    }
    
    func sendEvents(_ events: [AppEvent]) async throws {
        // Send events individually using GET requests
        var failedEvents: [AppEvent] = []
        
        for event in events {
            do {
                try await sendEvent(event)
                // Small delay between requests to avoid overwhelming server
                try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            } catch {
                failedEvents.append(event)
                // Continue trying other events even if one fails
            }
        }
        
        // If any events failed, throw error with details
        if !failedEvents.isEmpty {
            throw EventNetworkError.batchPartialFailure(
                succeeded: events.count - failedEvents.count,
                failed: failedEvents.count
            )
        }
    }
    
    // MARK: - Circuit Breaker Management
    
    func resetCircuitBreaker() {
        consecutiveFailures = 0
    }
    
    func getHealthStatus() -> NetworkHealthStatus {
        return NetworkHealthStatus(
            isAvailable: isNetworkAvailable,
            consecutiveFailures: consecutiveFailures,
            maxFailures: maxConsecutiveFailures
        )
    }
}

// MARK: - Network Errors
enum EventNetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case networkError(Error)
    case circuitBreakerOpen
    case batchPartialFailure(succeeded: Int, failed: Int)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid event URL"
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .circuitBreakerOpen:
            return "Network service temporarily unavailable"
        case .batchPartialFailure(let succeeded, let failed):
            return "Batch send partial failure: \(succeeded) succeeded, \(failed) failed"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Health Status
struct NetworkHealthStatus {
    let isAvailable: Bool
    let consecutiveFailures: Int
    let maxFailures: Int
    
    var healthPercentage: Double {
        let failureRate = Double(consecutiveFailures) / Double(maxFailures)
        return max(0.0, 1.0 - failureRate)
    }
}

// MARK: - Mock Network Service for Testing
final class MockEventNetworkService: EventNetworkServiceProtocol, @unchecked Sendable {
    var shouldSucceed = true
    var networkDelay: TimeInterval = 0.1
    var sentEvents: [AppEvent] = []
    
    var isNetworkAvailable: Bool = true
    
    func sendEvent(_ event: AppEvent) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(networkDelay * 1_000_000_000))
        
        if shouldSucceed {
            sentEvents.append(event)
        } else {
            throw EventNetworkError.networkError(URLError(.notConnectedToInternet))
        }
    }
    
    func sendEvents(_ events: [AppEvent]) async throws {
        for event in events {
            try await sendEvent(event)
        }
    }
    
    func reset() {
        sentEvents.removeAll()
        shouldSucceed = true
        isNetworkAvailable = true
    }
}