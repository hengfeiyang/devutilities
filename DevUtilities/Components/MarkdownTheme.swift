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
import Textual

struct ChatStructuredTextStyle: StructuredText.Style {
  let inlineStyle: InlineStyle = .gitHub
  let headingStyle: StructuredText.GitHubHeadingStyle = .gitHub
  let paragraphStyle: StructuredText.GitHubParagraphStyle = .gitHub
  let blockQuoteStyle: StructuredText.GitHubBlockQuoteStyle = .gitHub
  let codeBlockStyle: ChatCodeBlockStyle = .chatCopyable
  let listItemStyle: StructuredText.DefaultListItemStyle = .default
  let unorderedListMarker: StructuredText.HierarchicalSymbolListMarker = .hierarchical(
    .disc, .circle, .square)
  let orderedListMarker: StructuredText.DecimalListMarker = .decimal
  let tableStyle: StructuredText.GitHubTableStyle = .gitHub
  let tableCellStyle: StructuredText.GitHubTableCellStyle = .gitHub
  let thematicBreakStyle: StructuredText.GitHubThematicBreakStyle = .gitHub
}

extension StructuredText.Style where Self == ChatStructuredTextStyle {
  /// Default structured text style used by chat message rendering.
  static var chatStyle: Self {
    .init()
  }
}

struct ChatCodeBlockStyle: StructuredText.CodeBlockStyle {
  func makeBody(configuration: Configuration) -> some View {
    ChatCodeBlockContainer(configuration: configuration)
  }
}

private struct ChatCodeBlockContainer: View {
  let configuration: StructuredText.CodeBlockStyleConfiguration
  @State private var isCopied = false

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack(spacing: 8) {
        if let language = normalizedLanguageHint {
          Text(language)
            .font(.caption2.monospaced())
            .foregroundColor(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.secondary.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }

        Spacer()

        Button(action: copyCode) {
          ZStack {
            Image(systemName: "doc.on.doc")
              .opacity(isCopied ? 0 : 1)
            Image(systemName: "checkmark")
              .opacity(isCopied ? 1 : 0)
          }
          .font(.system(size: 12, weight: .medium))
          .frame(width: 14, height: 14)
          .foregroundColor(isCopied ? .green : .secondary)
          .padding(6)
          .background(Color.secondary.opacity(0.12))
          .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
        .help(isCopied ? "Copied" : "Copy code")
      }

      ScrollView(.horizontal, showsIndicators: false) {
        configuration.label
          .textual.lineSpacing(.fontScaled(0.225))
          .textual.fontScale(0.85)
          .fixedSize(horizontal: true, vertical: true)
          .monospaced()
          .padding(12)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .padding(10)
    .background(Color.secondary.opacity(0.08))
    .overlay(
      RoundedRectangle(cornerRadius: 10)
        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
    )
    .clipShape(RoundedRectangle(cornerRadius: 10))
    .textual.blockSpacing(.init(top: 0, bottom: 16))
  }

  private var normalizedLanguageHint: String? {
    guard let language = configuration.languageHint?
      .trimmingCharacters(in: .whitespacesAndNewlines), !language.isEmpty
    else {
      return nil
    }
    return language.uppercased()
  }

  private func copyCode() {
    configuration.codeBlock.copyToPasteboard()
    withAnimation(.easeInOut(duration: 0.15)) {
      isCopied = true
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
      withAnimation(.easeInOut(duration: 0.15)) {
        isCopied = false
      }
    }
  }
}

extension StructuredText.CodeBlockStyle where Self == ChatCodeBlockStyle {
  static var chatCopyable: Self {
    .init()
  }
}
