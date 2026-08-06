//
//  GlobalStatisticsScreen.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 06.08.26.
//

import SwiftData
import SwiftUI

struct GlobalStatisticsScreen: View {
    @Query(sort: \Session.started, order: .reverse) private var sessions: [Session]
    @State private var sessionHistoryPresented = false

    var body: some View {
        ScrollView {
            ScreenStack {
                StatisticsStack {
                    StatisticsRowStack {
                        MetricCard(
                            value: sessions.finishedSessionCount(in: .currentWeek).formatted(),
                            title: .statsThisWeek,
                            icon: "calendar",
                            tint: .green
                        )

                        MetricCard(
                            value: sessions.finishedSessionCount(in: .currentMonth).formatted(),
                            title: .statsThisMonth,
                            icon: "calendar.badge.clock",
                            tint: .blue
                        )
                    }

                    MetricCard(
                        value: sessions.finishedSessionCount(in: .allTime).formatted(),
                        title: .statsTotalSessions,
                        icon: "dumbbell",
                        tint: .purple
                    )

                    if !sessions.completedDisciplineDistribution.isEmpty {
                        DisciplineDistributionChart(data: sessions.completedDisciplineDistribution)
                    }

                    WeeklySessionsChart(data: sessions.weeklySessionCounts(), tint: .green)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle(.screenStats)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(.sessionHistory) {
                    sessionHistoryPresented = true
                }
            }
        }
        .sheet(isPresented: $sessionHistoryPresented) {
            NavigationStack {
                SessionListScreen(sessions: sessions)
            }
        }
    }
}

#Preview {
    NavigationStack {
        GlobalStatisticsScreen()
    }
    .sampleData()
}
