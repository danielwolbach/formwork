//
//  WeeklySessions.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

/// How many sessions there were a week, over the days on record: from the first session, if that's later than the
/// window's start, to its end, or today while it's under way.
struct WeeklySessions {
    let value: Double?
}

extension WeeklySessions: Metric {
    init(_ window: History.Window) {
        self.value = window.lengthInWeeks.map { Double(window.sessions.count) / $0 }
    }

    static var explanation: String {
        String(localized: ._Placeholder)
    }

    static var tolerance: Double? {
        0.1
    }

    var pictogram: Pictogram {
        .frequency
    }

    var title: String {
        String(localized: .statisticWeeklySessionsTitle)
    }

    func label(for value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0 ... 1)))
    }
}
