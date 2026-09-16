//
//  SummarySection.swift
//  Formwork
//
//  Created by Daniel Wolbach on 06.09.26.
//

import FormworkKit
import SwiftUI

struct SummarySection: View {
    let statistics: SessionStatistics

    var body: some View {
        TileGrid {
            StatisticCard(
                title: .statisticStreakTitle,
                value: String(localized: .statisticStreakValue(count: statistics.currentStreak)),
                pictogram: .streak
            )

            StatisticCard(
                title: .statisticLastSessionTitle,
                value: statistics.lastCompleted?.defaultFormattedRelative().localizedCapitalized,
                pictogram: .date
            )
        }
    }
}

#Preview("With History") {
    SummarySection(statistics: Samples.statistics)
        .padding()
}

#Preview("No History") {
    SummarySection(statistics: SessionStatistics([]))
        .padding()
}
