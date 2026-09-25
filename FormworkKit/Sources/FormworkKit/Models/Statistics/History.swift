//
//  History.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

//
// Guidelines
//
// - Use the history's `calendar` for all date math (no fixed calendars, no `86_400` arithmetic).
//   Weeks start on `calendar.firstWeekday`.
// - Sessions are dated by the clock where they started: ask them which period they fall into
//   (`falls(into:in:)`, `period(of:in:)`) and at which time of day they started (`startMinute(in:)`),
//   and show their dates with `localCalendar(from:)`. `started` and `ended` are real instants, only for
//   durations, ordering, comparisons with now and relative formatting.
// - Only finished sessions count. A session belongs to the day it started on, and intervals are half-open
//   (`start <= date < end`). `DateInterval.contains` includes the end, so don't use it.
// - A history is frozen at one moment. Its windows are whole days, cut out of the days on record: from the
//   day of the first session to the end of today. Statistics count a window's `interval`, charts lay out its
//   `period`.
// - Streaks are what the user saw on a window's last day on record: they count every session up to then,
//   before the window too.
//

import Foundation

/// A subject's finished sessions as of one moment. Every window is cut from it, so they all agree on what
/// today is and on the day the record starts.
public struct History: Hashable {
    /// What a history is of.
    public enum Subject: Hashable {
        /// Every session, e.g. from `@Query(Session.finishedDescriptor)`.
        case all([Session])
        case workout(Workout)
        case exercise(Exercise)
        /// An exercise in one workout's slot, apart from the same exercise elsewhere, like the slot's personal
        /// best in a session's recap.
        case entry(WorkoutEntry)
    }

    /// A window of a history: the days asked for, and the sessions and entries of the ones on record. Only a
    /// history makes one, so every window goes through the same rules.
    struct Window: Hashable {
        let history: History

        /// The days asked for, e.g. a month or the last 28 days, for a chart to lay out.
        let period: DateInterval

        /// The days of `period` on record. Statistics only count these, so a month still under way, or one
        /// before the first session, isn't taken for a month without sessions.
        let interval: DateInterval

        let sessions: [Session]

        /// The entries of `sessions`, only the exercise's or the slot's when the subject is one.
        let entries: [SessionEntry]

        fileprivate init(_ history: History, period: DateInterval) {
            let start = max(period.start, history.interval.start)
            let interval = DateInterval(start: start, end: max(start, min(period.end, history.interval.end)))
            let sessions = history.sessions.filter { $0.falls(into: interval, in: history.calendar) }

            self.history = history
            self.period = period
            self.interval = interval
            self.sessions = sessions
            self.entries = sessions.flatMap(\.entries).filter { entry in
                switch history.subject {
                case .all, .workout: true
                case let .exercise(exercise): entry.exercise == exercise
                case let .entry(slot): entry.workoutEntry == slot
                }
            }
        }
    }

    let subject: Subject

    let now: Date

    let calendar: Calendar

    /// Finished sessions that started up to the end of the day `now` falls on, by the clock where they started.
    let sessions: [Session]

    /// The days on record: from the day of the first session to the end of today. Empty without sessions.
    let interval: DateInterval

    public init(_ subject: Subject, at now: Date = .now, calendar: Calendar = .current) {
        let candidates = switch subject {
        case let .all(sessions): sessions
        case let .workout(workout): workout.sessions
        case let .exercise(exercise): Array(Set(exercise.sessionEntries.compactMap(\.session)))
        case let .entry(slot): Array(Set(slot.sessionEntries.compactMap(\.session)))
        }

        let today = calendar.startOfDay(for: now)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today
        let sessions = candidates.filter { !$0.isActive && $0.falls(into: DateInterval(start: .distantPast, end: tomorrow), in: calendar) }
        let first = sessions.compactMap { $0.period(of: .day, in: calendar)?.start }.min()

        self.subject = subject
        self.now = now
        self.calendar = calendar
        self.sessions = sessions
        self.interval = DateInterval(start: first ?? tomorrow, end: tomorrow)
    }
}

// MARK: - Windows

extension History {
    /// How many days a card looks back.
    static var recentDays: Int {
        28
    }

    /// How many days before those a trend compares them with.
    static var baselineDays: Int {
        84
    }

    /// Everything on record.
    var allTime: Window {
        Window(self, period: interval)
    }

    /// The days a card looks at: the last `recentDays`, today included.
    var recent: Window {
        days(Self.recentDays, endingOn: now)
    }

    /// The `baselineDays` before the recent ones, which a trend compares them with.
    var baseline: Window {
        days(Self.baselineDays, endingOn: calendar.date(byAdding: .day, value: -Self.recentDays, to: now) ?? now)
    }

    /// The years there's anything to page through: from the first session's to the current one.
    var years: ClosedRange<Int> {
        let current = calendar.component(.year, from: now)
        return min(calendar.component(.year, from: interval.start), current) ... current
    }

    /// The last `count` calendar weeks, the current one included. Whole weeks, so a grid of them has none cut
    /// off.
    func weeks(_ count: Int) -> Window {
        let current = calendar.dateInterval(of: .weekOfYear, for: now) ?? DateInterval(start: interval.end, duration: 0)
        let start = calendar.date(byAdding: .weekOfYear, value: 1 - max(count, 0), to: current.start) ?? current.start
        return Window(self, period: DateInterval(start: start, end: current.end))
    }

    /// The calendar month `date` falls in.
    func month(containing date: Date) -> Window {
        Window(self, period: calendar.dateInterval(of: .month, for: date) ?? DateInterval(start: date, duration: 0))
    }

    /// The calendar year.
    func year(_ year: Int) -> Window {
        let first = calendar.date(from: DateComponents(year: year)) ?? now
        return Window(self, period: calendar.dateInterval(of: .year, for: first) ?? DateInterval(start: first, duration: 0))
    }

    /// The `count` days up to and including the one `day` falls on.
    func days(_ count: Int, endingOn day: Date) -> Window {
        let end = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: day)) ?? day
        let start = calendar.date(byAdding: .day, value: -count, to: end) ?? end
        return Window(self, period: DateInterval(start: start, end: end))
    }
}

extension History.Window {
    /// How many weeks `interval` spans, at least one, so a first session doesn't count as seven a week. There's
    /// none without a day on record.
    var lengthInWeeks: Double? {
        guard let days = history.calendar.dateComponents([.day], from: interval.start, to: interval.end).day, days > 0 else {
            return nil
        }

        return Double(max(days, 7)) / 7
    }
}
