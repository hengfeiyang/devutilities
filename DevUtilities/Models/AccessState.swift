// Copyright 2026 Hengfei Yang.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

import Foundation

enum ProductAccess {
    case free
    case pro
}

enum AccessState: Equatable {
    case loading
    case legacyPro
    case purchasedPro
    case trialNotStarted
    case trialActive(expiresAt: Date)
    case trialExpired

    var hasPermanentProAccess: Bool {
        switch self {
        case .legacyPro, .purchasedPro:
            return true
        case .loading, .trialNotStarted, .trialActive, .trialExpired:
            return false
        }
    }

    func canUseTool(_ tool: ToolType) -> Bool {
        guard tool.productAccess == .pro else { return true }
        switch self {
        case .legacyPro, .purchasedPro, .trialActive:
            return true
        case .loading, .trialNotStarted, .trialExpired:
            return false
        }
    }
}

enum PurchaseState: Equatable {
    case idle
    case loadingProduct
    case purchasing
    case pending
    case succeeded
    case failed(message: String)

    var isBusy: Bool {
        switch self {
        case .loadingProduct, .purchasing, .pending:
            return true
        case .idle, .succeeded, .failed:
            return false
        }
    }

}

enum MonetizationConfiguration {
    static let lifetimeProductID = "com.hengfeiyang.devutilities.pro.lifetime"
    static let trialDurationDays = 30

    /// v3.0 ships free download with Lifetime Pro in both Debug and Release.
    /// The old paid-transition preview is available only in Debug builds.
    static var isFreemiumEnabled: Bool {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--paid-transition") {
            return false
        }
        #endif
        return true
    }

    /// Verified acquisitions from January 1, 2025 through October 24, 2026
    /// in Asia/Shanghai receive permanent Pro, whether paid or free.
    /// The lower bound also excludes Sandbox's fixed 2013 purchase date.
    static let legacyStartDate = Date(timeIntervalSince1970: 1_735_660_800)

    /// The exclusive cutoff is 2026-10-25 00:00:00 (2026-10-24 16:00:00 UTC).
    static let legacyCutoffDate: Date? = Date(timeIntervalSince1970: 1_792_857_600)

    static func qualifiesForEarlySupporter(originalPurchaseDate: Date) -> Bool {
        guard let legacyCutoffDate else { return false }
        return originalPurchaseDate >= legacyStartDate && originalPurchaseDate < legacyCutoffDate
    }
}

extension ToolType {
    var productAccess: ProductAccess {
        switch self {
        case .aiChat,
             .aiTranslate,
             .jwt,
             .cryptoTools,
             .parquetViewer,
             .ipQuery,
             .currencyConverter:
            return .pro
        default:
            return .free
        }
    }
}
