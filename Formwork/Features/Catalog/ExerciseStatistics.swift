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
        let hasWeight: Bool = switch history.subject {
        case let .exercise(exercise): exercise.kind == .weight
        case let .entry(entry): entry.exercise?.kind == .weight
        default: false
        }

        TileGrid {
            StatisticCard(.lastCompleted, of: history)

            StatisticCard(.completionRate, of: history)

            StatisticCard(.personalBest, of: history)

            StatisticCard(.completions, of: history)

            StatisticCard(.typicalDuration, of: history)

            StatisticCard(.typicalInterval, of: history)

            if hasWeight {
                StatisticCard(.oneRepMax, of: history)

                StatisticCard(.totalVolume, of: history)
            }

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
            ExerciseStatistics(history: History(.exercise(Samples.exercises[2])))
                .padding(.horizontal)
        }
    }
    .sampleData()
}
