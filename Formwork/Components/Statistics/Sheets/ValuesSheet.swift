//
//  ValuesSheet.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct ValuesSheet<S: Statistic>: View {
    let history: History

    var body: some View {
        let overall = S(history.allTime)

        StatisticSheet(overall, history: history) {
            ValuesSection(overall: overall.formattedValue, recent: S(history.recent).formattedValue)
        }
        .tint(overall.pictogram.color)
    }
}
