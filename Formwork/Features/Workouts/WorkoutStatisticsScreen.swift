//
//  WorkoutStatisticsScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 18.09.26.
//

import FormworkKit
import SwiftUI

struct WorkoutStatisticsScreen: View {
    let workout: Workout

    var body: some View {
        let statistics = workout.statistics()

        ScrollView {
            TileGrid {
                MetricCard(statistics.lastCompleted)

                MetricCard(statistics.typicalDuration)

                MetricCard(statistics.completionRate)

                MetricCard(statistics.mostSkippedExercise)

                HeatmapCard(statistics.activity)
                    .tileSpan(rows: 2, columns: 2)

                MetricCard(statistics.typicalStartTime)

                MetricCard(statistics.completions)

                DistributionCard(statistics.categories)
                    .tileSpan(columns: 2)
            }
            .padding(.horizontal, 16)
        }
        .navigationTitle(.screenWorkoutStatisticsTitle)
        .navigationSubtitle(workout.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        WorkoutStatisticsScreen(workout: Samples.workouts.first!)
    }
    .sampleData()
}
