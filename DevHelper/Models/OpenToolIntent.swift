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

import AppIntents
import Foundation

struct OpenToolIntent: AppIntent {
    static var title: LocalizedStringResource = "Open DevHelper Tool"
    static var description = IntentDescription("Open a specific tool in DevHelper")
    static var openAppWhenRun: Bool = true

    @Parameter(title: "Tool", description: "The tool to open")
    var tool: ToolEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Open \(\.$tool)")
    }

    func perform() async throws -> some IntentResult {
        // Post notification to open specific tool
        await MainActor.run {
            NotificationCenter.default.post(
                name: .openTool,
                object: nil,
                userInfo: ["tool": tool.toolType]
            )
        }
        
        return .result(
            dialog: "Opening \(tool.displayRepresentation.title) in DevHelper"
        )
    }
}

extension Notification.Name {
    static let openTool = Notification.Name("openTool")
}

struct ToolEntity: AppEntity {
    let id: String
    let toolType: ToolType
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(toolType.title)",
            subtitle: "DevHelper Tool",
            image: .init(systemName: toolType.iconName)
        )
    }
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = TypeDisplayRepresentation(name: "DevHelper Tool")
    
    static var defaultQuery = ToolEntityQuery()
    
    init(toolType: ToolType) {
        self.id = toolType.rawValue
        self.toolType = toolType
    }
}

struct ToolEntityQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [ToolEntity] {
        return identifiers.compactMap { identifier in
            guard let toolType = ToolType(rawValue: identifier) else { return nil }
            return ToolEntity(toolType: toolType)
        }
    }
    
    func suggestedEntities() async throws -> [ToolEntity] {
        return ToolType.allCases.map { ToolEntity(toolType: $0) }
    }
    
    func entities(matching query: String) async throws -> [ToolEntity] {
        let filteredTools = ToolType.allCases.filter { tool in
            tool.title.localizedCaseInsensitiveContains(query) ||
            tool.rawValue.localizedCaseInsensitiveContains(query)
        }
        return filteredTools.map { ToolEntity(toolType: $0) }
    }
}