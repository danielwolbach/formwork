//
//  Series.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

/// A statistic month by month through one calendar year. Months without a day on record, before the first
/// session or still ahead, have no bar.
struct Series<S: Statistic> {
    struct Bar {
        /// The start of the month.
        let month: Date

        let statistic: S
    }

    /// The whole year, so a chart can keep every month on its axis.
    let period: DateInterval

    let bars: [Bar]

    init(_: S.Type = S.self, of history: History, year: Int) {
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
    var id: Date {
        month
    }
}
