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
    @Query(Session.finishedDescriptor) private var sessions: [Session]

    var body: some View {
        let statistics = sessions.statistics()

        ScrollView {
            VStack(spacing: 32) {
                LazyVGrid(columns: GridItem.ntile(n: 2, spacing: 8), spacing: 8) {
                    StatisticCard(statistics.weekStreak)
                    StatisticCard(statistics.lastSession)
                    StatisticCard(statistics.longestWeekStreak)
                    StatisticCard(statistics.sessionsPerWeek)
                }
                .padding(.horizontal)

                SectionView(.sectionRecentSessionsTitle) {
                    LazyVStack(spacing: 0) {
                        ForEach(sessions.prefix(5)) { session in
                            NavigationLink(value: session) {
                                PictogramRow(session)

                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.tertiary)
                            }
                            .buttonStyle(.plain)
                            .padding(.vertical, 8)
                        }
                    }
                } accessory: {
                    NavigationLink(value: Route.sessions) {
                        Label(.viewAll)
                    }
                    .labelStyle(.fixedTitleAndIcon)
                    .buttonStyle(.glass)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle(.screenStatisticsTitle)
        .navigationDestination(for: Session.self) { session in
            SessionScreen(session: session)
        }
        .navigationDestination(for: Route.self) { $0 }
    }
}

#Preview {
    NavigationStack {
        StatisticsScreen()
    }
    .sampleData()
}
