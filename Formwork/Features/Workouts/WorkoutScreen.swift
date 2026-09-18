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
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Environment(\.dismiss) private var dismiss: DismissAction
    @Environment(\.presentSession) private var presentSession: PresentSessionAction
    @Query(Session.activeDescriptor) private var activeSessions: [Session]
    @State private var sheet: Sheet? = nil
    @State private var deleteAlert: Bool = false
    @State private var sessionActiveAlert: Bool = false
    @State private var statisticsScreen: Bool = false

    let workout: Workout

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                PictogramHeader(workout)

                HStack {
                    Button(.addExercise) {
                        sheet = .addWorkoutExercise(workout: workout)
                    }
                    .labelStyle(.fixedIconOnly)
                    .buttonStyle(.glass)
                    .buttonBorderShape(.circle)

                    Button(.startSession) {
                        startSession()
                    }
                    .labelStyle(.fixedTitleAndIcon)
                    .buttonStyle(.glassProminent)
                    .tint(.green)
                    .disabled(workout.entries.isEmpty)

                    Button(.viewStatistics) {
                        statisticsScreen = true
                    }
                    .labelStyle(.fixedIconOnly)
                    .buttonStyle(.glass)
                    .buttonBorderShape(.circle)
                }
                .controlSize(.large)

                if workout.entries.isEmpty {
                    ContentUnavailableView {
                        Label(.emptyExercisesTitle, systemImage: "dumbbell")
                    } description: {
                        Text(.emptyWorkoutExercisesDescription)
                    } actions: {
                        Button(.addExercise) {
                            sheet = .addWorkoutExercise(workout: workout)
                        }
                        .buttonStyle(.glassProminent)
                    }
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(workout.entries.sorted()) { entry in
                            NavigationLink(value: entry) {
                                PictogramRow(entry)

                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.tertiary)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
        }
        .navigationDestination(for: WorkoutEntry.self) { entry in
            WorkoutEntryScreen(entry: entry)
        }
        .navigationDestination(isPresented: $statisticsScreen) {
            WorkoutStatisticsScreen(workout: workout)
        }
        .toolbar {
            Menu(.more) {
                Section {
                    Button(.addExercise) {
                        sheet = .addWorkoutExercise(workout: workout)
                    }

                    Button(.viewStatistics) {
                        statisticsScreen = true
                    }
                }

                Section {
                    Button(.edit) {
                        sheet = .editWorkout(workout: workout)
                    }
                }

                Section {
                    Button(.delete) {
                        deleteAlert = true
                    }
                }
            }
        }
        .sheet(item: $sheet) { $0 }
        .alert(.alertWorkoutDeleteTitle, isPresented: $deleteAlert) {
            Button(.delete) {
                delete()
            }

            Button(.cancel) {}
        } message: {
            Text(.alertWorkoutDeleteMessage)
        }
        .alert(.alertSessionActiveTitle, isPresented: $sessionActiveAlert) {
            Button(.replaceSession) {
                replaceSession()
            }

            if let activeSession = activeSessions.first {
                Button(.resumeSession) {
                    presentSession(activeSession)
                }
            }

            Button(.cancel) {}
        } message: {
            Text(.alertSessionActiveMessage)
        }
    }

    private func delete() {
        modelContext.delete(workout)
        dismiss()
    }

    private func startSession() {
        guard activeSessions.first == nil else {
            sessionActiveAlert = true
            return
        }

        replaceSession()
    }

    private func replaceSession() {
        do {
            let session = try Session.start(workout, in: modelContext)
            DispatchQueue.main.async { presentSession(session) }
        } catch {
            // TODO: Log error
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutScreen(workout: Samples.workouts.first!)
    }
    .sampleData()
}
