//
//  Session.swift
//  Formwork
//
//  Created by Daniel Wolbach on 05.09.26.
//

import Foundation
import SwiftData

@Model
public final class Session {
    public var started: Date = Date.distantPast

    public var ended: Date?

    public var workout: Workout?

    @Relationship(deleteRule: .cascade, inverse: \SessionEntry.session)
    public var entries: [SessionEntry] = []

    private var currentIdentifier: UUID?

    var timeZoneIdentifier: String = TimeZone.current.identifier

    private init(workout: Workout, entries: [SessionEntry]) {
        self.started = .now
        self.ended = nil
        self.workout = workout
        self.entries = entries
        self.currentIdentifier = entries.sorted().first?.identifier
        self.timeZoneIdentifier = TimeZone.current.identifier
    }
}

/// Fetching sessions out of a context.
public extension Session {
    static var activeDescriptor: FetchDescriptor<Session> {
        var descriptor = FetchDescriptor<Session>(
            predicate: #Predicate<Session> { $0.ended == nil },
            sortBy: [SortDescriptor(\.started, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return descriptor
    }

    static var finishedDescriptor: FetchDescriptor<Session> {
        FetchDescriptor<Session>(
            predicate: #Predicate<Session> { $0.ended != nil },
            sortBy: [SortDescriptor(\.started, order: .reverse)]
        )
    }

    static func active(in context: ModelContext) throws -> Session? {
        try context.fetch(activeDescriptor).first
    }
}

/// Starting, finishing and abandoning a session.
public extension Session {
    @discardableResult
    static func start(_ workout: Workout, in context: ModelContext) throws -> Session {
        let entries = workout.entries.map { workoutEntry in SessionEntry(workoutEntry: workoutEntry) }
        let runningDescriptor = FetchDescriptor<Session>(predicate: #Predicate<Session> { $0.ended == nil })

        for running in try context.fetch(runningDescriptor) {
            context.delete(running)
        }

        let session = Session(workout: workout, entries: entries)
        context.insert(session)

        return session
    }

    func finish() {
        guard isActive else {
            return
        }

        for entry in entries {
            entry.workoutEntry?.target = entry.target
        }

        ended = .now
    }

    func cancel() {
        guard let modelContext else {
            return
        }

        modelContext.delete(self)
    }

    var isActive: Bool {
        ended == nil
    }

    var duration: TimeInterval? {
        guard let ended else {
            return nil
        }

        return ended.timeIntervalSince(started)
    }
}

/// The order entries are worked through in, and how much of it is left.
public extension Session {
    var pending: [SessionEntry] {
        entries
            .filter(\.status.isPending)
            .sorted()
    }

    var history: [SessionEntry] {
        entries
            .filter { !$0.status.isPending }
            .sorted { lhs, rhs in
                let left = lhs.status.resolved ?? .distantPast
                let right = rhs.status.resolved ?? .distantPast
                return left == right ? lhs.order < rhs.order : left < right
            }
    }

    var orderedEntries: [SessionEntry] {
        history + pending
    }

    var isComplete: Bool {
        pending.isEmpty
    }

    var resolvedCount: Int {
        entries.count { !$0.status.isPending }
    }

    private func renumber(_ entries: [SessionEntry]) {
        for (order, entry) in entries.enumerated() {
            entry.order = order
        }
    }
}

/// Which entry the player is on, and every way of leaving it.
public extension Session {
    var current: SessionEntry? {
        get {
            entries.first { $0.identifier == currentIdentifier }
                ?? pending.first
                ?? orderedEntries.first
        }
        set {
            currentIdentifier = newValue?.identifier
        }
    }

    var previous: SessionEntry? {
        neighbor(by: -1)
    }

    var next: SessionEntry? {
        neighbor(by: 1)
    }

    func moveToPrevious() {
        guard let previous else {
            return
        }

        current = previous
    }

    func moveToNext() {
        guard let next else {
            return
        }

        current = next
    }

    func completeAndAdvance() {
        advance(as: .completed(at: .now))
    }

    func skipAndAdvance() {
        advance(as: .skipped(at: .now))
    }

    func undoStatusChange() {
        guard let entry = current, !entry.status.isPending else {
            return
        }

        entry.status = .pending
        renumber([entry] + pending.filter { $0 !== entry })
    }

    private func advance(as status: SessionEntry.Status) {
        guard let entry = current else {
            return
        }

        let following = pending.first { $0 !== entry }
        entry.status = status
        current = following ?? entry
    }

    private func neighbor(by offset: Int) -> SessionEntry? {
        let ordered = orderedEntries

        guard let current, let index = ordered.firstIndex(where: { $0 === current }) else {
            return nil
        }

        return ordered.indices.contains(index + offset) ? ordered[index + offset] : nil
    }
}

/// Wall-clock time: where a session falls in the calendar, by the clock where it started.
extension Session {
    /// The time of day on the clock the session was recorded on, so an exercise resolved at 08:00 still
    /// reads as 08:00 wherever it is read back.
    public func wallClockTime() -> Date.FormatStyle {
        localCalendar(from: .current).formatStyle(time: .shortened)
    }

    func localCalendar(from calendar: Calendar) -> Calendar {
        var local = calendar
        local.timeZone = timeZone
        return local
    }

    func falls(into interval: DateInterval, in calendar: Calendar) -> Bool {
        assert(
            calendar.isDayBoundary(interval.start) && calendar.isDayBoundary(interval.end),
            "\(interval) isn't made of whole days, so it can't be compared with wall-clock time."
        )
        let started = localStarted(in: calendar)
        return interval.start <= started && started < interval.end
    }

    func period(of component: Calendar.Component, in calendar: Calendar) -> DateInterval? {
        calendar.dateInterval(of: component, for: localStarted(in: calendar))
    }

    func startMinute(in calendar: Calendar) -> Int? {
        let time = localCalendar(from: calendar).dateComponents([.hour, .minute], from: started)
        guard let hour = time.hour, let minute = time.minute else { return nil }
        return hour * 60 + minute
    }
}

private extension Session {
    var timeZone: TimeZone {
        TimeZone(identifier: timeZoneIdentifier) ?? .current
    }

    func localStarted(in calendar: Calendar) -> Date {
        guard timeZone != calendar.timeZone else { return started }

        let components = localCalendar(from: calendar).dateComponents([.year, .month, .day, .hour, .minute, .second], from: started)
        return calendar.date(from: components) ?? started
    }
}

private extension Calendar {
    func isDayBoundary(_ date: Date) -> Bool {
        date == .distantPast || date == .distantFuture || startOfDay(for: date) == date
    }
}
