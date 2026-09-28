//
//  CompletionRate.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

public struct CompletionRate {
    public let value: Double?
}

extension CompletionRate: Metric {
    public init(_ window: History.Window) {
        let entries = window.entries
        self.value = entries.isEmpty ? nil : Double(entries.count(where: \.status.isCompleted)) / Double(entries.count)
    }

    public static var explanation: String {
        String(localized: .placeholder)
    }

    /// A share doesn't grow with the days it's taken over.
    public static var tolerance: Double? {
        0.05
    }

    public var pictogram: Pictogram {
        .completed
    }

    public var title: String {
        String(localized: .statisticCompletionRateTitle)
    }

    public var format: FloatingPointFormatStyle<Double>.Percent {
        .percent.precision(.fractionLength(0))
    }
}
