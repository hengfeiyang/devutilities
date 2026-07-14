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

struct FeatureSettingsView: View {
    @ObservedObject var featureManager: FeatureManager
    @Environment(\.dismiss) private var dismiss
    @State private var draggedTool: ToolType?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 5)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                enabledSection

                Divider()
                    .padding(.horizontal, 20)

                disabledSection

                Spacer(minLength: 20)
            }
            .padding(.top, 20)
        }
        .navigationTitle("Feature Management")
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button("Reset") {
                    featureManager.resetToDefault()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
                .fontWeight(.medium)
            }
        }
        .frame(minWidth: 600, minHeight: 500)
    }

    private var enabledSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack (spacing: 4) {
                Text("Enabled Features")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 20)

                Text("💡 Click to toggle • Drag to reorder")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 0)
            }

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(featureManager.enabledTools, id: \.self) { tool in
                    FeatureCard(
                        tool: tool,
                        isEnabled: true,
                        isDragging: draggedTool == tool
                    ) {
                        featureManager.toggleTool(tool)
                    }
                    .draggable(tool) {
                        FeatureCard(tool: tool, isEnabled: true, isDragging: true) {}
                            .opacity(0.3)
                    }
                    .dropDestination(for: ToolType.self) { tools, location in
                        handleDrop(tools: tools, to: tool, inEnabledSection: true)
                    }
                    .onDrag {
                        draggedTool = tool
                        return NSItemProvider(object: tool.rawValue as NSString)
                    }
                }
            }
            .padding(.horizontal, 20)
            .dropDestination(for: ToolType.self) { tools, location in
                handleDrop(tools: tools, to: nil, inEnabledSection: true)
            }
        }
    }

    private var disabledSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Disabled Features")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal, 20)

            if featureManager.disabledTools.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "arrow.down.circle")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Text("Drag or click tools here to disable")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.secondary.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [8]))
                )
                .padding(.horizontal, 20)
                .dropDestination(for: ToolType.self) { tools, location in
                    handleDrop(tools: tools, to: nil, inEnabledSection: false)
                }
            } else {
                LazyVGrid(columns: columns, spacing: 12, pinnedViews: []) {
                    ForEach(featureManager.disabledTools, id: \.self) { tool in
                        FeatureCard(
                            tool: tool,
                            isEnabled: false,
                            isDragging: draggedTool == tool
                        ) {
                            featureManager.toggleTool(tool)
                        }
                        .draggable(tool) {
                            FeatureCard(tool: tool, isEnabled: false, isDragging: true) {}
                                .opacity(0.3)
                        }
                        .dropDestination(for: ToolType.self) { tools, location in
                            handleDrop(tools: tools, to: tool, inEnabledSection: false)
                        }
                        .onDrag {
                            draggedTool = tool
                            return NSItemProvider(object: tool.rawValue as NSString)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .frame(minHeight: 200, alignment: .top)
                .dropDestination(for: ToolType.self) { tools, location in
                    handleDrop(tools: tools, to: nil, inEnabledSection: false)
                }
            }
        }
    }

    private func handleDrop(tools: [ToolType], to targetTool: ToolType?, inEnabledSection: Bool) -> Bool {
        guard let droppedTool = tools.first else { return false }

        let wasEnabled = featureManager.isToolEnabled(droppedTool)
        let targetEnabled = inEnabledSection

        if wasEnabled != targetEnabled {
            featureManager.moveToolBetweenSections(tool: droppedTool, to: targetEnabled)
        } else {
            if let targetTool = targetTool {
                let sourceTools = inEnabledSection ? featureManager.enabledTools : featureManager.disabledTools
                guard let sourceIndex = sourceTools.firstIndex(of: droppedTool),
                      let targetIndex = sourceTools.firstIndex(of: targetTool) else { return false }

                let indexSet = IndexSet(integer: sourceIndex)
                let destination = targetIndex > sourceIndex ? targetIndex + 1 : targetIndex

                if inEnabledSection {
                    featureManager.moveEnabledTool(from: indexSet, to: destination)
                } else {
                    featureManager.moveDisabledTool(from: indexSet, to: destination)
                }
            }
        }

        draggedTool = nil
        return true
    }
}

struct FeatureCard: View {
    let tool: ToolType
    let isEnabled: Bool
    let isDragging: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: tool.iconName)
                .font(.title2)
                .foregroundColor(isEnabled ? .primary : .secondary)

            Text(tool.title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isEnabled ? .primary : .secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(width: 80, height: 64)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isEnabled ? Color.primary.opacity(0.05) : Color.secondary.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isEnabled ? Color.primary.opacity(0.2) : Color.secondary.opacity(0.2),
                    lineWidth: 1
                )
        )
        .scaleEffect(isDragging ? 1.05 : 1.0)
        .opacity(isDragging ? 0.3 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isDragging)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
                onTap()
            }
        }
        .contentShape(Rectangle())
    }
}


#Preview {
    FeatureSettingsView(featureManager: FeatureManager())
}
