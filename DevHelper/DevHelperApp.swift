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

import SwiftUI
import AppIntents

@main
struct DevHelperApp: App {
    @StateObject private var updateChecker = UpdateChecker()
    @StateObject private var appState = AppState()
    
    init() {
        // Register app shortcuts
        Task {
            DevHelperShortcutsProvider.updateAppShortcutParameters()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(updateChecker)
                .environmentObject(appState)
                .onAppear {
                    Task.detached {
                        await EventManager.shared.reportAppStart()
                    }
                    
                    // Check for updates after a short delay to not block startup
                    Task {
                        try await Task.sleep(for: .seconds(2))
                        updateChecker.checkForUpdate()
                    }
                }
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 1024, height: 800)
        .commands {
            CommandGroup(after: .appInfo) {
                Button("Check for Updates...") {
                    updateChecker.checkForUpdate(manualCheck: true)
                }
                .keyboardShortcut("u", modifiers: [.command])
            }
            
            CommandGroup(replacing: .newItem) {
                Button("New Chat") {
                    if appState.currentTool == .aiChat {
                        appState.shouldCreateNewChat = true
                    }
                }
                .keyboardShortcut("n", modifiers: [.command])
                .disabled(appState.currentTool != .aiChat)
            }

            CommandGroup(replacing: .help) {
                Button(action: {
                    let documents = "https://hengfeiyang.github.io/devhelper/"
                    NSWorkspace.shared.open(URL(string: documents)!)
                }) {
                    Text("DevHelper documentation")
                }
            }
        }
    }
}
