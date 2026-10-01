//
//  FullVersion.swift
//  FormworkModules
//
//  Created by Daniel Wolbach on 01.10.26.
//

import Observation
import StoreKit

@MainActor
@Observable
public final class FullVersion {
    public static let productIDs = [
        "de.danielwolbach.Formwork.fullversion.monthly",
        "de.danielwolbach.Formwork.fullversion.yearly",
    ]

    public private(set) var products: [Product] = []

    public private(set) var isUnlocked = false

    public private(set) var isLoadingProducts = false

    public nonisolated init() {}

    /// Runs for the app's lifetime: loads products, then follows renewals, refunds, Ask to Buy, other devices.
    public func observe() async {
        await loadProducts()
        await refresh()

        for await result in Transaction.updates {
            await handle(result)
        }
    }

    public func loadProducts() async {
        guard !isLoadingProducts else {
            return
        }

        isLoadingProducts = true
        defer { isLoadingProducts = false }

        // A failed load keeps what's already there, so a retry can't wipe loaded products.
        if let products = try? await Product.products(for: Self.productIDs) {
            self.products = products.sorted { $0.price < $1.price }
        }
    }

    public func handle(_ result: Product.PurchaseResult) async {
        if case let .success(verification) = result {
            await handle(verification)
        }
    }

    public func restore() async throws {
        try await AppStore.sync()
        await refresh()
    }

    private func handle(_ verification: VerificationResult<Transaction>) async {
        // An unverified transaction is left unfinished, so StoreKit delivers it again and a later verification can still unlock it.
        guard case let .verified(transaction) = verification else {
            return
        }
        await transaction.finish()
        await refresh()
    }

    private func refresh() async {
        var active = false
        for await case let .verified(transaction) in Transaction.currentEntitlements
            where Self.productIDs.contains(transaction.productID) && transaction.revocationDate == nil
        {
            active = true
        }
        isUnlocked = active
    }
}
