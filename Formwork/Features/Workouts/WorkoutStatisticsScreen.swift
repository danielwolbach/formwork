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

        ScrollView {
            TileGrid {
                StatisticCard(
                    title: .statisticTypicalDurationTitle,
                    value: statistics.typicalDuration.map { Duration.seconds($0).formatted(.units(
                        allowed: [.hours, .minutes],
                        width: .abbreviated
                    )) },
                    pictogram: .init(icon: "stopwatch", tint: .cyan)
                )

                StatisticCard(
                    title: .statisticLastSessionTitle,
                    value: statistics.lastCompleted?.relativeDayDescription().localizedCapitalized,
                    pictogram: .init(icon: "calendar", tint: .indigo)
                )

                StatisticCard(
                    title: .statisticTimesCompletedTitle,
                    value: statistics.completions.count.formatted(),
                    pictogram: .init(icon: "repeat", tint: .orange)
                )

                StatisticCard(
                    title: .statisticMostSkippedTitle,
                    value: statistics.mostSkippedExercise,
                    pictogram: .init(icon: "forward.end", tint: .pink)
                )
            }
            .padding(.horizontal)
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
