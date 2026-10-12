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
        let paywall = Paywall()

        #expect(paywall.canAddWorkout(in: store.context))

        let second = Workout(name: "Upper Body", pictogram: .workout, schedule: .inactive, entries: [])
        store.context.insert(second)

        #expect(!paywall.canAddWorkout(in: store.context))

        second.isArchived = true

        #expect(paywall.canAddWorkout(in: store.context))
    }

    @Test
    func canAddExerciseUntilTheLimitIgnoringArchived() {
        let paywall = Paywall()
        var added: [Exercise] = []

        for index in 0 ..< Paywall.exerciseLimit - 3 {
            let exercise = Exercise(name: "Exercise \(index)", kind: .bodyweight, categories: [])
            store.context.insert(exercise)
            added.append(exercise)
        }

        #expect(!paywall.canAddExercise(in: store.context))

        added.first?.isArchived = true

        #expect(paywall.canAddExercise(in: store.context))
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

    @Test
    func changingKindResetsWorkoutTargets() throws {
        let entry = try #require((store.workout.entries ?? []).sorted().first)
        let squat = try #require(entry.exercise)

        squat.change(kind: .duration, in: .metric)

        #expect(squat.kind == .duration)
        #expect(entry.target.exerciseKind == .duration)
        #expect(entry.target.rank == ExerciseTarget.initial(for: .duration, in: .metric).rank)
    }

    @Test
    func changingKindToTheSameKindKeepsTargets() throws {
        let entry = try #require((store.workout.entries ?? []).sorted().first)

        entry.exercise?.change(kind: .bodyweight, in: .metric)

        #expect(entry.target == .bodyweight(reps: 10, sets: 3))
    }

    @Test
    func changingKindResetsPendingSessionEntries() throws {
        let session = try store.startSession()
        let entry = try #require(session.orderedEntries.first)
        entry.target = .bodyweight(reps: 20, sets: 3)
        entry.updatesWorkoutTarget = true

        entry.exercise?.change(kind: .duration, in: .metric)
        session.finish()

        #expect(entry.target.exerciseKind == .duration)
        #expect(entry.updatesWorkoutTarget == nil)
        #expect(entry.workoutEntry?.target.exerciseKind == .duration)
    }

    @Test
    func resolvedEntriesKeepTheirKindAndDontSaveItBack() throws {
        let session = try store.startSession()
        let entry = try #require(session.orderedEntries.first)
        entry.target = .bodyweight(reps: 20, sets: 3)
        session.completeAndAdvance()

        entry.exercise?.change(kind: .duration, in: .metric)
        session.finish()

        #expect(entry.target == .bodyweight(reps: 20, sets: 3))
        #expect(entry.workoutEntry?.target.exerciseKind == .duration)
    }
}
