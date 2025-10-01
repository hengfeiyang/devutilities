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

import Foundation

enum TranslationLanguage: String, CaseIterable, Identifiable, Codable {
    case auto = "auto"
    case english = "en"
    case simplifiedChinese = "zh-Hans"
    case traditionalChinese = "zh-Hant"
    case japanese = "ja"
    case korean = "ko"
    case spanish = "es"
    case french = "fr"
    case german = "de"
    case russian = "ru"
    case arabic = "ar"
    case hindi = "hi"
    case portuguese = "pt"
    case italian = "it"
    case dutch = "nl"
    case turkish = "tr"
    case vietnamese = "vi"
    case thai = "th"
    case indonesian = "id"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .auto:
            return "Auto Detect"
        case .english:
            return "English"
        case .simplifiedChinese:
            return "简体中文"
        case .traditionalChinese:
            return "繁體中文"
        case .japanese:
            return "日本語"
        case .korean:
            return "한국어"
        case .spanish:
            return "Español"
        case .french:
            return "Français"
        case .german:
            return "Deutsch"
        case .russian:
            return "Русский"
        case .arabic:
            return "العربية"
        case .hindi:
            return "हिन्दी"
        case .portuguese:
            return "Português"
        case .italian:
            return "Italiano"
        case .dutch:
            return "Nederlands"
        case .turkish:
            return "Türkçe"
        case .vietnamese:
            return "Tiếng Việt"
        case .thai:
            return "ไทย"
        case .indonesian:
            return "Bahasa Indonesia"
        }
    }

    var languageName: String {
        switch self {
        case .auto:
            return "Auto"
        case .english:
            return "English"
        case .simplifiedChinese:
            return "Simplified Chinese"
        case .traditionalChinese:
            return "Traditional Chinese"
        case .japanese:
            return "Japanese"
        case .korean:
            return "Korean"
        case .spanish:
            return "Spanish"
        case .french:
            return "French"
        case .german:
            return "German"
        case .russian:
            return "Russian"
        case .arabic:
            return "Arabic"
        case .hindi:
            return "Hindi"
        case .portuguese:
            return "Portuguese"
        case .italian:
            return "Italian"
        case .dutch:
            return "Dutch"
        case .turkish:
            return "Turkish"
        case .vietnamese:
            return "Vietnamese"
        case .thai:
            return "Thai"
        case .indonesian:
            return "Indonesian"
        }
    }

    // Detect system language and map to TranslationLanguage
    static func detectSystemLanguage() -> TranslationLanguage {
        let systemLangCode = Locale.current.language.languageCode?.identifier ?? "en"

        switch systemLangCode {
        case "zh":
            // Check if it's traditional or simplified
            let scriptCode = Locale.current.language.script?.identifier
            if scriptCode == "Hant" {
                return .traditionalChinese
            }
            return .simplifiedChinese
        case "ja":
            return .japanese
        case "ko":
            return .korean
        case "es":
            return .spanish
        case "fr":
            return .french
        case "de":
            return .german
        case "ru":
            return .russian
        case "ar":
            return .arabic
        case "hi":
            return .hindi
        case "pt":
            return .portuguese
        case "it":
            return .italian
        case "nl":
            return .dutch
        case "tr":
            return .turkish
        case "vi":
            return .vietnamese
        case "th":
            return .thai
        case "id":
            return .indonesian
        default:
            return .english
        }
    }

    // Get available target languages (exclude auto)
    static var targetLanguages: [TranslationLanguage] {
        return allCases.filter { $0 != .auto }
    }
}
