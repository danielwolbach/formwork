//
//  SummarySection.swift
//  Formwork
//
//  Created by Daniel Wolbach on 06.09.26.
//

import FormworkKit
import SwiftUI

struct SummarySection: View {
    let statistics: WorkoutStatistics

    var body: some View {
        LazyVGrid(columns: [.init(.flexible()), .init(.flexible())]) {
            ValueCard(
                title: .statisticStreakTitle,
                value: String(localized: .statisticStreakValue(count: statistics.weekStreak())),
                pictogram: Pictogram(icon: "flame", tint: .orange)
            )

            ValueCard(
                title: .statisticLastSessionTitle,
                value: statistics.lastCompleted?.relativeDayDescription().localizedCapitalized,
                pictogram: Pictogram(icon: "calendar", tint: .indigo)
            )
        }
    }
}

#Preview("With History") {
    SummarySection(statistics: Samples.statistics.overall)
        .padding()
}

#Preview("No History") {
    SummarySection(statistics: Statistics(sessions: []).overall)
        .padding()
}
