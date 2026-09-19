//
//  Samples.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import SwiftData
import SwiftUI

@MainActor
public enum Samples {
    public static let exercises: [Exercise] = [
        Exercise(name: "Cross Trainer", type: .duration, categories: [.cardio, .legs]),
        Exercise(name: "Leg Press", type: .weight, categories: [.legs]),
        Exercise(name: "Chest Press", type: .weight, categories: [.chest, .arms]),
        Exercise(name: "Lat Pulldown", type: .weight, categories: [.back, .arms]),
        Exercise(name: "Leg Curl", type: .weight, categories: [.legs]),
        Exercise(name: "Shoulder Press", type: .weight, categories: [.shoulders, .arms]),
        Exercise(name: "Rowing Machine", type: .weight, categories: [.back, .arms]),
        Exercise(name: "Abdominal Machine", type: .weight, categories: [.core]),
        Exercise(name: "Hyperextensions", type: .bodyweight, categories: [.back]),
        Exercise(name: "Bicep Curl", type: .weight, categories: [.arms]),
        Exercise(name: "Tricep Pushdown", type: .weight, categories: [.arms]),
        Exercise(name: "Squat", type: .weight, categories: [.legs]),
        Exercise(name: "Deadlift", type: .weight, categories: [.legs, .back]),
        Exercise(name: "Bench Press", type: .weight, categories: [.chest]),
        Exercise(name: "Incline Dumbbell Press", type: .weight, categories: [.chest, .shoulders]),
        Exercise(name: "Lateral Raise", type: .weight, categories: [.shoulders]),
        Exercise(name: "Pull-Up", type: .bodyweight, categories: [.back, .arms]),
        Exercise(name: "Push-Up", type: .bodyweight, categories: [.chest, .arms]),
        Exercise(name: "Plank", type: .duration, categories: [.core]),
        Exercise(name: "Russian Twist", type: .bodyweight, categories: [.core]),
        Exercise(name: "Treadmill Run", type: .distance, categories: [.cardio, .legs]),
        Exercise(name: "Cycling", type: .distance, categories: [.cardio, .legs]),
        Exercise(name: "Jump Rope", type: .duration, categories: [.cardio, .legs]),
        Exercise(name: "Sun Salutation", type: .duration, categories: [.flexibility, .mindfulness]),
        Exercise(name: "Hamstring Stretch", type: .duration, categories: [.flexibility, .legs]),
        Exercise(name: "Box Breathing", type: .duration, categories: [.mindfulness]),
        Exercise(name: "Farmer's Carry", type: .weight, categories: [.arms, .core, .other]),
    ]

    public static let workouts: [Workout] = [
        Workout(
            name: "Full Body",
            pictogram: Pictogram(image: "figure.strengthtraining.traditional", tint: .blue),
            schedule: Schedule(weekdays: [.monday, .thursday]),
            entries: [
                WorkoutEntry(order: 0, exercise: exercises[0], target: .duration(target: .init(duration: Quantity(10, in: .minutes)))),
                WorkoutEntry(order: 1, exercise: exercises[1], target: .weight(target: .init(weight: Quantity(85, in: .kilograms), sets: 3, reps: 10))),
                WorkoutEntry(order: 2, exercise: exercises[2], target: .weight(target: .init(weight: Quantity(40, in: .kilograms), sets: 3, reps: 10))),
                WorkoutEntry(order: 3, exercise: exercises[3], target: .weight(target: .init(weight: Quantity(40, in: .kilograms), sets: 3, reps: 10))),
                WorkoutEntry(order: 4, exercise: exercises[4], target: .weight(target: .init(weight: Quantity(40, in: .kilograms), sets: 3, reps: 12))),
                WorkoutEntry(order: 5, exercise: exercises[5], target: .weight(target: .init(weight: Quantity(25, in: .kilograms), sets: 3, reps: 12))),
                WorkoutEntry(order: 6, exercise: exercises[6], target: .weight(target: .init(weight: Quantity(45, in: .kilograms), sets: 3, reps: 12))),
                WorkoutEntry(order: 7, exercise: exercises[7], target: .weight(target: .init(weight: Quantity(40, in: .kilograms), sets: 3, reps: 14))),
                WorkoutEntry(order: 8, exercise: exercises[8], target: .bodyweight(target: .init(sets: 3, reps: 12))),
            ]
        ),
        Workout(
            name: "Leg Day",
            pictogram: Pictogram(image: "figure.strengthtraining.functional", tint: .purple),
            schedule: Schedule(weekdays: [.saturday]),
            entries: [
                WorkoutEntry(order: 0, exercise: exercises[22], target: .duration(target: .init(duration: Quantity(5, in: .minutes)))),
                WorkoutEntry(order: 1, exercise: exercises[11], target: .weight(target: .init(weight: Quantity(70, in: .kilograms), sets: 4, reps: 8))),
                WorkoutEntry(order: 2, exercise: exercises[12], target: .weight(target: .init(weight: Quantity(80, in: .kilograms), sets: 3, reps: 6))),
                WorkoutEntry(order: 3, exercise: exercises[1], target: .weight(target: .init(weight: Quantity(100, in: .kilograms), sets: 3, reps: 10))),
                WorkoutEntry(order: 4, exercise: exercises[4], target: .weight(target: .init(weight: Quantity(35, in: .kilograms), sets: 3, reps: 12))),
                WorkoutEntry(order: 5, exercise: exercises[24], target: .duration(target: .init(duration: Quantity(5, in: .minutes)))),
            ]
        ),
    ]

    public static let sessions: [Session] = [
        // swiftlint:disable:next force_try
        try! Session.active(in: container.mainContext)!,
    ]

    public static let container: ModelContainer = {
        let configuration = ModelConfiguration(schema: Storage.schema, isStoredInMemoryOnly: true)

        // swiftlint:disable:next force_try
        let container = try! ModelContainer(for: Storage.schema, configurations: [configuration])

        Samples.exercises.forEach(container.mainContext.insert)
        Samples.workouts.forEach(container.mainContext.insert)

        // swiftlint:disable:next force_try
        try! Samples.seedHistory(in: container.mainContext)

        // swiftlint:disable:next force_try
        try! Session.start(Samples.workouts[0], in: container.mainContext)

        return container
    }()
}

public extension View {
    func sampleData() -> some View {
        modifier(SampleDataModifier())
    }
}

private struct SampleDataModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.modelContainer(Samples.container)
    }
}

private extension Samples {
    static func seedHistory(in context: ModelContext, days: Int = 84, calendar: Calendar = .current) throws {
        var random = SeededGenerator(seed: 42)
        let today = calendar.startOfDay(for: .now)

        for offset in (1 ... days).reversed() {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else {
                continue
            }

            let weekday = Schedule.Weekday(calendarNumber: calendar.component(.weekday, from: day))

            let progress = 1 - Double(offset) / Double(days)

            for workout in workouts where workout.schedule.weekdays.contains(weekday) {
                guard Double.random(in: 0 ..< 1, using: &random) < 0.8 else {
                    continue
                }

                let session = try Session.start(workout, in: context)
                var clock = day.addingTimeInterval(TimeInterval.random(in: 17 ... 19.5, using: &random) * 3600)
                session.started = clock

                for entry in session.entries.sorted() {
                    clock += TimeInterval.random(in: 180 ... 480, using: &random)
                    entry.target = entry.target.scaled(by: 0.85 + 0.15 * progress)
                    entry.status = Double.random(in: 0 ..< 1, using: &random) < 0.1 ? .skipped(at: clock) : .completed(at: clock)
                }

                // Not `finish()`: that stamps `.now` and writes the targets back into the workout.
                session.ended = clock
            }
        }
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

private extension ExerciseTarget {
    func scaled(by factor: Double) -> Self {
        switch self {
        case var .weight(target):
            target.weight = target.weight.scaled(by: factor)
            return .weight(target: target)
        case .bodyweight:
            return self
        case var .duration(target):
            target.duration = target.duration.scaled(by: factor)
            return .duration(target: target)
        case var .distance(target):
            target.distance = target.distance.scaled(by: factor)
            return .distance(target: target)
        }
    }
}

private extension Quantity {
    func scaled(by factor: Double) -> Self {
        var quantity = self
        quantity.value = (value * factor / stepSize).rounded() * stepSize
        return quantity
    }
}
