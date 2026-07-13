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
    @Environment(\.presentSession) private var presentSession: PresentSessionAction
    @Query(sort: \Session.started, order: .reverse) private var sessions: [Session]

    @State private var sheet: WorkoutSheet?
    @State private var deleteAlert = false
    @State private var replaceSessionAlert = false

    let workout: Workout

    var body: some View {
        ScrollView {
            ScreenStack {
                DetailHero(
                    title: workout.name,
                    subtitle: workout.entriesText,
                    systemImage: workout.systemImage,
                    color: workout.color
                )

                HStack {
                    IconButton(.addWorkoutExercise) {
                        sheet = .addWorkoutExercise(workout)
                    }

                    LabelButton(.startSession, style: .glassProminent) {
                        startSession()
                    }
                    .tint(.green)
                    .fontWeight(.semibold)
                    .disabled(workout.entries.isEmpty)

                    IconButton(.seeStats) {
                        // TODO:
                    }
                }
                .controlSize(.large)

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
        .alert("Replace Active Session?", isPresented: $replaceSessionAlert) {
            Button(.replaceSession) {
                replaceSession()
            }

            if let activeSession = sessions.activeSession {
                Button(.resumeSession) {
                    presentSession(activeSession)
                }
            }

            Button(.cancel) {}
        } message: {
            Text("Starting this workout will replace the active session.")
        }
        .alert("Delete Workout?", isPresented: $deleteAlert) {
            Button(.delete) {
                delete()
            }

            Button(.cancel) {}
        } message: {
            Text("This will delete the workout and all of its entries. This cannot be undone.")
        }
    }

    private func startSession() {
        guard !workout.entries.isEmpty else {
            return
        }

        guard sessions.activeSession == nil else {
            replaceSessionAlert = true
            return
        }

        replaceSession()
    }

    private func replaceSession() {
        do {
            try presentSession(modelContext.startSession(for: workout))
        } catch {
            fatalError("Failed to start session: \(error)")
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
