// Copyright 2026 Hengfei Yang.
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

actor CurrencyService {
    static let shared = CurrencyService()

    // MARK: - Constants
    private let cacheKey = "CurrencyConverter.cachedRates"
    private let historyKey = "CurrencyConverter.priceHistory"
    private let baseURL = "https://api.exchangerate-api.com/v4/latest"
    private let timeout: TimeInterval = 10.0

    // MARK: - Private Properties
    private var memoryCache: CachedExchangeRateData?
    private var historyCache: [DailyExchangeRate]?

    private init() {
        // Note: Caches are loaded lazily on first access
    }

    // MARK: - Public API

    /// Fetch exchange rates for a base currency (with 24-hour caching)
    func fetchExchangeRates(for baseCurrency: Currency, forceRefresh: Bool = false) async throws -> CachedExchangeRateData {
        // Check memory cache first
        if !forceRefresh,
           let cached = memoryCache,
           cached.baseCurrency == baseCurrency.rawValue,
           !cached.isExpired {
            print("📦 [CURRENCY] Using memory cache for \(baseCurrency.rawValue)")
            return cached
        }

        // Check disk cache
        if !forceRefresh,
           let cached = loadCacheFromDisk(),
           cached.baseCurrency == baseCurrency.rawValue,
           !cached.isExpired {
            print("💾 [CURRENCY] Using disk cache for \(baseCurrency.rawValue)")
            memoryCache = cached
            return cached
        }

        // Cache expired or missing - fetch from API
        print("🌐 [CURRENCY] Fetching fresh rates for \(baseCurrency.rawValue)")
        do {
            return try await fetchFromAPI(baseCurrency: baseCurrency)
        } catch {
            // API failed - check if we have expired cache to use as fallback
            if let cached = loadCacheFromDisk(),
               cached.baseCurrency == baseCurrency.rawValue {
                print("⚠️ [CURRENCY] API failed, using expired cache for \(baseCurrency.rawValue)")
                memoryCache = cached
                return cached
            }

            // No cache at all - use embedded default rates as last resort
            print("🔄 [CURRENCY] API failed with no cache, using embedded default rates for \(baseCurrency.rawValue)")
            let fallbackData = DefaultExchangeRates.createFallbackData(for: baseCurrency)

            // Save fallback data to cache so it can be used next time
            memoryCache = fallbackData
            saveCacheToDisk(fallbackData)

            return fallbackData
        }
    }

    /// Convert amount from one currency to another
    func convert(amount: Double, from: Currency, to: Currency) async throws -> Double {
        let rates = try await fetchExchangeRates(for: from)

        guard let rate = rates.rates[to.rawValue] else {
            throw CurrencyServiceError.unsupportedCurrency
        }

        return amount * rate
    }

    /// Get exchange rate between two currencies
    func getExchangeRate(from: Currency, to: Currency) async throws -> Double {
        let rates = try await fetchExchangeRates(for: from)

        guard let rate = rates.rates[to.rawValue] else {
            throw CurrencyServiceError.unsupportedCurrency
        }

        return rate
    }

    /// Save daily snapshot to price history (if not already saved today)
    func saveDailySnapshot(from: Currency, to: Currency, rate: Double) async {
        var history = await getPriceHistory(from: from, to: to)

        // Check if today's snapshot already exists
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let lastEntry = history.first,
           calendar.isDate(lastEntry.date, inSameDayAs: today) {
            print("📅 [CURRENCY] Today's snapshot already exists, skipping")
            return
        }

        // Create new snapshot
        let snapshot = DailyExchangeRate(
            date: today,
            baseCurrency: from.rawValue,
            targetCurrency: to.rawValue,
            rate: rate
        )

        // Add to beginning (most recent first)
        history.insert(snapshot, at: 0)

        // Maintain max 30 entries (remove oldest)
        if history.count > 30 {
            history = Array(history.prefix(30))
        }

        // Update cache
        historyCache = history
        saveHistoryToDisk(history)

        print("💾 [CURRENCY] Saved daily snapshot: \(from.rawValue)→\(to.rawValue) = \(rate)")
    }

    /// Get price history for a currency pair (last 30 days)
    func getPriceHistory(from: Currency, to: Currency) async -> [DailyExchangeRate] {
        if historyCache == nil {
            historyCache = loadHistoryFromDisk()
        }

        guard let history = historyCache else {
            return []
        }

        // Filter for specific currency pair
        return history.filter {
            $0.baseCurrency == from.rawValue && $0.targetCurrency == to.rawValue
        }
    }

    /// Calculate 24-hour change (today vs yesterday)
    func calculate24HourChange(from: Currency, to: Currency) async -> (change: Double, percentage: Double)? {
        let history = await getPriceHistory(from: from, to: to)

        guard history.count >= 2 else {
            return nil
        }

        let todayRate = history[0].rate
        let yesterdayRate = history[1].rate

        let change = todayRate - yesterdayRate
        let percentage = (change / yesterdayRate) * 100

        return (change: change, percentage: percentage)
    }

    /// Clear all cached data
    func clearCache() {
        memoryCache = nil
        historyCache = nil
        UserDefaults.standard.removeObject(forKey: cacheKey)
        UserDefaults.standard.removeObject(forKey: historyKey)
        print("🗑️ [CURRENCY] Cache cleared")
    }

    // MARK: - Private Methods

    private func fetchFromAPI(baseCurrency: Currency) async throws -> CachedExchangeRateData {
        guard let url = URL(string: "\(baseURL)/\(baseCurrency.rawValue)") else {
            throw CurrencyServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = timeout
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            // Check HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                throw CurrencyServiceError.invalidResponse
            }

            switch httpResponse.statusCode {
            case 200:
                break
            case 429:
                throw CurrencyServiceError.rateLimitExceeded
            case 401, 403:
                throw CurrencyServiceError.apiKeyRequired
            default:
                throw CurrencyServiceError.invalidResponse
            }

            // Decode response
            let decoder = JSONDecoder()
            let apiResponse: ExchangeRateAPIResponse

            do {
                apiResponse = try decoder.decode(ExchangeRateAPIResponse.self, from: data)
            } catch {
                throw CurrencyServiceError.decodingError(error)
            }

            // Create cached data
            let cachedData = CachedExchangeRateData(
                baseCurrency: apiResponse.base,
                rates: apiResponse.rates,
                timestamp: Date(),
                lastUpdated: apiResponse.date,
                isUsingDefaultRates: false
            )

            // Save to cache
            memoryCache = cachedData
            saveCacheToDisk(cachedData)

            print("✅ [CURRENCY] Successfully fetched and cached rates for \(baseCurrency.rawValue)")
            return cachedData
        } catch let error as CurrencyServiceError {
            throw error
        } catch {
            throw CurrencyServiceError.networkError(error)
        }
    }

    private func loadCacheFromDisk() -> CachedExchangeRateData? {
        guard let data = UserDefaults.standard.data(forKey: cacheKey) else {
            return nil
        }

        do {
            let cached = try JSONDecoder().decode(CachedExchangeRateData.self, from: data)
            return cached
        } catch {
            print("⚠️ [CURRENCY] Failed to decode cached data: \(error)")
            return nil
        }
    }

    private func saveCacheToDisk(_ data: CachedExchangeRateData) {
        do {
            let encoded = try JSONEncoder().encode(data)
            UserDefaults.standard.set(encoded, forKey: cacheKey)
            print("💾 [CURRENCY] Saved cache to disk")
        } catch {
            print("⚠️ [CURRENCY] Failed to save cache: \(error)")
        }
    }

    private func loadHistoryFromDisk() -> [DailyExchangeRate]? {
        guard let data = UserDefaults.standard.data(forKey: historyKey) else {
            return nil
        }

        do {
            let history = try JSONDecoder().decode([DailyExchangeRate].self, from: data)
            return history
        } catch {
            print("⚠️ [CURRENCY] Failed to decode history: \(error)")
            return nil
        }
    }

    private func saveHistoryToDisk(_ history: [DailyExchangeRate]) {
        do {
            let encoded = try JSONEncoder().encode(history)
            UserDefaults.standard.set(encoded, forKey: historyKey)
            print("💾 [CURRENCY] Saved history to disk (\(history.count) entries)")
        } catch {
            print("⚠️ [CURRENCY] Failed to save history: \(error)")
        }
    }
}
