//
//  Session+Logic.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import Foundation
import SwiftData

extension Collection<Session> {
    var activeSession: Session? {
        first(where: \.isActive)
    }
}

extension ModelContext {
    @discardableResult
    func startSession(for workout: Workout) throws -> Session {
        precondition(!workout.entries.isEmpty, "Cannot start a session for an empty workout.")

        let sessions = try fetch(FetchDescriptor<Session>(sortBy: [SortDescriptor(\.started, order: .reverse)]))
        let activeSessions = sessions.filter(\.isActive)

        if let session = activeSessions.first {
            for extraSession in activeSessions.dropFirst() {
                delete(extraSession)
            }

            let oldEntries = session.entries
            session.reset(for: workout)
            oldEntries.forEach(delete)
            try save()
            return session
        }

        let session = Session(workout: workout)
        insert(session)
        try save()
        return session
    }

    func finishSession(_ session: Session) throws {
        for entry in session.entries {
            entry.workoutEntry?.target = entry.target
        }

        session.ended = .now
        try save()
    }

    func cancelSession(_ session: Session) throws {
        delete(session)
        try save()
    }
}

extension Session {
    var isActive: Bool {
        ended == nil
    }

    var orderedEntries: [SessionEntry] {
        entries.sorted()
    }

    var firstEntry: SessionEntry? {
        orderedEntries.first
    }

    func reset(for workout: Workout) {
        let entries = workout.entries.sorted()
            .map {
                SessionEntry(
                    order: $0.order,
                    exercise: $0.exercise,
                    target: $0.target,
                    workoutEntry: $0
                )
            }

        precondition(!entries.isEmpty, "Cannot reset a session for an empty workout.")

        self.started = Date.now
        self.ended = nil
        self.workout = workout
        self.entries = entries
        self.current = entries[0]
        self.activity = UUID()
    }

    var pending: [SessionEntry] {
        orderedEntries.filter { $0.status == .pending }
    }

    var completed: [SessionEntry] {
        orderedEntries.filter { $0.status != .pending }
    }

    var previous: SessionEntry? {
        let sorted = orderedEntries

        guard let currentIndex = sorted.firstIndex(where: { $0.id == current.id }), currentIndex > 0 else {
            return nil
        }

        return sorted[currentIndex - 1]
    }

    var next: SessionEntry? {
        let sorted = orderedEntries

        guard let currentIndex = sorted.firstIndex(where: { $0.id == current.id }) else {
            return nil
        }

        let nextIndex = currentIndex + 1

        guard sorted.indices.contains(nextIndex) else {
            return nil
        }

        return sorted[nextIndex]
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
        advanceCurrent(as: .done)
    }

    func skipAndAdvance() {
        advanceCurrent(as: .skipped)
    }

    func undoStatusChange(for entry: SessionEntry) {
        entry.status = .pending
        reposition(entry)
    }

    func reorderPending(_ entries: [SessionEntry]) {
        let completedEntries = completed

        for (index, entry) in (completedEntries + entries).enumerated() {
            entry.order = index
        }
    }

    private func advanceCurrent(as status: SessionEntry.Status) {
        let nextPending = pending.first { $0.id != current.id }

        current.status = status
        reposition(current)
        current = nextPending ?? current
    }

    func undoStatusChange() {
        undoStatusChange(for: current)
    }

    func reposition(_ entry: SessionEntry) {
        var sorted = orderedEntries

        guard let currentIndex = sorted.firstIndex(where: { $0.id == entry.id }) else {
            return
        }

        sorted.remove(at: currentIndex)

        let insertIndex = sorted.firstIndex { $0.status == .pending } ?? sorted.count

        sorted.insert(entry, at: insertIndex)

        for (index, entry) in sorted.enumerated() {
            entry.order = index
        }
    }
}
