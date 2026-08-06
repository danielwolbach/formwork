//
//  SampleData.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftData
import SwiftUI

extension Exercise {
    static var samples: [Exercise] {
        [
            Exercise(name: "Cross Trainer", type: .duration, disciplines: [.cardio, .legs]),
            Exercise(name: "Leg Press", type: .weight, disciplines: [.legs]),
            Exercise(name: "Chest Press", type: .weight, disciplines: [.chest, .arms]),
            Exercise(name: "Lat Pulldown", type: .weight, disciplines: [.back, .arms]),
            Exercise(name: "Leg Curl", type: .weight, disciplines: [.legs]),
            Exercise(name: "Shoulder Press", type: .weight, disciplines: [.shoulders, .arms]),
            Exercise(name: "Rowing Machine", type: .weight, disciplines: [.back, .arms]),
            Exercise(name: "Abdominal Machine", type: .weight, disciplines: [.core]),
            Exercise(name: "Hyperextensions", type: .bodyweight, disciplines: [.back]),
        ]
    }
}

extension WorkoutEntry {
    static var samples: [WorkoutEntry] {
        let exercises = Exercise.samples
        return [
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
    }
}

extension Workout {
    static var samples: [Workout] {
        [
            Workout(name: "Full Body", entries: WorkoutEntry.samples),
        ]
    }
}

extension SessionEntry {
    static var samples: [SessionEntry] {
        let exercises = Exercise.samples
        return [
            SessionEntry(order: 0, exercise: exercises[0], target: .duration(minutes: 10)),
            SessionEntry(order: 1, exercise: exercises[1], target: .weight(weight: 85, sets: 3, reps: 10)),
        ]
    }
}

extension Session {
    static var samples: [Session] {
        let workout = Workout.samples[0]
        let now = Date.now

        return [
            Session(workout: workout),
            completedSample(
                workout: workout,
                started: now.addingTimeInterval(-2 * 24 * 60 * 60),
                duration: 106 * 60,
                targetUpdates: [
                    0: .duration(minutes: 12),
                    1: .weight(weight: 85, sets: 3, reps: 10),
                    2: .weight(weight: 42.5, sets: 3, reps: 10),
                    3: .weight(weight: 40, sets: 3, reps: 10),
                    4: .weight(weight: 40, sets: 3, reps: 12),
                    5: .weight(weight: 27.5, sets: 3, reps: 12),
                    6: .weight(weight: 47.5, sets: 3, reps: 12),
                    7: .weight(weight: 40, sets: 3, reps: 14),
                    8: .bodyweight(sets: 3, reps: 14),
                ]
            ),
            completedSample(
                workout: workout,
                started: now.addingTimeInterval(-5 * 24 * 60 * 60),
                duration: 112 * 60,
                targetUpdates: [
                    0: .duration(minutes: 12),
                    1: .weight(weight: 82.5, sets: 3, reps: 10),
                    2: .weight(weight: 40, sets: 3, reps: 10),
                    3: .weight(weight: 42.5, sets: 3, reps: 10),
                    4: .weight(weight: 42.5, sets: 3, reps: 12),
                    5: .weight(weight: 25, sets: 3, reps: 12),
                    6: .weight(weight: 45, sets: 3, reps: 12),
                    7: .weight(weight: 42.5, sets: 3, reps: 14),
                    8: .bodyweight(sets: 3, reps: 12),
                ],
                skippedEntryIndices: [2]
            ),
            completedSample(
                workout: workout,
                started: now.addingTimeInterval(-9 * 24 * 60 * 60),
                duration: 118 * 60,
                targetUpdates: [
                    0: .duration(minutes: 10),
                    1: .weight(weight: 80, sets: 3, reps: 10),
                    2: .weight(weight: 40, sets: 3, reps: 10),
                    3: .weight(weight: 40, sets: 3, reps: 10),
                    4: .weight(weight: 40, sets: 3, reps: 12),
                    5: .weight(weight: 25, sets: 3, reps: 12),
                    6: .weight(weight: 45, sets: 3, reps: 12),
                    7: .weight(weight: 40, sets: 3, reps: 14),
                    8: .bodyweight(sets: 3, reps: 12),
                ],
                skippedEntryIndices: [8]
            ),
            completedSample(
                workout: workout,
                started: now.addingTimeInterval(-13 * 24 * 60 * 60),
                duration: 104 * 60,
                targetUpdates: [
                    0: .duration(minutes: 10),
                    1: .weight(weight: 77.5, sets: 3, reps: 10),
                    2: .weight(weight: 37.5, sets: 3, reps: 10),
                    3: .weight(weight: 37.5, sets: 3, reps: 10),
                    4: .weight(weight: 40, sets: 3, reps: 12),
                    5: .weight(weight: 22.5, sets: 3, reps: 12),
                    6: .weight(weight: 42.5, sets: 3, reps: 12),
                    7: .weight(weight: 37.5, sets: 3, reps: 14),
                    8: .bodyweight(sets: 3, reps: 11),
                ],
                skippedEntryIndices: [6]
            ),
            completedSample(
                workout: workout,
                started: now.addingTimeInterval(-18 * 24 * 60 * 60),
                duration: 120 * 60,
                targetUpdates: [
                    0: .duration(minutes: 10),
                    1: .weight(weight: 75, sets: 3, reps: 10),
                    2: .weight(weight: 35, sets: 3, reps: 10),
                    3: .weight(weight: 35, sets: 3, reps: 10),
                    4: .weight(weight: 35, sets: 3, reps: 12),
                    5: .weight(weight: 20, sets: 3, reps: 12),
                    6: .weight(weight: 40, sets: 3, reps: 12),
                    7: .weight(weight: 35, sets: 3, reps: 14),
                    8: .bodyweight(sets: 3, reps: 10),
                ]
            ),
        ]
    }

    private static func completedSample(
        workout: Workout,
        started: Date,
        duration: TimeInterval,
        targetUpdates: [Int: ExerciseTarget],
        skippedEntryIndices: Set<Int> = []
    ) -> Session {
        let session = Session(workout: workout)
        session.started = started
        session.ended = started.addingTimeInterval(duration)
        for (index, entry) in session.entries.enumerated() {
            entry.target = targetUpdates[index] ?? entry.target
            entry.status = skippedEntryIndices.contains(index) ? .skipped : .done
        }
        return session
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

        let sessions = Session.samples
        sessions.compactMap(\.workout).forEach(container.mainContext.insert)
        sessions.forEach(container.mainContext.insert)
    }

    func body(content: Content) -> some View {
        content
            .modelContainer(container)
    }
}

extension View {
    func sampleData() -> some View {
        modifier(SampleDataModifier())
    }
}
