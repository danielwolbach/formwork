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
            calendar.weekdaySymbols[(rawValue + 1) % 7]
        }

        public func symbol(in calendar: Calendar = .autoupdatingCurrent) -> String {
            calendar.veryShortWeekdaySymbols[(rawValue + 1) % 7]
        }
    }
}

public extension Schedule.Weekday {
    static func ordered(in calendar: Calendar = .autoupdatingCurrent) -> [Self] {
        let offset = (calendar.firstWeekday + 5) % 7
        return Array(allCases[offset...] + allCases[..<offset])
    }
}

public extension Schedule {
    static let inactive = Schedule(weekdays: [])
}
