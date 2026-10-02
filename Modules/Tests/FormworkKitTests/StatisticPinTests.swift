//
//  StatisticPinTests.swift
//  FormworkKitTests
//
//  Created by Daniel Wolbach on 02.10.26.
//

@testable import FormworkKit
import Foundation
import SwiftData
import Testing

@MainActor
struct StatisticPinTests {
    @Test
    func keepsItsSubject() throws {
        let store = try TestStore()
        let entry = try #require(store.workout.entries.first)
        let exercise = try #require(entry.exercise)

        let subjects: [History.Subject] = [.all, .workout(store.workout), .exercise(exercise), .entry(entry)]

        for subject in subjects {
            #expect(StatisticPin(.completions, of: subject, order: 0).subject == subject)
        }
    }

    @Test
    func overallPinsAreNeverArchived() throws {
        let store = try TestStore()
        let pin = StatisticPin(.weekStreak, of: .all, order: 0)
        store.context.insert(pin)

        store.workout.isArchived = true

        #expect(!pin.isArchived)
    }

    @Test
    func entryPinsFollowTheirWorkoutAndExercise() throws {
        let store = try TestStore()
        let entry = try #require(store.workout.entries.first)
        let exercise = try #require(entry.exercise)
        let pin = StatisticPin(.personalBest, of: .entry(entry), order: 0)
        store.context.insert(pin)

        #expect(!pin.isArchived)

        exercise.isArchived = true
        #expect(pin.isArchived)

        exercise.isArchived = false
        store.workout.isArchived = true
        #expect(pin.isArchived)
    }

    @Test
    func appendingPlacesThePinLast() throws {
        let store = try TestStore()
        store.context.insert(StatisticPin(.weekStreak, of: .all, order: 4))

        try StatisticPin.append(.completions, of: .workout(store.workout), into: store.context)

        let pins = try store.context.fetch(FetchDescriptor<StatisticPin>(sortBy: [SortDescriptor(\.order)]))

        #expect(pins.map(\.kind) == [.weekStreak, .completions])
        #expect(pins.map(\.order) == [4, 5])
    }

    @Test
    func movingSwapsWithTheNeighbourAmongTheGivenPins() {
        let first = StatisticPin(.weekStreak, of: .all, order: 0)
        let hidden = StatisticPin(.completions, of: .all, order: 1)
        let last = StatisticPin(.lastCompleted, of: .all, order: 2)

        last.move(by: -1, among: [first, last])

        #expect(first.order == 2)
        #expect(hidden.order == 1)
        #expect(last.order == 0)

        last.move(by: -1, among: [last, first])

        #expect(last.order == 0)
    }
}
