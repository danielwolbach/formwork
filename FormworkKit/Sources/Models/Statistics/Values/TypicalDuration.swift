//
//  TypicalDuration.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

public struct TypicalDuration {
    public let value: Double?
}

extension TypicalDuration: Metric {
    public typealias Format = TypicalDurationFormat

    public init(_ window: History.Window) {
        let durations = switch window.history.subject {
        case .exercise, .entry: window.entries.filter(\.status.isCompleted).compactMap(\.duration)
        case .all, .workout: window.sessions.compactMap(\.duration)
        }

        self.value = durations.median
    }

    public static var explanation: String {
        String(localized: .placeholder)
    }

    public static var tolerance: Double? {
        0.05
    }

    /// Round durations, in seconds: from a quarter minute for a quick exercise up to two hours for a session.
    public static var axisSteps: [Double] {
        [15, 30, 60, 120, 300, 600, 900, 1800, 3600, 7200]
    }

    public var pictogram: Pictogram {
        .duration
    }

    public var title: String {
        String(localized: .statisticTypicalDurationTitle)
    }

    public var format: Format {
        TypicalDurationFormat()
    }
}
