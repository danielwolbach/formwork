//
//  ExerciseRow.swift
//  Formwork
//
//  Created by Daniel Wolbach on 29.09.26.
//

import FormworkKit
import FormworkUI
import SwiftData
import SwiftUI

struct ExerciseRow: View {
    private let exercise: Exercise

    private let isSelected: Bool

    @Environment(\.modelContext)
    private var context: ModelContext

    @Environment(\.paywall)
    private var paywall: Paywall

    @Environment(\.presentPaywall)
    private var presentPaywall: PresentPaywallAction

    @Environment(\.statistics)
    private var statistics: Statistics

    @State
    private var deleteAlert: Bool = false

    @State
    private var sheet: Sheet? = nil

    init(_ exercise: Exercise, isSelected: Bool = false) {
        self.exercise = exercise
        self.isSelected = isSelected
    }

    var body: some View {
        HStack {
            PictogramRow(exercise.pictogram, title: exercise.title, subtitle: exercise.categories.formatted(.exerciseCategories))

            Image(systemName: "chevron.forward")
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
        }
        .contentShape(.rect)
        .padding(8)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .opacity(isSelected ? 1 : 0)
                .animation(.snappy(duration: 0.1), value: isSelected)
        }
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
        .contextMenu {
            if !exercise.isArchived {
                Section {
                    Button(.addToWorkout) {
                        sheet = .exerciseAddToWorkout(exercise)
                    }
                }
            }

            Section {
                Button(.edit) {
                    sheet = .editExercise(exercise)
                }

                if exercise.isArchived {
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
        } preview: {
            let history = statistics.history(.exercise(exercise))

            ContentStack(spacing: .groups) {
                PictogramRow(exercise.pictogram, title: exercise.title, subtitle: exercise.categories.formatted(.exerciseCategories))

                if !history.occurrences.isEmpty {
                    StatisticGrid(history, includesCharts: false)
                }
            }
            .frame(width: 360)
            .padding(.vertical)
        }
        .swipeActions(edge: .leading) {
            if exercise.isArchived {
                Button(.unarchive) {
                    unarchive()
                }
                .labelStyle(.fixedIconOnly)
            } else {
                Button(.addToWorkout) {
                    sheet = .exerciseAddToWorkout(exercise)
                }
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
        .alert(.alertDeleteExerciseTitle, isPresented: $deleteAlert) {
            Button(.delete) {
                delete()
            }

            if !exercise.isArchived {
                Button(.archive) {
                    archive()
                }
            }

            Button(.cancel) {
                // Works automatically.
            }
        } message: {
            Text(.alertDeleteExerciseMessage)
        }
        .sheet(item: $sheet) { sheet in
            sheet
        }
    }

    private func archive() {
        exercise.isArchived = true
    }

    private func unarchive() {
        guard paywall.canAddExercise(in: context) else {
            presentPaywall()
            return
        }

        exercise.isArchived = false
    }

    private func delete() {
        context.delete(exercise)
    }
}

#Preview {
    NavigationRoot {
        ExerciseRow(Samples.exercises.first!, isSelected: true)
    }
    .sampleData()
}
