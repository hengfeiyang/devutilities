import Foundation
import AppKit

struct AppStoreResponse: Codable {
    let results: [AppStoreApp]
}

struct AppStoreApp: Codable {
    let version: String
    let releaseNotes: String?
    let currentVersionReleaseDate: String?

    enum CodingKeys: String, CodingKey {
        case version
        case releaseNotes
        case currentVersionReleaseDate
    }
}

struct UpdateInfo {
    let currentVersion: String
    let latestVersion: String
    let appStoreUrl: String
    let releaseNotes: String?
}

@MainActor
class UpdateChecker: ObservableObject {
    @Published var isCheckingForUpdate = false
    @Published var updateAvailable: UpdateInfo?
    @Published var showUpdateAlert = false
    @Published var showNoUpdateAlert = false

    private let appStoreLookupUrl = "https://itunes.apple.com/lookup?bundleId=com.hengfeiyang.devutilities"
    private let appStoreUrl = "https://apps.apple.com/app/devutilities/id6753612551"
    private var isManualCheck = false
    
    func checkForUpdate(manualCheck: Bool = false) {
        guard !isCheckingForUpdate else { return }
        
        isCheckingForUpdate = true
        isManualCheck = manualCheck
        updateAvailable = nil
        
        Task {
            do {
                let appStoreApp = try await fetchLatestRelease()
                let currentVersion = getCurrentVersion()

                if VersionComparator.isNewerVersion(appStoreApp.version, than: currentVersion) {
                    let updateInfo = UpdateInfo(
                        currentVersion: currentVersion,
                        latestVersion: appStoreApp.version,
                        appStoreUrl: self.appStoreUrl,
                        releaseNotes: appStoreApp.releaseNotes
                    )
                    
                    await MainActor.run {
                        self.updateAvailable = updateInfo
                        self.showUpdateAlert = true
                        self.isCheckingForUpdate = false
                    }
                } else {
                    await MainActor.run {
                        // Show "no updates" alert only for manual checks
                        if self.isManualCheck {
                            self.showNoUpdateAlert = true
                        }
                        self.isCheckingForUpdate = false
                    }
                }
            } catch {
                print("Failed to check for updates: \(error)")
                await MainActor.run {
                    if self.isManualCheck {
                        // Could show error alert here if needed
                    }
                    self.isCheckingForUpdate = false
                }
            }
        }
    }
    
    private func fetchLatestRelease() async throws -> AppStoreApp {
        guard let url = URL(string: appStoreLookupUrl) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 10.0

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        let appStoreResponse = try decoder.decode(AppStoreResponse.self, from: data)

        guard let app = appStoreResponse.results.first else {
            throw URLError(.cannotFindHost)
        }

        return app
    }
    
    private func getCurrentVersion() -> String {
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            return version
        }
        return "1.12.0" // Fallback to current version
    }
    
    func openAppStore() {
        guard let updateInfo = updateAvailable,
              let url = URL(string: updateInfo.appStoreUrl) else { return }

        NSWorkspace.shared.open(url)
    }
    
    func dismissAlert() {
        showUpdateAlert = false
        updateAvailable = nil
    }
    
    func dismissNoUpdateAlert() {
        showNoUpdateAlert = false
    }
}