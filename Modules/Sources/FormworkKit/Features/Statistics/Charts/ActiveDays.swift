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

extension ActiveDays {
    public init(_ window: History.Window) {
        let calendar = window.history.calendar
        // An exercise done twice in one session is still one session.
        let counts = Set(window.completions.map(\.session)).reduce(into: [Date: Int]()) { counts, session in
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

    public var weekdaySymbols: [String] {
        let symbols = calendar.veryShortWeekdaySymbols
        return calendar.orderedWeekdays.map { symbols[$0 - 1] }
    }
}

extension ActiveDays.Day: Identifiable {
    public var id: Date {
        date
    }
}
