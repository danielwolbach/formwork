//
//  WorkoutStatisticsScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 18.09.26.
//

import FormworkKit
import SwiftUI

struct WorkoutStatisticsScreen: View {
    private let workout: Workout

    @Environment(\.dismiss)
    private var dismiss: DismissAction

    init(_ workout: Workout) {
        self.workout = workout
    }

    var body: some View {
        let history = History(.workout(workout))

        ScrollView {
            TileGrid {
                StatisticCard(.lastCompleted, of: history)

                StatisticCard(.typicalDuration, of: history)

                StatisticCard(.completionRate, of: history)

                StatisticCard(.mostSkippedExercise, of: history)

                StatisticCard(.activeDays, of: history)
                    .tileSpan(rows: 2, columns: 2)

                StatisticCard(.typicalStartTime, of: history)

                StatisticCard(.completions, of: history)

                StatisticCard(.categories, of: history)
                    .tileSpan(rows: 2, columns: 2)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(.minimize) {
                    dismiss()
                }
            }
        }
        .navigationTitle(.screenStatisticsTitle)
        .navigationSubtitle(workout.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        WorkoutStatisticsScreen(Samples.workouts.first!)
    }
    .sampleData()
}
