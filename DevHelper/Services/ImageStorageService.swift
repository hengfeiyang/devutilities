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
        print("📱 ImageStorageService: Processing image from: \(urlString.prefix(50))...")
        
        let data: Data
        let fileExtension: String
        
        // Check if it's a data URL (base64 encoded)
        if urlString.hasPrefix("data:image/") {
            print("📱 ImageStorageService: Processing data URL (base64)")
            // Parse data URL format: data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA...
            let components = urlString.components(separatedBy: ",")
            guard components.count == 2,
                  let base64String = components.last,
                  let imageData = Data(base64Encoded: base64String) else {
                print("❌ ImageStorageService: Failed to parse base64 data URL")
                throw ImageStorageError.invalidURL
            }
            
            data = imageData
            
            // Extract file type from data URL
            let mimeType = urlString.components(separatedBy: ";").first?.components(separatedBy: ":").last ?? "image/png"
            fileExtension = getFileExtension(for: mimeType)
            
            print("📱 ImageStorageService: Processed base64 data URL, MIME type: \(mimeType), size: \(data.count) bytes, extension: \(fileExtension)")
        } else {
            // Regular URL - download from remote
            guard let url = URL(string: urlString) else {
                throw ImageStorageError.invalidURL
            }
            
            print("📱 ImageStorageService: Downloading from remote URL: \(urlString)")
            
            let (downloadedData, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw ImageStorageError.downloadFailed
            }
            
            data = downloadedData
            
            // Determine file extension from response or default to png
            let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type") ?? "image/png"
            fileExtension = getFileExtension(for: contentType)
        }
        
        // Generate local file path
        let fileName = "\(messageId.uuidString).\(fileExtension)"
        let localURL = imageDirectory.appendingPathComponent(fileName)
        
        // Save to local storage
        try data.write(to: localURL)
        
        let localPath = localURL.path
        print("✅ ImageStorageService: Image saved to: \(localPath)")
        
        return localPath
    }
    
    func saveBase64Image(_ base64DataURL: String, messageId: UUID) async throws -> String {
        print("📱 ImageStorageService: Saving base64 image for message: \(messageId)")
        
        // Reuse the existing downloadAndSaveImage method which already handles base64 data URLs
        return try await downloadAndSaveImage(from: base64DataURL, messageId: messageId)
    }
    
    func saveUploadedImage(from sourceURL: URL, imageId: UUID) async throws -> String {
        print("📱 ImageStorageService: Saving uploaded image from: \(sourceURL.path)")
        
        // Read the image data
        let data = try Data(contentsOf: sourceURL)
        
        // Determine file extension from source URL
        let sourceExtension = sourceURL.pathExtension.lowercased()
        let fileExtension = ["jpg", "jpeg", "png", "gif", "webp"].contains(sourceExtension) ? sourceExtension : "png"
        
        // Generate local file path with image ID
        let fileName = "\(imageId.uuidString).\(fileExtension)"
        let localURL = imageDirectory.appendingPathComponent(fileName)
        
        // Save to local storage
        try data.write(to: localURL)
        
        let localPath = localURL.path
        print("✅ ImageStorageService: Uploaded image saved to: \(localPath)")
        
        return localPath
    }
    
    func saveMultipleUploadedImages(from sourceURLs: [URL], imageIds: [UUID]) async throws -> [String] {
        guard sourceURLs.count == imageIds.count else {
            throw ImageStorageError.invalidInput
        }
        
        var savedPaths: [String] = []
        
        for (sourceURL, imageId) in zip(sourceURLs, imageIds) {
            do {
                let savedPath = try await saveUploadedImage(from: sourceURL, imageId: imageId)
                savedPaths.append(savedPath)
            } catch {
                print("❌ ImageStorageService: Failed to save image \(sourceURL.path): \(error)")
                throw error
            }
        }
        
        print("✅ ImageStorageService: Saved \(savedPaths.count) uploaded images")
        return savedPaths
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
    case invalidInput
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid image URL"
        case .downloadFailed:
            return "Failed to download image"
        case .saveFailed:
            return "Failed to save image to local storage"
        case .invalidInput:
            return "Invalid input parameters"
        }
    }
}