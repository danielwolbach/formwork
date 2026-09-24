//
//  CompletionRate.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

/// The share of the entries of finished sessions that were completed, rather than skipped or left pending.
struct CompletionRate {
    let value: Double?
}

extension CompletionRate: Metric {
    init(_ window: History.Window) {
        let entries = window.entries
        self.value = entries.isEmpty ? nil : Double(entries.count(where: \.status.isCompleted)) / Double(entries.count)
    }

    static var explanation: String {
        String(localized: ._Placeholder)
    }

    /// A share doesn't grow with the days it's taken over.
    static var tolerance: Double? {
        0.05
    }

    var pictogram: Pictogram {
        .completed
    }

    var title: String {
        String(localized: .statisticCompletionRateTitle)
    }

    func label(for value: Double) -> String {
        value.formatted(.percent.precision(.fractionLength(0)))
    }
}
