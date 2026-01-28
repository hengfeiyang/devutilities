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

import SwiftUI

struct TextCompareView: View {
    private let screenName = "Text Compare"
    private let module = ToolType.textCompare.eventModuleName

    @State private var leftText: String = ""
    @State private var rightText: String = ""
    @State private var validationMessage: String = ""
    @State private var isIdentical: Bool = true

    private let sampleText1 = """
Hello World!
This is the first text.
It has multiple lines.
Lorem ipsum dolor sit amet.
"""

    private let sampleText2 = """
Hello World!
This is the second text.
It has multiple lines too.
Lorem ipsum dolor sit amet.
"""

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack {
                Text("Text Diff Comparison")
                    .font(.headline)
                Spacer()
                Button("Clear All") {
                    leftText = ""
                    rightText = ""
                    validationMessage = ""
                }
                .buttonStyle(.borderless)
            }

            // Diff Editor
            CodeDiffEditor.plain(leftContent: $leftText, rightContent: $rightText, readOnly: false)
                .frame(maxHeight: .infinity)
                .onChange(of: leftText) { _, _ in
                    updateComparisonStatus()
                }
                .onChange(of: rightText) { _, _ in
                    updateComparisonStatus()
                }

            // Metrics Display
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Left: \(leftText.count) characters, \(leftText.components(separatedBy: .newlines).count) lines")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Right: \(rightText.count) characters, \(rightText.components(separatedBy: .newlines).count) lines")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Validation Message
            if !validationMessage.isEmpty {
                Text(validationMessage)
                    .font(.caption)
                    .foregroundColor(isIdentical ? .green : .red)
            }

            // Action Buttons
            HStack(spacing: 20) {
                Button("Sample") {
                    leftText = sampleText1
                    rightText = sampleText2
                }
                .buttonStyle(.bordered)

                Button("Clear Left") {
                    leftText = ""
                }
                .buttonStyle(.bordered)

                Button("Swap") {
                    (leftText, rightText) = (rightText, leftText)
                }
                .buttonStyle(.bordered)

                Button("Clear Right") {
                    rightText = ""
                }
                .buttonStyle(.bordered)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("\(screenName)")
    }

    private func updateComparisonStatus() {
        if leftText.isEmpty && rightText.isEmpty {
            validationMessage = ""
            isIdentical = true
        } else if leftText == rightText {
            isIdentical = true
            validationMessage = "✅ Both texts are the same"
        } else {
            isIdentical = false
            validationMessage = "❌ Texts are different"
        }
    }
}

#Preview {
    TextCompareView()
}
