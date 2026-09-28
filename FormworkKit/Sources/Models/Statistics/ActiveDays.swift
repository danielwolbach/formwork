//
//  ActiveDays.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

public struct ActiveDays {
    public struct Day {
        public let date: Date

        public let sessionCount: Int

        public let isAhead: Bool
    }

    public let calendar: Calendar

    public let days: [Day]
}

extension ActiveDays: Statistic {
    public init(_ window: History.Window) {
        let calendar = window.history.calendar
        let trained = switch window.history.subject {
        case .exercise, .entry: window.entries.filter(\.status.isCompleted).compactMap(\.session)
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

    public static var explanation: String {
        String(localized: .placeholder)
    }

    public var pictogram: Pictogram {
        .activity
    }

    public var title: String {
        String(localized: .statisticActiveDaysTitle)
    }

    /// The weekdays' symbols in the order the days of a week come in, to label them with.
    public var weekdaySymbols: [String] {
        let symbols = calendar.veryShortWeekdaySymbols
        return (0 ..< 7).map { symbols[(calendar.firstWeekday - 1 + $0) % 7] }
    }
}

extension ActiveDays.Day: Identifiable {
    public var id: Date {
        date
    }
}
