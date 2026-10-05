import Foundation

@main
struct EarlySupporterCacheTests {
    static func main() throws {
        // Older persisted states must still decode; boolean-only grants need
        // online revalidation before being treated as current-policy dates.
        let old = try JSONDecoder().decode(LocalMonetizationState.self,
            from: Data(#"{"legacyProVerified":true}"#.utf8))
        precondition(old.legacyProVerified == true)
        precondition(old.legacyOriginalPurchaseDate == nil)
        precondition(!old.hasEligibleCachedLegacyPro)

        var state = LocalMonetizationState.initial
        state.legacyProVerified = true
        for date in [MonetizationConfiguration.legacyStartDate,
                     MonetizationConfiguration.legacyCutoffDate!.addingTimeInterval(-0.001)] {
            state.legacyOriginalPurchaseDate = date
            let restored = try JSONDecoder().decode(LocalMonetizationState.self,
                from: JSONEncoder().encode(state))
            precondition(restored.hasEligibleCachedLegacyPro)
            precondition(restored.legacyOriginalPurchaseDate == date)
        }
        for date in [Date(timeIntervalSince1970: 1_375_340_400),
                     MonetizationConfiguration.legacyStartDate.addingTimeInterval(-1),
                     MonetizationConfiguration.legacyCutoffDate!] {
            state.legacyOriginalPurchaseDate = date
            precondition(!state.hasEligibleCachedLegacyPro)
        }
        state.legacyOriginalPurchaseDate = MonetizationConfiguration.legacyStartDate
        state.legacyProVerified = false
        precondition(!state.hasEligibleCachedLegacyPro)
        print("Early Supporter cache tests passed (old-state decoding, date persistence, current-policy cache eligibility)")
    }
}

// Compile with the actual EntitlementManager; replace only telemetry so these
// persistence tests never initialize analytics, StoreKit, or the real Keychain.
@MainActor
final class EventManager {
    static let shared = EventManager()
    func reportMonetization(action: String, tool: ToolType? = nil) {}
}
