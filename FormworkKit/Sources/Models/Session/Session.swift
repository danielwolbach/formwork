//
//  Session.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 05.09.26.
//

import Foundation
import SwiftData

@Model
public class Session {
    public var workout: Workout?

    public var startDate: Date = Date.distantPast

    public var endDate: Date?

    @Relationship(deleteRule: .cascade, inverse: \SessionEntry.session)
    public var entries: [SessionEntry] = []

    var timeZoneIdentifier: String = TimeZone.current.identifier

    private var currentEntryIdentifier: UUID?

    init(workout: Workout) {
        self.workout = workout
        self.startDate = .now
        self.entries = workout.entries.map { .init(entry: $0) }
        self.currentEntryIdentifier = entries.min { $0.order < $1.order }?.identifier
        self.timeZoneIdentifier = TimeZone.current.identifier
    }
}

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

    public var endedRecently: Bool {
        guard let endDate else {
            return false
        }

        return Date.now.timeIntervalSince(endDate) < 12 * 60 * 60 // 12h
    }

    public var pendingEntries: [SessionEntry] {
        entries
            .filter(\.status.isPending)
            .sorted()
    }

    public var resolvedEntries: [SessionEntry] {
        entries
            .filter { !$0.status.isPending }
            .sorted { lhs, rhs in
                let left = lhs.status.resolvedDate ?? .distantPast
                let right = rhs.status.resolvedDate ?? .distantPast
                return left == right ? lhs.order < rhs.order : left < right
            }
    }

    public var orderedEntries: [SessionEntry] {
        resolvedEntries + pendingEntries
    }

    public var resolvedCount: Int {
        entries.count { !$0.status.isPending }
    }

    public var isActive: Bool {
        endDate == nil
    }

    public var isComplete: Bool {
        pendingEntries.isEmpty
    }

    public var currentEntry: SessionEntry? {
        get {
            entries.first { $0.identifier == currentEntryIdentifier }
                ?? pendingEntries.first
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

    public var duration: TimeInterval? {
        guard let endDate else {
            return nil
        }

        return endDate.timeIntervalSince(startDate)
    }

    private var timeZone: TimeZone {
        TimeZone(identifier: timeZoneIdentifier) ?? .current
    }

    public static func active(in context: ModelContext) throws -> Session? {
        try context.fetch(activeDescriptor).first
    }

    public func finish() {
        guard isActive else {
            return
        }

        for entry in entries {
            if entry.status.isPending {
                entry.status = .skipped(date: .now)
            }

            entry.workoutEntry?.target = entry.target
        }

        endDate = .now
    }

    public func discard() {
        guard let modelContext else {
            return
        }

        modelContext.delete(self)
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
        advance(as: .completed(date: .now))
    }

    public func skipAndAdvance() {
        advance(as: .skipped(date: .now))
    }

    public func undoCurrentStatus() {
        guard let entry = currentEntry, !entry.status.isPending else {
            return
        }

        entry.status = .pending
        renumber([entry] + pendingEntries.filter { $0 !== entry })
    }

    public func localCalendar(from calendar: Calendar) -> Calendar {
        var local = calendar
        local.timeZone = timeZone
        return local
    }

    public func localStartDate(in calendar: Calendar) -> Date {
        guard timeZone != calendar.timeZone else {
            return startDate
        }

        let components = localCalendar(from: calendar).dateComponents([.era, .year, .month, .day, .hour, .minute, .second], from: startDate)
        return calendar.date(from: components) ?? startDate
    }

    public func falls(into interval: DateInterval, in calendar: Calendar) -> Bool {
        assert(
            calendar.isDayBoundary(interval.start) && calendar.isDayBoundary(interval.end),
            "\(interval) isn't made of whole days, so it can't be compared with wall-clock time."
        )
        let start = localStartDate(in: calendar)
        return interval.start <= start && start < interval.end
    }

    public func wallClockTime() -> Date.FormatStyle {
        localCalendar(from: .current).formatStyle(time: .shortened)
    }

    public func period(of component: Calendar.Component, in calendar: Calendar) -> DateInterval? {
        calendar.dateInterval(of: component, for: localStartDate(in: calendar))
    }

    func startMinute(in calendar: Calendar) -> Int? {
        let time = localCalendar(from: calendar).dateComponents([.hour, .minute], from: startDate)
        guard let hour = time.hour, let minute = time.minute else {
            return nil
        }
        return hour * 60 + minute
    }

    private func renumber(_ entries: [SessionEntry]) {
        for (order, entry) in entries.enumerated() {
            entry.order = order
        }
    }

    private func advance(as status: SessionEntry.Status) {
        guard let entry = currentEntry else {
            return
        }

        let following = pendingEntries.first { $0 !== entry }
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

extension Session: Displayable {
    public var pictogram: Pictogram {
        workout?.pictogram ?? .unknown
    }

    public var title: String {
        workout?.title ?? .init(localized: .placeholder)
    }

    public var subtitle: String? {
        let local = localCalendar(from: .current)
        return startDate.formatted(local.formatStyle(date: .numeric, time: .shortened))
    }
}

extension Calendar {
    fileprivate func isDayBoundary(_ date: Date) -> Bool {
        date == .distantPast || date == .distantFuture || startOfDay(for: date) == date
    }
}
