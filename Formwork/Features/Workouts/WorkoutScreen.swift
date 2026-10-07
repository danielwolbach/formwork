//
//  WorkoutScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import FormworkUI
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

    @Environment(\.fullVersion)
    private var fullVersion: FullVersion

    @Environment(\.presentPaywall)
    private var presentPaywall: PresentPaywallAction

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
        let badge = workout.isArchived ? Pictogram.archivedBadge : nil
        let entries = (workout.entries ?? []).sorted()

        ScrollView {
            ContentStack {
                PictogramHeader(
                    workout.pictogram,
                    title: workout.title,
                    subtitle: workout.formatted(.workoutDetails),
                    badge: badge
                )

                HStack {
                    Button(.addExercises) {
                        sheet = .workoutAddEntries(workout)
                    }
                    .labelStyle(.fixedIconOnly)
                    .buttonStyle(.glass)
                    .buttonBorderShape(.circle)
                    .disabled(workout.isArchived)

                    Button(.startSession) {
                        startSession()
                    }
                    .labelStyle(.fixedTitleAndIcon)
                    .buttonStyle(.glassProminent)
                    .fontWeight(.medium)
                    .tint(.green)
                    .disabled(!workout.isStartable)

                    Button(.viewStatistics) {
                        sheet = .workoutStatistics(workout)
                    }
                    .labelStyle(.fixedIconOnly)
                    .buttonStyle(.glass)
                    .buttonBorderShape(.circle)
                }
                .controlSize(.large)

                if entries.isEmpty {
                    ContentUnavailableView {
                        Label(.emptyWorkoutEntriesTitle, systemImage: "dumbbell")
                    } description: {
                        Text(.emptyWorkoutEntriesMessage)
                    } actions: {
                        Button(.addExercises) {
                            sheet = .workoutAddEntries(workout)
                        }
                        .labelStyle(.fixedTitleAndIcon)
                        .buttonStyle(.cardProminent)
                    }
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(entries.sorted()) { entry in
                            WorkoutEntryRow(entry)
                        }
                    }
                    .swipeActionsContainer()
                    .animation(.snappy, value: entries.count)
                    .edgeToEdge()
                }
            }
        }
        .contentMargins(.bottom, .sections, for: .scrollContent)
        .toolbar {
            Menu(.more) {
                Section {
                    if !workout.isArchived {
                        Button(.startSession) {
                            startSession()
                        }
                        .disabled(!workout.isStartable)

                        Button(.addExercises) {
                            sheet = .workoutAddEntries(workout)
                        }
                    }

                    Button(.viewStatistics) {
                        sheet = .workoutStatistics(workout)
                    }
                }

                Section {
                    Button(.edit) {
                        sheet = .editWorkout(workout)
                    }

                    if workout.isArchived {
                        Button(.unarchive) {
                            unarchive()
                        }
                    } else {
                        Button(.archive) {
                            archive()
                        }
                    }
                }

                Section {
                    Button(.delete) {
                        deleteAlert = true
                    }
                }
            }
        }
        .alert(.alertDeleteWorkoutTitle, isPresented: $deleteAlert) {
            Button(.delete) {
                delete()
            }

            if !workout.isArchived {
                Button(.archive) {
                    archive()
                }
            }

            Button(.cancel) {
                // Works automatically.
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
            sheet
        }
    }

    private func archive() {
        workout.isArchived = true
        dismiss()
    }

    private func unarchive() {
        guard fullVersion.canAddWorkout(in: context) else {
            presentPaywall()
            return
        }

        workout.isArchived = false
    }

    private func delete() {
        context.delete(workout)
        dismiss()
    }

    private func startSession() {
        guard activeSessions.isEmpty else {
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
    NavigationRoot {
        WorkoutScreen(Samples.workouts[1])
    }
    .sampleData()
}
