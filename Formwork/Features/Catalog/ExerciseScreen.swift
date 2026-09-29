//
//  ExerciseScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import FormworkUI
import SwiftData
import SwiftUI

struct ExerciseScreen: View {
    private let exercise: Exercise

    @Environment(\.modelContext)
    private var context: ModelContext

    @Environment(\.dismiss)
    private var dismiss: DismissAction

    @State
    private var sheet: Sheet? = nil

    @State
    private var deleteAlert: Bool = false

    init(_ exercise: Exercise) {
        self.exercise = exercise
    }

    var body: some View {
        let history = History(.exercise(exercise))

        ScrollView {
            VStack(spacing: 32) {
                PictogramHeader(exercise.pictogram, title: exercise.title, subtitle: exercise.categories.formatted(.exerciseCategories))

                if !history.sessions.isEmpty {
                    ExerciseStatistics(history: .init(.exercise(exercise)))
                        .padding(.horizontal)
                }

                ExerciseGuide(exercise)
                    .padding(.horizontal)
            }
        }
        .toolbar {
            Menu(.more) {
                Section {
                    Button(.edit) {
                        sheet = .editExercise(exercise)
                    }

                    Button(.delete) {
                        deleteAlert = true
                    }
                }
            }
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
            NavigationStack {
                sheet
            }
        }
    }

    private func delete() {
        context.delete(exercise)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        ExerciseScreen(Samples.exercises[1])
    }
}
