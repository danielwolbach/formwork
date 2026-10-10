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
    @Environment(\.scenePhase)
    private var scenePhase: ScenePhase

    @Query(Session.finishedDescriptor)
    private var sessions: [Session]

    var body: some View {
        content
            .navigationTitle(.screenStatisticsTitle)
            // Reread on return, since weigh-ins arrive in Health while the app is away.
            .task(id: scenePhase) {
                guard scenePhase == .active else {
                    return
                }

                await Health.shared.refresh()
            }
    }

    @ViewBuilder
    private var content: some View {
        let history = History(.all, among: sessions, measurements: Health.shared.measurements)

        if history.occurrences.isEmpty {
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
            ContentStack {
                StatisticGrid(history)

                SectionView(.fieldRecentSessionsTitle) {
                    LazyVStack(spacing: 0) {
                        ForEach(sessions.prefix(5)) { session in
                            SessionRow(session)
                        }
                    }
                    .swipeActionsContainer()
                    .animation(.snappy, value: sessions.count)
                    .edgeToEdge()
                } accessory: {
                    NavigationLink(value: Route.sessions) {
                        Label(.viewAll)
                    }
                    .labelStyle(.fixedTitleAndIcon)
                    .buttonStyle(.glass)
                }
            }
        }
        .contentMargins(.bottom, .sections, for: .scrollContent)
    }
}

#Preview {
    NavigationRoot {
        StatisticsScreen()
    }
    .sampleData()
}
