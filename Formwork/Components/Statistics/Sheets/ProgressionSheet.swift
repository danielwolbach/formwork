//
//  ProgressionSheet.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import FormworkKit
import SwiftUI

struct ProgressionSheet: View {
    private let history: History

    init(history: History) {
        self.history = history
    }

    var body: some View {
        let progression = Progression(history.recent)
        let trend = Trend<TypicalBest>(history)
        let best = PersonalBest(history.allTime)

        StatisticSheet(progression, history: history) {
            ValuesSection(
                overall: best.subtitle,
                recent: trend.recent.subtitle,
                baseline: trend.baseline?.subtitle,
                direction: trend.direction
            )

            YearSection(years: history.years) { year in
                ProgressionChart(Progression(history.year(year)), isYear: true)
                    .frame(height: 200)
            }
        }
        .tint(progression.pictogram.color)
    }
}
