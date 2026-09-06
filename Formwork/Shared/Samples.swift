//
//  Exercise.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import SwiftData
import SwiftUI

enum Samples {
    static let exercises: [Exercise] =
    [
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
    
    static let fullBodyEntries: [WorkoutEntry] =
    [
        WorkoutEntry(order: 0, exercise: exercises[0], target: .duration(minutes: 10)),
        WorkoutEntry(order: 1, exercise: exercises[1], target: .weight(weight: 85, sets: 3, reps: 10)),
        WorkoutEntry(order: 2, exercise: exercises[2], target: .weight(weight: 40, sets: 3, reps: 10)),
        WorkoutEntry(order: 3, exercise: exercises[3], target: .weight(weight: 40, sets: 3, reps: 10)),
        WorkoutEntry(order: 4, exercise: exercises[4], target: .weight(weight: 40, sets: 3, reps: 12)),
        WorkoutEntry(order: 5, exercise: exercises[5], target: .weight(weight: 25, sets: 3, reps: 12)),
        WorkoutEntry(order: 6, exercise: exercises[6], target: .weight(weight: 45, sets: 3, reps: 12)),
        WorkoutEntry(order: 7, exercise: exercises[7], target: .weight(weight: 40, sets: 3, reps: 14)),
        WorkoutEntry(order: 8, exercise: exercises[8], target: .bodyweight(sets: 3, reps: 12)),
    ]

    static let pushDayEntries: [WorkoutEntry] =
    [
        WorkoutEntry(order: 0, exercise: exercises[13], target: .weight(weight: 60, sets: 4, reps: 8)),
        WorkoutEntry(order: 1, exercise: exercises[14], target: .weight(weight: 22.5, sets: 3, reps: 10)),
        WorkoutEntry(order: 2, exercise: exercises[5], target: .weight(weight: 20, sets: 3, reps: 12)),
        WorkoutEntry(order: 3, exercise: exercises[15], target: .weight(weight: 8, sets: 3, reps: 15)),
        WorkoutEntry(order: 4, exercise: exercises[10], target: .weight(weight: 25, sets: 3, reps: 12)),
        WorkoutEntry(order: 5, exercise: exercises[17], target: .bodyweight(sets: 3, reps: 15)),
    ]

    static let legDayEntries: [WorkoutEntry] =
    [
        WorkoutEntry(order: 0, exercise: exercises[22], target: .duration(minutes: 5)),
        WorkoutEntry(order: 1, exercise: exercises[11], target: .weight(weight: 70, sets: 4, reps: 8)),
        WorkoutEntry(order: 2, exercise: exercises[12], target: .weight(weight: 80, sets: 3, reps: 6)),
        WorkoutEntry(order: 3, exercise: exercises[1], target: .weight(weight: 100, sets: 3, reps: 10)),
        WorkoutEntry(order: 4, exercise: exercises[4], target: .weight(weight: 35, sets: 3, reps: 12)),
        WorkoutEntry(order: 5, exercise: exercises[24], target: .duration(minutes: 5)),
    ]
    
    static let workouts: [Workout] =
    [
        Workout(
            name: "Full Body",
            pictogram: Pictogram(icon: "figure.strengthtraining.traditional", tint: .blue),
            entries: Samples.fullBodyEntries),
        Workout(
            name: "Push Day",
            pictogram: Pictogram(icon: "figure.boxing", tint: .orange),
            entries: Samples.pushDayEntries
        ),
        Workout(
            name: "Leg Day",
            pictogram: Pictogram(icon: "figure.strengthtraining.functional", tint: .purple),
            entries: Samples.legDayEntries
        ),
    ]
    
    static let workoutEntries: [WorkoutEntry] = fullBodyEntries
    
    static let session: Session = {
        try! Session.start(workouts[0], in: container.mainContext)
    }()
}

extension Samples {
    static let container: ModelContainer = {
        let schema = Schema([Exercise.self, Workout.self, WorkoutEntry.self, Session.self, SessionEntry.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        
        Samples.exercises.forEach(container.mainContext.insert)
        Samples.workouts.forEach(container.mainContext.insert)
      
        return container
    }()
}

private struct SampleDataModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .modelContainer(Samples.container)
    }
}

extension View {
    func sampleData() -> some View {
        modifier(SampleDataModifier())
    }
}
