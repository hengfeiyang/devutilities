import Foundation

@main
struct EarlySupporterPolicyTests {
    static func main() {
        let cutoff = ISO8601DateFormatter().date(from: "2026-10-25T00:00:00+08:00")!
        precondition(MonetizationConfiguration.legacyCutoffDate == cutoff)
        // Include the entire last eligible day, not just dates before it.
        for timestamp in [
            "2026-10-24T00:00:00+08:00",
            "2026-10-24T12:00:00+08:00",
            "2026-10-24T23:59:59.999+08:00"
        ] {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = timestamp.contains(".")
                ? [.withInternetDateTime, .withFractionalSeconds] : [.withInternetDateTime]
            precondition(MonetizationConfiguration.qualifiesForEarlySupporter(
                originalPurchaseDate: formatter.date(from: timestamp)!))
        }
        precondition(MonetizationConfiguration.qualifiesForEarlySupporter(
            originalPurchaseDate: cutoff.addingTimeInterval(-1)))
        precondition(!MonetizationConfiguration.qualifiesForEarlySupporter(
            originalPurchaseDate: cutoff))
        precondition(!MonetizationConfiguration.qualifiesForEarlySupporter(
            originalPurchaseDate: cutoff.addingTimeInterval(1)))
        precondition(MonetizationConfiguration.qualifiesForEarlySupporter(
            originalPurchaseDate: ISO8601DateFormatter().date(from: "2026-10-04T00:00:00Z")!))
        let utcCutoff = ISO8601DateFormatter().date(from: "2026-10-24T16:00:00Z")!
        precondition(cutoff == utcCutoff)
        precondition(ToolType.allCases.filter { $0.productAccess == .pro }.count == 7)
        precondition(ToolType.allCases.filter { $0.productAccess == .free }.count == 18)
        precondition(AccessState.legacyPro.hasPermanentProAccess)
        precondition(AccessState.purchasedPro.hasPermanentProAccess)
        precondition(!AccessState.trialNotStarted.hasPermanentProAccess)
        precondition(!AccessState.trialActive(expiresAt: cutoff).hasPermanentProAccess)
        precondition(!AccessState.trialExpired.hasPermanentProAccess)
        #if !DEBUG
        precondition(!MonetizationConfiguration.isFreemiumEnabled)
        #endif
        print("Early Supporter policy tests passed (UTC+8 cutoff, exclusive boundary, free/Pro split, Release guard)")
    }
}
