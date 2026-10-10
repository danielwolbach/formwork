//
//  History.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

//
// Guidelines
//
// - A history resolves its sessions into occurrences once: every time its subject was done, dated by the day it
//   started on, on the clock where it started. Everything else reads occurrences, never sessions, so no statistic
//   switches on the subject or does date math of its own.
// - Use the history's `calendar` for all date math (no fixed calendars, no `86_400` arithmetic).
//   Weeks start on `calendar.firstWeekday`.
// - Only finished sessions count. Intervals are half-open (`start <= date < end`). `DateInterval.contains`
//   includes the end, so don't use it.
// - A history is frozen at one moment. Its periods are whole days, cut out of the days on record: from the day of
//   the first occurrence to the end of today. Statistics count a period's `interval`, charts lay out its `span`.
// - An occurrence counts as done once it was completed. Skipped ones still count where a statistic asks what was
//   planned, like the completion rate or the most skipped exercise.
// - Streaks are what the user saw on a period's last day on record: they count every session up to then, before
//   the period too.
// - Body measurements are read through `body`, which has date rules of its own.
//

import Foundation

public struct History {
    public enum Subject: Hashable {
        case all
        case workout(Workout)
        case exercise(Exercise)
        case entry(WorkoutEntry)
    }

    public let subject: Subject

    public let now: Date

    public let calendar: Calendar

    public let occurrences: [Occurrence]

    public let interval: DateInterval

    public let measurements: [BodyMeasurement: [BodyMeasurement.Sample]]

    public init(
        _ subject: Subject,
        among sessions: [Session],
        measurements: [BodyMeasurement: [BodyMeasurement.Sample]] = [:],
        at now: Date = .now,
        calendar: Calendar = .current
    ) {
        let today = calendar.startOfDay(for: now)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today
        let occurrences = sessions
            .filter { !$0.isActive && $0.falls(into: DateInterval(start: .distantPast, end: tomorrow), in: calendar) }
            .flatMap { subject.occurrences(of: $0, in: calendar) }
            .sorted { ($0.day, $0.session.startDate) < ($1.day, $1.session.startDate) }

        self.subject = subject
        self.now = now
        self.calendar = calendar
        self.occurrences = occurrences
        self.interval = DateInterval(start: occurrences.first?.day ?? tomorrow, end: tomorrow)
        self.measurements = measurements
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

    fileprivate func occurrences(of session: Session, in calendar: Calendar) -> [Occurrence] {
        let entries = (session.entries ?? []).sorted()

        return switch self {
        case .all: [Occurrence(session, in: calendar)]
        case let .workout(workout): session.workout == workout ? [Occurrence(session, in: calendar)] : []
        case let .exercise(exercise): entries.filter { $0.exercise == exercise }.map { Occurrence(session, entry: $0, in: calendar) }
        case let .entry(slot): entries.filter { $0.workoutEntry == slot }.map { Occurrence(session, entry: $0, in: calendar) }
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

    public static var chartedWeeks: Int {
        recentWeeks + baselineWeeks
    }

    public static var chartedSessions: Int {
        20
    }

    static var minimumValues: Int {
        3
    }

    public var allTime: Period {
        Period(self, span: interval)
    }

    public var recent: Period {
        days(Self.recentWeeks * 7, endingOn: now)
    }

    public var baseline: Period {
        days(Self.baselineWeeks * 7, endingOn: calendar.date(byAdding: .day, value: -Self.recentWeeks * 7, to: now) ?? now)
    }

    public var years: ClosedRange<Int> {
        let current = calendar.component(.year, from: now)
        return min(calendar.component(.year, from: interval.start), current) ... current
    }

    public func weeks(_ count: Int) -> Period {
        let current = calendar.dateInterval(of: .weekOfYear, for: now) ?? DateInterval(start: interval.end, duration: 0)
        let start = calendar.date(byAdding: .weekOfYear, value: 1 - max(count, 0), to: current.start) ?? current.start
        return Period(self, span: DateInterval(start: start, end: current.end))
    }

    public func days(_ count: Int, endingOn day: Date) -> Period {
        let end = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: day)) ?? day
        let start = calendar.date(byAdding: .day, value: -count, to: end) ?? end
        return Period(self, span: DateInterval(start: start, end: end))
    }

    public func month(containing date: Date) -> Period {
        Period(self, span: calendar.dateInterval(of: .month, for: date) ?? DateInterval(start: date, duration: 0))
    }

    public func year(_ year: Int) -> Period {
        let first = calendar.date(from: DateComponents(year: year)) ?? now
        return Period(self, span: calendar.dateInterval(of: .year, for: first) ?? DateInterval(start: first, duration: 0))
    }

    public func months(in year: Int) -> [Period] {
        let span = self.year(year).span

        return sequence(first: span.start) { calendar.date(byAdding: .month, value: 1, to: $0) }
            .prefix { $0 < span.end }
            .map(month(containing:))
    }
}
