//
//  WorkoutStatisticsSheet.swift
//  Formwork
//
//  Created by Daniel Wolbach on 18.09.26.
//

import FormworkKit
import FormworkUI
import SwiftData
import SwiftUI

struct WorkoutStatisticsSheet: View {
    private let workout: Workout

    @Environment(\.dismiss)
    private var dismiss: DismissAction

    @Query(Session.finishedDescriptor)
    private var sessions: [Session]

    init(_ workout: Workout) {
        self.workout = workout
    }

    var body: some View {
        let history = History(.workout(workout), among: sessions)

        Group {
            if history.occurrences.isEmpty {
                ContentUnavailableView {
                    Label(.emptyStatisticsTitle, systemImage: "flame")
                } description: {
                    Text(.emptyStatisticsMessage)
                }
            } else {
                ScrollView {
                    ContentStack {
                        StatisticGrid(history)
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
    NavigationRoot {
        WorkoutStatisticsSheet(Samples.workouts.first!)
    }
    .sampleData()
}
