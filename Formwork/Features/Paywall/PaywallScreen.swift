//
//  PaywallScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 01.10.26.
//

import FormworkKit
import FormworkUI
import StoreKit
import SwiftUI

struct PaywallScreen: View {
    @Environment(\.dismiss)
    private var dismiss: DismissAction

    @Environment(\.purchase)
    private var purchase: PurchaseAction

    @Environment(\.fullVersion)
    private var fullVersion: FullVersion

    @State
    private var selection: Product? = nil

    @State
    private var isBusy: Bool = false

    @State
    private var pendingAlert: Bool = false

    @State
    private var purchaseError: (any Error)? = nil

    @State
    private var restoreError: (any Error)? = nil

    @State
    private var nothingToRestoreAlert: Bool = false

    var body: some View {
        VStack(spacing: .sections) {
            header

            PlanComparison()

            Spacer(minLength: 0)

            purchaseSection
        }
        .padding(.horizontal)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(.cancel) {
                    dismiss()
                }
            }
        }
        .onChange(of: fullVersion.isUnlocked) {
            if fullVersion.isUnlocked {
                dismiss()
            }
        }
        .onChange(of: fullVersion.products, initial: true) {
            selection = selection ?? fullVersion.products.first
        }
        .task {
            // Loading at launch fails while offline, so try again whenever the paywall opens without products.
            if fullVersion.products.isEmpty {
                await fullVersion.loadProducts()
            }
        }
        .alert(.alertPurchasePendingTitle, isPresented: $pendingAlert) {
            // OK is added automatically.
        } message: {
            Text(.alertPurchasePendingMessage)
        }
        .alert(.alertPurchaseFailedTitle, isPresented: Binding<Bool>(get: { purchaseError != nil }, set: { _ in purchaseError = nil }), presenting: purchaseError) { _ in
            // OK is added automatically.
        } message: { error in
            Text(error.localizedDescription)
        }
        .alert(.alertRestoreFailedTitle, isPresented: Binding<Bool>(get: { restoreError != nil }, set: { _ in restoreError = nil }), presenting: restoreError) { _ in
            // OK is added automatically.
        } message: { error in
            Text(error.localizedDescription)
        }
        .alert(.alertNothingToRestoreTitle, isPresented: $nothingToRestoreAlert) {
            // OK is added automatically.
        } message: {
            Text(.alertNothingToRestoreMessage)
        }
    }

    private var header: some View {
        VStack(spacing: .items) {
            Image(.imageAppIcon)
                .resizable()
                .frame(width: 64, height: 64)

            Text(.paywallTitle)
                .font(.title)
                .fontWeight(.bold)

            Text(.paywallMessage)
                .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal)
    }

    private var purchaseSection: some View {
        VStack(spacing: .groups) {
            if !fullVersion.products.isEmpty {
                ForEach(fullVersion.products) { product in
                    ProductButton(product: product, isSelected: selection == product) {
                        selection = product
                    }
                    .disabled(isBusy)
                }

                Button {
                    guard let selection else {
                        return
                    }

                    Task {
                        isBusy = true
                        defer { isBusy = false }

                        do {
                            let result = try await purchase(selection)
                            await fullVersion.handle(result)

                            // Ask to Buy or extra bank verification: access arrives later through the transaction updates.
                            if case .pending = result {
                                pendingAlert = true
                            }
                        } catch StoreKitError.userCancelled {
                            // Cancelling isn't a failure.
                        } catch {
                            purchaseError = error
                        }
                    }
                } label: {
                    Text(Action.coninue.title)
                        .fontWeight(.semibold)
                        .opacity(isBusy ? 0 : 1)
                        .overlay {
                            if isBusy {
                                ProgressView()
                                    .tint(.white)
                            }
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(.tint)
                }
                .buttonStyle(.plain)
                .clipShape(.rect(cornerRadius: 16))
                .disabled(selection == nil || isBusy)
            } else if fullVersion.isLoadingProducts {
                ProgressView()
                    .padding()
            } else {
                ContentUnavailableView {
                    Label(.emptyProductsTitle, systemImage: "exclamationmark.triangle")
                } description: {
                    Text(.emptyProductsMessage)
                } actions: {
                    Button(.retry) {
                        Task {
                            await fullVersion.loadProducts()
                        }
                    }
                    .labelStyle(.fixedTitleAndIcon)
                    .buttonStyle(.cardProminent)
                }
            }

            HStack {
                footerButton(.paywallTermsTitle) {
                    // TODO:
                }

                footerButton(.paywallRestoreTitle) {
                    Task {
                        isBusy = true
                        defer { isBusy = false }

                        do {
                            try await fullVersion.restore()

                            // If it was unlocked before restoring, onChange won't fire, so close here too.
                            if fullVersion.isUnlocked {
                                dismiss()
                            } else {
                                nothingToRestoreAlert = true
                            }
                        } catch StoreKitError.userCancelled {
                            // Cancelling the sign-in isn't a failure.
                        } catch {
                            restoreError = error
                        }
                    }
                }
                .disabled(isBusy)

                footerButton(.paywallPrivacyTitle) {
                    // TODO:
                }
            }
            .buttonStyle(.plain)
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .sensoryFeedback(.selection, trigger: selection)
    }

    private func footerButton(_ title: LocalizedStringResource, action: @escaping () -> Void) -> some View {
        Button(title, action: action)
            .frame(maxWidth: .infinity)
    }
}

private struct ProductButton: View {
    let product: Product
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: isSelected ? "checkmark.circle" : "circle")
                    .font(.system(size: 24))

                VStack(alignment: .leading) {
                    Text(product.displayName)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(product.description)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(product.displayPrice)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundStyle(.primary)
            }
            .padding(8)
        }
        .buttonStyle(isSelected ? .cardSelected : .card)
        .buttonBorderShape(.roundedRectangle(radius: 16))
    }
}

private struct PlanComparison: View {
    private enum Value {
        case text(String)
        case included(Bool)
    }

    private struct Row {
        let feature: LocalizedStringResource
        let free: Value
        let full: Value
    }

    private let rows: [Row] = [
        Row(feature: .paywallExercisesTitle, free: .text("10"), full: .text(String(localized: .paywallUnlimitedTitle))),
        Row(feature: .paywallWorkoutsTitle, free: .text("1"), full: .text(String(localized: .paywallUnlimitedTitle))),
        Row(feature: .paywallLiveActivityTitle, free: .included(false), full: .included(true)),
    ]

    var body: some View {
        Grid(horizontalSpacing: 32, verticalSpacing: 16) {
            GridRow {
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: 0)
                    .gridColumnAlignment(.leading)

                Text(.paywallFreeTitle)
                    .foregroundStyle(.secondary)

                Text(.paywallFullTitle)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(.tint, in: .capsule)
            }
            .font(.subheadline.weight(.semibold))

            Divider()

            ForEach(rows.indices, id: \.self) { index in
                let row = rows[index]
                GridRow {
                    Text(row.feature)
                    cell(row.free, highlighted: false)
                    cell(row.full, highlighted: true)
                }
            }
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private func cell(_ value: Value, highlighted: Bool) -> some View {
        switch value {
        case let .text(string):
            Text(string)
                .fontWeight(highlighted ? .semibold : .regular)
                .foregroundStyle(highlighted ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
        case let .included(isIncluded):
            Image(systemName: isIncluded ? "checkmark.circle.fill" : "minus")
                .foregroundStyle(isIncluded ? AnyShapeStyle(.tint) : AnyShapeStyle(.tertiary))
        }
    }
}

#Preview {
    NavigationStack {
        PaywallScreen()
    }
}
