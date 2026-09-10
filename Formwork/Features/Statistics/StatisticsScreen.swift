//
//  StatisticsScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 10.09.26.
//

import FormworkKit
import SwiftData
import SwiftUI

struct StatisticsScreen: View {
    @Query(Session.finishedDescriptor) private var sessions: [Session]

    var body: some View {
        let statistics = sessions.statistics()

        ScreenStack {
            TileGrid {
                StatisticCard(
                    title: .statisticStreakTitle,
                    value: String(localized: .statisticStreakValue(count: statistics.overall.weekStreak())),
                    pictogram: .streak
                )

                StatisticCard(
                    title: .statisticLastSessionTitle,
                    value: statistics.overall.lastCompleted?.relativeDayDescription().localizedCapitalized,
                    pictogram: .date
                )

                DistributionCard(
                    title: .statisticCompletedDistributionTitle,
                    distribution: statistics.completedDistribution
                )
                .tileSpan(columns: 2)
            }

            SectionStack(title: Text(.screenSessionsTitle)) {
                if sessions.isEmpty {
                    ContentUnavailableView {
                        Label(.emptySessionsTitle, systemImage: "flame")
                    } description: {
                        Text(.emptySessionsMessage)
                    }
                } else {
                    RowStack(navigating: Array(sessions.prefix(5)))
                }
            } accessory: {
                allSessionsLink.disabled(sessions.isEmpty)
            }
        }
        .navigationTitle(.screenStatisticsTitle)
        .navigationDestination(for: Route.self) { route in
            route
        }
        .navigationDestination(for: Session.self) { session in
            SessionScreen(session: session)
        }
    }

    private var allSessionsLink: some View {
        NavigationLink(.showAllSessions, value: Route.sessions)
            .labelStyle(.fixedTitleAndTrailingIcon)
            .buttonStyle(.glass)
    }
}

#Preview {
    NavigationStack {
        StatisticsScreen()
    }
    .sampleData()
}
