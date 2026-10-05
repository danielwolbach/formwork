//
//  Streaks.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 04.10.26.
//

import Foundation

public struct WeekStreak {
    public let weeks: Int

    public let isCurrentWeekFulfilled: Bool
}

extension History.Window {
    public var weekStreak: WeekStreak {
        guard let streak = streakWeeks else {
            return WeekStreak(weeks: 0, isCurrentWeekFulfilled: false)
        }

        let calendar = history.calendar
        let fulfilled = streak.weeks.contains(streak.current)
        var week = fulfilled ? streak.current : calendar.date(byAdding: .weekOfYear, value: -1, to: streak.current)
        var count = 0
        while let start = week, streak.weeks.contains(start) {
            count += 1
            week = calendar.date(byAdding: .weekOfYear, value: -1, to: start)
        }

        return WeekStreak(weeks: count, isCurrentWeekFulfilled: fulfilled)
    }

    var longestWeekStreak: Int {
        guard let streak = streakWeeks else {
            return 0
        }

        let calendar = history.calendar
        var longest = 0, run = 0, previous: Date?
        for week in streak.weeks.sorted() {
            run = previous.flatMap { calendar.date(byAdding: .weekOfYear, value: 1, to: $0) } == week ? run + 1 : 1
            longest = max(longest, run)
            previous = week
        }

        return longest
    }

    fileprivate var streakWeeks: (weeks: Set<Date>, current: Date)? {
        let calendar = history.calendar

        guard
            interval.duration > 0,
            let last = calendar.date(byAdding: .day, value: -1, to: interval.end),
            let current = calendar.dateInterval(of: .weekOfYear, for: last)?.start
        else {
            return nil
        }

        let earlier = DateInterval(start: .distantPast, end: interval.end)
        let weeks = history.sessions
            .filter { $0.falls(into: earlier, in: calendar) }
            .compactMap { $0.period(of: .weekOfYear, in: calendar)?.start }

        return (Set(weeks), current)
    }
}
