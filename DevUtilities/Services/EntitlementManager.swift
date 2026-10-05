// Copyright 2026 Hengfei Yang.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

import AppKit
import Foundation
import Security
import StoreKit
import SwiftUI

private struct LocalMonetizationState: Codable {
    var trialStartedAt: Date?
    var trialExpiresAt: Date?
    var lastTrustedLocalDate: Date?
    var legacyProVerified: Bool?
    var lifetimeProVerified: Bool?

    static let initial = LocalMonetizationState(
        trialStartedAt: nil,
        trialExpiresAt: nil,
        lastTrustedLocalDate: nil,
        legacyProVerified: nil,
        lifetimeProVerified: nil
    )
}

private final class SecureMonetizationStore {
    private let service = "com.hengfeiyang.devutilities.monetization"
    private let stateAccount = "local-state-v1"
    private let fallbackKey = "DevUtilities_MonetizationStateFallback"

    func load() -> LocalMonetizationState {
        if let data = keychainData(),
           let state = try? JSONDecoder().decode(LocalMonetizationState.self, from: data) {
            return state
        }

        if let data = UserDefaults.standard.data(forKey: fallbackKey),
           let state = try? JSONDecoder().decode(LocalMonetizationState.self, from: data) {
            return state
        }

        return .initial
    }

    func save(_ state: LocalMonetizationState) {
        guard let data = try? JSONEncoder().encode(state) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: stateAccount
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if status == errSecItemNotFound {
            var insert = query
            attributes.forEach { insert[$0.key] = $0.value }
            SecItemAdd(insert as CFDictionary, nil)
        }

        // Keep a fail-safe cache so a transient Keychain issue never restarts
        // a trial.
        UserDefaults.standard.set(data, forKey: fallbackKey)
    }

    private func keychainData() -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: stateAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess else {
            return nil
        }
        return result as? Data
    }
}

private enum EntitlementError: LocalizedError {
    case failedVerification
    case productUnavailable

    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "The App Store transaction could not be verified."
        case .productUnavailable:
            return "Pro Lifetime is temporarily unavailable. Please try again later."
        }
    }
}

@MainActor
final class EntitlementManager: ObservableObject {
    @Published private(set) var accessState: AccessState = .loading
    @Published private(set) var purchaseState: PurchaseState = .idle
    @Published private(set) var lifetimeProduct: Product?

    private let secureStore = SecureMonetizationStore()
    private let defaults = UserDefaults.standard
    private let trialExpiredEventKey = "DevUtilities_TrialExpiredEventReported"

    private var localState: LocalMonetizationState
    private var trialExpiryTask: Task<Void, Never>?
    private var transactionUpdatesTask: Task<Void, Never>?
    private var reportedGateKeys: Set<String> = []

    init() {
        localState = secureStore.load()

        transactionUpdatesTask = Task { [weak self] in
            await self?.listenForTransactions()
        }

        Task { [weak self] in
            await self?.prepare()
        }
    }

    var isFreemiumEnabled: Bool {
        MonetizationConfiguration.isFreemiumEnabled
    }

    var localizedLifetimePrice: String? {
        lifetimeProduct?.displayPrice
    }

    var trialDaysRemaining: Int? {
        guard case .trialActive(let expiresAt) = accessState else { return nil }
        let interval = max(0, expiresAt.timeIntervalSince(trustedNow()))
        return max(1, Int(ceil(interval / 86_400)))
    }

    var shouldShowProBadges: Bool {
        switch accessState {
        case .legacyPro, .purchasedPro:
            return false
        case .loading, .trialNotStarted, .trialActive, .trialExpired:
            return isFreemiumEnabled
        }
    }

    func prepare() async {
        if !isFreemiumEnabled {
            await refreshEntitlements()
            return
        }

        purchaseState = .loadingProduct
        await loadProduct()
        purchaseState = .idle
        await refreshEntitlements()
    }

    func refreshEntitlements() async {
        if !isFreemiumEnabled {
            // Anyone who launches the paid-transition build has already paid
            // for the download and must remain Pro after the storefront flips.
            localState.legacyProVerified = true
            defaults.set(true, forKey: "DevUtilities_LegacyProVerified")
            saveLocalState()
            accessState = .legacyPro
            cancelTrialExpiry()
            return
        }

        if applyDebugPreviewAccessState() {
            return
        }

        if await hasLegacyProEntitlement() {
            accessState = .legacyPro
            cancelTrialExpiry()
            return
        }

        if await hasLifetimePurchase() {
            accessState = .purchasedPro
            cancelTrialExpiry()
            return
        }

        updateLocalAccessState()
    }

    func startTrial() {
        guard debugPreviewAccessState == nil else { return }
        guard case .trialNotStarted = accessState else { return }

        let now = trustedNow()
        let expiresAt = Calendar.current.date(
            byAdding: .day,
            value: MonetizationConfiguration.trialDurationDays,
            to: now
        ) ?? now.addingTimeInterval(TimeInterval(MonetizationConfiguration.trialDurationDays) * 86_400)

        localState.trialStartedAt = now
        localState.trialExpiresAt = expiresAt
        localState.lastTrustedLocalDate = now
        saveLocalState()
        accessState = .trialActive(expiresAt: expiresAt)
        scheduleTrialExpiry(at: expiresAt)
        EventManager.shared.reportMonetization(action: "trial_started")
    }

    func purchaseLifetimePro() async {
        guard let lifetimeProduct else {
            purchaseState = .failed(message: EntitlementError.productUnavailable.localizedDescription)
            return
        }

        purchaseState = .purchasing
        EventManager.shared.reportMonetization(action: "purchase_started")

        do {
            let result = try await lifetimeProduct.purchase()
            switch result {
            case .success(let verification):
                let transaction = try verified(verification)
                await transaction.finish()
                purchaseState = .succeeded
                EventManager.shared.reportMonetization(action: "purchase_succeeded")
                await refreshEntitlements()
            case .pending:
                purchaseState = .pending
                EventManager.shared.reportMonetization(action: "purchase_pending")
            case .userCancelled:
                purchaseState = .idle
                EventManager.shared.reportMonetization(action: "purchase_cancelled")
            @unknown default:
                purchaseState = .failed(message: "The purchase could not be completed.")
                EventManager.shared.reportMonetization(action: "purchase_failed")
            }
        } catch {
            purchaseState = .failed(message: error.localizedDescription)
            EventManager.shared.reportMonetization(action: "purchase_failed")
        }
    }

    func reloadLifetimeProduct() async {
        guard isFreemiumEnabled, lifetimeProduct == nil else { return }

        purchaseState = .loadingProduct
        await loadProduct()
        if lifetimeProduct == nil {
            purchaseState = .failed(message: EntitlementError.productUnavailable.localizedDescription)
        } else {
            purchaseState = .idle
        }
    }

    func restorePurchases() async {
        purchaseState = .purchasing
        EventManager.shared.reportMonetization(action: "restore_started")

        do {
            try await AppStore.sync()
            await refreshEntitlements()
            if accessState == .purchasedPro || accessState == .legacyPro {
                purchaseState = .succeeded
                EventManager.shared.reportMonetization(action: "restore_succeeded")
            } else {
                purchaseState = .failed(message: "No previous Pro purchase was found.")
                EventManager.shared.reportMonetization(action: "restore_no_purchase_found")
            }
        } catch {
            purchaseState = .failed(message: error.localizedDescription)
            EventManager.shared.reportMonetization(action: "restore_failed")
        }
    }

    func dismissPurchaseMessage() {
        switch purchaseState {
        case .failed, .succeeded:
            purchaseState = .idle
        default:
            break
        }
    }

    func canUseTool(_ tool: ToolType) -> Bool {
        guard tool.productAccess == .pro else { return true }

        switch accessState {
        case .legacyPro, .purchasedPro, .trialActive:
            return true
        case .loading, .trialNotStarted, .trialExpired:
            return false
        }
    }

    func gateReason(for tool: ToolType) -> ProGateReason? {
        guard tool.productAccess == .pro, !canUseTool(tool) else { return nil }

        switch accessState {
        case .loading:
            return .loading
        case .trialNotStarted:
            return .trialOffer
        case .trialExpired:
            return .trialExpired
        case .legacyPro, .purchasedPro, .trialActive:
            return nil
        }
    }

    func recordGateShown(for tool: ToolType) {
        guard debugPreviewAccessState == nil else { return }
        guard let reason = gateReason(for: tool) else { return }
        let reasonName: String
        switch reason {
        case .loading:
            return
        case .trialOffer:
            reasonName = "trial_offer_viewed"
        case .trialExpired:
            reasonName = "trial_expired_paywall_viewed"
        }

        let day = Calendar.current.startOfDay(for: trustedNow()).timeIntervalSince1970
        let key = "\(reasonName):\(tool.rawValue):\(day)"
        guard reportedGateKeys.insert(key).inserted else { return }
        EventManager.shared.reportMonetization(action: reasonName, tool: tool)
    }

    func setApplicationActive(_ active: Bool) {
        if active {
            switch accessState {
            case .trialNotStarted, .trialActive, .trialExpired:
                updateLocalAccessState()
            case .loading, .legacyPro, .purchasedPro:
                break
            }
        }
    }

    func refreshTimeBasedAccess() {
        switch accessState {
        case .trialNotStarted, .trialActive, .trialExpired:
            updateLocalAccessState()
        case .loading, .legacyPro, .purchasedPro:
            break
        }
    }

    func statusTitle() -> String {
        switch accessState {
        case .loading:
            return "Checking Pro access…"
        case .legacyPro:
            return "Lifetime Pro · Early Supporter"
        case .purchasedPro:
            return "Lifetime Pro"
        case .trialNotStarted:
            return "30-day Pro trial available"
        case .trialActive:
            return "Pro Trial · \(trialDaysRemaining ?? 1) days left"
        case .trialExpired:
            return "Pro trial ended"
        }
    }

    private func loadProduct() async {
        do {
            lifetimeProduct = try await Product.products(
                for: [MonetizationConfiguration.lifetimeProductID]
            ).first
        } catch {
            lifetimeProduct = nil
        }
    }

    private func hasLifetimePurchase() async -> Bool {
        if let result = await Transaction.latest(
            for: MonetizationConfiguration.lifetimeProductID
        ) {
            switch result {
            case .verified(let transaction):
                let isActive = transaction.revocationDate == nil
                localState.lifetimeProVerified = isActive
                saveLocalState()
                return isActive
            case .unverified:
                break
            }
        }

        return localState.lifetimeProVerified == true
    }

    private func hasLegacyProEntitlement() async -> Bool {
        if localState.legacyProVerified == true {
            return true
        }

        // Migrate the earlier UserDefaults cache into the Keychain-backed
        // state so reinstalling the app does not discard a verified decision.
        if defaults.bool(forKey: "DevUtilities_LegacyProVerified") {
            localState.legacyProVerified = true
            saveLocalState()
            return true
        }

        do {
            let result = try await AppTransaction.shared
            guard case .verified(let appTransaction) = result else { return false }
            let isLegacyPro = MonetizationConfiguration.qualifiesForEarlySupporter(
                originalPurchaseDate: appTransaction.originalPurchaseDate
            )
            if isLegacyPro {
                localState.legacyProVerified = true
                defaults.set(true, forKey: "DevUtilities_LegacyProVerified")
                saveLocalState()
            }
            return isLegacyPro
        } catch {
            // A previous successful legacy decision is cached so an App Store
            // outage never locks a paid downloader out.
            return defaults.bool(forKey: "DevUtilities_LegacyProVerified")
        }
    }

    private func updateLocalAccessState() {
        if applyDebugPreviewAccessState() {
            return
        }

        let now = trustedNow()

        if let expiresAt = localState.trialExpiresAt,
           localState.trialStartedAt != nil,
           now < expiresAt {
            accessState = .trialActive(expiresAt: expiresAt)
            scheduleTrialExpiry(at: expiresAt)
        } else if localState.trialStartedAt == nil {
            cancelTrialExpiry()
            accessState = .trialNotStarted
        } else {
            cancelTrialExpiry()
            accessState = .trialExpired
            if !defaults.bool(forKey: trialExpiredEventKey) {
                defaults.set(true, forKey: trialExpiredEventKey)
                EventManager.shared.reportMonetization(action: "trial_expired")
            }
        }
    }

    private func trustedNow() -> Date {
        let systemNow = Date()
        if let lastTrusted = localState.lastTrustedLocalDate, systemNow < lastTrusted {
            return lastTrusted
        }
        localState.lastTrustedLocalDate = systemNow
        return systemNow
    }

    private func scheduleTrialExpiry(at expiresAt: Date) {
        trialExpiryTask?.cancel()
        let remaining = max(0, expiresAt.timeIntervalSince(trustedNow()))

        trialExpiryTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(remaining))
            guard !Task.isCancelled, let self else { return }
            self.updateLocalAccessState()
        }
    }

    private func cancelTrialExpiry() {
        trialExpiryTask?.cancel()
        trialExpiryTask = nil
    }

    /// Debug-only visual states for reviewing the complete Pro lifecycle
    /// without changing the real trial or entitlement records.
    private var debugPreviewAccessState: AccessState? {
        #if DEBUG
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("--preview-trial-not-started") {
            return .trialNotStarted
        }
        if arguments.contains("--preview-trial-active") {
            return .trialActive(expiresAt: Date().addingTimeInterval(30 * 86_400))
        }
        if arguments.contains("--preview-trial-expired") {
            return .trialExpired
        }
        #endif
        return nil
    }

    @discardableResult
    private func applyDebugPreviewAccessState() -> Bool {
        guard let previewState = debugPreviewAccessState else { return false }

        cancelTrialExpiry()
        accessState = previewState

        return true
    }

    private func saveLocalState() {
        secureStore.save(localState)
    }

    private func listenForTransactions() async {
        for await result in Transaction.updates {
            guard case .verified(let transaction) = result else { continue }
            guard transaction.productID == MonetizationConfiguration.lifetimeProductID else {
                continue
            }
            localState.lifetimeProVerified = transaction.revocationDate == nil
            saveLocalState()
            await transaction.finish()
            await refreshEntitlements()
        }
    }

    private func verified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let value):
            return value
        case .unverified:
            throw EntitlementError.failedVerification
        }
    }

}

enum ProGateReason {
    case loading
    case trialOffer
    case trialExpired
}
