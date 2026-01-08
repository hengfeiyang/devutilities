// Copyright 2026 Hengfei Yang.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import Foundation

/// Static fallback exchange rates used when API is unavailable
/// These rates are embedded in the app to ensure basic functionality even without network
/// Note: These rates are snapshots from January 2025 and may not reflect current market rates
struct DefaultExchangeRates {
    /// Date when these default rates were captured
    static let snapshotDate = "2025-01-08"

    /// Default exchange rates with USD as base currency
    /// All rates are USD -> Target Currency
    static let usdRates: [String: Double] = [
        "USD": 1.0,
        "EUR": 0.9534,
        "GBP": 0.7954,
        "JPY": 157.85,
        "CNY": 7.2845,
        "KRW": 1465.23,
        "INR": 85.48,
        "AUD": 1.5984,
        "NZD": 1.7654,
        "HKD": 7.7845,
        "SGD": 1.3456,
        "THB": 34.52,
        "MYR": 4.4234,
        "IDR": 16145.67,
        "PHP": 57.89,
        "VND": 25340.45,
        "TWD": 32.45,
        "AED": 3.6725,
        "SAR": 3.7504,
        "ZAR": 18.34,
        "ILS": 3.6543,
        "TRY": 34.87,
        "EGP": 49.23,
        "CAD": 1.4345,
        "MXN": 20.34,
        "BRL": 6.1234,
        "ARS": 1025.45,
        "CLP": 987.23,
        "CHF": 0.9012,
        "SEK": 10.87,
        "NOK": 11.23,
        "DKK": 7.1234,
        "PLN": 4.0234,
        "CZK": 23.45,
        "RUB": 95.67
    ]

    /// Generate default rates for any base currency using cross-rate calculation
    /// Formula: rate(A→B) = rate(USD→B) / rate(USD→A)
    static func getDefaultRates(for baseCurrency: Currency) -> [String: Double] {
        let baseCurrencyCode = baseCurrency.rawValue

        guard let baseRate = usdRates[baseCurrencyCode] else {
            // If base currency not found, return USD rates as fallback
            return usdRates
        }

        var convertedRates: [String: Double] = [:]

        for (currencyCode, usdRate) in usdRates {
            // Cross-rate calculation: rate(base→target) = rate(USD→target) / rate(USD→base)
            convertedRates[currencyCode] = usdRate / baseRate
        }

        return convertedRates
    }

    /// Create a CachedExchangeRateData using default fallback rates
    static func createFallbackData(for baseCurrency: Currency) -> CachedExchangeRateData {
        let rates = getDefaultRates(for: baseCurrency)

        return CachedExchangeRateData(
            baseCurrency: baseCurrency.rawValue,
            rates: rates,
            timestamp: Date(),
            lastUpdated: snapshotDate,
            isUsingDefaultRates: true
        )
    }
}
