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
// - A statistic that asks when, how often or how long the subject was done reads the window's `completions` (a
//   workout's finished sessions, an exercise's completed entries) instead of switching on the subject itself.
// - Body measurements come from Health, not sessions, so their windows only end at today and don't start at the
//   first session: someone who weighed in for years before their first session still gets a trend.
//

import Foundation

public struct History: Hashable {
    public enum Subject: Hashable {
        case all
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

        let completions: [Completion]

        fileprivate init(_ history: History, period: DateInterval, only session: Session? = nil) {
            let start = max(period.start, history.interval.start)
            let interval = DateInterval(start: start, end: max(start, min(period.end, history.interval.end)))
            let sessions = history.sessions.filter { candidate in
                candidate.falls(into: interval, in: history.calendar) && (session.map { $0 === candidate } ?? true)
            }
            let entries = sessions.flatMap { $0.entries ?? [] }.filter { entry in
                switch history.subject {
                case .all, .workout: true
                case let .exercise(exercise): entry.exercise == exercise
                case let .entry(slot): entry.workoutEntry == slot
                }
            }

            self.history = history
            self.period = period
            self.interval = interval
            self.sessions = sessions
            self.entries = entries
            self.completions = switch history.subject {
            case .all, .workout:
                sessions.compactMap { session in
                    session.endDate.map { Completion(session: session, date: $0, duration: session.duration) }
                }
            case .exercise, .entry:
                entries.compactMap { entry -> Completion? in
                    guard entry.status.isCompleted, let session = entry.session, let date = entry.status.resolvedDate else {
                        return nil
                    }

                    return Completion(session: session, date: date, duration: entry.duration)
                }
            }
        }
    }

    struct Completion: Hashable {
        let session: Session

        let date: Date

        let duration: TimeInterval?
    }

    public let subject: Subject

    public let now: Date

    public let calendar: Calendar

    public let sessions: [Session]

    public let interval: DateInterval

    public let measurements: BodyMeasurements

    public init(
        _ subject: Subject,
        among candidates: [Session],
        measurements: BodyMeasurements = BodyMeasurements(),
        at now: Date = .now,
        calendar: Calendar = .current
    ) {
        let today = calendar.startOfDay(for: now)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today
        let sessions = candidates.filter { session in
            !session.isActive && session.falls(into: DateInterval(start: .distantPast, end: tomorrow), in: calendar) && subject.includes(session)
        }
        let first = sessions.compactMap { $0.period(of: .day, in: calendar)?.start }.min()

        self.subject = subject
        self.now = now
        self.calendar = calendar
        self.sessions = sessions
        self.interval = DateInterval(start: first ?? tomorrow, end: tomorrow)
        self.measurements = measurements
    }
}

extension History.Window {
    public var measurements: BodyMeasurements {
        history.measurements.within(measurementInterval)
    }

    var measurementInterval: DateInterval {
        DateInterval(start: period.start, end: max(period.start, min(period.end, history.interval.end)))
    }
}

extension History.Subject {
    public var title: String? {
        switch self {
        case .all: nil
        case let .workout(workout): workout.title
        case let .exercise(exercise): exercise.title
        case let .entry(slot): slot.title
        }
    }

    var exercise: Exercise? {
        switch self {
        case .all, .workout: nil
        case let .exercise(exercise): exercise
        case let .entry(slot): slot.exercise
        }
    }

    fileprivate func includes(_ session: Session) -> Bool {
        switch self {
        case .all: true
        case let .workout(workout): session.workout == workout
        case let .exercise(exercise): (session.entries ?? []).contains { $0.exercise == exercise }
        case let .entry(slot): (session.entries ?? []).contains { $0.workoutEntry == slot }
        }
    }
}

extension History {
    public static var recentWeeks: Int {
        4
    }

    public static var baselineWeeks: Int {
        12
    }

    public static var comparedWeeks: Int {
        recentWeeks + baselineWeeks
    }

    public static var recentDays: Int {
        recentWeeks * 7
    }

    public static var baselineDays: Int {
        baselineWeeks * 7
    }

    public static var chartedSessions: Int {
        20
    }

    static var minimumValues: Int {
        3
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

    /// Just this session, so a window's values read as that session's own.
    public func session(_ session: Session) -> Window {
        let day = session.period(of: .day, in: calendar) ?? DateInterval(start: session.startDate, duration: 0)
        return Window(self, period: day, only: session)
    }

    public func days(_ count: Int, endingOn day: Date) -> Window {
        let end = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: day)) ?? day
        let start = calendar.date(byAdding: .day, value: -count, to: end) ?? end
        return Window(self, period: DateInterval(start: start, end: end))
    }
}
