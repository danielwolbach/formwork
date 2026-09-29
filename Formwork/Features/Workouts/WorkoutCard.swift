//
//  WorkoutCard.swift
//  Formwork
//
//  Created by Daniel Wolbach on 06.09.26.
//

import FormworkKit
import SwiftData
import SwiftUI

struct WorkoutCard: View {
    private let workout: Workout

    @Environment(\.modelContext)
    private var context: ModelContext

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
        NavigationLink(value: workout) {
            VStack(alignment: .leading, spacing: 0) {
                Image(systemName: workout.pictogram.image)
                    .font(.system(size: 48))
                    .fontWeight(.medium)
                    .foregroundStyle(workout.pictogram.color)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .padding()
                    .background(workout.pictogram.color.quinary)

                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading) {
                        Text(workout.title)
                            .lineLimit(1)
                            .font(.headline)

                        if let subtitle = workout.subtitle {
                            Text(subtitle)
                                .lineLimit(1)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if !workout.exerciseCategories.isEmpty {
                        FlowLayout(alignment: .leading, rowLimit: 2) {
                            ForEach(workout.exerciseCategories) { category in
                                Label(category.title, systemImage: category.pictogram.image)
                                    .labelStyle(.chip(tint: category.pictogram.color))
                            }
                        }
                    }
                }
                .padding()
            }
            .card()
        }
        .buttonStyle(.plain)
        .swipeActions {
            Button(Action.delete.title, systemImage: Action.delete.image) {
                deleteAlert = true
            }
            .tint(.red)
            .labelStyle(.fixedIconOnly)
        }
        .swipeActions(edge: .leading) {
            Button(.startSession) {
                startSession()
            }
            .tint(.green)
            .labelStyle(.fixedIconOnly)
            .disabled(workout.entries.isEmpty)
        }
        .contextMenu {
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
        } preview: {
            VStack(spacing: 16) {
                DisplayableRow(workout)

                if !workout.exerciseCategories.isEmpty {
                    FlowLayout(alignment: .leading) {
                        ForEach(workout.exerciseCategories) { category in
                            Label(category.title, systemImage: category.pictogram.image)
                                .labelStyle(.chip(tint: category.pictogram.color))
                        }
                    }
                }
            }
            .frame(width: 360)
            .padding()
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
        WorkoutCard(Samples.workouts.first!)
    }
    .padding()
}
