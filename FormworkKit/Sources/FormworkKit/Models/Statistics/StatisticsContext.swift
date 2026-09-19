//
//  StatisticsContext.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 19.09.26.
//

// MARK: - Guidelines

//
// - Use the injected `calendar` for all date math (no fixed calendars, no `86_400` arithmetic).
//   Weeks start on the current locale's first weekday.
// - Use wall-clock time: sessions are dated by `localStarted(in:)` and `localEnded(in:)`, never
//   `started` or `ended` directly.
//   Raw instants are only for durations, ordering and relative formatting.
// - A session belongs to the interval its local start falls in (half-open: `start <= date < end`)
//   and counts only if it ended by `interval.end`.
// - Streaks: the current streak is as of `interval.end` and uses all earlier history. The longest
//   streak is measured within the interval. An unfinished week doesn't break a streak.
//

import Foundation

struct StatisticsContext {
    struct Record {
        let session: Session
        let started: Date
        let ended: Date
    }

    let calendar: Calendar

    let interval: DateInterval

    /// All sessions started before and finished by `interval.end`.
    let history: [Record]

    /// The part of `history` started within `interval`.
    let records: [Record]

    init(sessions: [Session], interval: DateInterval, calendar: Calendar) {
        self.calendar = calendar
        self.interval = interval
        self.history = sessions
            .compactMap { session in
                session.localEnded(in: calendar).map {
                    Record(session: session, started: session.localStarted(in: calendar), ended: $0)
                }
            }
            .filter { $0.started < interval.end && $0.ended <= interval.end }
        self.records = history.filter { $0.started >= interval.start }
    }
}

extension StatisticsContext {
    /// Consecutive weeks with a session, up to the week containing `interval.end`.
    var currentWeekStreak: Int {
        let weeks = weekStarts(of: history)
        guard let current = startOfWeek(containing: interval.end) else { return 0 }

        var week = weeks.contains(current) ? current : adding(weeks: -1, to: current)
        var streak = 0
        while let start = week, weeks.contains(start) {
            streak += 1
            week = adding(weeks: -1, to: start)
        }
        return streak
    }

    /// The longest run of consecutive weeks with a session within `interval`.
    var longestWeekStreak: Int {
        var longest = 0, streak = 0, previous: Date?
        for week in weekStarts(of: records).sorted() {
            streak = previous.flatMap { adding(weeks: 1, to: $0) } == week ? streak + 1 : 1
            longest = max(longest, streak)
            previous = week
        }
        return longest
    }

    private func weekStarts(of records: [Record]) -> Set<Date> {
        Set(records.compactMap { startOfWeek(containing: $0.started) })
    }

    private func startOfWeek(containing date: Date) -> Date? {
        calendar.dateInterval(of: .weekOfYear, for: date)?.start
    }

    private func adding(weeks: Int, to week: Date) -> Date? {
        calendar.date(byAdding: .weekOfYear, value: weeks, to: week)
    }
}

public extension DateInterval {
    static func until(_ end: Date) -> Self {
        DateInterval(start: .distantPast, end: end)
    }

    static func month(_ month: Int, year: Int? = nil, calendar: Calendar = .current) -> Self {
        precondition((1 ... 12).contains(month), "Month must be between 1 and 12.")
        return period(.month, of: DateComponents(year: year ?? calendar.component(.year, from: .now), month: month), calendar: calendar)
    }

    static func year(_ year: Int? = nil, calendar: Calendar = .current) -> Self {
        period(.year, of: DateComponents(year: year ?? calendar.component(.year, from: .now)), calendar: calendar)
    }

    private static func period(_ component: Calendar.Component, of components: DateComponents, calendar: Calendar) -> Self {
        guard let date = calendar.date(from: components), let interval = calendar.dateInterval(of: component, for: date) else {
            preconditionFailure("No \(component) for \(components).")
        }
        return interval
    }
}

extension [Double] {
    var median: Double? {
        guard !isEmpty else { return nil }
        let sorted = sorted(), middle = count / 2
        return count.isMultiple(of: 2) ? (sorted[middle - 1] + sorted[middle]) / 2 : sorted[middle]
    }
}
