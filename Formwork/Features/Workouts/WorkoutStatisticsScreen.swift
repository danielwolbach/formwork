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
        let statistics = sessions.statistics()[workout]
        let distribution = CategoryDistribution(categories: workout.entries.compactMap { $0.exercise?.categories })

        ScreenStack {
            TileGrid {
                StatisticCard(
                    title: .statisticTypicalDurationTitle,
                    value: statistics.typicalDuration.map { Duration.seconds($0).formatted(.units(
                        allowed: [.hours, .minutes],
                        width: .abbreviated
                    )) },
                    pictogram: .duration
                )

                StatisticCard(
                    title: .statisticLastSessionTitle,
                    value: statistics.lastCompleted?.relativeDayDescription().localizedCapitalized,
                    pictogram: .date
                )

                StatisticCard(
                    title: .statisticTimesCompletedTitle,
                    value: statistics.completions.count.formatted(),
                    pictogram: .tally
                )

                StatisticCard(
                    title: .statisticMostSkippedTitle,
                    value: statistics.mostSkippedExercise,
                    pictogram: .skipped
                )

                DistributionCard(title: .statisticDistributionTitle, distribution: distribution)
                    .tileSpan(columns: 2)
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
