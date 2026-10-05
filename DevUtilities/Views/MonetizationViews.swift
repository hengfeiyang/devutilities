// Copyright 2026 Hengfei Yang.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

import SwiftUI

struct ProStatusView: View {
    let onOpenLicense: () -> Void

    @EnvironmentObject private var entitlementManager: EntitlementManager

    var body: some View {
        Button(action: onOpenLicense) {
            HStack(spacing: 9) {
                Image(systemName: statusIcon)
                    .foregroundStyle(statusColor)
                    .frame(width: 16)

                VStack(alignment: .leading, spacing: 2) {
                    Text(entitlementManager.statusTitle())
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Text(statusSubtitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 4)

                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(AppConstants.controlBackground)
            .clipShape(RoundedRectangle(cornerRadius: 9))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }

    private var statusIcon: String {
        switch entitlementManager.accessState {
        case .legacyPro, .purchasedPro:
            return "checkmark.seal.fill"
        case .trialActive:
            return "hourglass"
        case .trialExpired:
            return "exclamationmark.lock.fill"
        case .loading, .trialNotStarted:
            return "crown"
        }
    }

    private var statusColor: Color {
        switch entitlementManager.accessState {
        case .legacyPro, .purchasedPro:
            return .green
        case .trialExpired:
            return .orange
        default:
            return .accentColor
        }
    }

    private var statusSubtitle: String {
        switch entitlementManager.accessState {
        case .legacyPro:
            return "Thank you for supporting us early"
        case .purchasedPro:
            return "All Pro tools unlocked forever"
        case .trialNotStarted:
            return "Try every Pro tool"
        case .trialActive:
            return "All Pro tools are unlocked"
        case .trialExpired:
            return "Unlock once to keep using Pro tools"
        case .loading:
            return "Contacting the App Store"
        }
    }
}

struct LicenseSettingsView: View {
    @EnvironmentObject private var entitlementManager: EntitlementManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("DevUtilities Pro")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Button("Done") { dismiss() }
                    .keyboardShortcut(.defaultAction)
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 16)

            Divider()

            VStack(spacing: 14) {
                statusCard

                if !entitlementManager.accessState.hasPermanentProAccess {
                    benefits
                    purchaseOptions
                }

                purchaseMessage
            }
            .padding(20)
        }
        .frame(width: 620)
    }

    private var statusCard: some View {
        HStack(spacing: 14) {
            Image(systemName: entitlementManager.accessState.hasPermanentProAccess ? "checkmark.seal.fill" : "crown.fill")
                .font(.system(size: 27))
                .foregroundStyle(entitlementManager.accessState.hasPermanentProAccess ? .green : .accentColor)
                .frame(width: 34)

            VStack(alignment: .leading, spacing: 3) {
                Text(entitlementManager.statusTitle())
                    .font(.headline)
                Text(statusDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .background(AppConstants.controlBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var statusDescription: String {
        switch entitlementManager.accessState {
        case .legacyPro:
            return "You joined DevUtilities between January 1, 2025 and October 24, 2026. Every Pro tool is permanently unlocked."
        case .purchasedPro:
            return "Every Pro tool is permanently unlocked on this Apple Account."
        case .trialNotStarted:
            return "Start the trial when you are ready. The 30 days begin only after you choose to start."
        case .trialActive(let expiresAt):
            return "Your full Pro trial ends \(expiresAt.formatted(date: .abbreviated, time: .shortened))."
        case .trialExpired:
            return "Your 30-day Pro trial has ended. Unlock Lifetime Pro to continue using Pro tools."
        case .loading:
            return "Checking your App Store entitlement."
        }
    }

    private var benefits: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Everything in Pro")
                        .font(.headline)
                    Text("Seven advanced tools, unlocked forever with one purchase")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("7 PRO TOOLS")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color.accentColor)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.1))
                    .clipShape(Capsule())
            }

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10)
                ],
                alignment: .leading,
                spacing: 10
            ) {
                ForEach(proTools) { tool in
                    ProBenefitTile(tool: tool)
                }
            }
        }
        .padding(16)
        .background(AppConstants.controlBackground.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var proTools: [ToolType] {
        [.aiChat, .aiTranslate, .parquetViewer, .ipQuery, .currencyConverter, .jwt, .cryptoTools]
    }

    private var purchaseOptions: some View {
        VStack(spacing: 8) {
            HStack(spacing: 10) {
                if case .trialNotStarted = entitlementManager.accessState {
                    Button {
                        entitlementManager.startTrial()
                    } label: {
                        Text("Start 30-Day Trial")
                            .frame(width: 250)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }

                PurchaseButton()
                    .frame(width: 250)
            }
            .frame(maxWidth: .infinity)

            RestorePurchaseButton()
                .font(.caption)
        }
    }

    @ViewBuilder
    private var purchaseMessage: some View {
        switch entitlementManager.purchaseState {
        case .pending:
            Label("The purchase is waiting for App Store approval.", systemImage: "clock")
                .foregroundStyle(.secondary)
        case .failed(let message):
            VStack(spacing: 8) {
                Label(message, systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                Button("Dismiss") { entitlementManager.dismissPurchaseMessage() }
                    .buttonStyle(.link)
            }
        case .succeeded:
            Label("Pro is unlocked. Thank you for supporting DevUtilities.", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
        case .idle, .loadingProduct, .purchasing:
            EmptyView()
        }
    }

}

private struct PurchaseButton: View {
    @EnvironmentObject private var entitlementManager: EntitlementManager

    var body: some View {
        Button {
            Task {
                if entitlementManager.lifetimeProduct == nil {
                    await entitlementManager.reloadLifetimeProduct()
                } else {
                    await entitlementManager.purchaseLifetimePro()
                }
            }
        } label: {
            if case .pending = entitlementManager.purchaseState {
                Label("Waiting for App Store Approval", systemImage: "clock")
                    .frame(minWidth: 220)
            } else if entitlementManager.purchaseState.isBusy {
                ProgressView()
                    .controlSize(.small)
                    .frame(minWidth: 220)
            } else if let price = entitlementManager.localizedLifetimePrice {
                Text("Unlock Pro Forever — \(price)")
                    .frame(minWidth: 220)
            } else {
                Text("Retry Loading Pro")
                    .frame(minWidth: 220)
            }
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(entitlementManager.purchaseState.isBusy)
    }
}

private struct RestorePurchaseButton: View {
    @EnvironmentObject private var entitlementManager: EntitlementManager

    var body: some View {
        Button("Restore Purchase") {
            Task { await entitlementManager.restorePurchases() }
        }
        .buttonStyle(.link)
        .disabled(entitlementManager.purchaseState.isBusy)
    }
}

private struct ProBenefitTile: View {
    let tool: ToolType

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: tool.iconName)
                .foregroundStyle(Color.accentColor)
                .frame(width: 24, height: 24)

            Text(tool.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(Color.primary.opacity(0.035))
        .clipShape(RoundedRectangle(cornerRadius: 9))
    }
}
