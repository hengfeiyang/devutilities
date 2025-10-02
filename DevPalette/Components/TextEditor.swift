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
import AppKit

struct TextEditor: NSViewRepresentable {
    @Binding var text: String
    let bottom: CGFloat
    var onEnterKey: (() -> Void)?

    init(text: Binding<String>, bottom: CGFloat = 0, onEnterKey: (() -> Void)? = nil) {
        self._text = text
        self.bottom = bottom
        self.onEnterKey = onEnterKey
    }
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as! NSTextView
        
        // Disable smart quotes and other text substitutions
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isAutomaticDataDetectionEnabled = false
        textView.isRichText = false
        textView.usesFindPanel = true
        textView.delegate = context.coordinator
        
        // Add padding around the text
        textView.textContainerInset = NSSize(width: 0, height: 4)
        
        // Set font to match SwiftUI's system monospaced font
        textView.font = NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        
        // Set background color for proper visibility across macOS versions
        // Use controlBackgroundColor for better contrast on both light and dark modes
        // This ensures the editor is visible even when system background changed to white in macOS 26
        textView.backgroundColor = NSColor(AppConstants.lightGrayBackground)
        
        // Add rounded corners
        scrollView.wantsLayer = true
        scrollView.layer?.cornerRadius = 8
        scrollView.layer?.masksToBounds = true
        scrollView.layer?.borderWidth = 1
        scrollView.layer?.borderColor = NSColor.separatorColor.cgColor
        
        // Add bottom padding by setting content insets (if specified)
        if bottom > 0 {
            scrollView.automaticallyAdjustsContentInsets = false
            scrollView.contentInsets = NSEdgeInsets(top: 0, left: 0, bottom: bottom, right: 0)
        }
        
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        let textView = nsView.documentView as! NSTextView
        if textView.string != text {
            textView.string = text
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        let parent: TextEditor

        init(_ parent: TextEditor) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
        }

        // Handle key events with IME support
        func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            // Check if IME is active (markedRange indicates ongoing composition)
            if textView.hasMarkedText() {
                // Let IME handle the event
                return false
            }

            // Handle Return key when IME is not active
            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                // Check for modifier keys
                let modifierFlags = NSEvent.modifierFlags
                let hasShift = modifierFlags.contains(.shift)
                let hasOption = modifierFlags.contains(.option)
                let hasCommand = modifierFlags.contains(.command)

                // Only trigger callback on plain Enter (no modifiers)
                // Shift+Enter or Option+Enter should insert newline
                if !hasShift && !hasOption && !hasCommand {
                    if let callback = parent.onEnterKey {
                        callback()
                        return true // Event handled
                    }
                }
                // For Shift+Enter or Option+Enter, let default behavior insert newline
                return false
            }

            return false // Let default behavior handle other commands
        }
    }
}
