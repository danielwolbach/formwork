//
//  SummarySection.swift
//  Formwork
//
//  Created by Daniel Wolbach on 06.09.26.
//

import FormworkKit
import SwiftUI

struct SummarySection: View {
    let stats: Stats

    private var overall: WorkoutStats {
        stats.overall
    }

    var body: some View {
        LazyVGrid(columns: [.init(.flexible()), .init(.flexible())]) {
            ValueCard(
                title: .statisticStreakTitle,
                value: String(localized: .statisticStreakValue(count: overall.weekStreak())),
                pictogram: Pictogram(icon: "flame", tint: .orange)
            )

            ValueCard(
                title: .statisticLastSessionTitle,
                value: overall.lastCompleted.relativeDayDescription().localizedCapitalized,
                pictogram: Pictogram(icon: "calendar", tint: .indigo)
            )
        }
    }
}

#Preview("With History") {
    SummarySection(stats: Samples.stats)
        .padding()
}

#Preview("No History") {
    SummarySection(stats: Stats(sessions: []))
        .padding()
}
