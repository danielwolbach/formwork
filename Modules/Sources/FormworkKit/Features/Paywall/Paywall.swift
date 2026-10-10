//
//  Paywall.swift
//  FormworkModules
//
//  Created by Daniel Wolbach on 01.10.26.
//

import Observation
import OSLog
import StoreKit
import SwiftData

@MainActor
@Observable
public final class Paywall {
    public static let productIDs = [
        "de.danielwolbach.Formwork.premium.monthly",
        "de.danielwolbach.Formwork.premium.yearly",
    ]

    public nonisolated static let workoutLimit = 2

    public nonisolated static let exerciseLimit = 10

    public private(set) var products: [Product] = []

    public private(set) var isUnlocked = false

    public private(set) var hasCheckedEntitlements = false

    public private(set) var isLoadingProducts = false

    public nonisolated init(isUnlocked: Bool = false) {
        _isUnlocked = isUnlocked
    }

    public func observe() async {
        await refresh()
        await loadProducts()

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

        do {
            products = try await Product.products(for: Self.productIDs).sorted { $0.price < $1.price }
            Logger.paywall.info("Loaded \(products.count) products")
        } catch {
            Logger.paywall.error("Loading products failed: \(error, privacy: .public)")
        }
    }

    public func handle(_ result: Product.PurchaseResult) async {
        switch result {
        case let .success(verification):
            await handle(verification)
        case .pending:
            Logger.paywall.info("Purchase is pending")
        case .userCancelled:
            Logger.paywall.info("Purchase was cancelled")
        @unknown default:
            Logger.paywall.notice("Purchase ended with an unknown result")
        }
    }

    public func restore() async throws {
        do {
            try await AppStore.sync()
        } catch {
            Logger.paywall.error("Restoring purchases failed: \(error, privacy: .public)")
            throw error
        }

        await refresh()
    }

    public func canAddExercise(in context: ModelContext) -> Bool {
        isUnlocked || (try? context.fetchCount(FetchDescriptor<Exercise>(predicate: #Predicate { !$0.isArchived }))) ?? 0 < Self.exerciseLimit
    }

    public func canAddWorkout(in context: ModelContext) -> Bool {
        isUnlocked || (try? context.fetchCount(FetchDescriptor<Workout>(predicate: #Predicate { !$0.isArchived }))) ?? 0 < Self.workoutLimit
    }

    private func handle(_ verification: VerificationResult<Transaction>) async {
        guard case let .verified(transaction) = verification else {
            Logger.paywall.error("Transaction failed verification")
            return
        }
        Logger.paywall.info("Finishing transaction for \(transaction.productID, privacy: .public)")
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
        hasCheckedEntitlements = true

        Logger.paywall.info("Checked entitlements, unlocked: \(active)")
    }
}
