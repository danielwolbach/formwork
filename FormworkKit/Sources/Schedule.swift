//
//  Schedule.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 06.09.26.
//

import Foundation

public nonisolated struct Schedule: Codable, Hashable, Sendable {
    public var days: Set<Weekday>
    public var interval: Int
    public var startDate: Date

    public init(days: Set<Weekday>, interval: Int = 1, startDate: Date) {
        self.days = days
        self.interval = max(1, interval)
        self.startDate = startDate
    }
}

public extension Schedule {
    static let inactive = Schedule(days: [], interval: 1, startDate: .distantPast)

    var isActive: Bool {
        !days.isEmpty
    }

    mutating func setDay(_ day: Weekday, isOn: Bool, calendar: Calendar = .autoupdatingCurrent, now: Date = .now) {
        let wasActive = isActive

        if isOn {
            days.insert(day)
        } else {
            days.remove(day)
        }

        if !wasActive, isActive {
            startDate = calendar.startOfDay(for: now)
        }
    }

    func matches(_ date: Date, calendar: Calendar = .autoupdatingCurrent) -> Bool {
        guard isActive else { return false }

        guard let weekday = Weekday(calendarWeekday: calendar.component(.weekday, from: date)), days.contains(weekday)
        else { return false }

        guard calendar.startOfDay(for: date) >= calendar.startOfDay(for: startDate) else { return false }
        guard interval > 1 else { return true }

        guard
            let anchor = calendar.dateInterval(of: .weekOfYear, for: startDate)?.start,
            let week = calendar.dateInterval(of: .weekOfYear, for: date)?.start,
            let delta = calendar.dateComponents([.weekOfYear], from: anchor, to: week).weekOfYear
        else { return false }

        return delta % interval == 0
    }
}

public nonisolated enum Weekday: Int, Codable, Hashable, Sendable, CaseIterable, Identifiable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday

    public var id: Self {
        self
    }
}

public extension Weekday {
    var calendarWeekday: Int {
        (rawValue + 1) % 7 + 1
    }

    init?(calendarWeekday: Int) {
        guard (1 ... 7).contains(calendarWeekday) else { return nil }
        self.init(rawValue: (calendarWeekday + 5) % 7)
    }

    static func ordered(in calendar: Calendar = .autoupdatingCurrent) -> [Weekday] {
        (0 ..< 7).compactMap { Weekday(calendarWeekday: (calendar.firstWeekday - 1 + $0) % 7 + 1) }
    }

    func symbol(in calendar: Calendar = .autoupdatingCurrent) -> String {
        calendar.veryShortWeekdaySymbols[calendarWeekday - 1]
    }

    func name(in calendar: Calendar = .autoupdatingCurrent) -> String {
        calendar.weekdaySymbols[calendarWeekday - 1]
    }
}
