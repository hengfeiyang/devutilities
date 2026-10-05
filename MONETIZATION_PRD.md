# DevUtilities 30-Day Trial and Lifetime Pro Product Requirements Document

Version: 3.0

Status: Approved; implementation and release validation in progress

Platform: macOS 15+

Business model: Free download + full 30-day Pro trial + one-time Lifetime Pro purchase

## 1. Product Summary

DevUtilities 3.0 moves from paid download to free download. New users can use 18 everyday tools permanently for free and choose to start a single, full 30-day Pro trial. After the trial ends, a Lifetime Pro purchase is required to continue using the seven Pro tools. Existing paid-download customers automatically receive permanent Pro access without purchasing again.

Lifetime Pro is a StoreKit 2 non-consumable in-app purchase, not an auto-renewable subscription. It permanently unlocks all Pro tools for the current Apple Account and supports Family Sharing and purchase restoration.

The app source and website are maintained in a single Git repository, with `website/` as an ordinary subdirectory. Users who build their own copy may customize local entitlement logic under the repository license; users who prefer not to build locally can support development through the official App Store app and Lifetime Pro. This does not change the official 3.0 free-download and one-time purchase policy or include external AI API credits. Repository visibility and website publication remain separate operations.

Core principles:

- Free tools must form a complete developer toolkit that remains useful over time.
- Tools that require external paid services, provide less commonly available capabilities, or offer specialized security capabilities belong to Pro.
- Users explicitly start the 30-day trial; it does not start automatically on installation or first launch.
- No daily free allowance is available after the trial expires.
- Selecting a locked Pro tool keeps the current tool visible and opens the unified Pro window directly.
- Users who first acquired the app from January 1, 2025 through October 24, 2026 receive permanent Legacy Pro, whether the download was paid or free.

## 2. Product Goals

### 2.1 Business Goals

- Reduce the initial download barrier and increase installs and activation.
- Demonstrate the value of Pro tools through a full 30-day experience.
- Improve purchase conversion with a clear, one-time purchase path.
- Protect existing paid customers from duplicate purchases and negative experiences.

### 2.2 User Goals

- Use everyday tools immediately after downloading.
- Start a full 30-day trial when needed.
- Clearly understand which tools require Pro, when the trial ends, and what a purchase includes.
- Continue using all free tools without interruption after the trial ends.

### 2.3 Non-Goals

- No auto-renewable subscriptions.
- No monthly or annual billing.
- No daily minute limits, daily usage counts, or ad-based unlocking.
- No locking of data the user has already entered or generated.
- No purchase gates on free tools.

## 3. Tool Access

### 3.1 Permanently Free Tools: 18

1. Timestamp
2. Unit Converter
3. Number Base
4. Color
5. Text Compare
6. JSON
7. Base64
8. Hex String
9. Regex
10. UUID
11. Random String
12. URL
13. HTTP Client
14. QR Code
15. SQL
16. HTML
17. Struct Converter
18. Data Converter

### 3.2 Pro Tools: 7

1. AI Chat
2. AI Translate
3. Parquet
4. IP Lookup
5. Currency
6. JWT
7. Crypto

Classification principles:

- AI Chat and AI Translate may use external paid services.
- Parquet, IP Lookup, and Currency provide capabilities less commonly available in general-purpose tool collections.
- JWT and Crypto provide specialized, security-related capabilities that are used less frequently.

### 3.3 Spotlight and Shortcuts

Existing App Intents remain free and must not fail because the user has not purchased Pro. Quick commands do not open the Pro window.

## 4. StoreKit Product

| Field | Value |
|---|---|
| Type | Non-Consumable |
| Product ID | `com.hengfeiyang.devutilities.pro.lifetime` |
| Display name | Lifetime Pro |
| Base price | USD 29.99; the final price is the localized App Store price |
| Family Sharing | Enabled |
| Auto-renewal | None |

Use the following UI wording consistently:

- `Unlock Pro Forever`
- `One-time purchase`
- `Restore Purchase`

Do not use wording that implies a subscription, such as `Subscribe`, `per month`, or `renews automatically`.

## 5. Trial Rules

### 5.1 Starting the Trial

- New users initially have the `trialNotStarted` state.
- Record the trial start time only after the user selects `Start 30-Day Trial`.
- Store the trial start and expiration times in Keychain, with a fail-safe local cache.
- A normal reinstall on the same device must not grant another trial.

### 5.2 During the Trial

- All seven Pro tools are fully available for 30 days.
- Do not show tool-level purchase gates.
- The DevUtilities Pro page shows the remaining days and the exact expiration time.
- Users may purchase Lifetime Pro at any time during the trial.

### 5.3 After the Trial

- Switch the state to `trialExpired` immediately.
- All 18 free tools remain available.
- Access to the seven Pro tools ends, with no additional minutes or usage allowance.
- Trial expiration must not delete any input, history, or tool settings.
- A successful purchase or restore immediately unlocks all Pro tools.

## 6. Unified Pro Window

### 6.1 Entry Points

The following entry points open the same `LicenseSettingsView`:

- The crown button at the top of the sidebar.
- The Pro status card at the bottom of the sidebar, shown only to users without permanent Pro access. Hide this area for purchased Pro and Early Supporter users.
- Keep the top crown button available to permanent Pro users so they can inspect their entitlement status.
- Selecting a Pro tool the user is not currently entitled to use.
- Receiving the `licenseSettingsRequested` notification.

### 6.2 Navigation Interception

When a user selects a locked Pro tool:

1. Check entitlement before committing the sidebar selection.
2. Do not change `selectedTool`.
3. Preserve the current free tool's page and state.
4. Present the unified Pro window directly as a sheet.
5. Keep the user on the original tool after the window is dismissed.

Do not navigate to the Pro tool first and then block it with a blank page, overlay, or placeholder.

If the trial expires while the user is using a Pro tool:

1. Return to the most recently used free tool, or JSON if none is available.
2. Preserve the Pro tool's persisted data.
3. Show the unified Pro window.

### 6.3 Trial Not Started

The unified window shows:

- `30-day Pro trial available`
- `Start 30-Day Trial`
- `Unlock Pro Forever — {localized price}`
- `Restore Purchase`
- The seven Pro tools displayed individually with names and icons in a three-column grid, rather than grouped into categories such as AI, Network, or Security

### 6.4 Trial Active

The unified window shows:

- Remaining days
- Exact expiration time
- A one-time Lifetime Pro purchase button
- Restore Purchase

### 6.5 Trial Expired

The unified window shows:

- `Pro trial ended`
- `Your 30-day Pro trial has ended. Unlock Lifetime Pro to continue using Pro tools.`
- A one-time Lifetime Pro purchase button
- Restore Purchase
- No button to start another trial
- No wording about extra minutes, access returning tomorrow, or daily allowances

## 7. Access State Machine

```text
loading
  ├─ paid transition build ───────────────> legacyPro
  ├─ verified early supporter ────────────> legacyPro
  ├─ verified Lifetime Pro purchase ──────> purchasedPro
  ├─ trial never started ─────────────────> trialNotStarted
  ├─ trial active ────────────────────────> trialActive
  └─ trial ended ─────────────────────────> trialExpired

trialNotStarted -- user starts trial -----> trialActive
trialActive -- reaches expiry ------------> trialExpired
trialNotStarted/trialActive/trialExpired
  -- purchase or restore succeeds --------> purchasedPro
```

Entitlement priority:

1. Legacy Pro
2. Verified Lifetime Pro purchase
3. Active 30-day trial
4. Trial not started or trial expired

Pro tools are available only in the `legacyPro`, `purchasedPro`, or `trialActive` state.

## 8. Legacy Pro and Phased Release

### 8.1 Early Supporter

- Users who first acquired the app from January 1, 2025 through October 24, 2026 receive permanent Legacy Pro, including paid and free downloads. User-facing copy displays dates without a timezone label.
- Eligibility requires a verified `AppTransaction.originalPurchaseDate` at or after January 1, 2025 at 00:00:00 and strictly before October 25, 2026 at 00:00:00 in Asia/Shanghai. This includes all of October 24 and excludes midnight on October 25. It is not based on first launch or first use. The equivalent UTC interval is [December 31, 2024 at 16:00:00, October 24, 2026 at 16:00:00). The lower bound excludes Sandbox's fixed 2013 acquisition date.
- Cache a successful eligibility decision in Keychain and the fail-safe local cache.
- Revalidate old boolean-only grants when the App Store returns a verified transaction. Replace stale decisions, including old Sandbox grants. New grants persist the verified original acquisition date and provide immediate offline access under the current date policy. Missing or unverified responses must not revoke a previously granted entitlement.

### 8.2 Release Phases

The Early Supporter grant starts January 1, 2025 and includes all of October 24, 2026. The cutoff is October 25, 2026 at 00:00 in Asia/Shanghai, independent of storefront pricing, with no additional grace period. Paid and free acquisitions within this interval receive permanent Pro. Release freemium is enabled by the owner's launch instruction; `--paid-transition` is Debug-only. Actual distribution testing, the App Store price change, and version release remain external steps.

1. Verify permanent AppTransaction-based entitlements for existing paid customers and free-download users who acquired the app before the cutoff.
2. Complete Lifetime Pro configuration, Sandbox testing, and release scheduling.
3. Validate enabled Release freemium, archive, upload, and run TestFlight regression tests.
4. Submit Lifetime Pro together with version 3.0 for review. Keep manual release control and coordinate the free App Store price with the version's release.
5. Verify new users on both sides of the cutoff, existing Early Supporters, purchases, Family Sharing, and restoration.

## 9. Technical Implementation

### 9.1 Core Files

- `Models/AccessState.swift`: Access states and Pro tool mapping.
- `Services/EntitlementManager.swift`: StoreKit 2, Legacy Pro, trial handling, and local state.
- `Views/MonetizationViews.swift`: Unified Pro window, purchase UI, and restore UI.
- `ContentView.swift`: Sidebar navigation interception and sheet presentation.
- `Configuration.storekit`: Product configuration for local StoreKit testing.

### 9.2 Local State

Keychain state includes:

- `trialStartedAt`
- `trialExpiresAt`
- `lastTrustedLocalDate`
- `legacyProVerified`
- `lifetimeProVerified`

Ignore legacy daily-allowance fields when reading stored data. They no longer participate in entitlement decisions.

### 9.3 Time Handling

- Use the latest trusted local time to reduce the risk of bypassing the trial by simply rolling back the system clock.
- Refresh trial status when the app becomes active, the system clock changes, or the calendar day changes.
- Schedule an expiration task during an active trial and switch to `trialExpired` when the expiration time is reached.

### 9.4 Debug Previews

Debug builds support:

- `--preview-trial-not-started`
- `--preview-trial-active`
- `--preview-trial-expired`

Preview arguments must not modify actual Keychain records, StoreKit entitlements, or trial dates, and must not be included in Release binaries.

## 10. Purchase and Restore

- Load localized prices with `Product.products(for:)`.
- Complete purchases with StoreKit 2 `purchase()`.
- Accept only verified transactions.
- Do not grant access while a purchase is pending.
- Preserve the existing access state when a purchase is canceled.
- Restore purchases with `AppStore.sync()`.
- Refresh entitlements when receiving `Transaction.updates`.
- After a refund or revocation, remove `purchasedPro` and fall back to a valid trial or `trialExpired`.

## 11. Analytics and Privacy

Allowed events:

- Trial entry shown, trial started, and trial ended.
- Unified Pro window shown after trial expiration.
- Purchase started, succeeded, failed, canceled, or pending.
- Restore started, succeeded, failed, or no purchase found.

Do not collect:

- User input, output, or clipboard contents.
- File names, file paths, or file contents.
- API keys, request bodies, JWTs, cryptographic keys, or model conversations.
- Personally identifiable information.

## 12. Acceptance Criteria

### 12.1 Free Tools

- All 18 free tools can always be opened.
- Free tools do not show the Pro window.
- Trial expiration does not affect free tools' data or functionality.

### 12.2 Trial

- The trial does not start automatically.
- Starting the trial immediately unlocks all Pro tools.
- Remaining time is consistent across app restarts.
- The state changes to `trialExpired` at expiration.
- The trial cannot be started again.

### 12.3 Pro Navigation Interception

- Before the trial starts or after it expires, selecting any Pro tool does not change the currently selected tool.
- The unified Pro window appears immediately.
- No blank detail page, tool-level prompt card, or overlay appears.
- Dismissing the window leaves the user on the original free tool.
- If the trial expires while a Pro tool is open, the app returns to the most recently used free tool and shows the unified Pro window.

### 12.4 Purchase

- Display the localized App Store price.
- A successful purchase immediately makes all Pro tools available.
- Purchase status persists across restarts.
- Restoring a purchase restores access to all Pro tools.
- All purchase copy clearly describes a one-time, permanent unlock.

### 12.5 Legacy Pro

- Existing paid customers do not encounter purchase gates.
- Cached Legacy Pro remains valid during temporary App Store outages.
- Paid and free-download users who first acquired the app within the eligible interval receive permanent Legacy Pro. Dates before January 1, 2025 or at/after the cutoff must not automatically receive Legacy Pro. Sandbox users can therefore test the normal trial and purchase flow without a review-only override.

## 13. Test Matrix

| Scenario | Expected result |
|---|---|
| New user's first launch | All 18 free tools are available; Pro tools are marked |
| Select Pro before starting the trial | Current tool stays selected; the unified window offers trial and purchase |
| Start the trial | All Pro tools become available immediately |
| Restart during the trial | Remaining time is preserved |
| Trial expires while a free tool is open | The free tool remains usable |
| Trial expires while a Pro tool is open | Return to the most recently used free tool and show the unified window |
| Select Pro after trial expiration | Current tool stays selected; the unified window offers purchase |
| Successful purchase | All Pro tools are permanently unlocked |
| Purchase pending | No access is granted early; the window shows the waiting state |
| User cancels purchase | Existing entitlement state is preserved |
| Successful restore | All Pro tools are unlocked immediately |
| Restore with no previous purchase | Show a clear error; do not grant access |
| Legacy Pro user | All Pro tools remain permanently available |
| Acquisition before January 1, 2025, including Sandbox's 2013 date | No Early Supporter grant; regular trial and purchase options |
| Verified ineligible date with an old Legacy Pro cache | Clear the stale grant; preserve genuine IAP access or trial state |
| Release build launched with preview arguments | Arguments have no effect, and preview strings are absent from the binary |

## 14. Final Product Promise

> DevUtilities is free to download. Eighteen everyday tools are permanently free, and seven advanced tools can be tried in full for 30 days. After the trial, a one-time Lifetime Pro purchase unlocks them permanently, with no automatic renewal. All early paid customers keep permanent Pro access.
