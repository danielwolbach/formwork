//
//  StatisticCard.swift
//  Formwork
//
//  Created by Daniel Wolbach on 24.09.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct StatisticCard: View {
    private let kind: StatisticKind

    private let history: History

    private let action: () -> Void

    init(_ kind: StatisticKind, of history: History, action: @escaping () -> Void) {
        self.kind = kind
        self.history = history
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            label
        }
        .buttonStyle(.plain)
        .tileSpan(rows: span, columns: span)
    }

    @ViewBuilder
    private var label: some View {
        switch kind.summary(of: history) {
        case let .reading(reading, direction): ReadingCard(kind.definition, reading: reading, direction: direction)
        case let .activeDays(activeDays): ActiveDaysCard(activeDays)
        case let .categories(categories): CategoriesCard(categories)
        case let .progression(progression): ProgressionCard(progression)
        }
    }

    private var span: Int {
        kind.isChart ? 2 : 1
    }
}

#Preview {
    let history = History(.all, among: Samples.sessions)

    TileGrid {
        StatisticCard(.weekStreak, of: history) {}

        StatisticCard(.weeklySessions, of: history) {}

        StatisticCard(.activeDays, of: history) {}
    }
    .padding()
    .sampleData()
}
