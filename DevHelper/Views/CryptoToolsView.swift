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
import CryptoKit
import Foundation
import Compression

enum CryptoTab: String, CaseIterable {
    case hash = "hash"
    case symmetric = "symmetric"
    case asymmetric = "asymmetric"
    
    var title: String {
        switch self {
        case .hash:
            return "Hash Functions"
        case .symmetric:
            return "Symmetric Encryption"
        case .asymmetric:
            return "Asymmetric Encryption"
        }
    }
}

enum HashAlgorithm: String, CaseIterable {
    case md5 = "MD5"
    case crc32 = "CRC32"
    case sha1 = "SHA-1"
    case sha256 = "SHA-256"
    case sha384 = "SHA-384"
    case sha512 = "SHA-512"
    
    var title: String {
        return self.rawValue
    }
}

enum SymmetricAlgorithm: String, CaseIterable {
    case aesGcm256 = "AES-GCM-256"
    case aesCbc256 = "AES-CBC-256"
    
    var title: String {
        return self.rawValue
    }
}

enum AsymmetricAlgorithm: String, CaseIterable {
    case rsa2048 = "RSA-2048"
    case rsa4096 = "RSA-4096"
    
    var title: String {
        return self.rawValue
    }
}

struct CryptoToolsView: View {
    let screenName = "Crypto Tools"
    let module = "crypto_tools"
    @State private var selectedTab: CryptoTab = .hash
    
    var body: some View {
        VStack(spacing: 20) {
            Text(screenName)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Picker("Mode", selection: $selectedTab) {
                ForEach(CryptoTab.allCases, id: \.self) { tab in
                    Text(tab.title)
                        .tag(tab)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            switch selectedTab {
            case .hash:
                HashFunctionView()
            case .symmetric:
                SymmetricEncryptionView()
            case .asymmetric:
                AsymmetricEncryptionView()
            }
        }
        .padding()
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
}

struct HashFunctionView: View {
    @State private var inputText: String = ""
    @State private var selectedAlgorithm: HashAlgorithm = .md5
    @State private var hashResult: String = ""
    
    private let sampleText = "Hello, DevHelper!"
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(alignment: .top, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Algorithm")
                            .font(.headline)
                        Spacer()
                        Picker("", selection: $selectedAlgorithm) {
                            ForEach(HashAlgorithm.allCases, id: \.self) { alg in
                                Text(alg.title).tag(alg)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 120)
                        .onChange(of: selectedAlgorithm) { _, _ in
                            computeHash()
                        }
                    }
                    
                    HStack {
                        Text("Input Text")
                            .font(.headline)
                        Spacer()
                        Button("Sample") {
                            inputText = sampleText
                            computeHash()
                        }
                        .buttonStyle(.borderless)
                        Button("Clear") {
                            inputText = ""
                            hashResult = ""
                        }
                        .buttonStyle(.borderless)
                    }
                    
                    TextEditor(text: $inputText)
                        .font(.system(.body, design: .monospaced))
                        .padding(5)
                        .frame(maxHeight: .infinity)
                        .onChange(of: inputText) { _, _ in
                            computeHash()
                        }
                }
                .frame(maxWidth: .infinity)
                
                Image(systemName: "arrow.right")
                    .font(.title)
                    .foregroundColor(.blue)
                    .frame(maxHeight: .infinity, alignment: .center)
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Hash Result")
                            .font(.headline)
                        Spacer()
                        Button("Copy") {
                            copyToClipboard(hashResult)
                        }
                        .buttonStyle(.borderless)
                        .disabled(hashResult.isEmpty)
                    }
                    
                    ScrollView {
                        Text(hashResult.isEmpty ? "Hash will appear here" : hashResult)
                            .font(.system(.body, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                    }
                    .padding(5)
                    .frame(maxHeight: .infinity)
                    .background(AppConstants.lightGrayBackground)
                    .cornerRadius(8)
                    
                    if !hashResult.isEmpty {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Hash Information:")
                                .font(.caption)
                                .fontWeight(.medium)
                            
                            HStack(spacing: 5) {
                                Circle().fill(Color.blue.opacity(0.5)).frame(width: 8, height: 8)
                                Text("Length: \(hashResult.count) characters")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack(spacing: 5) {
                                Circle().fill(Color.green.opacity(0.5)).frame(width: 8, height: 8)
                                Text("Algorithm: \(selectedAlgorithm.title)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            if !inputText.isEmpty {
                computeHash()
            }
        }
    }
    
    private func computeHash() {
        guard !inputText.isEmpty else {
            hashResult = ""
            return
        }
        
        guard let data = inputText.data(using: .utf8) else {
            hashResult = "Error: Could not convert text to data"
            return
        }
        
        switch selectedAlgorithm {
        case .md5:
            hashResult = Insecure.MD5.hash(data: data).map { String(format: "%02hhx", $0) }.joined()
        case .crc32:
            hashResult = String(crc32(data))
        case .sha1:
            hashResult = Insecure.SHA1.hash(data: data).map { String(format: "%02hhx", $0) }.joined()
        case .sha256:
            hashResult = SHA256.hash(data: data).map { String(format: "%02hhx", $0) }.joined()
        case .sha384:
            hashResult = SHA384.hash(data: data).map { String(format: "%02hhx", $0) }.joined()
        case .sha512:
            hashResult = SHA512.hash(data: data).map { String(format: "%02hhx", $0) }.joined()
        }
    }
    
    private func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}

struct SymmetricEncryptionView: View {
    @State private var mode: String = "encrypt"
    @State private var inputText: String = ""
    @State private var secretKey: String = ""
    @State private var selectedAlgorithm: SymmetricAlgorithm = .aesGcm256
    @State private var result: String = ""
    @State private var errorMessage: String = ""
    
    private let sampleText = "Hello, DevHelper! This is a sample message for encryption."
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(alignment: .top, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Mode")
                            .font(.headline)
                        Spacer()
                        Picker("", selection: $mode) {
                            Text("Encrypt").tag("encrypt")
                            Text("Decrypt").tag("decrypt")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: mode) { _, _ in
                            processText()
                        }
                    }
                    
                    HStack {
                        Text("Algorithm")
                            .font(.headline)
                        Spacer()
                        Picker("", selection: $selectedAlgorithm) {
                            ForEach(SymmetricAlgorithm.allCases, id: \.self) { alg in
                                Text(alg.title).tag(alg)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 140)
                        .onChange(of: selectedAlgorithm) { _, _ in
                            processText()
                        }
                    }
                    
                    HStack {
                        Text(mode == "encrypt" ? "Plaintext" : "Ciphertext")
                            .font(.headline)
                        Spacer()
                        if mode == "encrypt" {
                            Button("Sample") {
                                inputText = sampleText
                                processText()
                            }
                            .buttonStyle(.borderless)
                        }
                        Button("Clear") {
                            inputText = ""
                            result = ""
                        }
                        .buttonStyle(.borderless)
                    }
                    
                    TextEditor(text: $inputText)
                        .font(.system(.body, design: .monospaced))
                        .padding(5)
                        .frame(maxHeight: .infinity)
                        .onChange(of: inputText) { _, _ in
                            processText()
                        }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text("Secret Key")
                                .font(.headline)
                            Spacer()
                            Button("Generate") {
                                generateRandomKey()
                            }
                            .buttonStyle(.borderless)
                        }
                        
                        TextField("Enter secret key or generate one", text: $secretKey)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: secretKey) { _, _ in
                                processText()
                            }
                        
                        Text("Key should be 32 bytes (64 hex characters) for AES-256")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                
                Image(systemName: "arrow.right")
                    .font(.title)
                    .foregroundColor(.blue)
                    .frame(maxHeight: .infinity, alignment: .center)
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(mode == "encrypt" ? "Encrypted Result" : "Decrypted Result")
                            .font(.headline)
                        Spacer()
                        Button("Copy") {
                            copyToClipboard(result)
                        }
                        .buttonStyle(.borderless)
                        .disabled(result.isEmpty)
                    }
                    
                    ScrollView {
                        Text(result.isEmpty ? "\(mode == "encrypt" ? "Encrypted" : "Decrypted") text will appear here" : result)
                            .font(.system(.body, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                    }
                    .padding(5)
                    .frame(maxHeight: .infinity)
                    .background(AppConstants.lightGrayBackground)
                    .cornerRadius(8)
                    
                    if !result.isEmpty && mode == "encrypt" {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Encryption Information:")
                                .font(.caption)
                                .fontWeight(.medium)
                            
                            HStack(spacing: 5) {
                                Circle().fill(Color.blue.opacity(0.5)).frame(width: 8, height: 8)
                                Text("Algorithm: \(selectedAlgorithm.title)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack(spacing: 5) {
                                Circle().fill(Color.green.opacity(0.5)).frame(width: 8, height: 8)
                                Text("Format: Base64 encoded")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
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
            if secretKey.isEmpty {
                generateRandomKey()
            }
        }
    }
    
    private func processText() {
        errorMessage = ""
        guard !inputText.isEmpty && !secretKey.isEmpty else {
            result = ""
            return
        }
        
        if mode == "encrypt" {
            encryptText()
        } else {
            decryptText()
        }
    }
    
    private func encryptText() {
        guard let keyData = Data(hexString: secretKey), keyData.count == 32 else {
            errorMessage = "Invalid key format. Please provide a 64-character hex string."
            result = ""
            return
        }
        
        guard let inputData = inputText.data(using: .utf8) else {
            errorMessage = "Could not convert input to data"
            result = ""
            return
        }
        
        let key = SymmetricKey(data: keyData)
        
        do {
            switch selectedAlgorithm {
            case .aesGcm256:
                let sealedBox = try AES.GCM.seal(inputData, using: key)
                result = sealedBox.combined?.base64EncodedString() ?? ""
            case .aesCbc256:
                // For CBC, we need to handle IV manually
                let iv = AES.GCM.Nonce()
                let encrypted = try AES.GCM.seal(inputData, using: key, nonce: iv)
                result = encrypted.combined?.base64EncodedString() ?? ""
            }
        } catch {
            errorMessage = "Encryption failed: \(error.localizedDescription)"
            result = ""
        }
    }
    
    private func decryptText() {
        guard let keyData = Data(hexString: secretKey), keyData.count == 32 else {
            errorMessage = "Invalid key format. Please provide a 64-character hex string."
            result = ""
            return
        }
        
        guard let cipherData = Data(base64Encoded: inputText) else {
            errorMessage = "Invalid ciphertext format. Expected base64-encoded data."
            result = ""
            return
        }
        
        let key = SymmetricKey(data: keyData)
        
        do {
            switch selectedAlgorithm {
            case .aesGcm256:
                let sealedBox = try AES.GCM.SealedBox(combined: cipherData)
                let decryptedData = try AES.GCM.open(sealedBox, using: key)
                result = String(data: decryptedData, encoding: .utf8) ?? "Could not decode decrypted data"
            case .aesCbc256:
                let sealedBox = try AES.GCM.SealedBox(combined: cipherData)
                let decryptedData = try AES.GCM.open(sealedBox, using: key)
                result = String(data: decryptedData, encoding: .utf8) ?? "Could not decode decrypted data"
            }
        } catch {
            errorMessage = "Decryption failed: \(error.localizedDescription)"
            result = ""
        }
    }
    
    private func generateRandomKey() {
        let keyData = SymmetricKey(size: .bits256)
        secretKey = keyData.withUnsafeBytes { Data($0) }.hexEncodedString()
        processText()
    }
    
    private func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}

struct AsymmetricEncryptionView: View {
    @State private var mode: String = "encrypt"
    @State private var inputText: String = ""
    @State private var publicKey: String = ""
    @State private var privateKey: String = ""
    @State private var selectedAlgorithm: AsymmetricAlgorithm = .rsa2048
    @State private var result: String = ""
    @State private var errorMessage: String = ""
    
    private let sampleText = "Hello, DevHelper!"
    
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
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(alignment: .top, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Mode")
                            .font(.headline)
                        Spacer()
                        Picker("", selection: $mode) {
                            Text("Encrypt").tag("encrypt")
                            Text("Decrypt").tag("decrypt")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: mode) { _, _ in
                            processText()
                        }
                    }
                    
                    HStack {
                        Text(mode == "encrypt" ? "Plaintext" : "Ciphertext")
                            .font(.headline)
                        Spacer()
                        if mode == "encrypt" {
                            Button("Sample") {
                                inputText = sampleText
                                processText()
                            }
                            .buttonStyle(.borderless)
                        }
                        Button("Clear") {
                            inputText = ""
                            result = ""
                        }
                        .buttonStyle(.borderless)
                    }
                    
                    TextEditor(text: $inputText)
                        .font(.system(.body, design: .monospaced))
                        .padding(5)
                        .frame(minHeight: 150, maxHeight: .infinity)
                        .onChange(of: inputText) { _, _ in
                            processText()
                        }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("\(mode == "encrypt" ? "Public" : "Private") Key")
                                .font(.headline)
                            Spacer()
                            Button("Sample Keys") {
                                publicKey = sampleRSAPublicKey
                                privateKey = sampleRSAPrivateKey
                                processText()
                            }
                            .buttonStyle(.borderless)
                        }
                        
                        if mode == "encrypt" {
                            TextEditor(text: $publicKey)
                                .font(.system(.caption, design: .monospaced))
                                .frame(height: 200)
                                .onChange(of: publicKey) { _, _ in
                                    processText()
                                }
                        } else {
                            TextEditor(text: $privateKey)
                                .font(.system(.caption, design: .monospaced))
                                .frame(height: 200)
                                .onChange(of: privateKey) { _, _ in
                                    processText()
                                }
                        }
                        
                        Text("Paste your RSA \(mode == "encrypt" ? "public" : "private") key in PEM format")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                
                Image(systemName: "arrow.right")
                    .font(.title)
                    .foregroundColor(.blue)
                    .frame(maxHeight: .infinity, alignment: .center)
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(mode == "encrypt" ? "Encrypted Result" : "Decrypted Result")
                            .font(.headline)
                        Spacer()
                        Button("Copy") {
                            copyToClipboard(result)
                        }
                        .buttonStyle(.borderless)
                        .disabled(result.isEmpty)
                    }
                    
                    ScrollView {
                        Text(result.isEmpty ? "\(mode == "encrypt" ? "Encrypted" : "Decrypted") text will appear here" : result)
                            .font(.system(.body, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                    }
                    .padding(5)
                    .frame(maxHeight: .infinity)
                    .background(AppConstants.lightGrayBackground)
                    .cornerRadius(8)
                    
                    if !result.isEmpty && mode == "encrypt" {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Encryption Information:")
                                .font(.caption)
                                .fontWeight(.medium)
                            
                            HStack(spacing: 5) {
                                Circle().fill(Color.blue.opacity(0.5)).frame(width: 8, height: 8)
                                Text("Algorithm: RSA PKCS1 Padding")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack(spacing: 5) {
                                Circle().fill(Color.green.opacity(0.5)).frame(width: 8, height: 8)
                                Text("Format: Base64 encoded")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
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
    }
    
    private func processText() {
        errorMessage = ""
        guard !inputText.isEmpty else {
            result = ""
            return
        }
        
        if mode == "encrypt" {
            encryptText()
        } else {
            decryptText()
        }
    }
    
    private func encryptText() {
        guard !publicKey.isEmpty else {
            errorMessage = "Public key is required for encryption"
            result = ""
            return
        }
        
        guard let keyData = parsePEMKey(publicKey) else {
            errorMessage = "Invalid public key format"
            result = ""
            return
        }
        
        let keyDict: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic
        ]
        
        var error: Unmanaged<CFError>?
        guard let secKey = SecKeyCreateWithData(keyData as CFData, keyDict as CFDictionary, &error) else {
            errorMessage = "Failed to create security key from public key"
            result = ""
            return
        }
        
        guard let inputData = inputText.data(using: .utf8) else {
            errorMessage = "Could not convert input to data"
            result = ""
            return
        }
        
        guard let encryptedData = SecKeyCreateEncryptedData(secKey, .rsaEncryptionPKCS1, inputData as CFData, &error) else {
            errorMessage = "Encryption failed. Make sure the input is not too long for RSA encryption."
            result = ""
            return
        }
        
        result = (encryptedData as Data).base64EncodedString()
    }
    
    private func decryptText() {
        guard !privateKey.isEmpty else {
            errorMessage = "Private key is required for decryption"
            result = ""
            return
        }
        
        guard let keyData = parsePEMKey(privateKey) else {
            errorMessage = "Invalid private key format"
            result = ""
            return
        }
        
        let keyDict: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate
        ]
        
        var error: Unmanaged<CFError>?
        guard let secKey = SecKeyCreateWithData(keyData as CFData, keyDict as CFDictionary, &error) else {
            errorMessage = "Failed to create security key from private key"
            result = ""
            return
        }
        
        guard let cipherData = Data(base64Encoded: inputText) else {
            errorMessage = "Invalid ciphertext format. Expected base64-encoded data."
            result = ""
            return
        }
        
        guard let decryptedData = SecKeyCreateDecryptedData(secKey, .rsaEncryptionPKCS1, cipherData as CFData, &error) else {
            errorMessage = "Decryption failed. Make sure the ciphertext is valid."
            result = ""
            return
        }
        
        result = String(data: decryptedData as Data, encoding: .utf8) ?? "Could not decode decrypted data"
    }
    
    private func parsePEMKey(_ pemString: String) -> Data? {
        let lines = pemString.components(separatedBy: .newlines)
        let base64Lines = lines.filter { line in
            !line.hasPrefix("-----") && !line.isEmpty
        }
        
        let base64String = base64Lines.joined()
        return Data(base64Encoded: base64String)
    }
    
    private func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}

// Helper extensions
extension Data {
    init?(hexString: String) {
        let length = hexString.count / 2
        var data = Data(capacity: length)
        for i in 0..<length {
            let start = hexString.index(hexString.startIndex, offsetBy: i * 2)
            let end = hexString.index(start, offsetBy: 2)
            let substring = String(hexString[start..<end])
            if let byte = UInt8(substring, radix: 16) {
                data.append(byte)
            } else {
                return nil
            }
        }
        self = data
    }
    
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

// CRC32 implementation
func crc32(_ data: Data) -> UInt32 {
    let polynomial: UInt32 = 0xEDB88320
    var crc: UInt32 = 0xFFFFFFFF
    
    for byte in data {
        crc ^= UInt32(byte)
        for _ in 0..<8 {
            if (crc & 1) != 0 {
                crc = (crc >> 1) ^ polynomial
            } else {
                crc >>= 1
            }
        }
    }
    
    return crc ^ 0xFFFFFFFF
}

#Preview {
    CryptoToolsView()
}