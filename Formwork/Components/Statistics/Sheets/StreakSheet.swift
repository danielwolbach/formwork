//
//  StreakSheet.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct StreakSheet: View {
    let history: History

    var body: some View {
        let current = WeekStreak(history.allTime)
        let longest = LongestWeekStreak(history.allTime)

        StatisticSheet(current, history: history) {
            VStack(spacing: 16) {
                ValueRow(title: current.title, value: current.formattedValue)

                Divider()

                ValueRow(title: longest.title, value: longest.formattedValue)
            }
            .padding()
            .card()
            .padding(.horizontal)
        }
        .tint(current.pictogram.color)
    }
}
