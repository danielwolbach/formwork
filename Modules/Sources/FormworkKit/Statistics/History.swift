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
//   and show their dates with `localCalendar(from:)`. `startDate` and `endDate` are real instants, only for
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

public struct History: Hashable {
    public enum Subject: Hashable {
        case all([Session])
        case workout(Workout)
        case exercise(Exercise)
        case entry(WorkoutEntry)
    }

    public struct Window: Hashable {
        public let history: History

        public let period: DateInterval

        public let interval: DateInterval

        public let sessions: [Session]

        public let entries: [SessionEntry]

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

    public let subject: Subject

    public let now: Date

    public let calendar: Calendar

    public let sessions: [Session]

    public let interval: DateInterval

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

extension History.Subject {
    public var title: String {
        switch self {
        case .all: String(localized: .placeholder)
        case let .workout(workout): workout.title
        case let .exercise(exercise): exercise.title
        case let .entry(slot): slot.title
        }
    }
}

extension History {
    public static var recentDays: Int {
        28
    }

    public static var baselineDays: Int {
        84
    }

    public var allTime: Window {
        Window(self, period: interval)
    }

    public var recent: Window {
        days(Self.recentDays, endingOn: now)
    }

    public var baseline: Window {
        days(Self.baselineDays, endingOn: calendar.date(byAdding: .day, value: -Self.recentDays, to: now) ?? now)
    }

    public var years: ClosedRange<Int> {
        let current = calendar.component(.year, from: now)
        return min(calendar.component(.year, from: interval.start), current) ... current
    }

    public func weeks(_ count: Int) -> Window {
        let current = calendar.dateInterval(of: .weekOfYear, for: now) ?? DateInterval(start: interval.end, duration: 0)
        let start = calendar.date(byAdding: .weekOfYear, value: 1 - max(count, 0), to: current.start) ?? current.start
        return Window(self, period: DateInterval(start: start, end: current.end))
    }

    public func month(containing date: Date) -> Window {
        Window(self, period: calendar.dateInterval(of: .month, for: date) ?? DateInterval(start: date, duration: 0))
    }

    public func year(_ year: Int) -> Window {
        let first = calendar.date(from: DateComponents(year: year)) ?? now
        return Window(self, period: calendar.dateInterval(of: .year, for: first) ?? DateInterval(start: first, duration: 0))
    }

    public func days(_ count: Int, endingOn day: Date) -> Window {
        let end = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: day)) ?? day
        let start = calendar.date(byAdding: .day, value: -count, to: end) ?? end
        return Window(self, period: DateInterval(start: start, end: end))
    }
}

extension History.Window {
    public var lengthInWeeks: Double? {
        guard let days = history.calendar.dateComponents([.day], from: interval.start, to: interval.end).day, days > 0 else {
            return nil
        }

        return Double(max(days, 7)) / 7
    }

    public var streakWeeks: (weeks: Set<Date>, current: Date)? {
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
