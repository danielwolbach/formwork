//
//  StatisticsScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 19.09.26.
//

import FormworkKit
import SwiftData
import SwiftUI

struct StatisticsScreen: View {
    @Query(Session.finishedDescriptor)
    private var sessions: [Session]

    var body: some View {
        content
            .navigationTitle(.screenStatisticsTitle)
            .navigationDestination(for: Session.self) { session in
                SessionScreen(session: session)
            }
            .navigationDestination(for: Route.self) { $0 }
    }

    @ViewBuilder
    private var content: some View {
        if sessions.isEmpty {
            ContentUnavailableView {
                Label(.emptyStatisticsTitle, systemImage: "flame")
            } description: {
                Text(.emptyStatisticsDescription)
            }
        } else {
            statisticsContent
        }
    }

    @ViewBuilder
    private var statisticsContent: some View {
        let statistics = sessions.statistics()

        ScrollView {
            VStack(spacing: 32) {
                TileGrid {
                    MetricCard(statistics.weekStreak)

                    MetricCard(statistics.lastSession)

                    HeatmapCard(statistics.activity)
                        .tileSpan(rows: 2, columns: 2)

                    MetricCard(statistics.sessionsPerWeek)

                    MetricCard(statistics.typicalDuration)

                    MetricCard(statistics.typicalStartTime)

                    MetricCard(statistics.favoriteWorkout)

                    DistributionCard(statistics.categories)
                        .tileSpan(columns: 2)

                    MetricCard(statistics.completions)

                    MetricCard(statistics.longestWeekStreak)
                }
                .padding(.horizontal)

                SectionView(.sectionRecentSessionsTitle) {
                    NavigationList(sessions.prefix(5)) { session in
                        PictogramRow(session)
                    }
                } accessory: {
                    NavigationLink(value: Route.sessions) {
                        Label(.viewAll)
                    }
                    .labelStyle(.fixedTitleAndIcon)
                    .buttonStyle(.glass)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        StatisticsScreen()
    }
    .sampleData()
}
