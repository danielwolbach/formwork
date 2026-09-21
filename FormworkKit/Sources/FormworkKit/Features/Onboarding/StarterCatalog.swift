//
//  StarterCatalog.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 20.09.26.
//

import Foundation
import SwiftData

public enum StarterCatalog {
    public struct ExerciseEntry: Sendable {
        public let name: LocalizedStringResource
        public let type: ExerciseType
        public let categories: Set<ExerciseCategory>

        public var detatchedExercise: Exercise {
            Exercise(name: String(localized: name), type: type, categories: categories)
        }
    }

    public struct WorkoutEntry: Sendable {
        public struct Entry: Sendable {
            public let exercise: LocalizedStringResource
            public let target: ExerciseTarget
        }

        public let name: LocalizedStringResource
        public let pictogram: Pictogram
        public let schedule: Schedule
        public let entries: [Entry]

        public var detatchedWorkout: Workout {
            let workout = Workout(name: String(localized: name), pictogram: pictogram, schedule: schedule, entries: [])

            for item in entries {
                guard let exercise = StarterCatalog.exercises.first(where: { $0.name.key == item.exercise.key })?.detatchedExercise else {
                    preconditionFailure("The starter catalog has no \(item.exercise.key) exercise.")
                }

                workout.append(exercise: exercise, target: item.target)
            }

            return workout
        }
    }

    public static let exercises: [ExerciseEntry] = [
        ExerciseEntry(name: .StarterCatalog.exerciseBenchPressName, type: .weight, categories: [.chest, .arms]),
        ExerciseEntry(name: .StarterCatalog.exerciseShoulderPressName, type: .weight, categories: [.shoulders, .arms]),
        ExerciseEntry(name: .StarterCatalog.exerciseLatPulldownName, type: .weight, categories: [.back, .arms]),
        ExerciseEntry(name: .StarterCatalog.exerciseBarbellRowName, type: .weight, categories: [.back, .arms]),
        ExerciseEntry(name: .StarterCatalog.exerciseDeadliftName, type: .weight, categories: [.back, .legs]),
        ExerciseEntry(name: .StarterCatalog.exerciseSquatName, type: .weight, categories: [.legs]),
        ExerciseEntry(name: .StarterCatalog.exerciseBicepCurlName, type: .weight, categories: [.arms]),

        ExerciseEntry(name: .StarterCatalog.exercisePushUpName, type: .bodyweight, categories: [.chest, .arms]),
        ExerciseEntry(name: .StarterCatalog.exercisePullUpName, type: .bodyweight, categories: [.back, .arms]),
        ExerciseEntry(name: .StarterCatalog.exerciseLungeName, type: .bodyweight, categories: [.legs]),
        ExerciseEntry(name: .StarterCatalog.exerciseSitUpName, type: .bodyweight, categories: [.core]),

        ExerciseEntry(name: .StarterCatalog.exercisePlankName, type: .duration, categories: [.core]),
        ExerciseEntry(name: .StarterCatalog.exerciseJumpRopeName, type: .duration, categories: [.cardio, .legs]),
        ExerciseEntry(name: .StarterCatalog.exerciseHamstringStretchName, type: .duration, categories: [.flexibility, .legs]),
        ExerciseEntry(name: .StarterCatalog.exerciseBoxBreathingName, type: .duration, categories: [.mindfulness]),

        ExerciseEntry(name: .StarterCatalog.exerciseTreadmillName, type: .distance, categories: [.cardio]),
        ExerciseEntry(name: .StarterCatalog.exerciseRunningName, type: .distance, categories: [.cardio, .legs]),
        ExerciseEntry(name: .StarterCatalog.exerciseWalkingName, type: .distance, categories: [.cardio, .legs]),
        ExerciseEntry(name: .StarterCatalog.exerciseCyclingName, type: .distance, categories: [.cardio, .legs]),
    ]

    public static var workouts: [WorkoutEntry] {
        [
            WorkoutEntry(
                name: .StarterCatalog.workoutStarterName,
                pictogram: .workout,
                schedule: .today(),
                entries: [
                    WorkoutEntry.Entry(exercise: .StarterCatalog.exerciseTreadmillName, target: .distance(target: .init(distance: .defaultDistance))),
                    WorkoutEntry.Entry(exercise: .StarterCatalog.exercisePushUpName, target: .bodyweight(target: .init(sets: 3, reps: 12))),
                    WorkoutEntry.Entry(exercise: .StarterCatalog.exerciseSquatName, target: .weight(target: .init(weight: .defaultWeight, sets: 3, reps: 10))),
                    WorkoutEntry.Entry(exercise: .StarterCatalog.exercisePlankName, target: .duration(target: .init(duration: Quantity(45, in: .seconds)))),
                ]
            ),
        ]
    }

    public static func detachedExerciseSample(of type: ExerciseType) -> Exercise {
        guard let entry = exercises.first(where: { $0.type == type }) else {
            preconditionFailure("The starter catalog has no \(type) exercise.")
        }

        return entry.detatchedExercise
    }

    public static func detatchedWorkoutSample() -> Workout {
        guard let workout = workouts.first else {
            preconditionFailure("The starter catalog has not workout.")
        }

        return workout.detatchedWorkout
    }

    public static func seed(into context: ModelContext) throws {
        // Only seed when there are no exercises already in the catalog or we
        // might fill a catalog that was already filled from another device.
        guard try context.fetchCount(FetchDescriptor<Exercise>()) == 0 else {
            return
        }

        // Every exercise is inserted once and kept under its catalog key, so a
        // workout naming it links that exercise instead of seeding a second one.
        var seeded: [String: Exercise] = [:]

        for entry in exercises {
            let exercise = entry.detatchedExercise
            context.insert(exercise)
            seeded[entry.name.key] = exercise
        }

        for entry in workouts {
            let workout = Workout(name: String(localized: entry.name), pictogram: entry.pictogram, schedule: entry.schedule, entries: [])
            context.insert(workout)

            for item in entry.entries {
                guard let exercise = seeded[item.exercise.key] else {
                    preconditionFailure("The starter catalog has no \(item.exercise.key) exercise.")
                }

                workout.append(exercise: exercise, target: item.target)
            }
        }
    }
}
