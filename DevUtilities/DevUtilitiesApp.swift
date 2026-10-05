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
import AppIntents

extension Notification.Name {
    static let newChatRequested = Notification.Name("newChatRequested")
    static let licenseSettingsRequested = Notification.Name("licenseSettingsRequested")
}

@main
struct DevUtilitiesApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var updateChecker = UpdateChecker()
    @StateObject private var entitlementManager = EntitlementManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(updateChecker)
                .environmentObject(entitlementManager)
                .onAppear {
                    Task.detached {
                        await EventManager.shared.reportAppStart()
                    }
                    
                    // Check for updates after a short delay to not block startup
                    Task {
                        try? await Task.sleep(for: .seconds(2))
                        guard !Task.isCancelled else { return }
                        updateChecker.checkForUpdate()
                    }
                }
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 1024, height: 650)
        .commands {
            CommandGroup(after: .appInfo) {
                if entitlementManager.isFreemiumEnabled {
                    Button("DevUtilities Pro…") {
                        NotificationCenter.default.post(name: .licenseSettingsRequested, object: nil)
                    }
                }

                Button("Check for Updates...") {
                    updateChecker.checkForUpdate(manualCheck: true)
                }
                .keyboardShortcut("u", modifiers: [.command])
            }
            
            CommandGroup(replacing: .newItem) {
                Button("New Chat") {
                    NotificationCenter.default.post(name: .newChatRequested, object: nil)
                }
                .keyboardShortcut("n", modifiers: [.command])
            }

            CommandGroup(replacing: .help) {
                Button(action: {
                    let documents = "https://hengfeiyang.github.io/devutilities/"
                    NSWorkspace.shared.open(URL(string: documents)!)
                }) {
                    Text("DevUtilities documentation")
                }
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
