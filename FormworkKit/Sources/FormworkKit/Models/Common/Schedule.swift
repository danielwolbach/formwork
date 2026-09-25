//
//  Schedule.swift
//  Formwork
//
//  Created by Daniel Wolbach on 06.09.26.
//

import Foundation

public enum Schedule: Codable, Hashable, Sendable {
    case weekly(weekdays: Weekdays, interval: Int, anchor: Date)
    case daily(interval: Int, anchor: Date)

    public enum Weekday: Int, Codable, CaseIterable, Sendable {
        case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    }

    public struct Weekdays: OptionSet, Codable, Hashable, Sendable {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
}

extension Schedule {
    public static var inactive: Schedule {
        .weekly(weekdays: [], interval: 1, anchor: .now)
    }

    public static func today(in calendar: Calendar = .current) -> Schedule {
        .weekly(weekdays: Weekdays([Weekday(calendarNumber: calendar.component(.weekday, from: .now))]), interval: 1, anchor: .now)
    }

    private static func isCycle(_ date: Date, every interval: Int, of component: Calendar.Component, from anchor: Date, in calendar: Calendar) -> Bool {
        guard
            calendar.startOfDay(for: date) >= calendar.startOfDay(for: anchor),
            let start = calendar.dateInterval(of: component, for: anchor)?.start,
            let end = calendar.dateInterval(of: component, for: date)?.start,
            let distance = calendar.dateComponents([component], from: start, to: end).value(for: component)
        else {
            return false
        }

        return distance % max(interval, 1) == 0
    }

    public func isScheduled(on date: Date, in calendar: Calendar = .current) -> Bool {
        switch self {
        case let .weekly(weekdays, interval, anchor):
            weekdays.contains(Weekday(calendarNumber: calendar.component(.weekday, from: date)))
                && Self.isCycle(date, every: interval, of: .weekOfYear, from: anchor, in: calendar)
        case let .daily(interval, anchor):
            Self.isCycle(date, every: interval, of: .day, from: anchor, in: calendar)
        }
    }
}

extension Schedule.Weekdays {
    public init(_ weekdays: some Sequence<Schedule.Weekday>) {
        self.init(rawValue: weekdays.reduce(0) { $0 | 1 << $1.rawValue })
    }

    public func contains(_ weekday: Schedule.Weekday) -> Bool {
        rawValue & 1 << weekday.rawValue != 0
    }
}

extension Schedule.Weekday: Identifiable {
    public var id: Self {
        self
    }
}

extension Schedule.Weekday {
    init(calendarNumber: Int) {
        self = Self.allCases[(calendarNumber + 5) % 7]
    }

    var calendarNumber: Int {
        (rawValue + 1) % 7 + 1
    }

    public static func ordered(in calendar: Calendar = .autoupdatingCurrent) -> [Self] {
        let offset = Self(calendarNumber: calendar.firstWeekday).rawValue
        return Array(allCases[offset...] + allCases[..<offset])
    }

    public func name(in calendar: Calendar = .autoupdatingCurrent) -> String {
        calendar.weekdaySymbols[calendarNumber - 1]
    }

    public func symbol(in calendar: Calendar = .autoupdatingCurrent) -> String {
        calendar.veryShortWeekdaySymbols[calendarNumber - 1]
    }
}
