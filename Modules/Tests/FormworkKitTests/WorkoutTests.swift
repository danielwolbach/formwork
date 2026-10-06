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

        #expect((store.workout.entries ?? []).sorted().map(\.title) == ["Squat", "Bench Press", "Deadlift", "Plank"])
        #expect((store.workout.entries ?? []).sorted().last?.order == 3)
    }

    @Test
    func canAddWorkoutUntilTheLimitIgnoringArchived() {
        let fullVersion = FullVersion()

        #expect(fullVersion.canAddWorkout(in: store.context))

        let second = Workout(name: "Upper Body", pictogram: .workout, schedule: .inactive, entries: [])
        store.context.insert(second)

        #expect(!fullVersion.canAddWorkout(in: store.context))

        second.isArchived = true

        #expect(fullVersion.canAddWorkout(in: store.context))
    }

    @Test
    func canAddExerciseUntilTheLimitIgnoringArchived() {
        let fullVersion = FullVersion()
        var added: [Exercise] = []

        for index in 0 ..< FullVersion.exerciseLimit - 3 {
            let exercise = Exercise(name: "Exercise \(index)", kind: .bodyweight, categories: [])
            store.context.insert(exercise)
            added.append(exercise)
        }

        #expect(!fullVersion.canAddExercise(in: store.context))

        added.first?.isArchived = true

        #expect(fullVersion.canAddExercise(in: store.context))
    }

    @Test
    func archivedWorkoutIsNotStartable() {
        #expect(store.workout.isStartable)

        store.workout.isArchived = true

        #expect(!store.workout.isStartable)
    }

    @Test
    func isStartableNeedsAnExerciseThatIsNotArchived() {
        let exercises = (store.workout.entries ?? []).compactMap(\.exercise)

        for exercise in exercises.dropLast() {
            exercise.isArchived = true
        }

        #expect(store.workout.isStartable)

        exercises.last?.isArchived = true

        #expect(!store.workout.isStartable)
    }

    @Test
    func appendContinuesAfterHighestOrder() {
        let exercise = Exercise(name: "Plank", kind: .duration, categories: [.core])
        store.context.insert(exercise)
        (store.workout.entries ?? []).sorted().last?.order = 7

        store.workout.append(exercise: exercise, target: .duration(seconds: 1 * 60))

        #expect((store.workout.entries ?? []).sorted().last?.order == 8)
    }
}
