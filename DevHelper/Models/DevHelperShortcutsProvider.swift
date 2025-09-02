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

struct DevHelperShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        return [
            AppShortcut(
                intent: OpenJSONFormatterIntent(),
                phrases: [
                    "Open JSON Formatter in \(.applicationName)",
                    "JSON Formatter in \(.applicationName)",
                    "Format JSON with \(.applicationName)"
                ],
                shortTitle: "JSON Formatter",
                systemImageName: "doc.text"
            ),
            
            AppShortcut(
                intent: OpenBase64Intent(),
                phrases: [
                    "Open Base64 in \(.applicationName)",
                    "Base64 Encoder in \(.applicationName)"
                ],
                shortTitle: "Base64",
                systemImageName: "6.circle"
            ),
            
            AppShortcut(
                intent: OpenUUIDGeneratorIntent(),
                phrases: [
                    "Open UUID Generator in \(.applicationName)",
                    "Generate UUID with \(.applicationName)"
                ],
                shortTitle: "UUID Generator",
                systemImageName: "dice"
            ),
            
            AppShortcut(
                intent: OpenTimestampConverterIntent(),
                phrases: [
                    "Open Timestamp Converter in \(.applicationName)",
                    "Convert Timestamp with \(.applicationName)"
                ],
                shortTitle: "Timestamp Converter",
                systemImageName: "clock"
            ),
            
            AppShortcut(
                intent: OpenURLToolsIntent(),
                phrases: [
                    "Open URL Tools in \(.applicationName)",
                    "Encode URL with \(.applicationName)"
                ],
                shortTitle: "URL Tools",
                systemImageName: "link"
            ),
            
            AppShortcut(
                intent: OpenRegexTestIntent(),
                phrases: [
                    "Open Regex Test in \(.applicationName)",
                    "Test Regex with \(.applicationName)"
                ],
                shortTitle: "Regex Test",
                systemImageName: "magnifyingglass"
            ),
            
            AppShortcut(
                intent: OpenJWTIntent(),
                phrases: [
                    "Open JWT in \(.applicationName)",
                    "JWT Decoder in \(.applicationName)"
                ],
                shortTitle: "JWT",
                systemImageName: "key.horizontal"
            ),
            
            AppShortcut(
                intent: OpenHTTPRequestIntent(),
                phrases: [
                    "Open HTTP Request in \(.applicationName)",
                    "API Test with \(.applicationName)"
                ],
                shortTitle: "HTTP Request",
                systemImageName: "network"
            ),
            
            AppShortcut(
                intent: OpenCryptoToolsIntent(),
                phrases: [
                    "Open Crypto Tools in \(.applicationName)",
                    "Hash Generator in \(.applicationName)"
                ],
                shortTitle: "Crypto Tools",
                systemImageName: "lock.shield"
            ),
            
            AppShortcut(
                intent: OpenAIChatIntent(),
                phrases: [
                    "Open AI Chat in \(.applicationName)",
                    "AI Assistant in \(.applicationName)"
                ],
                shortTitle: "AI Chat",
                systemImageName: "sparkles"
            )
        ]
    }
}