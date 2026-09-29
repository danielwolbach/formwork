//
//  TypicalInterval.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 28.09.26.
//

import Foundation

public struct TypicalInterval {
    public let value: Double?
}

extension TypicalInterval: Metric {
    public typealias Format = IntervalFormat

    public init(_ window: History.Window) {
        let calendar = window.history.calendar
        let days = switch window.history.subject {
        case .exercise, .entry:
            window.entries.filter(\.status.isCompleted).compactMap { $0.session?.period(of: .day, in: calendar)?.start }
        case .all, .workout:
            window.sessions.compactMap { $0.period(of: .day, in: calendar)?.start }
        }

        let sorted = Array(Set(days)).sorted()
        self.value = zip(sorted, sorted.dropFirst())
            .compactMap { calendar.dateComponents([.day], from: $0, to: $1).day }
            .map(Double.init)
            .median
    }

    public static var info: String {
        String(localized: .statisticTypicalIntervalInfo)
    }

    public static var tolerance: Double? {
        0.1
    }

    public var pictogram: Pictogram {
        .frequency
    }

    public var title: String {
        String(localized: .statisticTypicalIntervalTitle)
    }

    public var format: Format {
        IntervalFormat()
    }
}
