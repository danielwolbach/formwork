//
//  WeeklyActiveDays.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

/// Days with a session per week, counted like `WeeklySessions`: `ActiveDays` as a single number.
struct WeeklyActiveDays {
    let value: Double?
}

extension WeeklyActiveDays: Metric {
    init(_ window: History.Window) {
        let calendar = window.history.calendar
        let trained = switch window.history.subject {
        case .exercise, .entry: window.entries.filter(\.status.isCompleted).compactMap(\.session)
        case .all, .workout: window.sessions
        }

        let days = Set(trained.compactMap { $0.period(of: .day, in: calendar)?.start })
        self.value = window.lengthInWeeks.map { Double(days.count) / $0 }
    }

    static var explanation: String {
        String(localized: ._Placeholder)
    }

    static var tolerance: Double? {
        0.1
    }

    var pictogram: Pictogram {
        .activity
    }

    var title: String {
        String(localized: .statisticWeeklyActiveDaysTitle)
    }

    func label(for value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0 ... 1)))
    }
}
