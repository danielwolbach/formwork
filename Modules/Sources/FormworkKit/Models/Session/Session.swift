//
//  Session.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 05.09.26.
//

import Foundation
import OSLog
import SwiftData

@Model
public class Session {
    public var workout: Workout?

    public var startDate: Date = Date.distantPast

    public var endDate: Date?

    @Relationship(deleteRule: .cascade, inverse: \SessionEntry.session)
    public var entries: [SessionEntry]? = []

    var timeZoneIdentifier: String = TimeZone.current.identifier

    private var currentEntryID: UUID?

    init(workout: Workout) {
        self.workout = workout
        self.startDate = .now
        self.entries = (workout.entries ?? []).filter { !$0.isArchived }.map { .init(entry: $0) }
        self.currentEntryID = entries?.min { $0.order < $1.order }?.id
        self.timeZoneIdentifier = TimeZone.current.identifier
    }
}

extension Session {
    public static var activeDescriptor: FetchDescriptor<Session> {
        FetchDescriptor<Session>(
            predicate: #Predicate<Session> { $0.endDate == nil },
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
    }

    public static var finishedDescriptor: FetchDescriptor<Session> {
        FetchDescriptor<Session>(
            predicate: #Predicate<Session> { $0.endDate != nil },
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
    }

    public var pictogram: Pictogram {
        workout?.pictogram ?? .unknown
    }

    public var title: String {
        workout?.title ?? .init(localized: .workoutDeletedTitle)
    }

    public var endedRecently: Bool {
        guard let endDate else {
            return false
        }

        return Date.now.timeIntervalSince(endDate) < 12 * 60 * 60 // 12h
    }

    public var pendingEntries: [SessionEntry] {
        (entries ?? [])
            .filter(\.status.isPending)
            .sorted()
    }

    public var resolvedEntries: [SessionEntry] {
        (entries ?? [])
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
        (entries ?? []).count { !$0.status.isPending }
    }

    public var isActive: Bool {
        endDate == nil
    }

    public var isComplete: Bool {
        pendingEntries.isEmpty
    }

    public var currentEntry: SessionEntry? {
        get {
            entries?.first { $0.id == currentEntryID }
                ?? pendingEntries.first
                ?? orderedEntries.first
        }

        set {
            currentEntryID = newValue?.id
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

        for entry in entries ?? [] {
            if entry.status.isPending {
                entry.status = .skipped(date: .now)
            }

            if entry.shouldSaveTargetToWorkout {
                entry.workoutEntry?.target = entry.target
            }
        }

        endDate = .now

        let completed = (entries ?? []).count { $0.status.isCompleted }
        let total = entries?.count ?? 0
        Logger.session.info("Finished session with \(completed) of \(total) entries completed")
    }

    public func discard() {
        guard let modelContext else {
            return
        }

        modelContext.delete(self)

        Logger.session.info("Discarded session")
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
        currentEntry.map(undo)
    }

    public func skip(_ entry: SessionEntry) {
        guard entry.status.isPending else {
            return
        }

        guard entry !== currentEntry else {
            return skipAndAdvance()
        }

        entry.status = .skipped(date: .now)
    }

    /// The undone entry becomes current and goes first, so it's played next.
    public func undo(_ entry: SessionEntry) {
        guard !entry.status.isPending else {
            return
        }

        entry.status = .pending
        currentEntry = entry
        renumber([entry] + pendingEntries.filter { $0 !== entry })
    }

    public func remove(_ entry: SessionEntry) {
        guard entry.isAddedWithoutWorkout, entry.status.isPending else {
            return
        }

        if entry === currentEntry {
            currentEntry = pendingEntries.first { $0 !== entry } ?? resolvedEntries.last
        }

        entries?.removeAll { $0 === entry }
        modelContext?.delete(entry)
    }

    public func reorderPending(_ entries: [SessionEntry]) {
        renumber(entries)
    }

    public func add(_ exercises: [(exercise: Exercise, target: ExerciseTarget)]) {
        let firstOrder = (pendingEntries.last?.order ?? -1) + 1
        let added = exercises.enumerated().map { offset, item in
            SessionEntry(exercise: item.exercise, target: item.target, order: firstOrder + offset)
        }

        entries = (entries ?? []) + added

        if currentEntry?.status.isPending != true {
            currentEntry = added.first
        }
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

    public func wallClockTime(date: Date.FormatStyle.DateStyle? = nil) -> Date.FormatStyle {
        localCalendar(from: .current).formatStyle(date: date, time: .shortened)
    }

    public func period(of component: Calendar.Component, in calendar: Calendar) -> DateInterval? {
        calendar.dateInterval(of: component, for: localStartDate(in: calendar))
    }

    func startMinute(in calendar: Calendar) -> Int? {
        minute(of: startDate, in: calendar)
    }

    func endMinute(in calendar: Calendar) -> Int? {
        endDate.flatMap { minute(of: $0, in: calendar) }
    }

    private func minute(of date: Date, in calendar: Calendar) -> Int? {
        let time = localCalendar(from: calendar).dateComponents([.hour, .minute], from: date)
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

extension Calendar {
    fileprivate func isDayBoundary(_ date: Date) -> Bool {
        date == .distantPast || date == .distantFuture || startOfDay(for: date) == date
    }
}
