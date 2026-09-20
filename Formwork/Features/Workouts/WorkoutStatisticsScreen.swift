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
            LazyVGrid(columns: GridItem.ntile(n: 2, spacing: 8), spacing: 8) {
                StatisticCard(statistics.lastCompleted)
                StatisticCard(statistics.typicalDuration)
                StatisticCard(statistics.completionRate)
                StatisticCard(statistics.mostSkippedExercise)
                StatisticCard(statistics.typicalStartTime)
                StatisticCard(statistics.completions)
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
