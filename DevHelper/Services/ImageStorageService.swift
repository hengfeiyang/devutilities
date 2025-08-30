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

class ImageStorageService {
    static let shared = ImageStorageService()
    
    private let fileManager = FileManager.default
    private let documentsDirectory: URL
    
    private init() {
        documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        createDirectoryIfNeeded()
    }
    
    private func createDirectoryIfNeeded() {
        let imageDirectory = documentsDirectory.appendingPathComponent("DevHelper/GeneratedImages")
        try? fileManager.createDirectory(at: imageDirectory, withIntermediateDirectories: true)
    }
    
    private var imageDirectory: URL {
        documentsDirectory.appendingPathComponent("DevHelper/GeneratedImages")
    }
    
    func downloadAndSaveImage(from urlString: String, messageId: UUID) async throws -> String {
        guard let url = URL(string: urlString) else {
            throw ImageStorageError.invalidURL
        }
        
        print("📱 ImageStorageService: Downloading image from: \(urlString)")
        
        // Download image data
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ImageStorageError.downloadFailed
        }
        
        // Determine file extension from response or default to png
        let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type") ?? "image/png"
        let fileExtension = getFileExtension(for: contentType)
        
        // Generate local file path
        let fileName = "\(messageId.uuidString).\(fileExtension)"
        let localURL = imageDirectory.appendingPathComponent(fileName)
        
        // Save to local storage
        try data.write(to: localURL)
        
        let localPath = localURL.path
        print("✅ ImageStorageService: Image saved to: \(localPath)")
        
        return localPath
    }
    
    func deleteImage(at path: String) {
        guard fileManager.fileExists(atPath: path) else { return }
        
        do {
            try fileManager.removeItem(atPath: path)
            print("✅ ImageStorageService: Deleted image at: \(path)")
        } catch {
            print("❌ ImageStorageService: Failed to delete image at: \(path), error: \(error)")
        }
    }
    
    func cleanupOrphanedImages(validMessageIds: Set<UUID>) {
        do {
            let imageFiles = try fileManager.contentsOfDirectory(at: imageDirectory, 
                                                                includingPropertiesForKeys: nil, 
                                                                options: [.skipsHiddenFiles])
            
            for imageFile in imageFiles {
                let fileName = imageFile.deletingPathExtension().lastPathComponent
                if let uuid = UUID(uuidString: fileName),
                   !validMessageIds.contains(uuid) {
                    try fileManager.removeItem(at: imageFile)
                    print("🧹 ImageStorageService: Cleaned up orphaned image: \(imageFile.path)")
                }
            }
        } catch {
            print("❌ ImageStorageService: Failed to cleanup orphaned images: \(error)")
        }
    }
    
    private func getFileExtension(for contentType: String) -> String {
        switch contentType.lowercased() {
        case "image/jpeg", "image/jpg":
            return "jpg"
        case "image/png":
            return "png"
        case "image/gif":
            return "gif"
        case "image/webp":
            return "webp"
        default:
            return "png" // Default to png for unknown types
        }
    }
}

enum ImageStorageError: LocalizedError {
    case invalidURL
    case downloadFailed
    case saveFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid image URL"
        case .downloadFailed:
            return "Failed to download image"
        case .saveFailed:
            return "Failed to save image to local storage"
        }
    }
}