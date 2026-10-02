//
//  WorkoutStatisticsSheet.swift
//  Formwork
//
//  Created by Daniel Wolbach on 18.09.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct WorkoutStatisticsSheet: View {
    private let workout: Workout

    @Environment(\.dismiss)
    private var dismiss: DismissAction

    init(_ workout: Workout) {
        self.workout = workout
    }

    var body: some View {
        let history = History(.workout(workout))

        Group {
            if history.sessions.isEmpty {
                ContentUnavailableView {
                    Label(.emptyStatisticsTitle, systemImage: "flame")
                } description: {
                    Text(.emptyStatisticsMessage)
                }
            } else {
                ScrollView {
                    ContentStack {
                        TileGrid {
                            StatisticCard(.lastCompleted, of: history)

                            StatisticCard(.typicalDuration, of: history)

                            StatisticCard(.completionRate, of: history)

                            StatisticCard(.mostSkippedExercise, of: history)

                            StatisticCard(.activeDays, of: history)
                                .tileSpan(rows: 2, columns: 2)

                            StatisticCard(.typicalStartTime, of: history)

                            StatisticCard(.completions, of: history)

                            StatisticCard(.typicalInterval, of: history)

                            StatisticCard(.totalVolume, of: history)

                            StatisticCard(.categories, of: history)
                                .tileSpan(rows: 2, columns: 2)
                        }
                    }
                }
                .contentMargins(.bottom, .sections, for: .scrollContent)
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(.cancel) {
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
        WorkoutStatisticsSheet(Samples.workouts.first!)
    }
    .sampleData()
}
