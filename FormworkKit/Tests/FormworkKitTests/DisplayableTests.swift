//
//  DisplayableTests.swift
//  FormworkKitTests
//
//  Created by Daniel Wolbach on 18.09.26.
//

@testable import FormworkKit
import Foundation
import Testing

struct DisplayableTests {
    @Test(arguments: [
        (ExerciseTarget.weight(.init(weight: Quantity(10, in: .kilograms), sets: 3, reps: 10)), ExerciseType.weight),
        (ExerciseTarget.bodyweight(.init(sets: 3, reps: 10)), ExerciseType.bodyweight),
        (ExerciseTarget.duration(.init(duration: Quantity(10, in: .minutes))), ExerciseType.duration),
        (ExerciseTarget.distance(.init(distance: Quantity(1, in: .kilometers))), ExerciseType.distance),
    ])
    func targetDisplaysItsType(target: ExerciseTarget, type: ExerciseType) {
        #expect(target.type == type)
        #expect(target.title == type.title)
        #expect(target.pictogram == type.pictogram)
    }

    @Test
    func exerciseListsCategoriesInCatalogOrder() {
        let exercise = Exercise(name: "Deadlift", type: .weight, categories: [.back, .legs])

        #expect(exercise.subtitle == [ExerciseCategory.legs.title, ExerciseCategory.back.title].joined(separator: ", "))
    }

    @Test(arguments: [(0, "0 Exercises"), (1, "1 Exercise"), (5, "5 Exercises")])
    func exerciseCountIsPluralized(count: Int, expected: String) {
        var resource = Exercise.countTitle(count)
        resource.locale = Locale(identifier: "en")

        #expect(String(localized: resource) == expected)
    }

    @MainActor
    @Test
    func sessionIsDatedByTheClockItWasRecordedOn() throws {
        let store = try TestStore()
        let session = try store.session(7, hour: 8, zone: "America/New_York")
        var local = Calendar.current
        local.timeZone = try #require(TimeZone(identifier: "America/New_York"))
        let inNewYork = Date.FormatStyle(date: .numeric, time: .shortened, calendar: local, timeZone: local.timeZone)

        // 08:00 in New York is 14:00 in Berlin, but the user remembers starting at 08:00.
        #expect(session.subtitle == session.startDate.formatted(inNewYork))
    }

    @MainActor
    @Test
    func wallClockTimeIsTheClockItWasRecordedOn() throws {
        let store = try TestStore()
        let session = try store.session(7, hour: 8, zone: "America/New_York")
        var local = Calendar.current
        local.timeZone = try #require(TimeZone(identifier: "America/New_York"))

        #expect(session.startDate.formatted(session.wallClockTime()) == session.startDate.formatted(local.formatStyle(time: .shortened)))
    }

    @MainActor
    @Test
    func entryWithoutExerciseHasFallbackTitle() throws {
        let store = try TestStore()
        let entry = try #require(store.workout.entries.first)

        entry.exercise = nil

        #expect(entry.title == String(localized: .exerciseUnknownTitle))
        #expect(entry.pictogram == .unknown)
    }
}
