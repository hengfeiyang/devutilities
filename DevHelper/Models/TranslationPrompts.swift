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

    /// Check if the text is a single word
    private static func isWord(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        // Check if it's a single word (no spaces, not empty, reasonable length)
        return !trimmed.isEmpty
            && !trimmed.contains(" ")
            && !trimmed.contains("\n")
            && trimmed.count < 50  // Reasonable word length limit
    }

    /// Check if target language is Chinese
    private static func isChinese(_ language: TranslationLanguage) -> Bool {
        return language == .simplifiedChinese || language == .traditionalChinese
    }

    /// Generate system and user prompts based on mode and languages
    static func generatePrompts(
        mode: TranslationMode,
        sourceLanguage: TranslationLanguage,
        targetLanguage: TranslationLanguage,
        text: String
    ) -> (systemPrompt: String, userPrompt: String) {

        let sourceLangName = sourceLanguage.languageName
        let targetLangName = targetLanguage.languageName
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)

        switch mode {
        case .translate:
            // Special handling for single word translation
            if isWord(trimmedText) {
                if isChinese(targetLanguage) {
                    // Chinese word mode - detailed with etymology
                    let systemPrompt = """
                    你是一个翻译引擎，请翻译给出的文本，只需要翻译不需要解释。当且仅当文本只有一个单词时，请给出单词原始形态（如果有）、单词的语种、对应的音标或转写、所有含义（含词性）、双语示例，至少三条例句。如果你认为单词拼写错误，请提示我最可能的正确拼写，否则请严格按照下面格式给到翻译结果：
                    <单词>
                    [<语种>]· / <音标>
                    [<词性缩写>] <中文含义>
                    例句：
                    <序号><例句>(例句翻译)
                    词源：
                    <词源>
                    """
                    let userPrompt = "好的，我明白了，请给我这个单词。\n\n单词是：\(trimmedText)"
                    return (systemPrompt, userPrompt)
                } else {
                    // English word mode - detailed with etymology
                    let systemPrompt = """
                    You are a professional translation engine. Please translate the text into \(targetLangName) without explanation. When the text has only one word, please act as a professional dictionary, and list the original form of the word (if any), the language of the word, the corresponding phonetic notation or transcription, all senses with parts of speech, bilingual sentence examples (at least 3) and etymology. If you think there is a spelling mistake, please tell me the most possible correct word otherwise reply in the following format:
                    <word> (<original form>)
                    [<language>]· / <phonetic notation>
                    [<part of speech>] <translated meaning> / <meaning in source language>
                    Examples:
                    <index>. <sentence>(<sentence translation>)
                    Etymology:
                    <etymology>
                    """
                    let userPrompt = "I understand. Please give me the word.\n\nThe word is: \(trimmedText)"
                    return (systemPrompt, userPrompt)
                }
            }

            // Regular translation mode
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
