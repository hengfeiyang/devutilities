import Foundation

struct VersionComparator {
    
    /// Compares two version strings using semantic versioning rules
    /// Returns true if newVersion is newer than currentVersion
    static func isNewerVersion(_ newVersion: String, than currentVersion: String) -> Bool {
        let newComponents = parseVersion(newVersion)
        let currentComponents = parseVersion(currentVersion)
        
        // Compare major version
        if newComponents.major > currentComponents.major {
            return true
        } else if newComponents.major < currentComponents.major {
            return false
        }
        
        // Compare minor version
        if newComponents.minor > currentComponents.minor {
            return true
        } else if newComponents.minor < currentComponents.minor {
            return false
        }
        
        // Compare patch version
        if newComponents.patch > currentComponents.patch {
            return true
        }
        
        return false
    }
    
    /// Parses a version string into major.minor.patch components
    /// Handles formats like "v1.12.0", "1.12.0", "1.12", "1"
    private static func parseVersion(_ versionString: String) -> (major: Int, minor: Int, patch: Int) {
        // Remove 'v' prefix if present
        let cleanVersion = versionString.hasPrefix("v") ? String(versionString.dropFirst()) : versionString
        
        // Split by dots and convert to integers
        let components = cleanVersion.split(separator: ".").compactMap { Int($0) }
        
        let major = components.count > 0 ? components[0] : 0
        let minor = components.count > 1 ? components[1] : 0
        let patch = components.count > 2 ? components[2] : 0
        
        return (major: major, minor: minor, patch: patch)
    }
    
    /// Formats a version for display (adds 'v' prefix if not present)
    static func formatVersionForDisplay(_ version: String) -> String {
        return version.hasPrefix("v") ? version : "v\(version)"
    }
}