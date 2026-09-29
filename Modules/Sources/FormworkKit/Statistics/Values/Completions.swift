//
//  Completions.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

public struct Completions {
    public let count: Int
}

extension Completions: Metric {
    public init(_ window: History.Window) {
        self.count = switch window.history.subject {
        case .exercise, .entry: window.entries.count(where: \.status.isCompleted)
        case .all, .workout: window.sessions.count
        }
    }

    public static var info: String {
        String(localized: .statisticCompletionsInfo)
    }

    public static var tolerance: Double? {
        nil
    }

    public var pictogram: Pictogram {
        .tally
    }

    public var title: String {
        String(localized: .statisticCompletionsTitle)
    }

    public var value: Double? {
        Double(count)
    }

    public var format: FloatingPointFormatStyle<Double> {
        .number.precision(.fractionLength(0))
    }
}
