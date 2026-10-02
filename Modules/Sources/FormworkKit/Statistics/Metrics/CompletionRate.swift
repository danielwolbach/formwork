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

    public static var info: String {
        String(localized: .statisticCompletionRateInfo)
    }

    public static var pictogram: Pictogram {
        .completed
    }

    public static var title: String {
        String(localized: .statisticCompletionRateTitle)
    }

    public static var tolerance: Double? {
        0.05
    }

    public func reading(of value: Double) -> Reading {
        .percent(value)
    }
}
