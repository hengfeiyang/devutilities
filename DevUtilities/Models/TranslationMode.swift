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

enum TranslationMode: String, CaseIterable, Identifiable, Codable {
    case translate
    case polishing
    case summarize

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .translate:
            return "Translate"
        case .polishing:
            return "Polishing"
        case .summarize:
            return "Summarize"
        }
    }

    var iconName: String {
        switch self {
        case .translate:
            return "translate"
        case .polishing:
            return "sparkles"
        case .summarize:
            return "doc.text.magnifyingglass"
        }
    }

    var processingStatus: String {
        switch self {
        case .translate:
            return "Translating... ✍️"
        case .polishing:
            return "Polishing... ✍️"
        case .summarize:
            return "Summarizing... ✍️"
        }
    }

    var completedStatus: String {
        switch self {
        case .translate:
            return "Translated 👍"
        case .polishing:
            return "Polished 👍"
        case .summarize:
            return "Summarized 👍"
        }
    }
}
