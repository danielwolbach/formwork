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
    private let statistic: Statistic

    private let history: History

    private let action: () -> Void

    init(_ statistic: Statistic, of history: History, action: @escaping () -> Void) {
        self.statistic = statistic
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
        switch statistic.kind {
        case .formula, .measurement, .streak: ReadingCard(statistic, reading: statistic.reading(in: history), direction: statistic.direction(in: history))
        case .activeDays: ActiveDaysCard(ActiveDays(history.weeks(History.chartedWeeks)))
        case .categories: CategoriesCard(Categories(history.recent))
        case .progression: ProgressionCard(Progression(history.weeks(History.chartedWeeks)))
        }
    }

    private var span: Int {
        statistic.isChart ? 2 : 1
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
