//
//  ExerciseRow.swift
//  Formwork
//
//  Created by Daniel Wolbach on 29.09.26.
//

import FormworkKit
import SwiftData
import SwiftUI

struct ExerciseRow: View {
    private let exercise: Exercise

    @Environment(\.modelContext)
    private var context: ModelContext

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
                DisplayableRow(exercise)

                Image(systemName: "chevron.forward")
                    .foregroundStyle(.tertiary)
            }
            .padding(8)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .swipeActions {
            Button(Action.delete.title, systemImage: Action.delete.image) {
                deleteAlert = true
            }
            .tint(.red)
            .labelStyle(.fixedIconOnly)
        }
        .contextMenu {
            Section {
                Button(.edit) {
                    sheet = .editExercise(exercise)
                }

                Button(.delete) {
                    deleteAlert = true
                }
            }
        } preview: {
            let history = History(.exercise(exercise))

            VStack(spacing: 16) {
                DisplayableRow(exercise)

                if !history.sessions.isEmpty {
                    TileGrid {
                        StatisticCard(.lastCompleted, of: history)

                        StatisticCard(.completionRate, of: history)

                        StatisticCard(.personalBest, of: history)

                        StatisticCard(.completions, of: history)

                        StatisticCard(.typicalDuration, of: history)

                        StatisticCard(.typicalInterval, of: history)
                    }
                }
            }
            .frame(width: 360)
            .padding()
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
        .padding(.horizontal, 8)
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
