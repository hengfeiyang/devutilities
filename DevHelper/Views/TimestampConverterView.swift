// Copyright 2025 Hengfei Yang.
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
import AppKit

struct TimestampHistoryEntry: Codable, Identifiable, Equatable {
    let id: UUID
    let timestamp: String
    let convertedDate: String
    let convertedTimestamp: String
    let queryTime: Date
    let isLocalTime: Bool

    init(timestamp: String, convertedDate: String, convertedTimestamp: String, isLocalTime: Bool) {
        self.id = UUID()
        self.timestamp = timestamp
        self.convertedDate = convertedDate
        self.convertedTimestamp = convertedTimestamp
        self.queryTime = Date()
        self.isLocalTime = isLocalTime
    }
}

class TimestampHistoryManager: ObservableObject {
    @Published var entries: [TimestampHistoryEntry] = []
    private let maxEntries = 50
    private let userDefaultsKey = "TimestampConverter.History"

    init() {
        loadHistory()
    }

    func addEntry(_ entry: TimestampHistoryEntry) {
        if !entries.contains(where: { $0.timestamp == entry.timestamp && $0.isLocalTime == entry.isLocalTime }) {
            entries.insert(entry, at: 0)

            if entries.count > maxEntries {
                entries = Array(entries.prefix(maxEntries))
            }

            saveHistory()
        }
    }

    func removeEntry(_ entry: TimestampHistoryEntry) {
        entries.removeAll { $0.id == entry.id }
        saveHistory()
    }

    func clearHistory() {
        entries.removeAll()
        saveHistory()
    }

    func timeDifference(between entry1: TimestampHistoryEntry, and entry2: TimestampHistoryEntry) -> String {
        guard let timestamp1 = Int64(entry1.timestamp),
              let timestamp2 = Int64(entry2.timestamp) else {
            return "Invalid timestamps"
        }

        let diff = abs(timestamp1 - timestamp2)
        let days = diff / 86400
        let hours = (diff % 86400) / 3600
        let minutes = (diff % 3600) / 60
        let seconds = diff % 60

        var components: [String] = []
        if days > 0 { components.append("\(days)d") }
        if hours > 0 { components.append("\(hours)h") }
        if minutes > 0 { components.append("\(minutes)m") }
        if seconds > 0 || components.isEmpty { components.append("\(seconds)s") }

        return components.joined(separator: " ")
    }

    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([TimestampHistoryEntry].self, from: data) {
            entries = decoded
        }
    }
}

struct TimestampConverterView: View {
    let screenName = "Timestamp Converter"
    @State private var timestampInput: String = ""
    @State private var dateInput: String = ""
    @State private var convertedDate: String = ""
    @State private var convertedTimestamp: String = ""
    @State private var isLocalTime: Bool = true
    @State private var copiedButtonId: String? = nil
    @StateObject private var historyManager = TimestampHistoryManager()
    @State private var selectedEntries: Set<UUID> = []
    @State private var showHistory: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                // Timestamp to Date
                VStack(alignment: .leading, spacing: 10) {
                    Text("Timestamp to Date")
                        .font(.headline)
                    
                    TextField("Enter timestamp", text: $timestampInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: timestampInput) { _, newValue in
                            convertTimestampToDate(newValue)
                        }
                    
                    Button("Current Timestamp") {
                        timestampInput = String(Int(Date().timeIntervalSince1970))
                    }
                    .buttonStyle(.bordered)
                    
                    ScrollView {
                        if convertedDate.isEmpty {
                            Text("Converted date will appear here")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(AppConstants.lightGrayBackground)
                                .cornerRadius(8)
                        } else {
                            VStack(alignment: .leading, spacing: 4) {
                                dateRow("UTC Time", getUTCFromResult())
                                dateRow("Local Time", getLocalFromResult())
                            }
                            .padding()
                            .background(AppConstants.lightGrayBackground)
                            .cornerRadius(8)
                        }
                    }
                    .frame(height: 120)
                }
                
                // Date to Timestamp
                VStack(alignment: .leading, spacing: 10) {
                    Text("Date to Timestamp")
                        .font(.headline)
                    
                    TextField("Enter date (YYYY-MM-DD HH:MM:SS)", text: $dateInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: dateInput) { _, newValue in
                            convertDateToTimestamp(newValue)
                        }
                    
                    Button("Current Date") {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        dateInput = formatter.string(from: Date())
                    }
                    .buttonStyle(.bordered)
                    
                    ScrollView {
                        if convertedTimestamp.isEmpty {
                            Text("Converted timestamp will appear here")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(AppConstants.lightGrayBackground)
                                .cornerRadius(8)
                        } else {
                            VStack(alignment: .leading, spacing: 4) {
                                timestampRow("Seconds", getSecondsFromResult())
                                timestampRow("Milliseconds", getMillisecondsFromResult())
                                timestampRow("Microseconds", getMicrosecondsFromResult())
                                timestampRow("Nanoseconds", getNanosecondsFromResult())
                            }
                            .padding()
                            .background(AppConstants.lightGrayBackground)
                            .cornerRadius(8)
                        }
                    }
                    .frame(height: 120)
                }
            }
            .padding(.horizontal, 0)
            
            Toggle("Use Local Time", isOn: $isLocalTime)
                .onChange(of: isLocalTime) { _, _ in
                    if !timestampInput.isEmpty {
                        convertTimestampToDate(timestampInput)
                    }
                    if !dateInput.isEmpty {
                        convertDateToTimestamp(dateInput)
                    }
                }

            // Query History Section
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Query History")
                        .font(.headline)
                    Spacer()
                    Button(showHistory ? "Hide History" : "Show History") {
                        withAnimation {
                            showHistory.toggle()
                        }
                    }
                    .buttonStyle(.bordered)

                    if !historyManager.entries.isEmpty {
                        Button("Clear History") {
                            historyManager.clearHistory()
                            selectedEntries.removeAll()
                        }
                        .buttonStyle(.bordered)
                    }
                }

                if showHistory {
                    if historyManager.entries.isEmpty {
                        Text("No query history yet")
                            .foregroundColor(.secondary)
                            .italic()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(AppConstants.lightGrayBackground)
                            .cornerRadius(8)
                    } else {
                        VStack(spacing: 8) {
                            if selectedEntries.count == 2 {
                                let sortedEntries = selectedEntries.compactMap { id in
                                    historyManager.entries.first { $0.id == id }
                                }.sorted { $0.queryTime > $1.queryTime }

                                if sortedEntries.count == 2 {
                                    let diff = historyManager.timeDifference(between: sortedEntries[0], and: sortedEntries[1])
                                    HStack {
                                        Text("Time difference: \(diff)")
                                            .font(.system(.body, design: .monospaced))
                                            .foregroundColor(.blue)
                                        Spacer()
                                        Button("Clear Selection") {
                                            selectedEntries.removeAll()
                                        }
                                        .buttonStyle(.bordered)
                                    }
                                    .padding(8)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }

                            ScrollView {
                                LazyVStack(spacing: 6) {
                                    ForEach(historyManager.entries) { entry in
                                        historyEntryView(entry)
                                    }
                                }
                            }
                            .frame(maxHeight: 300)
                        }
                    }
                }
            }

            Spacer()
        }
        .padding()
        .navigationTitle("\(screenName)")
        .onAppear {
            loadState()
        }
        .onDisappear {
            saveState()
        }
    }
    
    private func convertTimestampToDate(_ timestamp: String) {
        guard !timestamp.isEmpty else {
            convertedDate = ""
            return
        }
        
        // Auto-detect timestamp format based on length
        var timeInterval: TimeInterval = 0
        
        if let timestampInt = Int64(timestamp) {
            switch timestamp.count {
            case 10: // seconds
                timeInterval = TimeInterval(timestampInt)
            case 13: // milliseconds
                timeInterval = TimeInterval(timestampInt) / 1000
            case 16: // microseconds
                timeInterval = TimeInterval(timestampInt) / 1_000_000
            case 19: // nanoseconds
                timeInterval = TimeInterval(timestampInt) / 1_000_000_000
            default:
                convertedDate = "Invalid timestamp format"
                return
            }
        } else {
            convertedDate = "Invalid timestamp"
            return
        }
        
        let date = Date(timeIntervalSince1970: timeInterval)
        
        // Format for local time
        let localFormatter = DateFormatter()
        localFormatter.timeZone = TimeZone.current
        localFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
        let localTime = localFormatter.string(from: date)
        
        // Format for UTC
        let utcFormatter = DateFormatter()
        utcFormatter.timeZone = TimeZone(abbreviation: "UTC")
        utcFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss 'UTC'"
        let utcTime = utcFormatter.string(from: date)
        
        convertedDate = """
        UTC Time: \(utcTime)

        Local Time: \(localTime)
        """

        // Add to history
        let historyEntry = TimestampHistoryEntry(
            timestamp: timestamp,
            convertedDate: convertedDate,
            convertedTimestamp: "",
            isLocalTime: isLocalTime
        )
        historyManager.addEntry(historyEntry)
    }
    
    private func convertDateToTimestamp(_ dateString: String) {
        guard !dateString.isEmpty else {
            convertedTimestamp = ""
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if isLocalTime {
            formatter.timeZone = TimeZone.current
        } else {
            formatter.timeZone = TimeZone(abbreviation: "UTC")
        }
        
        if let date = formatter.date(from: dateString) {
            let timestamp = Int64(date.timeIntervalSince1970)
            convertedTimestamp = generateTimestampResult(timestamp)

            // Add to history
            let historyEntry = TimestampHistoryEntry(
                timestamp: String(timestamp),
                convertedDate: "",
                convertedTimestamp: convertedTimestamp,
                isLocalTime: isLocalTime
            )
            historyManager.addEntry(historyEntry)
        } else {
            convertedTimestamp = "Invalid date format. Use: YYYY-MM-DD HH:MM:SS"
        }
    }
    
    @ViewBuilder
    private func timestampRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text("\(label):")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(value)
                .font(.system(.body, design: .monospaced))
                .frame(minWidth: 160, alignment: .leading)
                .textSelection(.enabled)
            Button(action: {
                copyToClipboard(value)
                withAnimation(.easeInOut(duration: 0.2)) {
                    copiedButtonId = "\(label)-\(value)"
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        copiedButtonId = nil
                    }
                }
            }) {
                Image(systemName: copiedButtonId == "\(label)-\(value)" ? "checkmark" : "doc.on.doc")
                    .foregroundColor(copiedButtonId == "\(label)-\(value)" ? .green : .blue)
                    .font(.caption)
            }
            .buttonStyle(.borderless)
            .help("Copy to clipboard")
        }
    }
    
    private func generateTimestampResult(_ timestamp: Int64) -> String {
        return """
        Seconds: \(timestamp)
        
        Milliseconds: \(timestamp * 1000)
        
        Microseconds: \(timestamp * 1_000_000)
        
        Nanoseconds: \(timestamp * 1_000_000_000)
        """
    }
    
    private func getSecondsFromResult() -> String {
        let lines = convertedTimestamp.components(separatedBy: "\n")
        for line in lines {
            if line.hasPrefix("Seconds:") {
                return String(line.dropFirst(9))
            }
        }
        return ""
    }
    
    private func getMillisecondsFromResult() -> String {
        let lines = convertedTimestamp.components(separatedBy: "\n")
        for line in lines {
            if line.hasPrefix("Milliseconds:") {
                return String(line.dropFirst(14))
            }
        }
        return ""
    }
    
    private func getMicrosecondsFromResult() -> String {
        let lines = convertedTimestamp.components(separatedBy: "\n")
        for line in lines {
            if line.hasPrefix("Microseconds:") {
                return String(line.dropFirst(14))
            }
        }
        return ""
    }
    
    private func getNanosecondsFromResult() -> String {
        let lines = convertedTimestamp.components(separatedBy: "\n")
        for line in lines {
            if line.hasPrefix("Nanoseconds:") {
                return String(line.dropFirst(13))
            }
        }
        return ""
    }
    
    @ViewBuilder
    private func dateRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text("\(label):")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(value)
                .frame(minWidth: 200, alignment: .leading)
                .textSelection(.enabled)
            Button(action: {
                copyToClipboard(value)
                withAnimation(.easeInOut(duration: 0.2)) {
                    copiedButtonId = "\(label)-\(value)"
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        copiedButtonId = nil
                    }
                }
            }) {
                Image(systemName: copiedButtonId == "\(label)-\(value)" ? "checkmark" : "doc.on.doc")
                    .foregroundColor(copiedButtonId == "\(label)-\(value)" ? .green : .blue)
                    .font(.caption)
            }
            .buttonStyle(.borderless)
            .help("Copy to clipboard")
        }
    }
    
    private func getUTCFromResult() -> String {
        let lines = convertedDate.components(separatedBy: "\n")
        for line in lines {
            if line.hasPrefix("UTC Time:") {
                return String(line.dropFirst(10))
            }
        }
        return ""
    }
    
    private func getLocalFromResult() -> String {
        let lines = convertedDate.components(separatedBy: "\n")
        for line in lines {
            if line.hasPrefix("Local Time:") {
                return String(line.dropFirst(12))
            }
        }
        return ""
    }
    
    private func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(text, forType: .string)
    }
    
    private func saveState() {
        let defaults = UserDefaults.standard
        defaults.set(timestampInput, forKey: "TimestampConverter.timestampInput")
        defaults.set(dateInput, forKey: "TimestampConverter.dateInput")
        defaults.set(convertedDate, forKey: "TimestampConverter.convertedDate")
        defaults.set(convertedTimestamp, forKey: "TimestampConverter.convertedTimestamp")
        defaults.set(isLocalTime, forKey: "TimestampConverter.isLocalTime")
    }
    
    private func loadState() {
        let defaults = UserDefaults.standard
        timestampInput = defaults.string(forKey: "TimestampConverter.timestampInput") ?? ""
        dateInput = defaults.string(forKey: "TimestampConverter.dateInput") ?? ""
        convertedDate = defaults.string(forKey: "TimestampConverter.convertedDate") ?? ""
        convertedTimestamp = defaults.string(forKey: "TimestampConverter.convertedTimestamp") ?? ""
        isLocalTime = defaults.bool(forKey: "TimestampConverter.isLocalTime")
        
        // If we have initial values, trigger conversions
        if !timestampInput.isEmpty {
            convertTimestampToDate(timestampInput)
        }
        if !dateInput.isEmpty {
            convertDateToTimestamp(dateInput)
        }
    }

    @ViewBuilder
    private func historyEntryView(_ entry: TimestampHistoryEntry) -> some View {
        HStack {
            Button(action: {
                if selectedEntries.contains(entry.id) {
                    selectedEntries.remove(entry.id)
                } else if selectedEntries.count < 2 {
                    selectedEntries.insert(entry.id)
                }
            }) {
                Image(systemName: selectedEntries.contains(entry.id) ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(selectedEntries.contains(entry.id) ? .blue : .gray)
            }
            .buttonStyle(.borderless)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("Timestamp: \(entry.timestamp)")
                        .font(.system(.caption, design: .monospaced))
                    Spacer()
                    Text(formatQueryTime(entry.queryTime))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                if !entry.convertedDate.isEmpty {
                    Text(extractMainInfo(from: entry.convertedDate))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                if !entry.convertedTimestamp.isEmpty {
                    Text("From date conversion")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            HStack(spacing: 8) {
                Button(action: {
                    timestampInput = entry.timestamp
                    convertTimestampToDate(entry.timestamp)
                }) {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.borderless)
                .help("Load this timestamp")

                Button(action: {
                    copyToClipboard(entry.timestamp)
                }) {
                    Image(systemName: "doc.on.doc")
                }
                .buttonStyle(.borderless)
                .help("Copy timestamp")

                Button(action: {
                    historyManager.removeEntry(entry)
                    selectedEntries.remove(entry.id)
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(.borderless)
                .help("Remove from history")
            }
        }
        .padding(8)
        .background(selectedEntries.contains(entry.id) ? Color.blue.opacity(0.1) : AppConstants.lightGrayBackground)
        .cornerRadius(6)
    }

    private func formatQueryTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func extractMainInfo(from result: String) -> String {
        let lines = result.components(separatedBy: "\n")
        for line in lines {
            if line.hasPrefix("Local Time:") {
                return String(line.dropFirst(12))
            }
        }
        return ""
    }
}

#Preview {
    TimestampConverterView()
}
