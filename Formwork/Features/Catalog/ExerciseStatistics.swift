//
//  ExerciseStatistics.swift
//  Formwork
//
//  Created by Daniel Wolbach on 24.09.26.
//

import FormworkKit
import SwiftUI

/// The statistics of an exercise, or of one workout's slot of it: whichever the history is of.
struct ExerciseStatistics: View {
    let history: History

    var body: some View {
        TileGrid {
            StatisticCard(.lastCompleted, of: history)

            StatisticCard(.completionRate, of: history)

            StatisticCard(.personalBest, of: history)

            StatisticCard(.completions, of: history)

            StatisticCard(.progression, of: history)

            StatisticCard(.activeDays, of: history)
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            ExerciseStatistics(history: History(.exercise(Samples.exercises.first!)))
        }
    }
    .sampleData()
}
