//
//  ExerciseDetailScreen.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftData
import SwiftUI

struct ExerciseDetailScreen: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Environment(\.dismiss) private var dismiss: DismissAction

    @State private var sheet: ExerciseSheet?
    @State private var deleteAlert = false

    let exercise: Exercise

    var body: some View {
        ScrollView {
            ScreenStack {
                DetailHero(
                    title: exercise.name,
                    subtitle: exercise.metric.description,
                    systemImage: exercise.systemImage,
                    color: exercise.color
                )

                // TODO:
            }
        }
        .toolbar {
            Menu(.moreOptions) {
                Section {
                    Button(.edit) {
                        sheet = .editExercise(exercise)
                    }
                }

                Section {
                    Button(.delete) {
                        deleteAlert = true
                    }
                }
            }
        }
        .exerciseSheet(item: $sheet)
        .alert("Delete Exercise?", isPresented: $deleteAlert) {
            Button(.delete) {
                delete()
            }

            Button(.cancel) {}
        } message: {
            Text("This will delete the exercise and remove it from all workouts. This cannot be undone.")
        }
    }

    private func delete() {
        modelContext.delete(exercise)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            fatalError("Failed to delete exercise: \(error)")
        }
    }
}
