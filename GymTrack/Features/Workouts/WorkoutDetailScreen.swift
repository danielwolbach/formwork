//
//  WorkoutDetailScreen.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftUI

struct WorkoutDetailScreen: View {
    @State private var sheet: WorkoutSheet?

    let workout: Workout

    var body: some View {
        ScrollView {
            ScreenStack {
                DetailHero(
                    title: workout.name,
                    subtitle: "\(workout.entries.count) Exercises",
                    systemImage: workout.systemImage,
                    color: workout.color
                )

                HStack {
                    Button(.addWorkoutExercise) {
                        // TODO:
                    }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.glass)
                    .controlSize(.large)
                    .buttonBorderShape(.circle)

                    Button(.startSession) {
                        // TODO:
                    }
                    .tint(.green)
                    .fontWeight(.semibold)
                    .buttonStyle(.glassProminent)
                    .controlSize(.large)

                    Button(.seeStats) {
                        // TODO:
                    }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.glass)
                    .controlSize(.large)
                    .buttonBorderShape(.circle)
                }

                WorkoutEntryList(entries: workout.entries.sorted())
            }
        }
        .navigationDestination(for: WorkoutEntry.self) { entry in
            WorkoutEntryDetailScreen(entry: entry)
        }
        .toolbar {
            Menu(.moreOptions) {
                Section {
                    Button(.addWorkoutExercise) {
                        // TODO:
                    }

                    Button(.seeStats) {
                        // TODO:
                    }
                }

                Section {
                    Button(.edit) {
                        sheet = .editWorkout(workout)
                    }
                }

                Section {
                    Button(.delete) {
                        // TODO:
                    }
                }
            }
        }
        .workoutSheet(item: $sheet)
    }
}

#Preview {
    NavigationStack {
        WorkoutDetailScreen(workout: Workout.samples[0])
    }
}
