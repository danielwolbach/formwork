//
//  StreakSheet.swift
//  Formwork
//
//  Created by Daniel Wolbach on 24.09.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct StreakSheet: View {
    let history: History

    @Environment(\.units)
    private var units: Units

    var body: some View {
        let current = WeekStreak(history.allTime)
        let longest = LongestWeekStreak(history.allTime)

        StatisticSheet(current, history: history) {
            VStack(spacing: 16) {
                ValueRow(title: current.title, value: current.reading?.formatted(.reading(units: units)))

                Divider()

                ValueRow(title: longest.title, value: longest.reading?.formatted(.reading(units: units)))
            }
            .padding()
            .card()
            .padding(.horizontal)
        }
        .tint(current.pictogram.color)
    }
}
