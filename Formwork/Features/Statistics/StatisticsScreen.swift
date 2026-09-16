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
        let statistics = SessionStatistics(sessions)

        ScreenStack {
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

                CompletionCalendarCard(
                    title: .statisticCompletionCalendarTitle,
                    completedDays: statistics.completedDays,
                    tint: Pictogram.streak.color
                )
                .tileSpan(columns: 2)

                StatisticCard(
                    title: .statisticTimesCompletedTitle,
                    value: statistics.completionCount.formatted(),
                    pictogram: .tally
                )

                StatisticCard(
                    title: .statisticSessionsThisMonthTitle,
                    value: statistics.completionsThisMonth.formatted(),
                    pictogram: .month
                )

                StatisticCard(
                    title: .statisticLongestStreakTitle,
                    value: String(localized: .statisticStreakValue(count: statistics.longestStreak)),
                    pictogram: .record
                )

                StatisticCard(
                    title: .statisticCompletionRateTitle,
                    value: statistics.completionRate?.defaultFormattedPercent(),
                    pictogram: .completed
                )

                ExerciseCategoryDistributionCard(
                    title: .statisticCompletedDistributionTitle,
                    shares: statistics.completedShares
                )
                .tileSpan(columns: 2)

                StatisticCard(
                    title: .statisticTypicalDurationTitle,
                    value: statistics.typicalDuration?.defaultFormatted(),
                    pictogram: .duration
                )

                StatisticCard(
                    title: .statisticTypicalStartTimeTitle,
                    value: statistics.typicalStartTime?.defaultFormattedTime(),
                    pictogram: .time
                )
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
