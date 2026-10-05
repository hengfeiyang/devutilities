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

struct ContentView: View {
    @State private var selectedTool: ToolType = .jsonFormatter
    @State private var searchText: String = ""
    @State private var lastFreeTool: ToolType = .jsonFormatter
    @State private var sidebarSelectionRevision = 0
    @State private var showingFeatureSettings = false
    @State private var showingLicenseSettings = false
    @State private var shouldCreateNewChat = false
    @StateObject private var featureManager = FeatureManager()
    @EnvironmentObject var updateChecker: UpdateChecker
    @EnvironmentObject var entitlementManager: EntitlementManager
    
    private var appVersion: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return "v\(version)"
        }
        return "v1.0"
    }
    
    var filteredTools: [ToolType] {
        let enabledTools = featureManager.filteredTools
        if searchText.isEmpty {
            return enabledTools
        } else {
            return enabledTools.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private func handleSearchSubmit() {
        if filteredTools.count == 1 {
            selectTool(filteredTools[0])
        }
    }

    private var toolSelection: Binding<ToolType> {
        Binding(
            get: { selectedTool },
            set: { selectTool($0) }
        )
    }

    private func selectTool(_ tool: ToolType) {
        guard entitlementManager.canUseTool(tool) else {
            guard tool.productAccess == .pro else { return }
            sidebarSelectionRevision &+= 1
            entitlementManager.recordGateShown(for: tool)
            showingLicenseSettings = true
            return
        }

        selectedTool = tool
        if tool.productAccess == .free {
            lastFreeTool = tool
        }
    }
    
    var body: some View {
        NavigationSplitView {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("DevUtilities")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Developer Tools \(appVersion)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    if entitlementManager.isFreemiumEnabled {
                        Button(action: {
                            showingLicenseSettings = true
                        }) {
                            Image(systemName: "crown")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .help("DevUtilities Pro")
                    }

                    Button(action: {
                        showingFeatureSettings = true
                    }) {
                        Image(systemName: "gearshape")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Feature Settings")
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search tools...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .onSubmit {
                            handleSearchSubmit()
                        }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(AppConstants.controlBackground)
                .cornerRadius(10)
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
                
                List(filteredTools, selection: toolSelection) { tool in
                    Label {
                        HStack(spacing: 6) {
                            Text(tool.title)
                            Spacer(minLength: 4)
                            if tool.productAccess == .pro && entitlementManager.shouldShowProBadges {
                                Text("PRO")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(Color.secondary.opacity(0.12))
                                    .clipShape(Capsule())
                            }
                        }
                    } icon: {
                        Image(systemName: tool.iconName)
                    }
                        .tag(tool)
                }
                .id(sidebarSelectionRevision)

                if entitlementManager.isFreemiumEnabled &&
                    !entitlementManager.accessState.hasPermanentProAccess {
                    ProStatusView {
                        showingLicenseSettings = true
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 220, ideal: 220, max: 220)
        } detail: {
            VStack(spacing: 0) {
                Color(NSColor.separatorColor).frame(height: 0.3)
                toolView(for: selectedTool)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(minWidth: 1024, minHeight: 650)
        .alert("Update Available", isPresented: $updateChecker.showUpdateAlert) {
            Button("Open App Store") {
                updateChecker.openAppStore()
            }
            Button("Close", role: .cancel) {
                updateChecker.dismissAlert()
            }
        } message: {
            if let updateInfo = updateChecker.updateAvailable {
                let currentVersionText = "Current version: \(VersionComparator.formatVersionForDisplay(updateInfo.currentVersion))"
                let newVersionText = "A new version \(VersionComparator.formatVersionForDisplay(updateInfo.latestVersion)) is available!"
                
                if let releaseNotes = updateInfo.releaseNotes, !releaseNotes.isEmpty {
                    let cleanReleaseNotes = releaseNotes.replacingOccurrences(of: "\r\n", with: "\n")
                    // Limit release notes to 200 characters to keep alert manageable
                    let truncatedNotes = cleanReleaseNotes.count > 200 
                        ? String(cleanReleaseNotes.prefix(200)) + "..." 
                        : cleanReleaseNotes
                    
                    Text("\(newVersionText)\n\n\(currentVersionText)\n\nWhat's new:\n\n\(truncatedNotes)")
                } else {
                    Text("\(newVersionText)\n\n\(currentVersionText)")
                }
            }
        }
        .alert("No Updates Available", isPresented: $updateChecker.showNoUpdateAlert) {
            Button("OK") {
                updateChecker.dismissNoUpdateAlert()
            }
        } message: {
            Text("You're already using the latest version of DevUtilities.")
        }
        .onChange(of: selectedTool) { oldValue, newValue in
            Task.detached {
                await EventManager.shared.reportModuleSwitch(
                    from: oldValue.eventModuleName,
                    to: newValue.eventModuleName
                )
            }
        }
        .onChange(of: entitlementManager.accessState) { _, _ in
            guard selectedTool.productAccess == .pro,
                  !entitlementManager.canUseTool(selectedTool) else { return }

            let blockedTool = selectedTool
            selectedTool = entitlementManager.canUseTool(lastFreeTool) ? lastFreeTool : .jsonFormatter
            entitlementManager.recordGateShown(for: blockedTool)
            showingLicenseSettings = true
        }
        .onAppear {
            entitlementManager.setApplicationActive(NSApplication.shared.isActive)
            // Report initial module selection
            Task.detached {
                await EventManager.shared.reportModuleSwitch(
                    from: nil,
                    to: selectedTool.eventModuleName
                )
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .newChatRequested)) { _ in
            if selectedTool == .aiChat && entitlementManager.canUseTool(.aiChat) {
                shouldCreateNewChat = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .licenseSettingsRequested)) { _ in
            showingLicenseSettings = true
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            entitlementManager.setApplicationActive(true)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didResignActiveNotification)) { _ in
            entitlementManager.setApplicationActive(false)
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.NSCalendarDayChanged)) { _ in
            entitlementManager.refreshTimeBasedAccess()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.NSSystemClockDidChange)) { _ in
            entitlementManager.refreshTimeBasedAccess()
        }
        .sheet(isPresented: $showingFeatureSettings) {
            FeatureSettingsView(featureManager: featureManager)
        }
        .sheet(isPresented: $showingLicenseSettings) {
            LicenseSettingsView()
                .environmentObject(entitlementManager)
        }
    }

    @ViewBuilder
    private func toolView(for tool: ToolType) -> some View {
        switch tool {
        case .aiChat:
            AIChatView(shouldCreateNewChat: $shouldCreateNewChat)
        case .aiTranslate:
            AITranslateView()
        case .timestampConverter:
            TimestampConverterView()
        case .unitConverter:
            UnitConverterView()
        case .baseConverter:
            BaseConverterView()
        case .colorPicker:
            ColorPickerView()
        case .jsonFormatter:
            JSONFormatterView()
        case .sqlFormatter:
            SQLFormatterView()
        case .htmlFormatter:
            HTMLFormatterView()
        case .base64:
            Base64View()
        case .hexString:
            HexStringConverterView()
        case .jwt:
            JWTView()
        case .regexTest:
            RegexTestView()
        case .uuidGenerator:
            UUIDGeneratorView()
        case .randomString:
            RandomStringView()
        case .cryptoTools:
            CryptoToolsView()
        case .urlTools:
            URLToolsView()
        case .httpRequest:
            HTTPRequestView()
        case .ipQuery:
            IPQueryView()
        case .qrCode:
            QRCodeView()
        case .parquetViewer:
            ParquetViewerView()
        case .currencyConverter:
            CurrencyConverterView()
        case .textCompare:
            TextCompareView()
        case .structConverter:
            StructConverterView()
        case .dataConverter:
            DataConverterView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(UpdateChecker())
        .environmentObject(EntitlementManager())
}
