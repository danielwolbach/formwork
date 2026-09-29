//
//  StarterCatalog.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 20.09.26.
//

import Foundation
import SwiftData

public enum StarterCatalog {
    public enum Samples {}

    public struct ExerciseEntry: Sendable {
        public let name: LocalizedStringResource

        public let kind: Exercise.Kind

        public let categories: Set<Exercise.Category>

        public var detachedExercise: Exercise {
            Exercise(name: String(localized: name), kind: kind, categories: categories)
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

        public var detachedWorkout: Workout {
            let workout = Workout(name: String(localized: name), pictogram: pictogram, schedule: schedule, entries: [])

            for item in entries {
                guard let exercise = StarterCatalog.exercises.first(where: { $0.name.key == item.exercise.key })?.detachedExercise else {
                    preconditionFailure("The starter catalog has no \(item.exercise.key) exercise.")
                }

                workout.append(exercise: exercise, target: item.target)
            }

            return workout
        }
    }

    public static let exercises: [ExerciseEntry] = [
        ExerciseEntry(name: .StarterCatalog.exerciseBenchPressName, kind: .weight, categories: [.chest, .arms]),
        ExerciseEntry(name: .StarterCatalog.exercisePushUpName, kind: .bodyweight, categories: [.chest, .arms]),
        ExerciseEntry(name: .StarterCatalog.exercisePlankName, kind: .duration, categories: [.core]),
        ExerciseEntry(name: .StarterCatalog.exerciseTreadmillName, kind: .distance, categories: [.cardio]),
    ]

    public static func workouts(in units: Units) -> [WorkoutEntry] {
        [
            WorkoutEntry(
                name: .StarterCatalog.workoutStarterName,
                pictogram: .workout,
                schedule: .today(),
                entries: [
                    WorkoutEntry.Entry(exercise: .StarterCatalog.exerciseTreadmillName, target: .initial(for: .distance, in: units)),
                    WorkoutEntry.Entry(exercise: .StarterCatalog.exercisePushUpName, target: .bodyweight(reps: 12, sets: 3)),
                    WorkoutEntry.Entry(exercise: .StarterCatalog.exerciseBenchPressName, target: .initial(for: .weight, in: units)),
                    WorkoutEntry.Entry(exercise: .StarterCatalog.exercisePlankName, target: .duration(seconds: 60)),
                ]
            ),
        ]
    }

    public static func seed(into context: ModelContext, units: Units) throws {
        // Only seed when there are no exercises already in the catalog or we
        // might fill a catalog that was already filled from another device.
        guard try context.fetchCount(FetchDescriptor<Exercise>()) == 0 else {
            return
        }

        // Every exercise is inserted once and kept under its catalog key, so a
        // workout naming it links that exercise instead of seeding a second one.
        var seeded: [String: Exercise] = [:]

        for entry in exercises {
            let exercise = entry.detachedExercise
            context.insert(exercise)
            seeded[entry.name.key] = exercise
        }

        for entry in workouts(in: units) {
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

extension StarterCatalog.Samples {
    public static var weekStreak: some Indicator {
        WeekStreak(weeks: 6, isCurrentWeekFulfilled: true)
    }

    public static var weeklySessions: some Indicator {
        WeeklySessions(value: 2.8)
    }

    public static func personalBest(in units: Units) -> some Indicator {
        PersonalBest(target: .weight(kilograms: kilograms(metric: 90, imperial: 200, in: units), reps: 10, sets: 3))
    }

    public static func totalVolume(in units: Units) -> SessionSummary.Figure<Double> {
        .totalVolume(kilograms(metric: 12480, imperial: 27500, in: units))
    }

    public static func weightTarget(in units: Units) -> ExerciseTarget {
        .weight(kilograms: kilograms(metric: 85, imperial: 185, in: units), reps: 10, sets: 3)
    }

    public static func activeWeek(calendar: Calendar = .current) -> ActiveDays {
        let start = calendar.dateInterval(of: .weekOfYear, for: .now)?.start ?? calendar.startOfDay(for: .now)
        let trained: Set = [0, 2]

        let days = (0 ..< 7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: start).map { date in
                ActiveDays.Day(date: date, sessionCount: trained.contains(offset) ? 1 : 0, isAhead: offset > 3)
            }
        }

        return ActiveDays(calendar: calendar, days: days)
    }

    public static func exercise(of kind: Exercise.Kind) -> Exercise {
        guard let entry = StarterCatalog.exercises.first(where: { $0.kind == kind }) else {
            preconditionFailure("The starter catalog has no \(kind) exercise.")
        }

        return entry.detachedExercise
    }

    public static func workout(in units: Units) -> Workout {
        guard let entry = StarterCatalog.workouts(in: units).first else {
            preconditionFailure("The starter catalog has no workout.")
        }

        return entry.detachedWorkout
    }

    private static func kilograms(metric: Double, imperial pounds: Double, in units: Units) -> Double {
        units.weight == .metric ? metric : Measurement(value: pounds, unit: UnitMass.pounds).converted(to: .kilograms).value
    }
}
