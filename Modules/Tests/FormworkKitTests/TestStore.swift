//
//  TestStore.swift
//  FormworkKitTests
//
//  Created by Daniel Wolbach on 18.09.26.
//

@testable import FormworkKit
import SwiftData

/// An in-memory store with one workout of three bodyweight exercises: Squat, Bench Press and Deadlift.
@MainActor
struct TestStore {
    let container: ModelContainer

    let workout: Workout

    init() throws {
        let configuration = ModelConfiguration(schema: Storage.schema, isStoredInMemoryOnly: true)
        self.container = try ModelContainer(for: Storage.schema, configurations: [configuration])

        self.workout = Workout(name: "Full Body", pictogram: Pictogram(image: "figure.run", tint: .pink), schedule: .inactive, entries: [])
        container.mainContext.insert(workout)

        for name in ["Squat", "Bench Press", "Deadlift"] {
            let exercise = Exercise(name: name, kind: .bodyweight, categories: [])
            container.mainContext.insert(exercise)
            workout.append(exercise: exercise, target: .bodyweight(reps: 10, sets: 3))
        }
    }

    var context: ModelContext {
        container.mainContext
    }

    func startSession() throws -> Session {
        guard let session = workout.startSession() else {
            throw TestStoreError.sessionNotStarted
        }

        return session
    }
}

enum TestStoreError: Error {
    case sessionNotStarted
}

/// A bodyweight target's payload, since `ExerciseTarget` is not `Equatable`.
struct BodyweightTarget: Equatable {
    let sets: Int

    let reps: Int
}

extension ExerciseTarget {
    var bodyweightTarget: BodyweightTarget? {
        if case let .bodyweight(reps, sets) = self {
            BodyweightTarget(sets: sets, reps: reps)
        } else {
            nil
        }
    }
}

extension Units {
    static let metric = Units(weight: .metric, distance: .metric)
}
