//
//  WorkoutStatisticsScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 06.09.26.
//

import FormworkKit
import SwiftData
import SwiftUI

struct WorkoutStatisticsScreen: View {
    @Environment(\.dismiss) private var dismiss: DismissAction
    @Query(Session.finishedDescriptor) private var sessions: [Session]

    let workout: Workout

    var body: some View {
        let statistics = SessionStatistics(sessions, of: workout)
        let shares = ExerciseCategory.shares(of: workout.entries.compactMap { $0.exercise?.categories })

        ScreenStack {
            TileGrid {
                StatisticCard(
                    title: .statisticLastSessionTitle,
                    value: statistics.lastCompleted?.defaultFormattedRelative().localizedCapitalized,
                    pictogram: .date
                )

                StatisticCard(
                    title: .statisticTimesCompletedTitle,
                    value: statistics.completionCount.formatted(),
                    pictogram: .tally
                )

                CompletionCalendarCard(
                    title: .statisticCompletionCalendarTitle,
                    completedDays: statistics.completedDays,
                    tint: workout.pictogram.color
                )
                .tileSpan(columns: 2)

                StatisticCard(
                    title: .statisticCompletionRateTitle,
                    value: statistics.completionRate?.defaultFormattedPercent(),
                    pictogram: .completed
                )

                StatisticCard(
                    title: .statisticMostSkippedTitle,
                    value: statistics.mostSkippedExercise,
                    pictogram: .skipped
                )

                ExerciseCategoryDistributionCard(title: .statisticDistributionTitle, shares: shares)
                    .tileSpan(columns: 2)

                StatisticCard(
                    title: .statisticTypicalDurationTitle,
                    value: statistics.typicalDuration?.defaultFormatted(),
                    pictogram: .duration
                )

                StatisticCard(
                    title: .statisticTypicalStartTimeTitle,
                    value: statistics.typicalStartTime?.defaultFormattedTime(),
                    pictogram: .time
                )
            }
        }
        .navigationTitle(.screenStatisticsTitle)
        .navigationSubtitle(workout.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(.cancel) {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutStatisticsScreen(workout: Samples.workouts.first!)
    }
    .sampleData()
}
