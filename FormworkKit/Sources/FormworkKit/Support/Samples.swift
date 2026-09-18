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
        Workout(
            name: "Empty",
            pictogram: Pictogram(image: "figure.martial.arts", tint: .red),
            schedule: .inactive,
            entries: []
        )
    ]

    public static let sessions: [Session] = [
        // swiftlint:disable:next force_try
        try! container.mainContext.fetch(FetchDescriptor<Session>()).first!
    ]

    public static let container: ModelContainer = {
        let configuration = ModelConfiguration(schema: Storage.schema, isStoredInMemoryOnly: true)

        // swiftlint:disable:next force_try
        let container = try! ModelContainer(for: Storage.schema, configurations: [configuration])

        Samples.exercises.forEach(container.mainContext.insert)
        Samples.workouts.forEach(container.mainContext.insert)

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
