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

    public static var explanation: String {
        String(localized: .placeholder)
    }

    /// A count grows with the days it's taken over, so four weeks would always look worse than twelve.
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
