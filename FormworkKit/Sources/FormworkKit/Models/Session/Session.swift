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
    public var startDate: Date = Date.distantPast

    public var endDate: Date?

    public var workout: Workout?

    @Relationship(deleteRule: .cascade, inverse: \SessionEntry.session)
    public var entries: [SessionEntry] = []

    var timeZoneIdentifier: String = TimeZone.current.identifier

    private var currentEntryIdentifier: UUID?

    private init(workout: Workout, entries: [SessionEntry]) {
        self.startDate = .now
        self.endDate = nil
        self.workout = workout
        self.entries = entries
        self.currentEntryIdentifier = entries.sorted().first?.identifier
        self.timeZoneIdentifier = TimeZone.current.identifier
    }
}

/// Fetching sessions out of a context.
extension Session {
    public static var activeDescriptor: FetchDescriptor<Session> {
        var descriptor = FetchDescriptor<Session>(
            predicate: #Predicate<Session> { $0.endDate == nil },
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return descriptor
    }

    public static var finishedDescriptor: FetchDescriptor<Session> {
        FetchDescriptor<Session>(
            predicate: #Predicate<Session> { $0.endDate != nil },
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
    }

    public static func active(in context: ModelContext) throws -> Session? {
        try context.fetch(activeDescriptor).first
    }
}

/// Starting, finishing and abandoning a session.
extension Session {
    public var isActive: Bool {
        endDate == nil
    }

    public var endedRecently: Bool {
        guard let endDate else {
            return false
        }
        return Date.now.timeIntervalSince(endDate) < 12 * 60 * 60 // 12h
    }

    public var duration: TimeInterval? {
        guard let endDate else {
            return nil
        }

        return endDate.timeIntervalSince(startDate)
    }

    @discardableResult
    public static func start(_ workout: Workout, in context: ModelContext) throws -> Session {
        let entries = workout.entries.map { workoutEntry in SessionEntry(workoutEntry: workoutEntry) }
        let runningDescriptor = FetchDescriptor<Session>(predicate: #Predicate<Session> { $0.endDate == nil })

        for running in try context.fetch(runningDescriptor) {
            context.delete(running)
        }

        let session = Session(workout: workout, entries: entries)
        context.insert(session)

        return session
    }

    public func finish() {
        guard isActive else {
            return
        }

        for entry in entries {
            entry.workoutEntry?.target = entry.target
        }

        endDate = .now
    }

    public func cancel() {
        guard let modelContext else {
            return
        }

        modelContext.delete(self)
    }
}

/// The order entries are worked through in, and how much of it is left.
extension Session {
    public var pending: [SessionEntry] {
        entries
            .filter(\.status.isPending)
            .sorted()
    }

    public var history: [SessionEntry] {
        entries
            .filter { !$0.status.isPending }
            .sorted { lhs, rhs in
                let left = lhs.status.resolvedDate ?? .distantPast
                let right = rhs.status.resolvedDate ?? .distantPast
                return left == right ? lhs.order < rhs.order : left < right
            }
    }

    public var orderedEntries: [SessionEntry] {
        history + pending
    }

    public var isComplete: Bool {
        pending.isEmpty
    }

    public var resolvedCount: Int {
        entries.count { !$0.status.isPending }
    }

    private func renumber(_ entries: [SessionEntry]) {
        for (order, entry) in entries.enumerated() {
            entry.order = order
        }
    }
}

/// Which entry the player is on, and every way of leaving it.
extension Session {
    public var currentEntry: SessionEntry? {
        get {
            entries.first { $0.identifier == currentEntryIdentifier }
                ?? pending.first
                ?? orderedEntries.first
        }
        set {
            currentEntryIdentifier = newValue?.identifier
        }
    }

    public var previousEntry: SessionEntry? {
        neighbor(by: -1)
    }

    public var nextEntry: SessionEntry? {
        neighbor(by: 1)
    }

    public func moveToPrevious() {
        guard let previousEntry else {
            return
        }

        currentEntry = previousEntry
    }

    public func moveToNext() {
        guard let nextEntry else {
            return
        }

        currentEntry = nextEntry
    }

    public func completeAndAdvance() {
        advance(as: .completed(at: .now))
    }

    public func skipAndAdvance() {
        advance(as: .skipped(at: .now))
    }

    public func undoStatusChange() {
        guard let entry = currentEntry, !entry.status.isPending else {
            return
        }

        entry.status = .pending
        renumber([entry] + pending.filter { $0 !== entry })
    }

    private func advance(as status: SessionEntry.Status) {
        guard let entry = currentEntry else {
            return
        }

        let following = pending.first { $0 !== entry }
        entry.status = status
        currentEntry = following ?? entry
    }

    private func neighbor(by offset: Int) -> SessionEntry? {
        let ordered = orderedEntries

        guard let currentEntry, let index = ordered.firstIndex(where: { $0 === currentEntry }) else {
            return nil
        }

        return ordered.indices.contains(index + offset) ? ordered[index + offset] : nil
    }
}

/// Wall-clock time: where a session falls in the calendar, by the clock where it started.
extension Session {
    private var timeZone: TimeZone {
        TimeZone(identifier: timeZoneIdentifier) ?? .current
    }

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
        let start = localStartDate(in: calendar)
        return interval.start <= start && start < interval.end
    }

    func period(of component: Calendar.Component, in calendar: Calendar) -> DateInterval? {
        calendar.dateInterval(of: component, for: localStartDate(in: calendar))
    }

    func startMinute(in calendar: Calendar) -> Int? {
        let time = localCalendar(from: calendar).dateComponents([.hour, .minute], from: startDate)
        guard let hour = time.hour, let minute = time.minute else {
            return nil
        }
        return hour * 60 + minute
    }

    private func localStartDate(in calendar: Calendar) -> Date {
        guard timeZone != calendar.timeZone else {
            return startDate
        }

        let components = localCalendar(from: calendar).dateComponents([.year, .month, .day, .hour, .minute, .second], from: startDate)
        return calendar.date(from: components) ?? startDate
    }
}

extension Session {
    public static func countTitle(_ count: Int) -> LocalizedStringResource {
        .sessionCountTitle(count)
    }
}

extension Session: Displayable {
    public var title: String {
        workout?.title ?? String(localized: .workoutUnknownTitle)
    }

    public var subtitle: String? {
        let local = localCalendar(from: .current)
        return startDate.formatted(local.formatStyle(date: .numeric, time: .shortened))
    }

    public var pictogram: Pictogram {
        workout?.pictogram ?? .unknown
    }
}

extension Calendar {
    fileprivate func isDayBoundary(_ date: Date) -> Bool {
        date == .distantPast || date == .distantFuture || startOfDay(for: date) == date
    }
}
