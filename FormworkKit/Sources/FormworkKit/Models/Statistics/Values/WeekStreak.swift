//
//  WeekStreak.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

/// Consecutive weeks with a session, as seen on the window's last day on record. The week of that day doesn't
/// break the streak until it's over.
struct WeekStreak {
    let weeks: Int
}

/// The longest run of consecutive weeks with a session, up to the window's last day on record.
struct LongestWeekStreak {
    let weeks: Int
}

extension WeekStreak: Statistic {
    init(_ window: History.Window) {
        guard let streak = window.streakWeeks else {
            self.weeks = 0
            return
        }

        let calendar = window.history.calendar
        var week = streak.weeks.contains(streak.current) ? streak.current : calendar.date(byAdding: .weekOfYear, value: -1, to: streak.current)
        var count = 0
        while let start = week, streak.weeks.contains(start) {
            count += 1
            week = calendar.date(byAdding: .weekOfYear, value: -1, to: start)
        }

        self.weeks = count
    }

    static var explanation: String {
        String(localized: ._Placeholder)
    }

    var pictogram: Pictogram {
        .streak
    }

    var title: String {
        String(localized: .statisticWeekStreakTitle)
    }

    var subtitle: String? {
        weeks.formatted()
    }
}

extension LongestWeekStreak: Statistic {
    init(_ window: History.Window) {
        guard let streak = window.streakWeeks else {
            self.weeks = 0
            return
        }

        let calendar = window.history.calendar
        var longest = 0, run = 0, previous: Date?
        for week in streak.weeks.sorted() {
            run = previous.flatMap { calendar.date(byAdding: .weekOfYear, value: 1, to: $0) } == week ? run + 1 : 1
            longest = max(longest, run)
            previous = week
        }

        self.weeks = longest
    }

    static var explanation: String {
        String(localized: ._Placeholder)
    }

    var pictogram: Pictogram {
        .record
    }

    var title: String {
        String(localized: .statisticLongestWeekStreakTitle)
    }

    var subtitle: String? {
        weeks.formatted()
    }
}

extension History.Window {
    /// The weeks with a session up to the window's last day on record, before the window too, and the week of that
    /// day. There are none for a window without a day on record.
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
