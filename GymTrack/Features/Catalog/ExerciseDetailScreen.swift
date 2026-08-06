//
//  ExerciseDetailScreen.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftData
import SwiftUI

struct ExerciseDetailScreen: View {
    @Environment(\.dismiss) private var dismiss: DismissAction
    @Environment(\.modelContext) private var modelContext: ModelContext
    @State private var sheet: ExerciseSheet?
    @State private var deleteAlert = false

    let exercise: Exercise

    var body: some View {
        ScrollView {
            ScreenStack {
                IconHero(icon: exercise.icon, color: exercise.color, title: exercise.title, subtitle: exercise.subtitle)

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
        .alert(.alertDeleteExerciseTitle, isPresented: $deleteAlert) {
            Button(.delete) {
                delete()
            }

            Button(.cancel) {}
        } message: {
            Text(.alertDeleteExerciseMessage)
        }
    }

    private func delete() {
        do {
            try modelContext.deleteExercise(exercise)
            dismiss()
        } catch {
            fatalError("Failed to delete exercise: \(error)")
        }
    }
}

#Preview {
    ExerciseDetailScreen(exercise: Exercise.samples[0])
}
