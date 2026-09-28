//
//  ExerciseStatistics.swift
//  Formwork
//
//  Created by Daniel Wolbach on 24.09.26.
//

import FormworkKit
import SwiftUI

struct ExerciseStatistics: View {
    private let history: History

    init(history: History) {
        self.history = history
    }

    var body: some View {
        TileGrid {
            StatisticCard(.lastCompleted, of: history)

            StatisticCard(.completionRate, of: history)

            StatisticCard(.personalBest, of: history)

            StatisticCard(.completions, of: history)

            StatisticCard(.progression, of: history)
                .tileSpan(rows: 2, columns: 2)

            StatisticCard(.activeDays, of: history)
                .tileSpan(rows: 2, columns: 2)
        }
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            ExerciseStatistics(history: History(.exercise(Samples.exercises.first!)))
                .padding(.horizontal)
        }
    }
    .sampleData()
}
