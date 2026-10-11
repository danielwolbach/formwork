//
//  StatisticChips.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.10.26.
//

import Flow
import FormworkKit
import FormworkUI
import SwiftUI

struct StatisticChips: View {
    private static let statistics: [Statistic] = [.weekStreak, .lastCompleted]

    @Environment(\.statistics)
    private var statistics: Statistics

    @Environment(\.units)
    private var units: Units

    @State
    private var selection: Statistic? = nil

    var body: some View {
        let history = statistics.history(.all)

        HFlow {
            ForEach(Self.statistics) { statistic in
                let summary = text(of: statistic, in: history)
                let pictogram = statistic == .weekStreak ? history.allTime.streak.pictogram : statistic.pictogram

                Button {
                    guard selection == nil else {
                        return
                    }

                    selection = statistic
                } label: {
                    Label(summary, systemImage: pictogram.image)
                        .labelStyle(.chip(tint: pictogram.color))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(statistic.title)
                .accessibilityValue(accessibilityValue(of: statistic, summary: summary, in: history))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .sheet(item: $selection) { statistic in
            NavigationRoot {
                StatisticSheet(statistic, of: history)
            }
            .presentationDetents([.medium, .large])
        }
    }

    /// The grey chip tells whether this week counts yet, so VoiceOver says it too.
    private func accessibilityValue(of statistic: Statistic, summary: String, in history: History) -> String {
        guard !statistic.isChart else {
            return ""
        }

        guard statistic == .weekStreak else {
            return summary
        }

        let status: LocalizedStringResource = history.allTime.streak.isCurrentWeekFulfilled ? .statisticWeekStreakFulfilledSubtitle : .statisticWeekStreakPendingSubtitle
        return "\(summary), \(String(localized: status))"
    }

    private func text(of statistic: Statistic, in history: History) -> String {
        guard !statistic.isChart else {
            return statistic.title
        }

        return statistic.reading(in: history)?.formatted(.reading(units: units)) ?? "—"
    }
}

#Preview {
    NavigationRoot {
        ScrollView {
            ContentStack {
                StatisticChips()
            }
        }
    }
    .sampleData()
}
