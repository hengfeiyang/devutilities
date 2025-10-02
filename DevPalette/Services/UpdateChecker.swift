import Foundation
import AppKit

struct GitHubRelease: Codable {
    let tagName: String
    let name: String
    let htmlUrl: String
    let publishedAt: String
    let body: String?
    
    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case name
        case htmlUrl = "html_url"
        case publishedAt = "published_at"
        case body
    }
}

struct UpdateInfo {
    let currentVersion: String
    let latestVersion: String
    let downloadUrl: String
    let releaseNotes: String?
}

@MainActor
class UpdateChecker: ObservableObject {
    @Published var isCheckingForUpdate = false
    @Published var updateAvailable: UpdateInfo?
    @Published var showUpdateAlert = false
    @Published var showNoUpdateAlert = false
    
    private let githubApiUrl = "https://api.github.com/repos/DevPalette/DevPalette/releases/latest"
    private var isManualCheck = false
    
    func checkForUpdate(manualCheck: Bool = false) {
        guard !isCheckingForUpdate else { return }
        
        isCheckingForUpdate = true
        isManualCheck = manualCheck
        updateAvailable = nil
        
        Task {
            do {
                let latestRelease = try await fetchLatestRelease()
                let currentVersion = getCurrentVersion()
                
                if VersionComparator.isNewerVersion(latestRelease.tagName, than: currentVersion) {
                    let updateInfo = UpdateInfo(
                        currentVersion: currentVersion,
                        latestVersion: latestRelease.tagName,
                        downloadUrl: latestRelease.htmlUrl,
                        releaseNotes: latestRelease.body
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
    
    private func fetchLatestRelease() async throws -> GitHubRelease {
        guard let url = URL(string: githubApiUrl) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10.0
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(GitHubRelease.self, from: data)
    }
    
    private func getCurrentVersion() -> String {
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            return version
        }
        return "1.12.0" // Fallback to current version
    }
    
    func openDownloadPage() {
        guard let updateInfo = updateAvailable,
              let url = URL(string: updateInfo.downloadUrl) else { return }
        
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