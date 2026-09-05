//
//  Exercise.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

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
       ]
    
    static let workouts: [Workout] =
    [
        Workout(name: "Full Body", entries: Samples.workoutEntries),
    ]
    
    static let workoutEntries: [WorkoutEntry] =
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
