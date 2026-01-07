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
import AppKit
import CryptoKit
import Foundation

enum JWTTab: String, CaseIterable {
    case encode = "encode"
    case decode = "decode"
    
    var title: String {
        switch self {
        case .encode:
            return "Encode"
        case .decode:
            return "Decode"
        }
    }
}

enum JWTAlgorithm: String, CaseIterable {
    case hs256 = "HS256"
    case hs384 = "HS384"
    case hs512 = "HS512"
    case rs256 = "RS256"
    case rs384 = "RS384"
    case rs512 = "RS512"
    case none = "none"
    
    var title: String {
        return self.rawValue
    }
    
    var isRSA: Bool {
        switch self {
        case .rs256, .rs384, .rs512:
            return true
        default:
            return false
        }
    }
    
    var isHMAC: Bool {
        switch self {
        case .hs256, .hs384, .hs512:
            return true
        default:
            return false
        }
    }
}

struct JWTView: View {
    let screenName = "JWT Encoder/Decoder"
    let module = "jwt_codec"
    @State private var selectedTab: JWTTab = .decode
    @State private var jwtToken: String = ""
    @State private var headerText: String = ""
    @State private var payloadText: String = ""
    @State private var signatureText: String = ""
    @State private var secretKey: String = "your-256-bit-secret"
    @State private var privateKey: String = ""
    @State private var publicKey: String = ""
    @State private var isValidSignature: Bool = false
    @State private var selectedAlgorithm: JWTAlgorithm = .hs256
    @State private var errorMessage: String = ""
    @State private var encodedJWT: String = ""
    
    // Sample JWT with known secret key
    private let sampleJWT = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"
    private let sampleSecretKey = "your-256-bit-secret"
    
    // Sample RSA key pair for testing
    private let sampleRSAPrivateKey = """
    -----BEGIN RSA PRIVATE KEY-----
    MIIEpQIBAAKCAQEAzT/5NnNPBYrhbnwpU8ERvePPKC5R+BwG1rxexCCW5486FElP
    A97SlnRFc4rW3RlaE554pPZ++VI3iHJMZ7bSzTX+QNZXQT4zlIgF1hifMKB9N1zU
    nXJuxtEgF0gyooWnnuXS6G8NEJWLeQLtdR4wOD5O33HQkO936zxtG3rXrZjDTjO2
    i+sxvn012bicWtufN7WzFw8TB5G1uVdJClJjte4KrtAE/YHLAuUNZm2j4cqKBOu2
    bITIPyFG4XmL+upZdQyD2KL0WzSeH9upoXkpPrHrCXp8uWxZ7tkEl76sQPRQCKjS
    Zk2SnDaaD3nq/A0cF+YKrgmkUR8oaHpO8ZOKlQIDAQABAoIBAFvizXNSeOh+zcBU
    Jn4/22z63SVcY0bjaS5eI0DDZDtjM/mb/hs5+GXxxJve5qUR8fEBi3oyfhKo+4KC
    xPDTeJj1GI+3RVXIfnf60z4PRMkUuCn+TZL1BWHNgoPZxw1aL3nj4qE7AgrQICH7
    LQo3CxhK0K2Yuun/wtxVb3UTcBXfFdn7DhHn+UiNnMRxHcdLYvFDmxrAqhMgr6mu
    6Phfou6xlyTsWB+al5eAxkylFgg8Ulk4g7vIy4GCmIrbwLYerNp3m7TqxhGe2Vym
    WciysjeN/XKz4C/6gmMmaA/P89vto3kwtbuT040BUi2tzCUYJvNs/kG6sOc7o1mH
    uOzJ8nsCgYEA2SuikNhHak0lx7eofeEYzSeRvXo2bpXJDxeEVKJotye2JqAYL682
    pjiVjhUkMSea2w9/v5J1VtRaoU3aN6Z3oXIXRqKMaXG+HpiCH09jR7CtVpSglyps
    E/sV/QhmN8vSR59pY/LfFtxTOiDb+XyVOzRT3Y0nImt43AqdDJYUmosCgYEA8fK1
    cdTdqFlypF2Uh67yC4BU7GHlFPyrLrytCpVgMYCN2Lf6hpS9p5etkEsnZ4Dp7D3O
    B6VJ40pF12Y4qlDZkNZjhdQZ/35UC8FXbwbsunDXs1n+7I/hcFAUKmB8RXagALv2
    nS1vgwqH881WnmkvbkZ4T/9rOIVqmAGKMGZ9s18CgYEAiOH0CZAJE3ulAIlGbnFf
    DJCQT/mkLXfDzvtnsWDc1/Tz3syx8fxiWcr4mSHCOilYdhMC1mEeDKi0p09G6CTI
    6r3a5e62yg+jYe2Gtu13CkzWNOhhgGaA0OdGKMMOisSxuetEpncDHomo+86SWGKq
    PTLyWYcKz6sl9qvJ6ZD/U5kCgYEAr/2i/A0hus5ttJ+ZZeTcjX8oxtUipFRyVEnL
    +RHU6c0f4M9avUA+gES1bGsuW3yLK1t9nVQe3eTtzpO9ji3HRDKeK/+vdYg3rGFT
    ryAzXB6u1/gTlZHHI0IsmPKcEo8KLd6LsaMWJRSo9a+cXRgX9zftVgttu6xYb/9W
    vIQg1TMCgYEA1FpBKeQdjI8JNaxeZWwA06Fr3Al8OhjkFpxW7veCCCzNW6Y2vH34
    pBQFqC41Ao2YPsRyB8abn3BHpcq09vLvZjnKtoyTzDOlZfkpeQxv1D1gqHcQjexV
    MHGb/3fFzS0sPLCYSq/hNp4SF2cAgz4rJd7VTMC/4rzMnJOtTPO9Jzc=
    -----END RSA PRIVATE KEY-----
    """
    
    private let sampleRSAPublicKey = """
    -----BEGIN PUBLIC KEY-----
    MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAzT/5NnNPBYrhbnwpU8ER
    vePPKC5R+BwG1rxexCCW5486FElPA97SlnRFc4rW3RlaE554pPZ++VI3iHJMZ7bS
    zTX+QNZXQT4zlIgF1hifMKB9N1zUnXJuxtEgF0gyooWnnuXS6G8NEJWLeQLtdR4w
    OD5O33HQkO936zxtG3rXrZjDTjO2i+sxvn012bicWtufN7WzFw8TB5G1uVdJClJj
    te4KrtAE/YHLAuUNZm2j4cqKBOu2bITIPyFG4XmL+upZdQyD2KL0WzSeH9upoXkp
    PrHrCXp8uWxZ7tkEl76sQPRQCKjSZk2SnDaaD3nq/A0cF+YKrgmkUR8oaHpO8ZOK
    lQIDAQAB
    -----END PUBLIC KEY-----
    """
    
    private let defaultHeader = """
    {
      "alg": "HS256",
      "typ": "JWT"
    }
    """
    
    private let defaultPayload = """
    {
      "sub": "1234567890",
      "name": "John Doe",
      "iat": 1516239022
    }
    """
    
    var body: some View {
        VStack(spacing: 20) {
            Picker("Mode", selection: $selectedTab) {
                ForEach(JWTTab.allCases, id: \.self) { tab in
                    Text(tab.title)
                        .tag(tab)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            if selectedTab == .decode {
                decodeView
            } else {
                encodeView
            }
        }
        .padding()
        .navigationTitle("\(screenName)")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: selectedTab) { oldValue, newValue in
            Task.detached {
                await EventManager.shared.reportSubmoduleSwitch(
                    module: module,
                    from: oldValue.rawValue,
                    to: newValue.rawValue
                )
            }
        }
    }
    
    private var encodeView: some View {
        VStack(spacing: 20) {
            HStack(alignment: .top, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Algorithm")
                                .font(.headline)
                            Spacer()
                            Picker("", selection: $selectedAlgorithm) {
                                ForEach(JWTAlgorithm.allCases, id: \.self) { alg in
                                    Text(alg.title).tag(alg)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 100)
                            .onChange(of: selectedAlgorithm) { _, _ in
                                updateHeaderAlgorithm()
                                if selectedAlgorithm.isRSA && privateKey.isEmpty {
                                    privateKey = sampleRSAPrivateKey
                                    publicKey = sampleRSAPublicKey
                                }
                                encodeJWT()
                            }
                        }
                        
                        HStack {
                            Text("Header")
                                .font(.headline)
                            Spacer()
                            Button("Default") {
                                headerText = defaultHeader
                                encodeJWT()
                            }
                            .buttonStyle(.borderless)
                        }
                        
                        TextEditor(text: $headerText)
                            .font(.system(.body, design: .monospaced))
                            .padding(5)
                            .frame(maxHeight: .infinity)
                            .onChange(of: headerText) { _, _ in
                                encodeJWT()
                            }
                    }
                    .frame(maxHeight: .infinity)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Payload")
                                .font(.headline)
                            Spacer()
                            Button("Default") {
                                payloadText = defaultPayload
                                encodeJWT()
                            }
                            .buttonStyle(.borderless)
                        }
                        
                        TextEditor(text: $payloadText)
                            .font(.system(.body, design: .monospaced))
                            .padding(5)
                            .frame(maxHeight: .infinity)
                            .onChange(of: payloadText) { _, _ in
                                encodeJWT()
                            }
                    }
                    .frame(maxHeight: .infinity)
                    
                    if selectedAlgorithm != .none {
                        if selectedAlgorithm.isHMAC {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Secret Key")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                TextField("Secret key", text: $secretKey)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .onChange(of: secretKey) { _, _ in
                                        encodeJWT()
                                    }
                            }
                        } else if selectedAlgorithm.isRSA {
                            VStack(alignment: .leading, spacing: 10) {
                                VStack(alignment: .leading, spacing: 5) {
                                    HStack {
                                        Text("Private Key (for signing)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Button("Use Sample") {
                                            privateKey = sampleRSAPrivateKey
                                            publicKey = sampleRSAPublicKey
                                            encodeJWT()
                                        }
                                        .buttonStyle(.borderless)
                                        .font(.caption)
                                    }
                                    
                                    TextEditor(text: $privateKey)
                                        .font(.system(.caption, design: .monospaced))
                                        .frame(height: 80)
                                        .onChange(of: privateKey) { _, _ in
                                            encodeJWT()
                                        }
                                }
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Public Key (for verification)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    TextEditor(text: $publicKey)
                                        .font(.system(.caption, design: .monospaced))
                                        .frame(height: 80)
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                
                Image(systemName: "arrow.right")
                    .font(.title)
                    .foregroundColor(.blue)
                    .frame(maxHeight: .infinity, alignment: .center)
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Encoded JWT")
                            .font(.headline)
                        Spacer()
                        Button("Copy") {
                            copyToClipboard(encodedJWT)
                        }
                        .buttonStyle(.borderless)
                        .disabled(encodedJWT.isEmpty)
                    }
                    
                    ScrollView {
                        Text(encodedJWT.isEmpty ? "Encoded JWT will appear here" : encodedJWT)
                            .font(.system(.body, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                    }
                    .padding(5)
                    .frame(maxHeight: .infinity)
                    .background(AppConstants.lightGrayBackground)
                    .cornerRadius(8)
                    
                    if !encodedJWT.isEmpty {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Token Structure:")
                                .font(.caption)
                                .fontWeight(.medium)
                            
                            let parts = encodedJWT.split(separator: ".")
                            if parts.count >= 1 {
                                HStack(spacing: 5) {
                                    Circle().fill(Color.red.opacity(0.5)).frame(width: 8, height: 8)
                                    Text("Header: \(parts[0].prefix(40))...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                            }
                            if parts.count >= 2 {
                                HStack(spacing: 5) {
                                    Circle().fill(Color.purple.opacity(0.5)).frame(width: 8, height: 8)
                                    Text("Payload: \(parts[1].prefix(40))...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                            }
                            if parts.count >= 3 && selectedAlgorithm != .none {
                                HStack(spacing: 5) {
                                    Circle().fill(Color.blue.opacity(0.5)).frame(width: 8, height: 8)
                                    Text("Signature: \(parts[2].prefix(40))...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .onAppear {
            if headerText.isEmpty {
                headerText = defaultHeader
            }
            if payloadText.isEmpty {
                payloadText = defaultPayload
            }
            encodeJWT()
        }
    }
    

    private var decodeView: some View {
        VStack(spacing: 20) {
            HStack(alignment: .top, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("JWT Token")
                            .font(.headline)
                        Spacer()
                        Button("Sample") {
                            jwtToken = sampleJWT
                            secretKey = sampleSecretKey
                            decodeJWT()
                        }
                        .buttonStyle(.borderless)
                        Button("Paste") {
                            if let clipboardContent = NSPasteboard.general.string(forType: .string) {
                                jwtToken = clipboardContent
                                decodeJWT()
                            }
                        }
                        .buttonStyle(.borderless)
                        Button("Clear") {
                            clearDecode()
                        }
                        .buttonStyle(.borderless)
                    }
                    
                    TextEditor(text: $jwtToken)
                        .font(.system(.body, design: .monospaced))
                        .padding(5)
                        .frame(maxHeight: .infinity)
                        .onChange(of: jwtToken) { _, _ in
                            decodeJWT()
                        }
                    
                    // Get algorithm from token to show appropriate key input
                    let tokenAlgorithm = getAlgorithmFromToken()
                    
                    if tokenAlgorithm?.isHMAC == true || tokenAlgorithm == nil {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Secret Key (for signature verification)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                TextField("Secret key", text: $secretKey)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .onChange(of: secretKey) { _, _ in
                                        if !jwtToken.isEmpty {
                                            verifySignature()
                                        }
                                    }
                                
                                if !jwtToken.isEmpty {
                                    Image(systemName: isValidSignature ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(isValidSignature ? .green : .red)
                                        .help(isValidSignature ? "Signature Valid" : "Signature Invalid")
                                }
                            }
                        }
                    } else if tokenAlgorithm?.isRSA == true {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Public Key (for signature verification)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            VStack {
                                TextEditor(text: $publicKey)
                                    .font(.system(.caption, design: .monospaced))
                                    .frame(height: 80)
                                    .onChange(of: publicKey) { _, _ in
                                        if !jwtToken.isEmpty {
                                            verifySignature()
                                        }
                                    }
                                
                                HStack {
                                    Spacer()
                                    if !jwtToken.isEmpty {
                                        Image(systemName: isValidSignature ? "checkmark.circle.fill" : "xmark.circle.fill")
                                            .foregroundColor(isValidSignature ? .green : .red)
                                            .help(isValidSignature ? "Signature Valid" : "Signature Invalid")
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                
                Image(systemName: "arrow.right")
                    .font(.title)
                    .foregroundColor(.blue)
                    .frame(maxHeight: .infinity, alignment: .center)
                
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Header")
                                .font(.headline)
                            Spacer()
                            Button("Copy") {
                                copyToClipboard(headerText)
                            }
                            .buttonStyle(.borderless)
                            .disabled(headerText.isEmpty)
                        }
                        
                        ScrollView {
                            Text(headerText.isEmpty ? "Header will appear here" : headerText)
                                .font(.system(.body, design: .monospaced))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .textSelection(.enabled)
                        }
                        .padding(5)
                        .frame(maxHeight: .infinity)
                        .background(AppConstants.lightGrayBackground)
                        .cornerRadius(8)
                    }
                    .frame(maxHeight: .infinity)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text("Payload")
                                .font(.headline)
                            Spacer()
                            Button("Copy") {
                                copyToClipboard(payloadText)
                            }
                            .buttonStyle(.borderless)
                            .disabled(payloadText.isEmpty)
                        }
                        
                        ScrollView {
                            Text(payloadText.isEmpty ? "Payload will appear here" : payloadText)
                                .font(.system(.body, design: .monospaced))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .textSelection(.enabled)
                        }
                        .padding(5)
                        .frame(maxHeight: .infinity)
                        .background(AppConstants.lightGrayBackground)
                        .cornerRadius(8)
                    }
                    .frame(maxHeight: .infinity)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text("Signature")
                                .font(.headline)
                            Spacer()
                            Button("Copy") {
                                copyToClipboard(signatureText)
                            }
                            .buttonStyle(.borderless)
                            .disabled(signatureText.isEmpty)
                        }
                        
                        ScrollView {
                            Text(signatureText.isEmpty ? "Signature will appear here" : signatureText)
                                .font(.system(.body, design: .monospaced))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .textSelection(.enabled)
                        }
                        .padding(5)
                        .frame(height: 60)
                        .background(AppConstants.lightGrayBackground)
                        .cornerRadius(8)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private func decodeJWT() {
        errorMessage = ""
        guard !jwtToken.isEmpty else {
            clearDecodeResults()
            return
        }
        
        let parts = jwtToken.split(separator: ".")
        guard parts.count >= 2 else {
            errorMessage = "Invalid JWT format. Expected header.payload.signature"
            clearDecodeResults()
            return
        }
        
        // Decode header
        if let headerData = base64URLDecode(String(parts[0])),
           let headerJSON = try? JSONSerialization.jsonObject(with: headerData, options: []) as? [String: Any],
           let headerFormatted = try? JSONSerialization.data(withJSONObject: headerJSON, options: [.prettyPrinted, .sortedKeys]),
           let headerString = String(data: headerFormatted, encoding: .utf8) {
            headerText = headerString
        } else {
            headerText = "Error decoding header"
        }
        
        // Decode payload
        if let payloadData = base64URLDecode(String(parts[1])),
           let payloadJSON = try? JSONSerialization.jsonObject(with: payloadData, options: []) as? [String: Any],
           let payloadFormatted = try? JSONSerialization.data(withJSONObject: payloadJSON, options: [.prettyPrinted, .sortedKeys]),
           let payloadString = String(data: payloadFormatted, encoding: .utf8) {
            payloadText = payloadString
        } else {
            payloadText = "Error decoding payload"
        }
        
        // Display signature
        if parts.count >= 3 {
            signatureText = String(parts[2])
            verifySignature()
        } else {
            signatureText = "No signature (unsigned token)"
            isValidSignature = false
        }
    }
    
    private func encodeJWT() {
        errorMessage = ""
        encodedJWT = ""
        
        // Validate and encode header
        guard let headerData = headerText.data(using: .utf8),
              let _ = try? JSONSerialization.jsonObject(with: headerData, options: []) else {
            errorMessage = "Invalid JSON in header"
            return
        }
        
        // Validate and encode payload
        guard let payloadData = payloadText.data(using: .utf8),
              let _ = try? JSONSerialization.jsonObject(with: payloadData, options: []) else {
            errorMessage = "Invalid JSON in payload"
            return
        }
        
        let encodedHeader = base64URLEncode(headerData)
        let encodedPayload = base64URLEncode(payloadData)
        
        if selectedAlgorithm == .none {
            encodedJWT = "\(encodedHeader).\(encodedPayload)"
        } else {
            let signingInput = "\(encodedHeader).\(encodedPayload)"
            
            guard let signature = createSignature(signingInput: signingInput, secret: secretKey, algorithm: selectedAlgorithm) else {
                errorMessage = "Failed to create signature"
                return
            }
            
            encodedJWT = "\(signingInput).\(signature)"
        }
    }
    
    private func verifySignature() {
        let parts = jwtToken.split(separator: ".")
        guard parts.count >= 3 else {
            isValidSignature = false
            return
        }
        
        // Get algorithm from header
        guard let headerData = base64URLDecode(String(parts[0])),
              let headerJSON = try? JSONSerialization.jsonObject(with: headerData, options: []) as? [String: Any],
              let algString = headerJSON["alg"] as? String else {
            isValidSignature = false
            return
        }
        
        guard let algorithm = JWTAlgorithm(rawValue: algString) else {
            isValidSignature = false
            return
        }
        
        if algorithm == .none {
            isValidSignature = parts.count == 2 || (parts.count == 3 && parts[2].isEmpty)
            return
        }
        
        let signingInput = "\(parts[0]).\(parts[1])"
        let providedSignature = String(parts[2])
        
        if algorithm.isHMAC {
            if let expectedSignature = createSignature(signingInput: signingInput, secret: secretKey, algorithm: algorithm) {
                isValidSignature = expectedSignature == providedSignature
            } else {
                isValidSignature = false
            }
        } else if algorithm.isRSA {
            guard let signingData = signingInput.data(using: .utf8),
                  let signatureData = base64URLDecode(providedSignature) else {
                isValidSignature = false
                return
            }
            
            isValidSignature = verifyRSASignature(data: signingData, signature: signatureData, publicKey: publicKey, algorithm: algorithm)
        } else {
            isValidSignature = false
        }
    }
    
    private func createSignature(signingInput: String, secret: String, algorithm: JWTAlgorithm) -> String? {
        guard let signingData = signingInput.data(using: .utf8) else {
            return nil
        }
        
        let signature: Data
        
        switch algorithm {
        case .hs256, .hs384, .hs512:
            guard let keyData = secret.data(using: .utf8) else {
                return nil
            }
            let key = SymmetricKey(data: keyData)
            
            switch algorithm {
            case .hs256:
                signature = Data(HMAC<SHA256>.authenticationCode(for: signingData, using: key))
            case .hs384:
                signature = Data(HMAC<SHA384>.authenticationCode(for: signingData, using: key))
            case .hs512:
                signature = Data(HMAC<SHA512>.authenticationCode(for: signingData, using: key))
            default:
                return nil
            }
            
        case .rs256, .rs384, .rs512:
            guard let rsaSignature = createRSASignature(data: signingData, privateKey: privateKey, algorithm: algorithm) else {
                return nil
            }
            signature = rsaSignature
            
        case .none:
            return ""
        }
        
        return base64URLEncode(signature)
    }
    
    private func updateHeaderAlgorithm() {
        guard let headerData = headerText.data(using: .utf8),
              var headerJSON = try? JSONSerialization.jsonObject(with: headerData, options: []) as? [String: Any] else {
            return
        }
        
        headerJSON["alg"] = selectedAlgorithm.rawValue
        
        if let updatedData = try? JSONSerialization.data(withJSONObject: headerJSON, options: [.prettyPrinted, .sortedKeys]),
           let updatedString = String(data: updatedData, encoding: .utf8) {
            headerText = updatedString
        }
    }
    
    private func base64URLEncode(_ data: Data) -> String {
        return data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
    
    private func base64URLDecode(_ string: String) -> Data? {
        var base64 = string
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        // Add padding if needed
        let remainder = base64.count % 4
        if remainder > 0 {
            base64.append(String(repeating: "=", count: 4 - remainder))
        }
        
        return Data(base64Encoded: base64)
    }
    
    private func clearDecode() {
        jwtToken = ""
        headerText = ""
        payloadText = ""
        signatureText = ""
        isValidSignature = false
        errorMessage = ""
    }
    
    private func clearDecodeResults() {
        headerText = ""
        payloadText = ""
        signatureText = ""
        isValidSignature = false
    }
    
    private func createRSASignature(data: Data, privateKey: String, algorithm: JWTAlgorithm) -> Data? {
        guard let keyData = parsePEMKey(privateKey) else {
            return nil
        }
        
        let keyDict: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate
        ]
        
        var error: Unmanaged<CFError>?
        guard let secKey = SecKeyCreateWithData(keyData as CFData, keyDict as CFDictionary, &error) else {
            return nil
        }
        
        let signatureAlgorithm: SecKeyAlgorithm
        switch algorithm {
        case .rs256:
            signatureAlgorithm = .rsaSignatureMessagePKCS1v15SHA256
        case .rs384:
            signatureAlgorithm = .rsaSignatureMessagePKCS1v15SHA384
        case .rs512:
            signatureAlgorithm = .rsaSignatureMessagePKCS1v15SHA512
        default:
            return nil
        }
        
        guard let signature = SecKeyCreateSignature(secKey, signatureAlgorithm, data as CFData, &error) else {
            return nil
        }
        
        return signature as Data
    }
    
    private func verifyRSASignature(data: Data, signature: Data, publicKey: String, algorithm: JWTAlgorithm) -> Bool {
        guard let keyData = parsePEMKey(publicKey) else {
            return false
        }
        
        let keyDict: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic
        ]
        
        var error: Unmanaged<CFError>?
        guard let secKey = SecKeyCreateWithData(keyData as CFData, keyDict as CFDictionary, &error) else {
            return false
        }
        
        let signatureAlgorithm: SecKeyAlgorithm
        switch algorithm {
        case .rs256:
            signatureAlgorithm = .rsaSignatureMessagePKCS1v15SHA256
        case .rs384:
            signatureAlgorithm = .rsaSignatureMessagePKCS1v15SHA384
        case .rs512:
            signatureAlgorithm = .rsaSignatureMessagePKCS1v15SHA512
        default:
            return false
        }
        
        return SecKeyVerifySignature(secKey, signatureAlgorithm, data as CFData, signature as CFData, &error)
    }
    
    private func parsePEMKey(_ pemString: String) -> Data? {
        let lines = pemString.components(separatedBy: .newlines)
        let base64Lines = lines.filter { line in
            !line.hasPrefix("-----") && !line.isEmpty
        }
        
        let base64String = base64Lines.joined()
        return Data(base64Encoded: base64String)
    }
    
    private func getAlgorithmFromToken() -> JWTAlgorithm? {
        let parts = jwtToken.split(separator: ".")
        guard parts.count >= 2,
              let headerData = base64URLDecode(String(parts[0])),
              let headerJSON = try? JSONSerialization.jsonObject(with: headerData, options: []) as? [String: Any],
              let algString = headerJSON["alg"] as? String else {
            return nil
        }
        return JWTAlgorithm(rawValue: algString)
    }
    
    private func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}

#Preview {
    JWTView()
}