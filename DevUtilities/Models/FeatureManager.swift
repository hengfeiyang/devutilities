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
import SwiftUI

struct FeaturePreference: Codable, Identifiable {
    let id: ToolType
    var isEnabled: Bool
    var sortOrder: Int

    init(toolType: ToolType, isEnabled: Bool = true, sortOrder: Int = 0) {
        self.id = toolType
        self.isEnabled = isEnabled
        self.sortOrder = sortOrder
    }
}

class FeatureManager: ObservableObject {
    @Published var preferences: [ToolType: FeaturePreference] = [:]

    private let userDefaults = UserDefaults.standard
    private let preferencesKey = "feature_preferences"

    init() {
        loadPreferences()
    }

    var enabledTools: [ToolType] {
        let enabled = preferences.values.filter { $0.isEnabled }
        return enabled.sorted { $0.sortOrder < $1.sortOrder }.map { $0.id }
    }

    var disabledTools: [ToolType] {
        let disabled = preferences.values.filter { !$0.isEnabled }
        return disabled.sorted { $0.sortOrder < $1.sortOrder }.map { $0.id }
    }

    var filteredTools: [ToolType] {
        return enabledTools
    }

    func isToolEnabled(_ tool: ToolType) -> Bool {
        return preferences[tool]?.isEnabled ?? true
    }

    func toggleTool(_ tool: ToolType) {
        guard var preference = preferences[tool] else { return }

        preference.isEnabled.toggle()

        if preference.isEnabled {
            let maxEnabledOrder = enabledTools.compactMap { preferences[$0]?.sortOrder }.max() ?? -1
            preference.sortOrder = maxEnabledOrder + 1
        } else {
            let maxDisabledOrder = disabledTools.compactMap { preferences[$0]?.sortOrder }.max() ?? -1
            preference.sortOrder = maxDisabledOrder + 1
        }

        preferences[tool] = preference
        savePreferences()
    }

    func moveEnabledTool(from source: IndexSet, to destination: Int) {
        var tools = enabledTools
        tools.move(fromOffsets: source, toOffset: destination)

        for (index, tool) in tools.enumerated() {
            preferences[tool]?.sortOrder = index
        }

        savePreferences()
        objectWillChange.send()
    }

    func moveDisabledTool(from source: IndexSet, to destination: Int) {
        var tools = disabledTools
        tools.move(fromOffsets: source, toOffset: destination)

        for (index, tool) in tools.enumerated() {
            preferences[tool]?.sortOrder = index
        }

        savePreferences()
        objectWillChange.send()
    }

    func moveToolBetweenSections(tool: ToolType, to section: Bool) {
        guard var preference = preferences[tool] else { return }

        preference.isEnabled = section

        if section {
            let maxEnabledOrder = enabledTools.compactMap { preferences[$0]?.sortOrder }.max() ?? -1
            preference.sortOrder = maxEnabledOrder + 1
        } else {
            let maxDisabledOrder = disabledTools.compactMap { preferences[$0]?.sortOrder }.max() ?? -1
            preference.sortOrder = maxDisabledOrder + 1
        }

        preferences[tool] = preference
        savePreferences()
    }

    func resetToDefault() {
        initializeDefaultPreferences()
        savePreferences()
    }

    private func loadPreferences() {
        if let data = userDefaults.data(forKey: preferencesKey),
           let decoded = try? JSONDecoder().decode([FeaturePreference].self, from: data) {
            preferences = Dictionary(uniqueKeysWithValues: decoded.map { ($0.id, $0) })

            let existingTools = Set(preferences.keys)
            let allTools = Set(ToolType.allCases)
            let newTools = allTools.subtracting(existingTools)

            if !newTools.isEmpty {
                let maxOrder = preferences.values.filter { $0.isEnabled }.map { $0.sortOrder }.max() ?? -1
                for (index, tool) in newTools.enumerated() {
                    preferences[tool] = FeaturePreference(toolType: tool, sortOrder: maxOrder + 1 + index)
                }
                savePreferences()
            }
        } else {
            initializeDefaultPreferences()
            savePreferences()
        }
    }

    private func initializeDefaultPreferences() {
        preferences = [:]
        for (index, tool) in ToolType.allCases.enumerated() {
            preferences[tool] = FeaturePreference(toolType: tool, sortOrder: index)
        }
    }

    private func savePreferences() {
        let preferencesArray = Array(preferences.values)
        if let encoded = try? JSONEncoder().encode(preferencesArray) {
            userDefaults.set(encoded, forKey: preferencesKey)
        }
    }
}