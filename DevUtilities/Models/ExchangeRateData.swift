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

// MARK: - API Response Model
struct ExchangeRateAPIResponse: Codable {
    let base: String
    let date: String
    let rates: [String: Double]
    let time_last_updated: Int?

    enum CodingKeys: String, CodingKey {
        case base, date, rates
        case time_last_updated = "time_last_update_unix"
    }
}

// MARK: - Cached Exchange Rate Data
struct CachedExchangeRateData: Codable {
    let baseCurrency: String
    let rates: [String: Double]
    let timestamp: Date
    let lastUpdated: String // Human-readable date from API
    let isUsingDefaultRates: Bool // Indicates if using embedded fallback rates

    init(baseCurrency: String, rates: [String: Double], timestamp: Date, lastUpdated: String, isUsingDefaultRates: Bool = false) {
        self.baseCurrency = baseCurrency
        self.rates = rates
        self.timestamp = timestamp
        self.lastUpdated = lastUpdated
        self.isUsingDefaultRates = isUsingDefaultRates
    }

    var isExpired: Bool {
        let hoursSinceCache = Date().timeIntervalSince(timestamp) / 3600
        return hoursSinceCache >= 24 // 24-hour expiration
    }

    var cacheAge: String {
        let hours = Int(Date().timeIntervalSince(timestamp) / 3600)
        if hours < 1 {
            let minutes = Int(Date().timeIntervalSince(timestamp) / 60)
            if minutes < 1 {
                return "just now"
            }
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        } else if hours < 24 {
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        } else {
            let days = hours / 24
            return "\(days) day\(days == 1 ? "" : "s") ago"
        }
    }
}

// MARK: - Daily History Entry (30-day snapshots)
struct DailyExchangeRate: Codable, Identifiable {
    let id: UUID
    let date: Date
    let baseCurrency: String
    let targetCurrency: String
    let rate: Double

    init(id: UUID = UUID(), date: Date, baseCurrency: String, targetCurrency: String, rate: Double) {
        self.id = id
        self.date = date
        self.baseCurrency = baseCurrency
        self.targetCurrency = targetCurrency
        self.rate = rate
    }

    var formattedDate: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from: date)
        }
    }

    var shortFormattedDate: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
}

// MARK: - Currency Service Error
enum CurrencyServiceError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case noData
    case invalidResponse
    case rateLimitExceeded
    case apiKeyRequired
    case unsupportedCurrency

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .noData:
            return "No data received from server"
        case .invalidResponse:
            return "Invalid response from server"
        case .rateLimitExceeded:
            return "API rate limit exceeded. Please try again later."
        case .apiKeyRequired:
            return "API key required. Please check configuration."
        case .unsupportedCurrency:
            return "Currency not supported by API"
        }
    }
}
