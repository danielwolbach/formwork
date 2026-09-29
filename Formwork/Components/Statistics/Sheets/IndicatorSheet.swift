//
//  IndicatorSheet.swift
//  Formwork
//
//  Created by Daniel Wolbach on 24.09.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct IndicatorSheet<S: Indicator>: View {
    let history: History

    @Environment(\.units)
    private var units: Units

    var body: some View {
        let overall = S(history.allTime)

        StatisticSheet(overall, history: history) {
            ValuesSection(overall: overall.reading?.formatted(.reading(units: units)), recent: S(history.recent).reading?.formatted(.reading(units: units)))
        }
        .tint(overall.pictogram.color)
    }
}
