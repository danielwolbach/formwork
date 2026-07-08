//
//  Samples.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftData
import SwiftUI

extension Exercise {
    static var samples: [Exercise] {
        [
            Exercise(name: "Bench Press", metric: .weight, disciplines: [.chest, .arms]),
            Exercise(name: "Back Squat", metric: .weight, disciplines: [.legs]),
            Exercise(name: "Plank", metric: .duration, disciplines: [.core]),
            Exercise(name: "Treadmill", metric: .distance, disciplines: [.legs]),
            Exercise(name: "Hyperextensions", metric: .bodyweight, disciplines: [.back]),
        ]
    }
}

extension WorkoutEntry {
    static var samples: [WorkoutEntry] {
        let exercises = Exercise.samples
        return [
            WorkoutEntry(order: 0, exercise: exercises[0], target: .weight(weight: 60, sets: 3, reps: 10)),
            WorkoutEntry(order: 1, exercise: exercises[2], target: .duration(minutes: 2)),
            WorkoutEntry(order: 2, exercise: exercises[3], target: .distance(meters: 2000)),
            WorkoutEntry(order: 3, exercise: exercises[4], target: .bodyweight(sets: 3, reps: 13)),
        ]
    }
}

extension Workout {
    static var samples: [Workout] {
        return [
            Workout(name: "Full Body", entries: WorkoutEntry.samples),
        ]
    }
}

extension SessionEntry {
    static var samples: [SessionEntry] {
        let exercises = Exercise.samples
        return [
            SessionEntry(order: 0, exercise: exercises[0], target: .weight(weight: 60, sets: 3, reps: 10)),
            SessionEntry(order: 1, exercise: exercises[3], target: .distance(meters: 1000)),
        ]
    }
}

extension Session {
    static var samples: [Session] {
        [Session(workout: Workout.samples[0])]
    }
}

private struct SampleDataModifier: ViewModifier {
    let container: ModelContainer

    init() {
        let schema = Schema([Exercise.self, Workout.self, WorkoutEntry.self, Session.self, SessionEntry.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create sample data container: \(error)")
        }

        Workout.samples.forEach(container.mainContext.insert)
        Session.samples.forEach(container.mainContext.insert)
    }

    func body(content: Content) -> some View {
        content.modelContainer(container)
    }
}

extension View {
    func sampleData() -> some View {
        modifier(SampleDataModifier())
    }
}
