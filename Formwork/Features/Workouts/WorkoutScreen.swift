//
//  WorkoutScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import SwiftData
import SwiftUI

struct WorkoutScreen: View {
    private let workout: Workout

    @Environment(\.modelContext)
    private var context: ModelContext

    @Environment(\.dismiss)
    private var dismiss: DismissAction

    @Environment(\.presentSession)
    private var presentSession: PresentSessionAction

    @Query(Session.activeDescriptor)
    private var activeSessions: [Session]

    @State
    private var sheet: Sheet? = nil

    @State
    private var deleteAlert: Bool = false

    @State
    private var replaceSessionAlert: Bool = false

    init(_ workout: Workout) {
        self.workout = workout
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                DisplayableHeader(workout)

                HStack {
                    Button(.addExercise) {
                        sheet = .workoutAddEntries(workout)
                    }
                    .labelStyle(.fixedIconOnly)
                    .buttonStyle(.glass)
                    .buttonBorderShape(.circle)

                    Button(.startSession) {
                        startSession()
                    }
                    .labelStyle(.fixedTitleAndIcon)
                    .buttonStyle(.glassProminent)
                    .fontWeight(.medium)
                    .tint(.green)
                    .disabled(workout.entries.isEmpty)

                    Button(.viewStatistics) {
                        sheet = .workoutStatistics(workout)
                    }
                    .labelStyle(.fixedIconOnly)
                    .buttonStyle(.glass)
                    .buttonBorderShape(.circle)
                }
                .controlSize(.large)

                if workout.entries.isEmpty {
                    ContentUnavailableView {
                        Label(.emptyWorkoutEntriesTitle, systemImage: "dumbbell")
                    } description: {
                        Text(.emptyWorkoutEntriesMessage)
                    } actions: {
                        Button(.addExercise) {
                            sheet = .workoutAddEntries(workout)
                        }
                        .labelStyle(.fixedTitleAndIcon)
                        .buttonStyle(.cardProminent())
                    }
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(workout.entries.sorted()) { entry in
                            WorkoutEntryRow(entry)
                        }
                    }
                    .animation(.snappy, value: workout.entries.count)
                }
            }
        }
        .navigationDestination(for: WorkoutEntry.self) { entry in
            WorkoutEntryScreen(entry)
        }
        .toolbar {
            Menu(.more) {
                Section {
                    Button(.startSession) {
                        startSession()
                    }
                    .disabled(workout.entries.isEmpty)
                }

                Section {
                    Button(.addExercise) {
                        sheet = .workoutAddEntries(workout)
                    }

                    Button(.viewStatistics) {
                        sheet = .workoutStatistics(workout)
                    }
                }

                Section {
                    Button(.edit) {
                        sheet = .editWorkout(workout)
                    }

                    Button(.delete) {
                        deleteAlert = true
                    }
                }
            }
        }
        .alert(.alertDeleteWorkoutTitle, isPresented: $deleteAlert) {
            Button(.cancel) {
                // Works automatically.
            }

            Button(.delete) {
                delete()
            }
        } message: {
            Text(.alertDeleteWorkoutMessage)
        }
        .alert(.alertReplaceSessionTitle, isPresented: $replaceSessionAlert) {
            Button(.cancel) {
                // Works automatically.
            }

            Button(.replaceSession) {
                replaceSession()
            }

            if let session = activeSessions.first {
                Button(.resumeSession) {
                    presentSession(session)
                }
            }
        } message: {
            Text(.alertReplaceSessionMessage)
        }
        .sheet(item: $sheet) { sheet in
            NavigationStack {
                sheet
            }
        }
    }

    private func delete() {
        context.delete(workout)
        dismiss()
    }

    private func startSession() {
        guard activeSessions.first == nil else {
            replaceSessionAlert = true
            return
        }

        replaceSession()
    }

    private func replaceSession() {
        if let session = workout.startSession() {
            presentSession(session)
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutScreen(Samples.workouts[1])
    }
    .sampleData()
}
