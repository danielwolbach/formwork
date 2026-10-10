//
//  StatisticChips.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.10.26.
//

import Flow
import FormworkKit
import FormworkUI
import SwiftData
import SwiftUI

struct StatisticChips: View {
    private static let statistics: [Statistic] = [.weekStreak, .lastCompleted]

    @Query(Session.finishedDescriptor)
    private var sessions: [Session]

    @State
    private var selection: Statistic? = nil

    var body: some View {
        let history = History(.all, among: sessions)

        HFlow {
            ForEach(Self.statistics) { statistic in
                Button {
                    guard selection == nil else {
                        return
                    }

                    selection = statistic
                } label: {
                    StatisticChip(statistic, of: history)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(statistic.title)
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
}

private struct StatisticChip: View {
    private let statistic: Statistic

    private let history: History

    @Environment(\.units)
    private var units: Units

    init(_ statistic: Statistic, of history: History) {
        self.statistic = statistic
        self.history = history
    }

    var body: some View {
        let pictogram = statistic.pictogram

        Label(text, systemImage: pictogram.image)
            .labelStyle(.chip(tint: pictogram.color))
    }

    private var text: String {
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
