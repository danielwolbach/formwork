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

    var context: ModelContext {
        container.mainContext
    }

    init() throws {
        let configuration = ModelConfiguration(schema: Storage.schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Storage.schema, configurations: [configuration])

        workout = Workout(name: "Full Body", pictogram: Pictogram(image: "figure.run", tint: .pink), schedule: .inactive, entries: [])
        container.mainContext.insert(workout)

        for name in ["Squat", "Bench Press", "Deadlift"] {
            let exercise = Exercise(name: name, type: .bodyweight, categories: [])
            container.mainContext.insert(exercise)
            workout.append(exercise: exercise, target: .bodyweight(target: .init(sets: 3, reps: 10)))
        }
    }

    func startSession() throws -> Session {
        try Session.start(workout, in: context)
    }
}

extension ExerciseTarget {
    /// `ExerciseTarget` is not `Equatable`, so tests compare its payload instead.
    var bodyweightTarget: BodyweightTarget? {
        if case let .bodyweight(target) = self {
            target
        } else {
            nil
        }
    }
}
