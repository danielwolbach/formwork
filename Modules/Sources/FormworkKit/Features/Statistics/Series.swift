//
//  Series.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

/// One value per month of a year, for the months on record.
public struct Series<Value> {
    public struct Bar {
        public let month: Date

        public let value: Value
    }

    public let period: DateInterval

    public let bars: [Bar]

    public init(_ history: History, year: Int, value: (History.Window) -> Value) {
        let period = history.year(year).period

        self.period = period
        self.bars = sequence(first: period.start) { history.calendar.date(byAdding: .month, value: 1, to: $0) }
            .prefix { $0 < period.end }
            .compactMap { month in
                let window = history.month(containing: month)
                return window.interval.duration > 0 ? Bar(month: month, value: value(window)) : nil
            }
    }
}

extension Series.Bar: Identifiable {
    public var id: Date {
        month
    }
}
