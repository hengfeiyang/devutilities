import Foundation

// MARK: - Batch Processor Protocol
@MainActor
protocol EventBatchProcessorProtocol {
    func startProcessing()
    func stopProcessing()
    func processImmediately() async
    var isProcessing: Bool { get }
}

// MARK: - Event Batch Processor
@MainActor
class EventBatchProcessor: EventBatchProcessorProtocol, ObservableObject {
    private let storage: EventStorageProtocol
    private let networkService: EventNetworkServiceProtocol
    private let chunkSize = 10  // Process up to 10 events per processing cycle
    private let processingInterval: TimeInterval = 30.0 // Process every 30 seconds
    private let maxRetryDelay: TimeInterval = 300.0 // Max 5 minutes
    
    private var processingTask: Task<Void, Never>?
    private var isActive = false
    
    @Published private(set) var isProcessing = false
    @Published private(set) var lastProcessTime: Date?
    @Published private(set) var pendingEventCount = 0
    
    init(storage: EventStorageProtocol, networkService: EventNetworkServiceProtocol) {
        self.storage = storage
        self.networkService = networkService
    }
    
    deinit {
        // Can't call @MainActor isolated method from deinit
        // Just cancel the task and set isActive to false
        isActive = false
        processingTask?.cancel()
        processingTask = nil
    }
    
    // MARK: - Public Methods
    
    func startProcessing() {
        guard processingTask == nil else { return }
        
        isActive = true
        processingTask = Task { [weak self] in
            await self?.processingLoop()
        }
    }
    
    func stopProcessing() {
        isActive = false
        processingTask?.cancel()
        processingTask = nil
        isProcessing = false
    }
    
    func processImmediately() async {
        await processBatch()
    }
    
    // MARK: - Private Methods
    
    private func processingLoop() async {
        while isActive {
            do {
                await processBatch()
                await updatePendingEventCount()
                
                // Wait for next processing interval
                try await Task.sleep(nanoseconds: UInt64(processingInterval * 1_000_000_000))
                
            } catch is CancellationError {
                break
            } catch {
                // Log error but continue processing
                print("EventBatchProcessor error: \(error)")
                
                // Wait before retrying
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            }
        }
    }
    
    private func processBatch() async {
        await MainActor.run {
            isProcessing = true
        }
        
        defer {
            Task { @MainActor in
                isProcessing = false
                lastProcessTime = Date()
            }
        }
        
        do {
            // Check if network is available
            guard networkService.isNetworkAvailable else {
                return
            }
            
            // Load pending events
            let pendingEvents = try await storage.loadPendingEvents()
            guard !pendingEvents.isEmpty else {
                return
            }
            
            // Process in chunks of events per cycle
            let chunks = pendingEvents.splitIntoChunks(of: chunkSize)
            
            for chunk in chunks {
                // Check if we should continue
                guard isActive else { break }
                
                do {
                    // Try to send chunk of events
                    print("📤 [EVENT PROCESSOR] Sending \(chunk.count) events via individual GET requests")
                    for (index, event) in chunk.enumerated() {
                        if let url = event.buildURL(baseURL: "https://api.devpalette.feiliwu.com") {
                            print("   \(index + 1). \(event.module)/\(event.submodule) → \(url.absoluteString)")
                        } else {
                            print("   \(index + 1). \(event.module)/\(event.submodule) → [Invalid URL]")
                        }
                    }
                    
                    try await networkService.sendEvents(chunk)
                    
                    // Success - remove from storage
                    try await storage.removeEvents(chunk)
                    print("✅ [EVENT PROCESSOR] Successfully sent \(chunk.count) events via individual GET API calls")
                    
                } catch {
                    // Handle chunk failure
                    print("❌ [EVENT PROCESSOR] Failed to send chunk: \(error.localizedDescription)")
                    await handleChunkFailure(chunk, error: error)
                }
            }
            
            // Clean up old events (older than 7 days)
            let cutoffDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            try await storage.clearOldEvents(olderThan: cutoffDate)
            
        } catch {
            print("Batch processing error: \(error)")
        }
    }
    
    private func handleChunkFailure(_ chunk: [AppEvent], error: Error) async {
        for event in chunk {
            do {
                // Increment retry count
                if let storage = storage as? EventStorage {
                    try await storage.incrementRetryCount(for: event)
                }
                
                // Calculate exponential backoff delay
                let delay = calculateRetryDelay(for: event.retryCount)
                
                // If delay is too long, we'll let the regular processing cycle handle it
                if delay < maxRetryDelay {
                    print("Event retry scheduled in \(delay) seconds for: \(event.module)/\(event.submodule)")
                } else {
                    print("Event exceeded max retry delay, will be cleaned up: \(event.module)/\(event.submodule)")
                }
                
            } catch {
                print("Failed to handle batch failure for event: \(error)")
            }
        }
    }
    
    private func calculateRetryDelay(for retryCount: Int) -> TimeInterval {
        // Exponential backoff: 1s, 2s, 4s, 8s, 16s, etc.
        let baseDelay = 1.0
        let exponentialDelay = baseDelay * pow(2.0, Double(retryCount))
        return min(exponentialDelay, maxRetryDelay)
    }
    
    private func updatePendingEventCount() async {
        do {
            let count = try await storage.getEventCount()
            await MainActor.run {
                pendingEventCount = count
            }
        } catch {
            print("Failed to update pending event count: \(error)")
        }
    }
}

// MARK: - Array Extension for Chunking
extension Array {
    func splitIntoChunks(of size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

// MARK: - Mock Batch Processor for Testing
@MainActor
class MockEventBatchProcessor: EventBatchProcessorProtocol, ObservableObject {
    @Published var isProcessing = false
    @Published var processCallCount = 0
    
    private var isActive = false
    
    func startProcessing() {
        isActive = true
    }
    
    func stopProcessing() {
        isActive = false
        isProcessing = false
    }
    
    func processImmediately() async {
        isProcessing = true
        processCallCount += 1
        
        // Simulate processing delay
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        isProcessing = false
    }
    
    func reset() {
        processCallCount = 0
        isProcessing = false
        isActive = false
    }
}