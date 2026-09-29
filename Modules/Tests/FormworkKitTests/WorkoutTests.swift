//
//  WorkoutTests.swift
//  FormworkKitTests
//
//  Created by Daniel Wolbach on 18.09.26.
//

@testable import FormworkKit
import Testing

@MainActor
struct WorkoutTests {
    let store: TestStore

    init() throws {
        self.store = try TestStore()
    }

    @Test
    func appendPlacesExerciseLast() {
        let exercise = Exercise(name: "Plank", kind: .duration, categories: [.core])
        store.context.insert(exercise)

        store.workout.append(exercise: exercise, target: .duration(seconds: 1 * 60))

        #expect(store.workout.entries.sorted().map(\.title) == ["Squat", "Bench Press", "Deadlift", "Plank"])
        #expect(store.workout.entries.sorted().last?.order == 3)
    }

    @Test
    func appendContinuesAfterHighestOrder() {
        let exercise = Exercise(name: "Plank", kind: .duration, categories: [.core])
        store.context.insert(exercise)
        store.workout.entries.sorted().last?.order = 7

        store.workout.append(exercise: exercise, target: .duration(seconds: 1 * 60))

        #expect(store.workout.entries.sorted().last?.order == 8)
    }
}
