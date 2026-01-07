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
        // Try multiple methods to detect the language
        let preferredLanguages = Locale.preferredLanguages
        let systemLangCode = Locale.current.language.languageCode?.identifier ?? "en"

        // First check preferred languages (more reliable)
        if let firstPreferred = preferredLanguages.first {
            let locale = Locale(identifier: firstPreferred)
            let langCode = locale.language.languageCode?.identifier ?? systemLangCode

            switch langCode {
            case "zh":
                // Check if it's traditional or simplified
                let scriptCode = locale.language.script?.identifier
                let regionCode = locale.region?.identifier

                // Traditional Chinese: Hong Kong, Taiwan, Macau
                if scriptCode == "Hant" || regionCode == "TW" || regionCode == "HK" || regionCode == "MO" {
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

        // Fallback to system language code
        switch systemLangCode {
        case "zh":
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

    // MARK: - TTS Language Code Mapping

    /// Convert to AVSpeech language code for Text-to-Speech
    var ttsLanguageCode: String {
        switch self {
        case .auto:
            return "en-US"  // Default to English for auto
        case .english:
            return "en-US"
        case .simplifiedChinese:
            return "zh-CN"
        case .traditionalChinese:
            return "zh-TW"
        case .japanese:
            return "ja-JP"
        case .korean:
            return "ko-KR"
        case .spanish:
            return "es-ES"
        case .french:
            return "fr-FR"
        case .german:
            return "de-DE"
        case .russian:
            return "ru-RU"
        case .arabic:
            return "ar-SA"
        case .hindi:
            return "hi-IN"
        case .portuguese:
            return "pt-BR"
        case .italian:
            return "it-IT"
        case .dutch:
            return "nl-NL"
        case .turkish:
            return "tr-TR"
        case .vietnamese:
            return "vi-VN"
        case .thai:
            return "th-TH"
        case .indonesian:
            return "id-ID"
        }
    }
}
