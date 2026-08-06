//
//  WorkoutDetailScreen.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftData
import SwiftUI

struct WorkoutDetailScreen: View {
    @Environment(\.dismiss) private var dismiss: DismissAction
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Environment(\.presentSession) private var presentSession: PresentSessionAction
    @Query(sort: \Session.started, order: .reverse) private var sessions: [Session]
    @State private var sheet: WorkoutSheet?
    @State private var deleteAlert = false
    @State private var replaceSessionAlert = false
    @State private var statisticsPresented = false

    let workout: Workout

    var body: some View {
        content
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
                            statisticsPresented = true
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
            .alert(.alertReplaceSessionTitle, isPresented: $replaceSessionAlert) {
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
                Text(.alertReplaceSessionMessage)
            }
            .alert(.alertDeleteWorkoutTitle, isPresented: $deleteAlert) {
                Button(.delete) {
                    delete()
                }

                Button(.cancel) {}
            } message: {
                Text(.alertDeleteWorkoutMessage)
            }
    }

    private var content: some View {
        ScrollView {
            ScreenStack {
                ScreenSection {
                    IconHero(icon: workout.icon, color: workout.color, title: workout.title, subtitle: workout.subtitle)

                    ButtonStack {
                        Button(.addWorkoutExercise) {
                            sheet = .addWorkoutExercise(workout)
                        }
                        .labelStyle(.fixedIconOnly)
                        .buttonStyle(.glass)
                        .buttonBorderShape(.circle)

                        Button(.startSession) {
                            startSession()
                        }
                        .tint(.green)
                        .fontWeight(.semibold)
                        .disabled(workout.entries.isEmpty)
                        .labelStyle(.fixedTitleAndIcon)
                        .buttonStyle(.glassProminent)

                        Button(.seeStats) {
                            statisticsPresented = true
                        }
                        .labelStyle(.fixedIconOnly)
                        .buttonStyle(.glass)
                        .buttonBorderShape(.circle)
                    }
                }

                if workout.entries.isEmpty {
                    ScreenSection {
                        ContentUnavailableView(.emptyNoExercises, systemImage: Exercise.genericIcon)
                    }
                } else {
                    WorkoutEntryList(entries: workout.entries.sorted())
                }
            }
        }
        .sheet(isPresented: $statisticsPresented) {
            NavigationStack {
                WorkoutStatisticsScreen(workout: workout)
            }
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
        do {
            modelContext.delete(workout)
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
