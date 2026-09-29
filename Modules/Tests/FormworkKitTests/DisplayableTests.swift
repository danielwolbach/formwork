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
        (ExerciseTarget.weight(kilograms: 10, reps: 10, sets: 3), Exercise.Kind.weight),
        (ExerciseTarget.bodyweight(reps: 10, sets: 3), Exercise.Kind.bodyweight),
        (ExerciseTarget.duration(seconds: 10 * 60), Exercise.Kind.duration),
        (ExerciseTarget.distance(meters: 1 * 1000), Exercise.Kind.distance),
    ])
    func targetDisplaysItsKind(target: ExerciseTarget, kind: Exercise.Kind) {
        #expect(target.exerciseKind == kind)
        #expect(target.title == kind.title)
        #expect(target.pictogram == kind.pictogram)
    }

    @Test
    func exerciseListsCategoriesInCatalogOrder() {
        let exercise = Exercise(name: "Deadlift", kind: .weight, categories: [.back, .legs])

        #expect(exercise.subtitle == [Exercise.Category.legs.title, Exercise.Category.back.title].formatted(.list(type: .and, width: .narrow)))
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

        #expect(entry.title == String(localized: .placeholder))
        #expect(entry.pictogram == .unknown)
    }
}
