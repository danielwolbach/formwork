//
//  StarterCatalogTests.swift
//  FormworkKitTests
//
//  Created by Daniel Wolbach on 20.09.26.
//

@testable import FormworkKit
import Foundation
import SwiftData
import Testing

@MainActor
struct StarterCatalogTests {
    @Test func everyEntryIsNamedAndFiled() {
        for entry in StarterCatalog.exercises {
            let name = String(localized: entry.name)

            // A missing translation falls back to the key, which would seed "exercise.squat.name".
            #expect(!name.isEmpty)
            #expect(!name.contains("exercise."))
            #expect(!entry.categories.isEmpty)
        }
    }

    @Test func namesAreDistinct() {
        let names = StarterCatalog.exercises.map { String(localized: $0.name) }

        #expect(Set(names).count == names.count)
    }

    @Test func everyCategoryButOtherIsCovered() {
        let covered = Set(StarterCatalog.exercises.flatMap(\.categories))

        for category in ExerciseCategory.allCases where category != .other {
            #expect(covered.contains(category))
        }
    }

    @Test func everyTypeHasASample() {
        // `sample(of:)` traps on a type the catalog dropped, and the onboarding tour calls it.
        for type in ExerciseType.allCases {
            #expect(StarterCatalog.detachedExerciseSample(of: type).type == type)
        }
    }

    @Test func seedingFillsAnEmptyCatalog() throws {
        let configuration = ModelConfiguration(schema: Storage.schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Storage.schema, configurations: [configuration])
        let context = container.mainContext

        try StarterCatalog.seed(into: context)

        #expect(try context.fetchCount(FetchDescriptor<Exercise>()) == StarterCatalog.exercises.count)
    }

    @Test func everyWorkoutTrainsCatalogExercises() {
        let keys = Set(StarterCatalog.exercises.map(\.name.key))

        for workout in StarterCatalog.workouts {
            #expect(!workout.entries.isEmpty)

            for entry in workout.entries {
                #expect(keys.contains(entry.exercise.key))
            }
        }
    }

    @Test func seedingLinksWorkoutsToTheSeededExercises() throws {
        let configuration = ModelConfiguration(schema: Storage.schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Storage.schema, configurations: [configuration])
        let context = container.mainContext

        try StarterCatalog.seed(into: context)

        let workouts = try context.fetch(FetchDescriptor<Workout>())
        let exercises = try context.fetch(FetchDescriptor<Exercise>())

        // A workout that copied its exercises instead of linking them would push this past the catalog.
        #expect(exercises.count == StarterCatalog.exercises.count)
        #expect(workouts.count == StarterCatalog.workouts.count)

        for workout in workouts {
            let linked = workout.entries.sorted().compactMap(\.exercise)

            #expect(linked.count == workout.entries.count)
            #expect(linked.allSatisfy { exercise in exercises.contains { $0 === exercise } })
        }
    }

    @Test func theStarterWorkoutIsDueTheDayItIsSeeded() throws {
        let configuration = ModelConfiguration(schema: Storage.schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Storage.schema, configurations: [configuration])
        let context = container.mainContext

        try StarterCatalog.seed(into: context)

        let workouts = try context.fetch(FetchDescriptor<Workout>())

        #expect(workouts.allSatisfy { $0.schedule.isScheduled(on: .now) })
        #expect(workouts.pending().count == workouts.count)
    }

    @Test func seedingLeavesAnExistingCatalogAlone() throws {
        let store = try TestStore()

        try StarterCatalog.seed(into: store.context)

        #expect(try store.context.fetchCount(FetchDescriptor<Exercise>()) == 3)
    }
}
