//
//  ExerciseScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import SwiftData
import SwiftUI

struct ExerciseScreen: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Environment(\.dismiss) private var dismiss: DismissAction
    @State private var sheet: Sheet? = nil
    @State private var deleteAlert: Bool = false

    let exercise: Exercise

    var body: some View {
        let statistics = exercise.statistics()

        ScrollView {
            VStack(spacing: 32) {
                PictogramHeader(exercise)

                TileGrid {
                    StatisticCard(statistics.lastCompleted)
                    StatisticCard(statistics.completionRate)
                    StatisticCard(statistics.personalBest)
                    StatisticCard(statistics.completions)
                }
                .padding(.horizontal, 16)
            }
        }
        .toolbar {
            Menu(.more) {
                Section {
                    Button(.edit) {
                        sheet = .editExercise(exercise: exercise)
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
        .alert(.alertExerciseDeleteTitle, isPresented: $deleteAlert) {
            Button(.delete) {
                delete()
            }

            Button(.cancel) {}
        } message: {
            Text(.alertExerciseDeleteMessage)
        }
    }

    func delete() {
        modelContext.delete(exercise)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        ExerciseScreen(exercise: Samples.exercises.first!)
    }
}
