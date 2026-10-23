//
//  StatisticsScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 19.09.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct StatisticsScreen: View {
    @Environment(\.scenePhase)
    private var scenePhase: ScenePhase

    @Environment(\.statistics)
    private var statistics: Statistics

    @State
    private var sheet: Sheet?

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
            .sheet(item: $sheet) { sheet in
                sheet
            }
    }

    @ViewBuilder
    private var content: some View {
        let history = statistics.history(.all)

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
                        ForEach(statistics.sessions.prefix(5)) { session in
                            NavigationLink(value: session) {
                                SessionRow(session)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .swipeActionsContainer()
                    .animation(.snappy, value: statistics.sessions.count)
                    .edgeToEdge()
                } accessory: {
                    Button {
                        sheet = .sessions
                    } label: {
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
