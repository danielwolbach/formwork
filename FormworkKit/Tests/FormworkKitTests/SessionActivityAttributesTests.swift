//
//  SessionActivityAttributesTests.swift
//  FormworkKitTests
//
//  Created by Daniel Wolbach on 18.09.26.
//

@testable import FormworkKit
import Foundation
import Testing

@MainActor
struct SessionActivityAttributesTests {
    let store: TestStore

    init() throws {
        self.store = try TestStore()
    }

    @Test func mapsCurrentEntry() throws {
        let session = try store.startSession()

        let state = try #require(SessionActivityAttributes.ContentState(session: session))

        #expect(state.title == "Squat")
        #expect(state.pictogram == ExerciseType.bodyweight.pictogram)
        #expect(state.workout == store.workout.pictogram)
        #expect(state.status == nil)
        #expect(state.started == session.started)
        #expect(state.resolved == 0)
        #expect(state.total == 3)
        #expect(state.canMoveForward)
        #expect(!state.canMoveBackward)
    }

    @Test func showsStatusOfResolvedEntry() throws {
        let session = try store.startSession()
        session.completeAndAdvance()
        session.moveToPrevious()

        let state = try #require(SessionActivityAttributes.ContentState(session: session))

        #expect(state.title == "Squat")
        #expect(state.status == SessionEntry.Status.completed(at: .now).pictogram)
        #expect(state.resolved == 1)
    }

    @Test func differsBetweenSessionsOfSameWorkout() throws {
        let first = try #require(try SessionActivityAttributes.ContentState(session: store.startSession()))
        let second = try #require(try SessionActivityAttributes.ContentState(session: store.startSession()))

        // The Live Activity is only updated when the state changes, so a replaced session must never produce the
        // same state as the one it replaces.
        #expect(first != second)
    }
}
