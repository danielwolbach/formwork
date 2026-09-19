//
//  Schedule.swift
//  Formwork
//
//  Created by Daniel Wolbach on 06.09.26.
//

import Foundation

public nonisolated struct Schedule: Codable, Sendable {
    public var weekdays: Set<Weekday>

    public init(weekdays: Set<Weekday>) {
        self.weekdays = weekdays
    }
}

public extension Schedule {
    enum Weekday: Int, Identifiable, Codable, CaseIterable, Sendable {
        case monday, tuesday, wednesday, thursday, friday, saturday, sunday

        public var id: Self {
            self
        }

        public func name(in calendar: Calendar = .autoupdatingCurrent) -> String {
            calendar.weekdaySymbols[calendarNumber - 1]
        }

        public func symbol(in calendar: Calendar = .autoupdatingCurrent) -> String {
            calendar.veryShortWeekdaySymbols[calendarNumber - 1]
        }
    }
}

public extension Schedule.Weekday {
    /// The number `Calendar` uses for a weekday: Sunday = 1 … Saturday = 7.
    init(calendarNumber: Int) {
        self = Self.allCases[(calendarNumber + 5) % 7]
    }

    /// The number `Calendar` uses for a weekday: Sunday = 1 … Saturday = 7.
    var calendarNumber: Int {
        (rawValue + 1) % 7 + 1
    }

    static func ordered(in calendar: Calendar = .autoupdatingCurrent) -> [Self] {
        let offset = Self(calendarNumber: calendar.firstWeekday).rawValue
        return Array(allCases[offset...] + allCases[..<offset])
    }
}

public extension Schedule {
    /// Whether a workout on this schedule is meant to be done on `date`.
    func isScheduled(on date: Date, in calendar: Calendar = .current) -> Bool {
        weekdays.contains(Schedule.Weekday(calendarNumber: calendar.component(.weekday, from: date)))
    }
}

public extension Schedule {
    static let inactive = Schedule(weekdays: [])
}
