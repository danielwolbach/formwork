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
    public init(_ period: Period) {
        let calendar = period.history.calendar
        // An exercise done twice in one session is still one session.
        let sessions = period.completions.reduce(into: [Date: Set<Session>]()) { sessions, occurrence in
            sessions[occurrence.day, default: []].insert(occurrence.session)
        }

        self.calendar = calendar
        self.days = sequence(first: period.span.start) { calendar.date(byAdding: .day, value: 1, to: $0) }
            .prefix { $0 < period.span.end }
            .map { date in
                Day(date: date, sessionCount: sessions[date]?.count ?? 0, isAhead: date >= period.history.interval.end)
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
