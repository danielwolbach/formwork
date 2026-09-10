//
//  Session.swift
//  Formwork
//
//  Created by Daniel Wolbach on 05.09.26.
//

import Foundation
import SwiftData

@Model
final class Session {
    var started: Date = Date.distantPast

    var ended: Date?

    var workout: Workout?

    @Relationship(deleteRule: .cascade, inverse: \SessionEntry.session)
    var entries: [SessionEntry] = []

    private var currentIdentifier: UUID?

    private init(workout: Workout, entries: [SessionEntry]) {
        self.started = .now
        self.ended = nil
        self.workout = workout
        self.entries = entries
        self.currentIdentifier = entries.sorted().first?.identifier
    }
}

/// Fetching sessions out of a context.
extension Session {
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
            sortBy: [SortDescriptor(\.ended, order: .reverse)]
        )
    }

    static func active(in context: ModelContext) throws -> Session? {
        try context.fetch(activeDescriptor).first
    }
}

/// Starting, finishing and abandoning a session.
extension Session {
    static func start(_ workout: Workout, in context: ModelContext) throws -> Session {
        precondition(!workout.entries.isEmpty)

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

    var completion: Date? {
        guard let ended, entries.contains(where: \.status.isCompleted) else {
            return nil
        }

        return ended
    }

    var duration: TimeInterval? {
        guard let ended else {
            return nil
        }

        return ended.timeIntervalSince(started)
    }
}

/// The order entries are worked through in, and how much of it is left.
extension Session {
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

    var completedCount: Int {
        entries.count { $0.status.isCompleted }
    }

    var skippedCount: Int {
        entries.count { $0.status.isSkipped }
    }

    var progressText: String {
        "\(resolvedCount) / \(entries.count)"
    }

    func entry(identifiedBy identifier: UUID) -> SessionEntry? {
        entries.first { $0.identifier == identifier }
    }

    private func renumber(_ entries: [SessionEntry]) {
        for (order, entry) in entries.enumerated() {
            entry.order = order
        }
    }
}

/// Which entry the player is on, and every way of leaving it.
extension Session {
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
        guard let current else {
            return nil
        }

        let ordered = orderedEntries

        guard let index = ordered.firstIndex(where: { $0 === current }), index > ordered.startIndex else {
            return nil
        }

        return ordered[index - 1]
    }

    var next: SessionEntry? {
        guard let current else {
            return nil
        }

        let ordered = orderedEntries

        guard
            let index = ordered.firstIndex(where: { $0 === current }),
            ordered.indices.contains(index + 1)
        else {
            return nil
        }

        return ordered[index + 1]
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

    func undoStatusChange(for entry: SessionEntry) {
        guard !entry.status.isPending else {
            return
        }

        entry.status = .pending
        renumber([entry] + pending.filter { $0 !== entry })
    }

    func undoStatusChange() {
        guard let current else {
            return
        }

        undoStatusChange(for: current)
    }

    private func advance(as status: SessionEntry.Status) {
        guard let entry = current else {
            return
        }

        let following = pending.first { $0 !== entry }
        entry.status = status
        current = following ?? entry
    }
}
