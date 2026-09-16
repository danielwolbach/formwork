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
    @Query(sort: \Workout.name) private var workouts: [Workout]
    @State private var sheet: Sheet? = nil
    @State private var deleteAlert: Bool = false

    let exercise: Exercise

    var body: some View {
        let statistics = ExerciseStatistics(sessions, of: exercise)

        ScreenStack {
            DisplayableHero(displayable: exercise)

            TileGrid {
                StatisticCard(
                    title: .statisticPersonalBestTitle,
                    value: statistics.personalBest?.measure,
                    pictogram: .record
                )

                StatisticCard(
                    title: .statisticLastPerformedTitle,
                    value: statistics.lastCompleted?.defaultFormattedRelative().localizedCapitalized,
                    pictogram: .date
                )

                ExerciseProgressCard(
                    title: .statisticProgressTitle,
                    progress: statistics.progress,
                    tint: exercise.pictogram.color
                )
                .tileSpan(columns: 2)

                StatisticCard(
                    title: .statisticTimesCompletedTitle,
                    value: statistics.completionCount.formatted(),
                    pictogram: .tally
                )

                StatisticCard(
                    title: .statisticCompletionRateTitle,
                    value: statistics.completionRate?.defaultFormattedPercent(),
                    pictogram: .completed
                )

                CompletionCalendarCard(
                    title: .statisticCompletionCalendarTitle,
                    completedDays: statistics.completedDays,
                    tint: exercise.pictogram.color
                )
                .tileSpan(columns: 2)
            }
        }
        .toolbar {
            Menu(.more) {
                Section {
                    Menu(.addToWorkout) {
                        ForEach(workouts) { workout in
                            Button(workout.name, systemImage: workout.pictogram.icon) {
                                sheet = .addExerciseToWorkout(exercise: exercise, workout: workout)
                            }
                        }
                    }
                    .disabled(workouts.isEmpty)
                }

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
