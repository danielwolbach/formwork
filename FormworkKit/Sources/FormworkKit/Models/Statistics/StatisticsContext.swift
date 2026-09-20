//
//  StatisticsContext.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 19.09.26.
//

//
// Guidelines
//
// - Use the injected `calendar` for all date math (no fixed calendars, no `86_400` arithmetic).
//   Weeks start on `calendar.firstWeekday`.
// - Sessions are dated by the clock where they started: ask them which period they fall into
//   (`falls(into:in:)`, `period(of:in:)`) and at which time of day they started (`startMinute(in:)`),
//   and show their dates with `localCalendar(from:)`. `started` and `ended` are real instants, only for
//   durations, ordering, comparisons with now and relative formatting.
// - Only finished sessions count. A session belongs to the interval it started in, half-open
//   (`start <= date < end`). `DateInterval.contains` includes the end, so don't use it.
//   Intervals are whole days in `calendar`, e.g. a month, or unbounded, never ending at now.
// - Everything but streaks only counts sessions within the interval (`sessions`).
// - Streaks are what the user saw on the last day of the interval, or sees now while it's ongoing:
//   both use all history from `.distantPast` up to then (`history`), and there's none before the
//   interval starts. The week containing that day doesn't break a streak until it's over.
//

import Foundation

struct StatisticsContext {
    let calendar: Calendar

    let interval: DateInterval

    /// All finished sessions started before the end of `interval`.
    let history: [Session]

    /// The part of `history` that falls into `interval`.
    let sessions: [Session]

    init(sessions: [Session], interval: DateInterval, calendar: Calendar) {
        let earlier = DateInterval(start: .distantPast, end: interval.end)
        self.calendar = calendar
        self.interval = interval
        self.history = sessions.filter { !$0.isActive && $0.falls(into: earlier, in: calendar) }
        self.sessions = history.filter { $0.falls(into: interval, in: calendar) }
    }
}

extension StatisticsContext {
    /// Consecutive weeks with a session as seen on the last day of `interval`, or `now` while it's ongoing.
    func currentWeekStreak(at now: Date) -> Int {
        let weeks = weekStarts(of: history)
        guard let day = day(at: now), let current = calendar.dateInterval(of: .weekOfYear, for: day)?.start else { return 0 }

        var week = weeks.contains(current) ? current : adding(weeks: -1, to: current)
        var streak = 0
        while let start = week, weeks.contains(start) {
            streak += 1
            week = adding(weeks: -1, to: start)
        }
        return streak
    }

    /// The longest run of consecutive weeks with a session up to the end of `interval`, or up to `now` while it's ongoing.
    func longestWeekStreak(at now: Date) -> Int {
        guard day(at: now) != nil else { return 0 }

        var longest = 0, streak = 0, previous: Date?
        for week in weekStarts(of: history).sorted() {
            streak = previous.flatMap { adding(weeks: 1, to: $0) } == week ? streak + 1 : 1
            longest = max(longest, streak)
            previous = week
        }
        return longest
    }

    /// Sessions within `interval` per week, over the days from its start, or the first session if later,
    /// to its last day, or `now` while it's ongoing. At least a week, so a first session doesn't count as seven.
    func sessionsPerWeek(at now: Date) -> Double? {
        guard
            let day = day(at: now),
            let first = history.compactMap({ $0.period(of: .day, in: calendar)?.start }).min(),
            let end = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: day)),
            let days = calendar.dateComponents([.day], from: max(interval.start, first), to: end).day
        else { return nil }

        return Double(sessions.count) / (Double(max(days, 7)) / 7)
    }

    /// The session within `interval` that ended last.
    var lastSession: Session? {
        sessions.max { ($0.ended ?? .distantPast) < ($1.ended ?? .distantPast) }
    }

    private func weekStarts(of sessions: [Session]) -> Set<Date> {
        Set(sessions.compactMap { $0.period(of: .weekOfYear, in: calendar)?.start })
    }

    private func adding(weeks: Int, to week: Date) -> Date? {
        calendar.date(byAdding: .weekOfYear, value: weeks, to: week)
    }

    private func day(at now: Date) -> Date? {
        guard now > interval.start else { return nil }
        return now < interval.end ? now : calendar.date(byAdding: .day, value: -1, to: interval.end)
    }
}

private extension Int {
    static let minutesPerDay = 24 * 60
}

extension [Int] {
    var clockMedoid: Element? {
        sorted().min { distance(to: $0) < distance(to: $1) }
    }

    private func distance(to minute: Element) -> Element {
        reduce(0) { total, other in
            let delta = abs(other - minute)
            return total + Swift.min(delta, .minutesPerDay - delta)
        }
    }
}

extension [Double] {
    var median: Double? {
        guard !isEmpty else { return nil }
        let sorted = sorted(), middle = count / 2
        return count.isMultiple(of: 2) ? (sorted[middle - 1] + sorted[middle]) / 2 : sorted[middle]
    }
}
