import SwiftUI
import AppKit

struct AppConstants {
    static let lightGrayBackground = Color.gray.opacity(0.1)
    static let controlBackground = Color(NSColor.controlBackgroundColor)
    static let sectionBackground = Color(NSColor.separatorColor).opacity(0.1)
    
    // Colors that adapt to dark/light mode
    static let adaptiveBackground = Color(NSColor.controlBackgroundColor)
    static let adaptiveText = Color(NSColor.labelColor)
    static let adaptiveSecondaryText = Color(NSColor.secondaryLabelColor)
    static let adaptiveBorder = Color(NSColor.separatorColor)
    
    // Custom adaptive colors using NSColor
    static let customBackground = Color(
        nsColor: NSColor(name: nil) { appearance in
            if appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua {
                return NSColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0) // Dark gray
            } else {
                return NSColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0) // Light gray
            }
        }
    )
    
    static let customAccent = Color(
        nsColor: NSColor(name: nil) { appearance in
            if appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua {
                return NSColor.cyan
            } else {
                return NSColor.blue
            }
        }
    )
}