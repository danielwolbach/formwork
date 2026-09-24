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
        let history = History(.exercise(exercise))

        ScrollView {
            VStack(spacing: 32) {
                PictogramHeader(exercise)

                TileGrid {
                    StatisticCard(.lastCompleted, of: history)

                    StatisticCard(.completionRate, of: history)

                    StatisticCard(.personalBest, of: history)

                    StatisticCard(.completions, of: history)

                    StatisticCard(.progression, of: history)

                    StatisticCard(.activeDays, of: history)
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
    let _ = Samples.sessions

    NavigationStack {
        ExerciseScreen(exercise: Samples.exercises.first!)
    }
}
