//
//  Schedule.swift
//  Formwork
//
//  Created by Daniel Wolbach on 06.09.26.
//

import Foundation

public struct Schedule: Codable, Sendable {
    public enum Weekday: Int, Codable, CaseIterable, Sendable {
        case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    }

    public var weekdays: Set<Weekday>

    public init(weekdays: Set<Weekday>) {
        self.weekdays = weekdays
    }
}

public extension Schedule {
    static let inactive = Schedule(weekdays: [])

    static func today(in calendar: Calendar = .current) -> Schedule {
        Schedule(weekdays: [Weekday(calendarNumber: calendar.component(.weekday, from: .now))])
    }

    func isScheduled(on date: Date, in calendar: Calendar = .current) -> Bool {
        weekdays.contains(Schedule.Weekday(calendarNumber: calendar.component(.weekday, from: date)))
    }
}

extension Schedule.Weekday: Identifiable {
    public var id: Self {
        self
    }
}

public extension Schedule.Weekday {
    internal init(calendarNumber: Int) {
        self = Self.allCases[(calendarNumber + 5) % 7]
    }

    static func ordered(in calendar: Calendar = .autoupdatingCurrent) -> [Self] {
        let offset = Self(calendarNumber: calendar.firstWeekday).rawValue
        return Array(allCases[offset...] + allCases[..<offset])
    }

    func name(in calendar: Calendar = .autoupdatingCurrent) -> String {
        calendar.weekdaySymbols[calendarNumber - 1]
    }

    func symbol(in calendar: Calendar = .autoupdatingCurrent) -> String {
        calendar.veryShortWeekdaySymbols[calendarNumber - 1]
    }

    internal var calendarNumber: Int {
        (rawValue + 1) % 7 + 1
    }
}
