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
    @Query(Session.finishedDescriptor) private var sessions: [Session]
    @State private var sheet: Sheet? = nil
    @State private var deleteAlert: Bool = false

    let exercise: Exercise

    var body: some View {
        let statistics = sessions.statistics()[exercise]

        ScreenStack {
            DisplayableHero(displayable: exercise)

            TileGrid {
                StatisticCard(
                    title: .statisticPersonalBestTitle,
                    value: statistics.personalBest?.measure,
                    pictogram: .record
                )

                StatisticCard(
                    title: .statisticCompletionRateTitle,
                    value: statistics.completionRate?.formatted(.percent.precision(.fractionLength(0))),
                    pictogram: .completed
                )

                StatisticCard(
                    title: .statisticLastPerformedTitle,
                    value: statistics.lastCompleted?.relativeDayDescription().localizedCapitalized,
                    pictogram: .date
                )

                StatisticCard(
                    title: .statisticTimesCompletedTitle,
                    value: statistics.completions.count.formatted(),
                    pictogram: .tally
                )
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
        .sheet(item: $sheet) { sheet in
            NavigationStack {
                sheet
            }
        }
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
