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
        (ExerciseTarget.weight(target: .init(weight: Quantity(10, in: .kilograms), sets: 3, reps: 10)), ExerciseType.weight),
        (ExerciseTarget.bodyweight(target: .init(sets: 3, reps: 10)), ExerciseType.bodyweight),
        (ExerciseTarget.duration(target: .init(duration: Quantity(10, in: .minutes))), ExerciseType.duration),
        (ExerciseTarget.distance(target: .init(distance: Quantity(1, in: .kilometers))), ExerciseType.distance),
    ])
    func targetDisplaysItsType(target: ExerciseTarget, type: ExerciseType) {
        #expect(target.type == type)
        #expect(target.title == type.title)
        #expect(target.pictogram == type.pictogram)
    }

    @Test func exerciseListsCategoriesInCatalogOrder() {
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
    @Test func entryWithoutExerciseHasFallbackTitle() throws {
        let store = try TestStore()
        let entry = try #require(store.workout.entries.first)

        entry.exercise = nil

        #expect(entry.title == String(localized: .exerciseUnknownTitle))
        #expect(entry.pictogram == .unknown)
    }
}
