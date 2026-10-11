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

                Button {
                    guard selection == nil else {
                        return
                    }

                    selection = statistic
                } label: {
                    Label(summary, systemImage: statistic.pictogram.image)
                        .labelStyle(.chip(tint: statistic.pictogram.color))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(statistic.title)
                .accessibilityValue(statistic.isChart ? "" : summary)
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
