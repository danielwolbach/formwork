//
//  WorkoutDetailScreen.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftData
import SwiftUI

struct WorkoutDetailScreen: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Environment(\.dismiss) private var dismiss: DismissAction

    @State private var sheet: WorkoutSheet?
    @State private var deleteAlert = false

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
                        sheet = .addWorkoutExercise(workout)
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
                        sheet = .addWorkoutExercise(workout)
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
                        deleteAlert = true
                    }
                }
            }
        }
        .workoutSheet(item: $sheet)
        .alert("Delete Workout?", isPresented: $deleteAlert) {
            Button(.delete) {
                delete()
            }

            Button(.cancel) {}
        } message: {
            Text("This will delete the workout and all of its entries. This cannot be undone.")
        }
    }

    private func delete() {
        modelContext.delete(workout)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            fatalError("Failed to delete workout: \(error)")
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutDetailScreen(workout: Workout.samples[0])
    }
}
