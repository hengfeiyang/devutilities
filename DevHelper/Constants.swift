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
    
    // Custom adaptive colors
    static let customBackground = Color(
        light: Color(red: 0.98, green: 0.98, blue: 0.98), // Light gray for light mode
        dark: Color(red: 0.15, green: 0.15, blue: 0.15)   // Dark gray for dark mode
    )
    
    static let customAccent = Color(
        light: Color.blue,
        dark: Color.cyan
    )
}

// Extension to create adaptive colors
extension Color {
    init(light: Color, dark: Color) {
        self.init(
            nsColor: NSColor(name: nil) { appearance in
                if appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua {
                    return NSColor(dark)
                } else {
                    return NSColor(light)
                }
            }
        )
    }
}