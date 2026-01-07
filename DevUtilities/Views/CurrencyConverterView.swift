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

import SwiftUI

struct CurrencyConverterView: View {
    let screenName = "Currency Converter"
    let module = "currency_converter"

    // State
    @State private var fromCurrency: Currency = .usd
    @State private var toCurrency: Currency = .krw
    @State private var inputAmount: String = "100"
    @State private var outputAmount: String = ""
    @State private var exchangeRate: Double = 0.0
    @State private var isLoading: Bool = false
    @State private var errorMessage: String = ""
    @State private var lastUpdated: String = ""
    @State private var cacheAge: String = ""
    @State private var isOfflineMode: Bool = false
    @State private var priceHistory: [DailyExchangeRate] = []
    @State private var change24h: Double = 0.0
    @State private var changePercent24h: Double = 0.0
    @State private var lastCurrencyPair: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack(alignment: .top, spacing: 40) {
                    // From Currency Section (Left)
                    VStack(alignment: .leading, spacing: 10) {
                        Picker("From Currency", selection: $fromCurrency) {
                            ForEach(Currency.allCases) { currency in
                                Text(currency.displayName).tag(currency)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .onChange(of: fromCurrency) { _, _ in
                            performConversion()
                        }

                        TextField("Amount", text: $inputAmount)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: inputAmount) { _, _ in
                                performConversion()
                            }

                        // Sample amount buttons
                        HStack(spacing: 8) {
                            ForEach([1.0, 100.0, 1000.0, 10000.0], id: \.self) { amount in
                                Button(amount >= 1000 ? "\(Int(amount / 1000))K" : "\(Int(amount))") {
                                    inputAmount = "\(Int(amount))"
                                }
                                .buttonStyle(.bordered)
                                .font(.caption)
                            }
                        }
                    }

                    // Swap Button
                    VStack {
                        Spacer()
                        Button(action: swapCurrencies) {
                            Image(systemName: "arrow.left.arrow.right")
                                .font(.title2)
                        }
                        .buttonStyle(.bordered)
                        .help("Swap currencies")
                        Spacer()
                    }

                    // To Currency Section (Right)
                    VStack(alignment: .leading, spacing: 10) {
                        Picker("To Currency", selection: $toCurrency) {
                            ForEach(Currency.allCases) { currency in
                                Text(currency.displayName).tag(currency)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .onChange(of: toCurrency) { _, _ in
                            performConversion()
                        }

                        TextField("Result", text: $outputAmount)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disabled(true)

                        // Copy button
                        Button(action: {
                            copyToClipboard(outputAmount)
                        }) {
                            HStack {
                                Image(systemName: "doc.on.doc")
                                Text("Copy Result")
                            }
                        }
                        .buttonStyle(.bordered)
                        .disabled(outputAmount.isEmpty)
                    }
                }
                .padding(.horizontal)

                // Exchange Rate Display
                if exchangeRate > 0 {
                    VStack(spacing: 8) {
                        Text("1 \(fromCurrency.rawValue) = \(formatExchangeRate(exchangeRate)) \(toCurrency.rawValue)")
                            .font(.headline)
                            .foregroundColor(.primary)

                        HStack(spacing: 16) {
                            // 24-hour trend
                            if changePercent24h != 0 {
                                HStack(spacing: 4) {
                                    Image(systemName: changePercent24h > 0 ? "arrow.up" : "arrow.down")
                                        .font(.caption)
                                    Text("\(formatChange(change24h)) (\(formatPercentage(changePercent24h))%) vs yesterday")
                                        .font(.caption)
                                }
                                .foregroundColor(changePercent24h > 0 ? .green : .red)
                            }

                            Spacer()

                            if isOfflineMode {
                                Label("Offline Mode", systemImage: "wifi.slash")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }

                            if !lastUpdated.isEmpty {
                                Text("Updated: \(lastUpdated)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            if !cacheAge.isEmpty {
                                Text("(\(cacheAge))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Button(action: refreshRates) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.caption)
                            }
                            .buttonStyle(.borderless)
                            .disabled(isLoading)
                            .help("Refresh exchange rates")
                        }
                    }
                    .padding()
                    .background(AppConstants.controlBackground)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }

                // Loading indicator
                if isLoading {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Fetching exchange rates...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                // Error message
                if !errorMessage.isEmpty {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    .padding(8)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(6)
                    .padding(.horizontal)
                }

                // 30-Day Price History
                if !priceHistory.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("30-Day Price History (\(priceHistory.count) entries)")
                            .font(.headline)

                        VStack(spacing: 8) {
                            ForEach(priceHistory) { entry in
                                HStack {
                                    Text(entry.shortFormattedDate)
                                        .font(.caption)
                                        .frame(width: 80, alignment: .leading)

                                    Text("→")
                                        .font(.caption)
                                        .foregroundColor(.secondary)

                                    Text(formatExchangeRate(entry.rate))
                                        .font(.caption)
                                        .frame(alignment: .leading)

                                    Text(toCurrency.rawValue)
                                        .font(.caption)
                                        .foregroundColor(.secondary)

                                    Spacer()

                                    // Daily change indicator
                                    if let index = priceHistory.firstIndex(where: { $0.id == entry.id }),
                                       index < priceHistory.count - 1 {
                                        let previousRate = priceHistory[index + 1].rate
                                        let dailyChange = entry.rate - previousRate
                                        let dailyPercentage = (dailyChange / previousRate) * 100

                                        HStack(spacing: 2) {
                                            Image(systemName: dailyPercentage > 0 ? "arrow.up" : (dailyPercentage < 0 ? "arrow.down" : "minus"))
                                                .font(.caption2)
                                            Text(formatPercentage(dailyPercentage) + "%")
                                                .font(.caption2)
                                        }
                                        .foregroundColor(dailyPercentage > 0 ? .green : (dailyPercentage < 0 ? .red : .secondary))
                                    }
                                }
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(4)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }

                Spacer()
            }
            .padding(.top)
        }
        .navigationTitle("\(screenName)")
        .onAppear {
            loadState()
            performConversion()
        }
        .onDisappear {
            saveState()
        }
    }

    // MARK: - Private Methods

    private func performConversion() {
        // Clear error
        errorMessage = ""

        // Check if currency pair changed
        let currentPair = "\(fromCurrency.rawValue)-\(toCurrency.rawValue)"
        let pairChanged = currentPair != lastCurrencyPair

        // Remove commas from input to support formats like "1,000,000"
        let cleanedInput = inputAmount.replacingOccurrences(of: ",", with: "")

        // Validate input
        guard let amount = Double(cleanedInput), amount > 0 else {
            outputAmount = ""
            exchangeRate = 0.0
            return
        }

        // Only show loading indicator if we're fetching new data (pair changed)
        if pairChanged {
            isLoading = true
            lastCurrencyPair = currentPair
        }

        Task {
            do {
                // Get exchange rate
                let rate = try await CurrencyService.shared.getExchangeRate(from: fromCurrency, to: toCurrency)
                let result = amount * rate

                if pairChanged {
                    // Only load metadata when currency pair changes
                    let cachedData = try await CurrencyService.shared.fetchExchangeRates(for: fromCurrency)

                    // Save daily snapshot
                    await CurrencyService.shared.saveDailySnapshot(from: fromCurrency, to: toCurrency, rate: rate)

                    // Load price history
                    let history = await CurrencyService.shared.getPriceHistory(from: fromCurrency, to: toCurrency)

                    // Calculate 24-hour change
                    let change = await CurrencyService.shared.calculate24HourChange(from: fromCurrency, to: toCurrency)

                    await MainActor.run {
                        exchangeRate = rate
                        outputAmount = formatNumber(result)
                        lastUpdated = cachedData.lastUpdated
                        cacheAge = cachedData.cacheAge
                        isOfflineMode = cachedData.isExpired
                        priceHistory = history
                        change24h = change?.change ?? 0
                        changePercent24h = change?.percentage ?? 0
                        isLoading = false
                    }
                } else {
                    // Only update amount and rate (no history reload)
                    await MainActor.run {
                        exchangeRate = rate
                        outputAmount = formatNumber(result)
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }

    private func swapCurrencies() {
        let temp = fromCurrency
        fromCurrency = toCurrency
        toCurrency = temp
        performConversion()
    }

    private func refreshRates() {
        Task {
            isLoading = true
            do {
                // Force refresh from API
                _ = try await CurrencyService.shared.fetchExchangeRates(for: fromCurrency, forceRefresh: true)

                // Reset the pair tracker to force full reload
                lastCurrencyPair = ""
                performConversion()
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }

    private func formatNumber(_ value: Double, maxDecimals: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = maxDecimals

        // Use more decimals for very small numbers
        if value < 1 {
            formatter.maximumFractionDigits = 6
        } else if value < 10 {
            formatter.maximumFractionDigits = 4
        }

        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }

    private func formatExchangeRate(_ rate: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 4

        // Use fewer decimals for large numbers
        if rate > 1000 {
            formatter.maximumFractionDigits = 2
        }

        return formatter.string(from: NSNumber(value: rate)) ?? "0"
    }

    private func formatChange(_ change: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.positivePrefix = "+"

        return formatter.string(from: NSNumber(value: change)) ?? "0"
    }

    private func formatPercentage(_ percentage: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.positivePrefix = "+"

        return formatter.string(from: NSNumber(value: percentage)) ?? "0"
    }

    private func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }

    private func saveState() {
        let defaults = UserDefaults.standard
        defaults.set(fromCurrency.rawValue, forKey: "CurrencyConverter.fromCurrency")
        defaults.set(toCurrency.rawValue, forKey: "CurrencyConverter.toCurrency")
        defaults.set(inputAmount, forKey: "CurrencyConverter.inputAmount")
    }

    private func loadState() {
        let defaults = UserDefaults.standard

        if let fromCode = defaults.string(forKey: "CurrencyConverter.fromCurrency"),
           let currency = Currency(rawValue: fromCode) {
            fromCurrency = currency
        }

        if let toCode = defaults.string(forKey: "CurrencyConverter.toCurrency"),
           let currency = Currency(rawValue: toCode) {
            toCurrency = currency
        }

        inputAmount = defaults.string(forKey: "CurrencyConverter.inputAmount") ?? "100"
    }
}
