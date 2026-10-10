//
//  Samples.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 04.09.26.
//

import Foundation
import SwiftData

@MainActor
public enum Samples {
    public static let exercises = makeExercises()

    public static let workouts = makeWorkouts(with: exercises)

    public static let sessions = makeSessions(for: workouts)

    public static let measurements = makeMeasurements()

    public static var activeSession: Session {
        // swiftlint:disable:next force_try
        try! Session.active(in: container.mainContext)!
    }

    public static func insert(into context: ModelContext) {
        let exercises = makeExercises()
        let workouts = makeWorkouts(with: exercises)
        let sessions = makeSessions(for: workouts)

        exercises.forEach(context.insert)
        workouts.forEach(context.insert)
        sessions.forEach(context.insert)
    }

    private static func makeExercises() -> [Exercise] {
        [
            Exercise(name: "Cross Trainer", kind: .duration, categories: [.cardio, .legs]),
            Exercise(name: "Leg Press", kind: .weight, categories: [.legs]),
            Exercise(name: "Chest Press", kind: .weight, categories: [.chest, .arms]),
            Exercise(name: "Lat Pulldown", kind: .weight, categories: [.back, .arms]),
            Exercise(name: "Leg Curl", kind: .weight, categories: [.legs]),
            Exercise(name: "Shoulder Press", kind: .weight, categories: [.shoulders, .arms]),
            Exercise(name: "Rowing Machine", kind: .weight, categories: [.back, .arms]),
            Exercise(name: "Abdominal Machine", kind: .weight, categories: [.core]),
            Exercise(name: "Hyperextensions", kind: .bodyweight, categories: [.back]),
            Exercise(name: "Bicep Curl", kind: .weight, categories: [.arms]),
            Exercise(name: "Tricep Pushdown", kind: .weight, categories: [.arms]),
            Exercise(name: "Squat", kind: .weight, categories: [.legs]),
            Exercise(name: "Deadlift", kind: .weight, categories: [.legs, .back]),
            Exercise(name: "Bench Press", kind: .weight, categories: [.chest]),
            Exercise(name: "Incline Dumbbell Press", kind: .weight, categories: [.chest, .shoulders]),
            Exercise(name: "Lateral Raise", kind: .weight, categories: [.shoulders]),
            Exercise(name: "Pull-Up", kind: .bodyweight, categories: [.back, .arms]),
            Exercise(name: "Push-Up", kind: .bodyweight, categories: [.chest, .arms]),
            Exercise(name: "Plank", kind: .duration, categories: [.core]),
            Exercise(name: "Russian Twist", kind: .bodyweight, categories: [.core]),
            Exercise(name: "Treadmill Run", kind: .distance, categories: [.cardio, .legs]),
            Exercise(name: "Cycling", kind: .distance, categories: [.cardio, .legs]),
            Exercise(name: "Jump Rope", kind: .duration, categories: [.cardio, .legs]),
            Exercise(name: "Sun Salutation", kind: .duration, categories: [.flexibility, .mindfulness]),
            Exercise(name: "Hamstring Stretch", kind: .duration, categories: [.flexibility, .legs]),
            Exercise(name: "Box Breathing", kind: .duration, categories: [.mindfulness]),
            Exercise(name: "Farmer's Carry", kind: .weight, categories: [.arms, .core, .other]),
        ]
    }

    private static func makeWorkouts(with exercises: [Exercise]) -> [Workout] {
        [
            Workout(
                name: "Full Body",
                pictogram: Pictogram(image: "figure.strengthtraining.traditional", tint: .blue),
                schedule: .weekly(weekdays: [Schedule.Weekdays(calendarWeekday: 2), Schedule.Weekdays(calendarWeekday: 5)], anchor: historyStart),
                entries: [
                    WorkoutEntry(exercise: exercises[0], target: .duration(seconds: 10 * 60)),
                    WorkoutEntry(exercise: exercises[1], target: .weight(kilograms: 85, reps: 10, sets: 3)),
                    WorkoutEntry(exercise: exercises[2], target: .weight(kilograms: 40, reps: 10, sets: 3)),
                    WorkoutEntry(exercise: exercises[3], target: .weight(kilograms: 40, reps: 10, sets: 3)),
                    WorkoutEntry(exercise: exercises[4], target: .weight(kilograms: 40, reps: 12, sets: 3)),
                    WorkoutEntry(exercise: exercises[5], target: .weight(kilograms: 25, reps: 12, sets: 3)),
                    WorkoutEntry(exercise: exercises[6], target: .weight(kilograms: 45, reps: 12, sets: 3)),
                    WorkoutEntry(exercise: exercises[7], target: .weight(kilograms: 40, reps: 14, sets: 3)),
                    WorkoutEntry(exercise: exercises[8], target: .bodyweight(reps: 12, sets: 3)),
                ]
            ),
            Workout(
                name: "Leg Day",
                pictogram: Pictogram(image: "figure.strengthtraining.functional", tint: .purple),
                schedule: .weekly(weekdays: Schedule.Weekdays(calendarWeekday: 7), anchor: historyStart),
                entries: [
                    WorkoutEntry(exercise: exercises[22], target: .duration(seconds: 5 * 60)),
                    WorkoutEntry(exercise: exercises[11], target: .weight(kilograms: 70, reps: 8, sets: 4)),
                    WorkoutEntry(exercise: exercises[12], target: .weight(kilograms: 80, reps: 6, sets: 3)),
                    WorkoutEntry(exercise: exercises[1], target: .weight(kilograms: 100, reps: 10, sets: 3)),
                    WorkoutEntry(exercise: exercises[4], target: .weight(kilograms: 35, reps: 12, sets: 3)),
                    WorkoutEntry(exercise: exercises[24], target: .duration(seconds: 5 * 60)),
                ]
            ),
        ]
    }
}

extension Samples {
    public static let container: ModelContainer = {
        let configuration = ModelConfiguration(schema: Storage.schema, isStoredInMemoryOnly: true)

        // swiftlint:disable:next force_try
        let container = try! ModelContainer(for: Storage.schema, configurations: [configuration])

        Samples.exercises.forEach(container.mainContext.insert)
        Samples.workouts.forEach(container.mainContext.insert)
        Samples.sessions.forEach(container.mainContext.insert)

        _ = Samples.workouts[0].startSession()

        return container
    }()

    private static let historyDays = 1000

    private static let historyStart = Calendar.current.date(byAdding: .day, value: -historyDays, to: .now) ?? .now

    fileprivate static func makeSessions(for workouts: [Workout], days: Int = historyDays, calendar: Calendar = .current) -> [Session] {
        var random = SeededGenerator(seed: 42)
        var sessions: [Session] = []
        var lastSessions: [Workout: Date] = [:]
        let today = calendar.startOfDay(for: .now)

        for offset in (1 ... days).reversed() {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else {
                continue
            }

            let progress = 1 - Double(offset) / Double(days)

            for workout in workouts where workout.schedule.isScheduled(on: day, after: lastSessions[workout], now: day, in: calendar) {
                guard Double.random(in: 0 ..< 1, using: &random) < 0.8 else {
                    continue
                }

                let session = Session(workout: workout)
                var clock = day.addingTimeInterval(TimeInterval.random(in: 17 ... 19.5, using: &random) * 3600)
                session.startDate = clock
                lastSessions[workout] = clock

                for entry in (session.entries ?? []).sorted() {
                    clock += TimeInterval.random(in: 180 ... 480, using: &random)
                    entry.target = entry.target.scaled(by: 0.85 + 0.15 * progress)
                    entry.status = Double.random(in: 0 ..< 1, using: &random) < 0.1 ? .skipped(date: clock) : .completed(date: clock)
                }

                session.endDate = clock
                sessions.append(session)
            }
        }

        return sessions
    }

    /// A weigh-in every few days, with body fat on some of them, slowly going down.
    fileprivate static func makeMeasurements(days: Int = historyDays, calendar: Calendar = .current) -> [BodyMeasurement: [BodyMeasurement.Sample]] {
        var random = SeededGenerator(seed: 3)
        var measurements: [BodyMeasurement: [BodyMeasurement.Sample]] = [:]
        let today = calendar.startOfDay(for: .now)

        for offset in stride(from: days, through: 1, by: -3) {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else {
                continue
            }

            let date = day.addingTimeInterval(TimeInterval.random(in: 6.5 ... 8, using: &random) * 3600)
            let progress = 1 - Double(offset) / Double(days)
            measurements[.weight, default: []].append(.init(date: date, value: 84 - 4 * progress + Double.random(in: -0.6 ... 0.6, using: &random)))

            if offset.isMultiple(of: 2) {
                measurements[.bodyFat, default: []].append(.init(date: date, value: 0.22 - 0.03 * progress + Double.random(in: -0.004 ... 0.004, using: &random)))
            }
        }

        return measurements
    }
}

private struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

extension ExerciseTarget {
    fileprivate func scaled(by factor: Double) -> Self {
        func scale(_ value: Int, to step: Double) -> Int {
            Int((Double(value) * factor / step).rounded() * step)
        }

        return switch self {
        case let .weight(kilograms, reps, sets): .weight(kilograms: (kilograms * factor / 2.5).rounded() * 2.5, reps: reps, sets: sets)
        case .bodyweight: self
        case let .duration(seconds, sets): .duration(seconds: scale(seconds, to: 60), sets: sets)
        case let .distance(meters, sets): .distance(meters: scale(meters, to: 100), sets: sets)
        }
    }
}
