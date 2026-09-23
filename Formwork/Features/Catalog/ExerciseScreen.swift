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
    let exercise: Exercise

    @Environment(\.modelContext)
    private var modelContext: ModelContext

    @Environment(\.dismiss)
    private var dismiss: DismissAction

    @State
    private var sheet: Sheet? = nil

    @State
    private var deleteAlert: Bool = false

    var body: some View {
        let statistics = exercise.statistics()

        ScrollView {
            VStack(spacing: 32) {
                PictogramHeader(exercise)

                TileGrid {
                    MetricCard(statistics.lastCompleted)
                    MetricCard(statistics.completionRate)
                    MetricCard(statistics.personalBest)
                    MetricCard(statistics.completions)

                    ProgressionCard(statistics.progression)
                        .tileSpan(rows: 2, columns: 2)

                    HeatmapCard(statistics.activity)
                        .tileSpan(rows: 2, columns: 2)
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
