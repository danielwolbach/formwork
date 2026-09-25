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
        let history = History(.workout(workout))

        ScrollView {
            TileGrid {
                StatisticCard(.lastCompleted, of: history)

                StatisticCard(.typicalDuration, of: history)

                StatisticCard(.completionRate, of: history)

                StatisticCard(.mostSkippedExercise, of: history)

                StatisticCard(.activeDays, of: history)

                StatisticCard(.typicalStartTime, of: history)

                StatisticCard(.completions, of: history)

                StatisticCard(.categories, of: history)
            }
            .padding(.horizontal, 16)
            .padding(.bottom)
        }
        .navigationTitle(.screenStatisticsTitle)
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
