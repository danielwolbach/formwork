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
    @Query private var sessions: [Session]

    var body: some View {
        let statistics = sessions.statistics()

        ScrollView {
            LazyVGrid(columns: [.init(.flexible(), spacing: 8), .init(.flexible(), spacing: 8)], spacing: 8) {
                StatisticCard(statistics.weekStreak)
                StatisticCard(statistics.lastSession)
                StatisticCard(statistics.longestWeekStreak)
                StatisticCard(statistics.sessionsPerWeek)
            }
            .padding(.horizontal)
        }
        .navigationTitle(.screenStatisticsTitle)
    }
}

#Preview {
    NavigationStack {
        StatisticsScreen()
    }
    .sampleData()
}
