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

    init(_ exercise: Exercise) {
        self.exercise = exercise
    }

    var body: some View {
        NavigationLink(value: exercise) {
            HStack {
                PictogramRow(exercise.pictogram, title: exercise.title, subtitle: exercise.categories.formatted(.exerciseCategories))

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
        .contextMenu {
            Section {
                if !exercise.isArchived {
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
            ContentStack(spacing: .groups) {
                PictogramRow(exercise.pictogram, title: exercise.title, subtitle: exercise.categories.formatted(.exerciseCategories))

                StatisticPreview(.exercise(exercise))
            }
            .frame(width: 360)
            .padding(.vertical)
        }
        .alert(.alertDeleteExerciseTitle, isPresented: $deleteAlert) {
            Button(.cancel) {
                // Works automatically.
            }

            Button(.delete) {
                delete()
            }
        } message: {
            Text(.alertDeleteExerciseMessage)
        }
        .sheet(item: $sheet) { sheet in
            sheet
        }
        .padding(.horizontal, 8)
    }

    private func archive() {
        exercise.isArchived = true
    }

    private func unarchive() {
        guard fullVersion.canAddExercise(in: context) else {
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
    NavigationStack {
        ExerciseRow(Samples.exercises.first!)
    }
    .sampleData()
}
