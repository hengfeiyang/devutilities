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

struct ColorPickerView: View {
    let screenName = "Color Picker"
    let module = "color_picker"

    @State private var selectedColor: Color = .blue
    @State private var hexValue: String = ""
    @State private var rgbValue: String = ""
    @State private var rgbaValue: String = ""
    @State private var hslValue: String = ""
    @State private var hslaValue: String = ""
    @State private var hsbValue: String = ""
    @State private var cmykValue: String = ""

    @State private var colorHistory: [String] = [] // Store as hex strings
    @State private var isUpdatingFromPicker = false
    @State private var isAddingToHistory = false
    @State private var lastHistoryAddTime: Date = Date.distantPast

    private let maxHistoryCount = 22
    private let historyDebounceInterval: TimeInterval = 0.2 // 200ms

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Color Preview and Picker Section
            VStack(spacing: 16) {
                HStack(spacing: 20) {
                    // Color Preview Box - Reduced size from 150 to 80
                    RoundedRectangle(cornerRadius: 8)
                        .fill(selectedColor)
                        .frame(width: 80, height: 80)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )

                    VStack(alignment: .leading, spacing: 12) {
                        ColorPicker("Select Color", selection: $selectedColor)
                            .onChange(of: selectedColor) { _, newValue in
                                updateAllFormatsFromColor(newValue)
                                addToHistory(newValue)
                            }

                        Text("Click to open the system color panel")
                            .font(.caption)
                            .foregroundColor(.secondary)


                        // Color History Section
                        if !colorHistory.isEmpty {
                            HStack(spacing: 8) {
                                Text("History")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)

                                HStack(spacing: 6) {
                                    ForEach(Array(colorHistory.enumerated()), id: \.offset) { _, hexString in
                                        if let color = hexStringToColor(hexString) {
                                            RoundedRectangle(cornerRadius: 3)
                                                .fill(color)
                                                .frame(width: 20, height: 20)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 3)
                                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                                )
                                                .onTapGesture {
                                                    selectedColor = color
                                                    updateAllFormatsFromColor(color)
                                                }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)

            // Format Conversions Section
            VStack(spacing: 0) {
                Text("Format Conversions")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 12)

                Divider()

                // HEX
                formatRow(
                    label: "HEX",
                    value: $hexValue,
                    placeholder: "#RRGGBB or #RRGGBBAA",
                    onChange: { updateColorFromHex(hexValue) }
                )

                Divider()

                // RGB
                formatRow(
                    label: "RGB",
                    value: $rgbValue,
                    placeholder: "rgb(r, g, b)",
                    onChange: { updateColorFromRGB(rgbValue) }
                )

                Divider()

                // RGBA
                formatRow(
                    label: "RGBA",
                    value: $rgbaValue,
                    placeholder: "rgba(r, g, b, a)",
                    onChange: { updateColorFromRGBA(rgbaValue) }
                )

                Divider()

                // HSL
                formatRow(
                    label: "HSL",
                    value: $hslValue,
                    placeholder: "hsl(h, s%, l%)",
                    onChange: { updateColorFromHSL(hslValue) }
                )

                Divider()

                // HSLA
                formatRow(
                    label: "HSLA",
                    value: $hslaValue,
                    placeholder: "hsla(h, s%, l%, a)",
                    onChange: { updateColorFromHSLA(hslaValue) }
                )

                Divider()

                // HSB
                formatRow(
                    label: "HSB",
                    value: $hsbValue,
                    placeholder: "hsb(h, s%, b%)",
                    onChange: { updateColorFromHSB(hsbValue) }
                )

                Divider()

                // CMYK
                formatRow(
                    label: "CMYK",
                    value: $cmykValue,
                    placeholder: "cmyk(c%, m%, y%, k%)",
                    onChange: { updateColorFromCMYK(cmykValue) }
                )

                Divider()

                // Tip message
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.orange)
                    Text("Tip: You can edit any format value above to change the color")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 20)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)

            Spacer()
        }
        .padding()
        .navigationTitle(screenName)
        .onAppear {
            loadState()
        }
        .onDisappear {
            saveState()
        }
    }

    // MARK: - Format Row Component

    @ViewBuilder
    private func formatRow(label: String, value: Binding<String>, placeholder: String, onChange: @escaping () -> Void) -> some View {
        HStack(spacing: 12) {
            Text(label)
                .font(.system(.body, design: .monospaced))
                .frame(width: 60, alignment: .leading)
                .foregroundColor(.secondary)

            TextField(placeholder, text: value)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.system(.body, design: .monospaced))
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(4)
                .onChange(of: value.wrappedValue) { _, _ in
                    onChange()
                }
                .onSubmit {
                    onChange()
                }

            Button(action: {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(value.wrappedValue, forType: .string)
            }) {
                Image(systemName: "doc.on.doc")
            }
            .buttonStyle(PlainButtonStyle())
            .help("Copy to clipboard")
        }
        .padding(.vertical, 8)
    }

    // MARK: - Color History Management

    private func addToHistory(_ color: Color) {
        // Prevent concurrent calls - if already adding, skip this call
        if isAddingToHistory {
            print("Skipping history add - already in progress")
            return
        }

        // Set flag to prevent concurrent calls
        isAddingToHistory = true
        defer { isAddingToHistory = false } // Always reset flag when done

        let now = Date()
        let timeSinceLastAdd = now.timeIntervalSince(lastHistoryAddTime)

        // Debouncing: Don't add if less than 100ms since last add
        // This prevents multiple rapid changes from creating duplicate entries
        if timeSinceLastAdd < historyDebounceInterval {
            print("Skipping history add - too soon (timeSinceLastAdd: \(timeSinceLastAdd * 1000)ms)")
            return
        }

        // Convert color to hex string
        let hexString = colorToHex(color)
        print("Adding color to history: \(hexString)")

        // Don't add if it's the same as the most recent color
        if let lastHex = colorHistory.first, lastHex == hexString {
            print("Skipping history add - same as most recent color")
            return
        }

        // Add to beginning of history
        colorHistory.insert(hexString, at: 0)

        // Limit history size
        if colorHistory.count > maxHistoryCount {
            colorHistory = Array(colorHistory.prefix(maxHistoryCount))
        }

        // Update last add time
        lastHistoryAddTime = now
        print("Color added to history successfully. History count: \(colorHistory.count)")
    }

    private func colorToHex(_ color: Color) -> String {
        let nsColor = NSColor(color)
        guard let rgbColor = nsColor.usingColorSpace(.deviceRGB) else {
            return "#000000"
        }

        let r = Int(rgbColor.redComponent * 255)
        let g = Int(rgbColor.greenComponent * 255)
        let b = Int(rgbColor.blueComponent * 255)
        let a = rgbColor.alphaComponent

        if a < 1.0 {
            let alpha = Int(a * 255)
            return String(format: "#%02X%02X%02X%02X", r, g, b, alpha)
        } else {
            return String(format: "#%02X%02X%02X", r, g, b)
        }
    }

    private func hexStringToColor(_ hexString: String) -> Color? {
        let cleaned = hexString.replacingOccurrences(of: "#", with: "")
        var r: UInt64 = 0, g: UInt64 = 0, b: UInt64 = 0, a: UInt64 = 255

        if cleaned.count == 6 {
            Scanner(string: String(cleaned.prefix(2))).scanHexInt64(&r)
            Scanner(string: String(cleaned.dropFirst(2).prefix(2))).scanHexInt64(&g)
            Scanner(string: String(cleaned.dropFirst(4).prefix(2))).scanHexInt64(&b)
        } else if cleaned.count == 8 {
            Scanner(string: String(cleaned.prefix(2))).scanHexInt64(&r)
            Scanner(string: String(cleaned.dropFirst(2).prefix(2))).scanHexInt64(&g)
            Scanner(string: String(cleaned.dropFirst(4).prefix(2))).scanHexInt64(&b)
            Scanner(string: String(cleaned.dropFirst(6).prefix(2))).scanHexInt64(&a)
        } else {
            return nil
        }

        return Color(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }

    private func colorsAreEqual(_ color1: Color, _ color2: Color) -> Bool {
        let nsColor1 = NSColor(color1).usingColorSpace(.deviceRGB)
        let nsColor2 = NSColor(color2).usingColorSpace(.deviceRGB)

        guard let rgb1 = nsColor1, let rgb2 = nsColor2 else { return false }

        return abs(rgb1.redComponent - rgb2.redComponent) < 0.001 &&
               abs(rgb1.greenComponent - rgb2.greenComponent) < 0.001 &&
               abs(rgb1.blueComponent - rgb2.blueComponent) < 0.001 &&
               abs(rgb1.alphaComponent - rgb2.alphaComponent) < 0.001
    }

    // MARK: - Color Conversion Functions

    private func updateAllFormatsFromColor(_ color: Color) {
        updateOtherFormatsFromColor(color, excluding: nil)
    }

    private func updateOtherFormatsFromColor(_ color: Color, excluding: String?) {
        guard !isUpdatingFromPicker else { return }
        isUpdatingFromPicker = true

        let nsColor = NSColor(color)
        guard let rgbColor = nsColor.usingColorSpace(.deviceRGB) else {
            isUpdatingFromPicker = false
            return
        }

        let r = Int(rgbColor.redComponent * 255)
        let g = Int(rgbColor.greenComponent * 255)
        let b = Int(rgbColor.blueComponent * 255)
        let a = rgbColor.alphaComponent

        // HEX
        if excluding != "hex" {
            if a < 1.0 {
                let alpha = Int(a * 255)
                hexValue = String(format: "#%02X%02X%02X%02X", r, g, b, alpha)
            } else {
                hexValue = String(format: "#%02X%02X%02X", r, g, b)
            }
        }

        // RGB
        if excluding != "rgb" {
            rgbValue = "rgb(\(r), \(g), \(b))"
        }

        // RGBA
        if excluding != "rgba" {
            rgbaValue = String(format: "rgba(%d, %d, %d, %.2f)", r, g, b, a)
        }

        // HSL
        let (h, s, l) = rgbToHSL(r: Double(r)/255, g: Double(g)/255, b: Double(b)/255)
        if excluding != "hsl" {
            hslValue = String(format: "hsl(%.0f, %.0f%%, %.0f%%)", h, s * 100, l * 100)
        }
        if excluding != "hsla" {
            hslaValue = String(format: "hsla(%.0f, %.0f%%, %.0f%%, %.2f)", h, s * 100, l * 100, a)
        }

        // HSB
        let (hh, ss, bb) = rgbToHSB(r: Double(r)/255, g: Double(g)/255, b: Double(b)/255)
        if excluding != "hsb" {
            hsbValue = String(format: "hsb(%.0f, %.0f%%, %.0f%%)", hh, ss * 100, bb * 100)
        }

        // CMYK
        let (c, m, y, k) = rgbToCMYK(r: Double(r)/255, g: Double(g)/255, b: Double(b)/255)
        if excluding != "cmyk" {
            cmykValue = String(format: "cmyk(%.0f%%, %.0f%%, %.0f%%, %.0f%%)", c * 100, m * 100, y * 100, k * 100)
        }

        isUpdatingFromPicker = false
    }

    // MARK: - Update Color from Input

    private func updateColorFromHex(_ hex: String) {
        guard !isUpdatingFromPicker else { return }
        let cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")

        var r: UInt64 = 0, g: UInt64 = 0, b: UInt64 = 0, a: UInt64 = 255

        if cleaned.count == 6 {
            Scanner(string: String(cleaned.prefix(2))).scanHexInt64(&r)
            Scanner(string: String(cleaned.dropFirst(2).prefix(2))).scanHexInt64(&g)
            Scanner(string: String(cleaned.dropFirst(4).prefix(2))).scanHexInt64(&b)
        } else if cleaned.count == 8 {
            Scanner(string: String(cleaned.prefix(2))).scanHexInt64(&r)
            Scanner(string: String(cleaned.dropFirst(2).prefix(2))).scanHexInt64(&g)
            Scanner(string: String(cleaned.dropFirst(4).prefix(2))).scanHexInt64(&b)
            Scanner(string: String(cleaned.dropFirst(6).prefix(2))).scanHexInt64(&a)
        } else {
            return
        }

        isUpdatingFromPicker = true
        selectedColor = Color(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
        updateOtherFormatsFromColor(selectedColor, excluding: "hex")
        isUpdatingFromPicker = false
    }

    private func updateColorFromRGB(_ rgb: String) {
        guard !isUpdatingFromPicker else { return }
        let pattern = #"rgb\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: rgb, range: NSRange(rgb.startIndex..., in: rgb)),
              match.numberOfRanges == 4 else { return }

        let r = Int((rgb as NSString).substring(with: match.range(at: 1))) ?? 0
        let g = Int((rgb as NSString).substring(with: match.range(at: 2))) ?? 0
        let b = Int((rgb as NSString).substring(with: match.range(at: 3))) ?? 0

        isUpdatingFromPicker = true
        selectedColor = Color(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255)
        updateOtherFormatsFromColor(selectedColor, excluding: "rgb")
        isUpdatingFromPicker = false
    }

    private func updateColorFromRGBA(_ rgba: String) {
        guard !isUpdatingFromPicker else { return }
        let pattern = #"rgba\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*([\d.]+)\s*\)"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: rgba, range: NSRange(rgba.startIndex..., in: rgba)),
              match.numberOfRanges == 5 else { return }

        let r = Int((rgba as NSString).substring(with: match.range(at: 1))) ?? 0
        let g = Int((rgba as NSString).substring(with: match.range(at: 2))) ?? 0
        let b = Int((rgba as NSString).substring(with: match.range(at: 3))) ?? 0
        let a = Double((rgba as NSString).substring(with: match.range(at: 4))) ?? 1.0

        isUpdatingFromPicker = true
        selectedColor = Color(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: a)
        updateOtherFormatsFromColor(selectedColor, excluding: "rgba")
        isUpdatingFromPicker = false
    }

    private func updateColorFromHSL(_ hsl: String) {
        guard !isUpdatingFromPicker else { return }
        let pattern = #"hsl\s*\(\s*([\d.]+)\s*,\s*([\d.]+)%\s*,\s*([\d.]+)%\s*\)"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: hsl, range: NSRange(hsl.startIndex..., in: hsl)),
              match.numberOfRanges == 4 else { return }

        let h = Double((hsl as NSString).substring(with: match.range(at: 1))) ?? 0
        let s = (Double((hsl as NSString).substring(with: match.range(at: 2))) ?? 0) / 100
        let l = (Double((hsl as NSString).substring(with: match.range(at: 3))) ?? 0) / 100

        let (r, g, b) = hslToRGB(h: h, s: s, l: l)

        isUpdatingFromPicker = true
        selectedColor = Color(.sRGB, red: r, green: g, blue: b)
        updateOtherFormatsFromColor(selectedColor, excluding: "hsl")
        isUpdatingFromPicker = false
    }

    private func updateColorFromHSLA(_ hsla: String) {
        guard !isUpdatingFromPicker else { return }
        let pattern = #"hsla\s*\(\s*([\d.]+)\s*,\s*([\d.]+)%\s*,\s*([\d.]+)%\s*,\s*([\d.]+)\s*\)"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: hsla, range: NSRange(hsla.startIndex..., in: hsla)),
              match.numberOfRanges == 5 else { return }

        let h = Double((hsla as NSString).substring(with: match.range(at: 1))) ?? 0
        let s = (Double((hsla as NSString).substring(with: match.range(at: 2))) ?? 0) / 100
        let l = (Double((hsla as NSString).substring(with: match.range(at: 3))) ?? 0) / 100
        let a = Double((hsla as NSString).substring(with: match.range(at: 4))) ?? 1.0

        let (r, g, b) = hslToRGB(h: h, s: s, l: l)

        isUpdatingFromPicker = true
        selectedColor = Color(.sRGB, red: r, green: g, blue: b, opacity: a)
        updateOtherFormatsFromColor(selectedColor, excluding: "hsla")
        isUpdatingFromPicker = false
    }

    private func updateColorFromHSB(_ hsb: String) {
        guard !isUpdatingFromPicker else { return }
        let pattern = #"hsb\s*\(\s*([\d.]+)\s*,\s*([\d.]+)%\s*,\s*([\d.]+)%\s*\)"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: hsb, range: NSRange(hsb.startIndex..., in: hsb)),
              match.numberOfRanges == 4 else { return }

        let h = Double((hsb as NSString).substring(with: match.range(at: 1))) ?? 0
        let s = (Double((hsb as NSString).substring(with: match.range(at: 2))) ?? 0) / 100
        let b = (Double((hsb as NSString).substring(with: match.range(at: 3))) ?? 0) / 100

        let (r, g, bb) = hsbToRGB(h: h, s: s, b: b)

        isUpdatingFromPicker = true
        selectedColor = Color(.sRGB, red: r, green: g, blue: bb)
        updateOtherFormatsFromColor(selectedColor, excluding: "hsb")
        isUpdatingFromPicker = false
    }

    private func updateColorFromCMYK(_ cmyk: String) {
        guard !isUpdatingFromPicker else { return }
        let pattern = #"cmyk\s*\(\s*([\d.]+)%\s*,\s*([\d.]+)%\s*,\s*([\d.]+)%\s*,\s*([\d.]+)%\s*\)"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: cmyk, range: NSRange(cmyk.startIndex..., in: cmyk)),
              match.numberOfRanges == 5 else { return }

        let c = (Double((cmyk as NSString).substring(with: match.range(at: 1))) ?? 0) / 100
        let m = (Double((cmyk as NSString).substring(with: match.range(at: 2))) ?? 0) / 100
        let y = (Double((cmyk as NSString).substring(with: match.range(at: 3))) ?? 0) / 100
        let k = (Double((cmyk as NSString).substring(with: match.range(at: 4))) ?? 0) / 100

        let (r, g, b) = cmykToRGB(c: c, m: m, y: y, k: k)

        isUpdatingFromPicker = true
        selectedColor = Color(.sRGB, red: r, green: g, blue: b)
        updateOtherFormatsFromColor(selectedColor, excluding: "cmyk")
        isUpdatingFromPicker = false
    }

    // MARK: - Color Space Conversions

    private func rgbToHSL(r: Double, g: Double, b: Double) -> (h: Double, s: Double, l: Double) {
        let max = Swift.max(r, g, b)
        let min = Swift.min(r, g, b)
        let delta = max - min

        var h: Double = 0
        var s: Double = 0
        let l = (max + min) / 2

        if delta != 0 {
            s = l > 0.5 ? delta / (2 - max - min) : delta / (max + min)

            if max == r {
                h = ((g - b) / delta) + (g < b ? 6 : 0)
            } else if max == g {
                h = ((b - r) / delta) + 2
            } else {
                h = ((r - g) / delta) + 4
            }

            h *= 60
        }

        return (h, s, l)
    }

    private func hslToRGB(h: Double, s: Double, l: Double) -> (r: Double, g: Double, b: Double) {
        if s == 0 {
            return (l, l, l)
        }

        let q = l < 0.5 ? l * (1 + s) : l + s - l * s
        let p = 2 * l - q

        let hk = h / 360

        func hueToRGB(_ p: Double, _ q: Double, _ t: Double) -> Double {
            var tt = t
            if tt < 0 { tt += 1 }
            if tt > 1 { tt -= 1 }
            if tt < 1/6 { return p + (q - p) * 6 * tt }
            if tt < 1/2 { return q }
            if tt < 2/3 { return p + (q - p) * (2/3 - tt) * 6 }
            return p
        }

        let r = hueToRGB(p, q, hk + 1/3)
        let g = hueToRGB(p, q, hk)
        let b = hueToRGB(p, q, hk - 1/3)

        return (r, g, b)
    }

    private func rgbToHSB(r: Double, g: Double, b: Double) -> (h: Double, s: Double, b: Double) {
        let max = Swift.max(r, g, b)
        let min = Swift.min(r, g, b)
        let delta = max - min

        var h: Double = 0
        let s: Double = max == 0 ? 0 : delta / max
        let brightness = max

        if delta != 0 {
            if max == r {
                h = ((g - b) / delta) + (g < b ? 6 : 0)
            } else if max == g {
                h = ((b - r) / delta) + 2
            } else {
                h = ((r - g) / delta) + 4
            }

            h *= 60
        }

        return (h, s, brightness)
    }

    private func hsbToRGB(h: Double, s: Double, b: Double) -> (r: Double, g: Double, b: Double) {
        let c = b * s
        let x = c * (1 - abs((h / 60).truncatingRemainder(dividingBy: 2) - 1))
        let m = b - c

        var r: Double = 0, g: Double = 0, bb: Double = 0

        if h < 60 {
            r = c; g = x; bb = 0
        } else if h < 120 {
            r = x; g = c; bb = 0
        } else if h < 180 {
            r = 0; g = c; bb = x
        } else if h < 240 {
            r = 0; g = x; bb = c
        } else if h < 300 {
            r = x; g = 0; bb = c
        } else {
            r = c; g = 0; bb = x
        }

        return (r + m, g + m, bb + m)
    }

    private func rgbToCMYK(r: Double, g: Double, b: Double) -> (c: Double, m: Double, y: Double, k: Double) {
        let k = 1 - Swift.max(r, g, b)

        if k == 1 {
            return (0, 0, 0, 1)
        }

        let c = (1 - r - k) / (1 - k)
        let m = (1 - g - k) / (1 - k)
        let y = (1 - b - k) / (1 - k)

        return (c, m, y, k)
    }

    private func cmykToRGB(c: Double, m: Double, y: Double, k: Double) -> (r: Double, g: Double, b: Double) {
        let r = (1 - c) * (1 - k)
        let g = (1 - m) * (1 - k)
        let b = (1 - y) * (1 - k)

        return (r, g, b)
    }

    // MARK: - State Persistence

    private func saveState() {
        let defaults = UserDefaults.standard
        defaults.set(hexValue, forKey: "ColorPicker.hexValue")

        // Save color history (already as hex strings)
        defaults.set(colorHistory, forKey: "ColorPicker.history")
    }

    private func loadState() {
        let defaults = UserDefaults.standard

        if let savedHex = defaults.string(forKey: "ColorPicker.hexValue"), !savedHex.isEmpty {
            hexValue = savedHex
            updateColorFromHex(savedHex)
        } else {
            updateAllFormatsFromColor(selectedColor)
        }

        // Load color history (already as hex strings)
        if let historyHexValues = defaults.stringArray(forKey: "ColorPicker.history") {
            colorHistory = historyHexValues
        }
    }
}

#Preview {
    ColorPickerView()
}
