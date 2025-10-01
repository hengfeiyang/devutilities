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

struct TranslationPrompts {

    /// Generate system and user prompts based on mode and languages
    static func generatePrompts(
        mode: TranslationMode,
        sourceLanguage: TranslationLanguage,
        targetLanguage: TranslationLanguage,
        text: String
    ) -> (systemPrompt: String, userPrompt: String) {

        let sourceLangName = sourceLanguage.languageName
        let targetLangName = targetLanguage.languageName

        switch mode {
        case .translate:
            let systemPrompt = "You are a professional translation engine, please translate the text, only translate directly, don't explain."

            let userPrompt: String
            if sourceLanguage == .auto {
                userPrompt = """
                Translate the following text to \(targetLangName). Only reply the result and nothing else:

                \(text)
                """
            } else {
                userPrompt = """
                Translate from \(sourceLangName) to \(targetLangName). Only reply the result and nothing else:

                \(text)
                """
            }

            return (systemPrompt, userPrompt)

        case .polishing:
            let systemPrompt = "You are an expert translator, translate directly without explanation."

            let langForPolishing = sourceLanguage == .auto ? "the original language" : sourceLangName
            let userPrompt = """
            Please edit the following sentences in \(langForPolishing) to improve clarity, conciseness, and coherence, making them match the expression of native speakers. Only reply the result and nothing else:

            \(text)
            """

            return (systemPrompt, userPrompt)

        case .summarize:
            let systemPrompt = "You are a professional text summarizer, you can only summarize the text, don't interpret it."

            let userPrompt = """
            Please summarize this text in the most concise language and must use \(targetLangName) language. Only reply the result and nothing else:

            \(text)
            """

            return (systemPrompt, userPrompt)
        }
    }
}
