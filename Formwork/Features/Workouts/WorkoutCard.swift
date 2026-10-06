//
//  WorkoutCard.swift
//  Formwork
//
//  Created by Daniel Wolbach on 06.09.26.
//

import Flow
import FormworkKit
import FormworkUI
import SwiftData
import SwiftUI

struct WorkoutCard: View {
    enum Style {
        case card, row
    }

    private let workout: Workout

    private let style: Style

    @Environment(\.modelContext)
    private var context: ModelContext

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

    init(_ workout: Workout, style: Style = .card) {
        self.workout = workout
        self.style = style
    }

    var body: some View {
        NavigationLink(value: workout) {
            switch style {
            case .card: card
            case .row: row
            }
        }
        .buttonStyle(.plain)
        .padding(8)
        .contextMenu {
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
        .swipeActions(edge: .leading) {
            if workout.isArchived {
                Button(.unarchive) {
                    unarchive()
                }
                .labelStyle(.fixedIconOnly)
            } else if workout.isStartable {
                Button(.startSession) {
                    startSession()
                }
                .tint(.green)
                .labelStyle(.fixedIconOnly)
            } else {
                Button(.viewStatistics) {
                    sheet = .workoutStatistics(workout)
                }
                .tint(.green)
                .labelStyle(.fixedIconOnly)
            }
        }
        .swipeActions(edge: .trailing) {
            // No destructive role: it makes SwiftUI expect the row to disappear, so cancelling the alert leaves the button stuck.
            Button(Action.delete.title, systemImage: Action.delete.image) {
                deleteAlert = true
            }
            .tint(.red)
            .labelStyle(.fixedIconOnly)
        }
        .padding(.horizontal, 8)
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

    private var card: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(systemName: workout.pictogram.image)
                .font(.system(size: 48))
                .fontWeight(.medium)
                .foregroundStyle(workout.pictogram.color)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .padding()
                .background(workout.pictogram.color.quinary)

            VStack(alignment: .leading, spacing: .groups) {
                VStack(alignment: .leading) {
                    Text(workout.title)
                        .lineLimit(1)
                        .font(.headline)

                    Text(workout.formatted(.workoutDetails))
                        .lineLimit(1)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                HFlow {
                    ForEach(workout.exerciseCategories) { category in
                        Label(category.title, systemImage: category.pictogram.image)
                            .labelStyle(.chip(tint: category.pictogram.color))
                    }
                }
                .maxLines(2) { hidden in
                    Text(hidden, format: .plusMore)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 16, style: .continuous))
    }

    private var row: some View {
        HStack {
            PictogramRow(workout.pictogram, title: workout.title, subtitle: workout.formatted(.workoutDetails))

            Image(systemName: "chevron.forward")
                .foregroundStyle(.tertiary)
        }
    }

    private func archive() {
        workout.isArchived = true
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
    NavigationRoot {
        WorkoutCard(Samples.workouts.first!)
    }
}
