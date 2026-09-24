//
//  ActiveDays.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

/// The days trained, day by day over the days a window asked for. For an exercise, the days it was completed on.
struct ActiveDays {
    struct Day {
        let date: Date

        let sessionCount: Int

        /// Whether the day is still to come, so there's nothing it could show yet.
        let isAhead: Bool
    }

    /// The calendar the days are laid out in.
    let calendar: Calendar

    /// Every day of the window's period, oldest first.
    let days: [Day]
}

extension ActiveDays: Statistic {
    init(_ window: History.Window) {
        let calendar = window.history.calendar
        let trained = switch window.history.subject {
        case .exercise: window.entries.filter(\.status.isCompleted).compactMap(\.session)
        case .all, .workout: window.sessions
        }

        let counts = trained.reduce(into: [Date: Int]()) { counts, session in
            guard let day = session.period(of: .day, in: calendar)?.start else {
                return
            }

            counts[day, default: 0] += 1
        }

        self.calendar = calendar
        self.days = sequence(first: window.period.start) { calendar.date(byAdding: .day, value: 1, to: $0) }
            .prefix { $0 < window.period.end }
            .map { date in
                Day(date: date, sessionCount: counts[date] ?? 0, isAhead: date >= window.history.interval.end)
            }
    }

    static var explanation: String {
        String(localized: ._Placeholder)
    }

    var pictogram: Pictogram {
        .activity
    }

    var title: String {
        String(localized: .statisticActivityTitle)
    }

    /// The weekdays in the order the days of a week come in, to label them with.
    var weekdays: [Schedule.Weekday] {
        Schedule.Weekday.ordered(in: calendar)
    }
}

extension ActiveDays.Day: Identifiable {
    var id: Date {
        date
    }
}
