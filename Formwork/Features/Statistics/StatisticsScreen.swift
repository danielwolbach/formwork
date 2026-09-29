//
//  StatisticsScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 19.09.26.
//

import FormworkKit
import FormworkUI
import SwiftData
import SwiftUI

struct StatisticsScreen: View {
    @Query(Session.finishedDescriptor)
    private var sessions: [Session]

    var body: some View {
        content
            .navigationTitle(.screenStatisticsTitle)
            .navigationDestination(for: Session.self) { session in
                SessionScreen(session)
            }
            .navigationDestination(for: Route.self) { $0 }
    }

    @ViewBuilder
    private var content: some View {
        let history = History(.all(sessions))

        if history.sessions.isEmpty {
            ContentUnavailableView {
                Label(.emptyStatisticsTitle, systemImage: "flame")
            } description: {
                Text(.emptyStatisticsMessage)
            }
        } else {
            statisticsContent(history)
        }
    }

    private func statisticsContent(_ history: History) -> some View {
        ScrollView {
            VStack(spacing: 32) {
                TileGrid {
                    StatisticCard(.weekStreak, of: history)

                    StatisticCard(.lastCompleted, of: history)

                    StatisticCard(.activeDays, of: history)
                        .tileSpan(rows: 2, columns: 2)

                    StatisticCard(.weeklySessions, of: history)

                    StatisticCard(.completions, of: history)

                    StatisticCard(.typicalDuration, of: history)

                    StatisticCard(.typicalStartTime, of: history)

                    StatisticCard(.categories, of: history)
                        .tileSpan(rows: 2, columns: 2)

                    StatisticCard(.favoriteWorkout, of: history)

                    StatisticCard(.favoriteExercise, of: history)

                    StatisticCard(.totalVolume, of: history)
                }
                .padding(.horizontal)

                SectionView(.init(localized: .placeholder)) {
                    LazyVStack(spacing: 0) {
                        ForEach(sessions.prefix(5)) { session in
                            SessionRow(session)
                        }
                    }
                    .swipeActionsContainer()
                    .animation(.snappy, value: sessions.count)
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
