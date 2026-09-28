//
//  Series.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

public struct Series<S: Statistic> {
    public struct Bar {
        public let month: Date

        public let statistic: S
    }

    public let period: DateInterval

    public let bars: [Bar]

    public init(_ history: History, year: Int) {
        let period = history.year(year).period

        self.period = period
        self.bars = sequence(first: period.start) { history.calendar.date(byAdding: .month, value: 1, to: $0) }
            .prefix { $0 < period.end }
            .compactMap { month in
                let window = history.month(containing: month)
                return window.interval.duration > 0 ? Bar(month: month, statistic: S(window)) : nil
            }
    }
}

extension Series.Bar: Identifiable {
    public var id: Date {
        month
    }
}
