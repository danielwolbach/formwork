//
//  WorkoutRow.swift
//  Formwork
//
//  Created by Daniel Wolbach on 02.10.26.
//

import FormworkKit
import FormworkUI
import SwiftData
import SwiftUI

struct WorkoutRow: View {
    private let workout: Workout

    @Environment(\.modelContext)
    private var context: ModelContext

    @Environment(\.fullVersion)
    private var fullVersion: FullVersion

    @Environment(\.presentPaywall)
    private var presentPaywall: PresentPaywallAction

    @State
    private var deleteAlert: Bool = false

    @State
    private var sheet: Sheet? = nil

    init(_ workout: Workout) {
        self.workout = workout
    }

    var body: some View {
        NavigationLink(value: workout) {
            HStack {
                PictogramRow(workout.pictogram, title: workout.title, subtitle: workout.formatted(.workoutDetails))

                Image(systemName: "chevron.forward")
                    .foregroundStyle(.tertiary)
            }
            .padding(8)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .swipeActions {
            // No destructive role: it makes SwiftUI expect the row to disappear, so cancelling the alert leaves the button stuck.
            Button(Action.delete.title, systemImage: Action.delete.image) {
                deleteAlert = true
            }
            .tint(.red)
            .labelStyle(.fixedIconOnly)
        }
        .swipeActions(edge: .leading) {
            if workout.isArchived {
                Button(.unarchive) {
                    unarchive()
                }
                .labelStyle(.fixedIconOnly)
            } else {
                Button(.viewStatistics) {
                    sheet = .workoutStatistics(workout)
                }
                .labelStyle(.fixedIconOnly)
            }
        }
        .contextMenu {
            Section {
                Button(.viewStatistics) {
                    sheet = .workoutStatistics(workout)
                }
            }

            Section {
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
        .sheet(item: $sheet) { sheet in
            sheet
        }
        .padding(.horizontal, 8)
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
}

#Preview {
    NavigationStack {
        VStack(spacing: 0) {
            WorkoutRow(Samples.workouts[0])
            WorkoutRow(Samples.workouts[1])
        }
        .swipeActionsContainer()
    }
    .sampleData()
}
