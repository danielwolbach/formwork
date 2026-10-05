//
//  Schedule.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 06.09.26.
//

import Foundation

public enum Schedule: Codable, Hashable, Sendable {
    public struct Weekdays: Codable, Hashable, OptionSet, Sendable {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public init(calendarWeekday: Int) {
            rawValue = 1 << (calendarWeekday - 1)
        }
    }

    case weekly(weekdays: Weekdays = [], anchor: Date = .now)
    case daily(days: Int = 1, anchor: Date = .now)
}

extension Schedule {
    public static var inactive: Schedule {
        .weekly()
    }

    public static func today(in calendar: Calendar = .current) -> Schedule {
        .weekly(weekdays: Weekdays(calendarWeekday: calendar.component(.weekday, from: .now)))
    }

    public func isScheduled(on date: Date, after lastSession: Date?, now: Date = .now, in calendar: Calendar = .current) -> Bool {
        switch self {
        case let .weekly(weekdays, anchor):
            return calendar.startOfDay(for: date) >= calendar.startOfDay(for: anchor)
                && weekdays.contains(Weekdays(calendarWeekday: calendar.component(.weekday, from: date)))
        case let .daily(days, anchor):
            let days = max(days, 1)
            let day = calendar.startOfDay(for: date)
            var due = calendar.startOfDay(for: anchor)

            if let lastSession, let next = calendar.date(byAdding: .day, value: days, to: calendar.startOfDay(for: lastSession)) {
                due = max(due, next)
            }

            // A missed day stays due until it's done. Later days assume every due day gets done.
            let today = calendar.startOfDay(for: now)
            guard day > today else {
                return day >= due
            }

            guard let distance = calendar.dateComponents([.day], from: max(due, today), to: day).day else {
                return false
            }

            return distance >= 0 && distance % days == 0
        }
    }

    public func isDue(on date: Date, after lastSession: Date?, now: Date = .now, in calendar: Calendar = .current) -> Bool {
        if let lastSession, calendar.isDate(lastSession, inSameDayAs: date) {
            return false
        }

        return isScheduled(on: date, after: lastSession, now: now, in: calendar)
    }
}

extension Calendar {
    public var orderedWeekdays: [Int] {
        (0 ..< 7).map { (firstWeekday - 1 + $0) % 7 + 1 }
    }
}
