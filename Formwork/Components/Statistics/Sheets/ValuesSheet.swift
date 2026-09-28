//
//  ValuesSheet.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import FormworkKit
import SwiftUI

struct ValuesSheet<S: Statistic>: View {
    let history: History

    var body: some View {
        let overall = S(history.allTime)

        StatisticSheet(overall, history: history) {
            ValuesSection(overall: overall.subtitle, recent: S(history.recent).subtitle)
        }
        .tint(overall.pictogram.color)
    }
}
