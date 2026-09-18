//
//  SessionTests.swift
//  FormworkKitTests
//
//  Created by Daniel Wolbach on 18.09.26.
//

@testable import FormworkKit
import Foundation
import SwiftData
import Testing

@MainActor
struct SessionLifecycleTests {
    let store: TestStore

    init() throws {
        self.store = try TestStore()
    }

    @Test func startCopiesWorkoutEntriesInOrder() throws {
        let session = try store.startSession()
        let active = try Session.active(in: store.context)
        let allPending = session.entries.allSatisfy(\.status.isPending)

        #expect(session.isActive)
        #expect(session.workout === store.workout)
        #expect(session.orderedEntries.map(\.title) == ["Squat", "Bench Press", "Deadlift"])
        #expect(allPending)
        #expect(active === session)
    }

    @Test func startReplacesRunningSessionButKeepsFinishedOnes() throws {
        let finished = try store.startSession()
        finished.finish()
        _ = try store.startSession()
        let running = try store.startSession()
        try store.context.save()

        let sessions = try store.context.fetch(FetchDescriptor<Session>())
        let active = try Session.active(in: store.context)

        #expect(sessions.count == 2)
        #expect(sessions.contains { $0 === finished })
        #expect(active === running)
    }

    @Test func finishWritesTargetsBackToWorkout() throws {
        let session = try store.startSession()
        session.current?.target = .bodyweight(target: .init(sets: 5, reps: 12))
        session.finish()
        try store.context.save()

        #expect(!session.isActive)
        #expect(session.duration != nil)
        #expect(store.workout.entries.sorted().first?.target.bodyweightTarget == .init(sets: 5, reps: 12))
        #expect(try Session.active(in: store.context) == nil)
    }

    @Test func finishTwiceKeepsFirstEndDate() throws {
        let session = try store.startSession()
        session.finish()
        let ended = session.ended

        session.finish()

        #expect(session.ended == ended)
    }

    @Test func cancelDeletesSessionAndEntries() throws {
        let session = try store.startSession()
        session.cancel()
        try store.context.save()

        #expect(try store.context.fetchCount(FetchDescriptor<Session>()) == 0)
        #expect(try store.context.fetchCount(FetchDescriptor<SessionEntry>()) == 0)
    }
}

@MainActor
struct SessionNavigationTests {
    let store: TestStore

    init() throws {
        self.store = try TestStore()
    }

    @Test func startsAtFirstEntry() throws {
        let session = try store.startSession()

        #expect(session.current?.title == "Squat")
        #expect(session.previous == nil)
        #expect(session.next?.title == "Bench Press")
        #expect(session.resolvedCount == 0)
        #expect(!session.isComplete)
    }

    @Test func movesWithinBounds() throws {
        let session = try store.startSession()

        session.moveToPrevious()
        #expect(session.current?.title == "Squat")

        session.moveToNext()
        session.moveToNext()
        session.moveToNext()
        #expect(session.current?.title == "Deadlift")
        #expect(session.next == nil)
    }

    @Test func completingAdvancesToNextPendingEntry() throws {
        let session = try store.startSession()

        session.completeAndAdvance()

        #expect(session.orderedEntries.first?.status.isCompleted == true)
        #expect(session.current?.title == "Bench Press")
        #expect(session.resolvedCount == 1)
    }

    @Test func skippingMarksEntryAsSkipped() throws {
        let session = try store.startSession()

        session.skipAndAdvance()

        #expect(session.orderedEntries.first?.status.isSkipped == true)
        #expect(session.current?.title == "Bench Press")
    }

    @Test func completingOutOfOrderReturnsToFirstPendingEntry() throws {
        let session = try store.startSession()

        session.moveToNext()
        session.completeAndAdvance()

        #expect(session.current?.title == "Squat")
        #expect(session.orderedEntries.map(\.title) == ["Bench Press", "Squat", "Deadlift"])
    }

    @Test func completingLastPendingEntryStaysOnIt() throws {
        let session = try store.startSession()

        session.completeAndAdvance()
        session.completeAndAdvance()
        session.completeAndAdvance()

        #expect(session.isComplete)
        #expect(session.resolvedCount == 3)
        #expect(session.current?.title == "Deadlift")
    }
}

@MainActor
struct SessionOrderTests {
    let store: TestStore

    init() throws {
        self.store = try TestStore()
    }

    @Test func historyIsOrderedByResolutionDate() throws {
        let session = try store.startSession()
        let entries = session.orderedEntries

        entries[2].status = .completed(at: Date(timeIntervalSince1970: 1))
        entries[0].status = .skipped(at: Date(timeIntervalSince1970: 2))

        #expect(session.history.map(\.title) == ["Deadlift", "Squat"])
        #expect(session.orderedEntries.map(\.title) == ["Deadlift", "Squat", "Bench Press"])
    }

    @Test func historyWithSameDateKeepsWorkoutOrder() throws {
        let session = try store.startSession()
        let entries = session.orderedEntries
        let date = Date(timeIntervalSince1970: 1)

        entries[2].status = .completed(at: date)
        entries[0].status = .completed(at: date)

        #expect(session.history.map(\.title) == ["Squat", "Deadlift"])
    }

    @Test func undoMakesEntryPendingAgain() throws {
        let session = try store.startSession()
        session.completeAndAdvance()
        session.completeAndAdvance()
        session.moveToPrevious()
        session.moveToPrevious()

        session.undoStatusChange()

        #expect(session.current?.title == "Squat")
        #expect(session.current?.status.isPending == true)
        #expect(session.pending.map(\.title) == ["Squat", "Deadlift"])
        #expect(session.orderedEntries.map(\.title) == ["Bench Press", "Squat", "Deadlift"])
    }

    @Test func undoneEntryComesBeforeOtherPendingEntries() throws {
        let session = try store.startSession()
        session.moveToNext()
        session.moveToNext()
        session.completeAndAdvance()
        session.moveToPrevious()

        session.undoStatusChange()

        #expect(session.current?.title == "Deadlift")
        #expect(session.orderedEntries.map(\.title) == ["Deadlift", "Squat", "Bench Press"])
    }

    @Test func undoOnPendingEntryDoesNothing() throws {
        let session = try store.startSession()

        session.undoStatusChange()

        #expect(session.current?.title == "Squat")
        #expect(session.orderedEntries.map(\.order) == [0, 1, 2])
    }
}

struct SessionEntryStatusTests {
    @Test func pending() {
        let status = SessionEntry.Status.pending

        #expect(status.isPending)
        #expect(!status.isCompleted)
        #expect(!status.isSkipped)
        #expect(status.resolved == nil)
    }

    @Test func completed() {
        let date = Date(timeIntervalSince1970: 1)
        let status = SessionEntry.Status.completed(at: date)

        #expect(!status.isPending)
        #expect(status.isCompleted)
        #expect(!status.isSkipped)
        #expect(status.resolved == date)
    }

    @Test func skipped() {
        let date = Date(timeIntervalSince1970: 1)
        let status = SessionEntry.Status.skipped(at: date)

        #expect(!status.isPending)
        #expect(!status.isCompleted)
        #expect(status.isSkipped)
        #expect(status.resolved == date)
    }
}
