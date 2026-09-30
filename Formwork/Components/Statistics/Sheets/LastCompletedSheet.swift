//
//  LastCompletedSheet.swift
//  Formwork
//
//  Created by Daniel Wolbach on 24.09.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct LastCompletedSheet: View {
    let history: History

    @Environment(\.units)
    private var units: Units

    var body: some View {
        let lastCompleted = LastCompleted(history.allTime)

        StatisticSheet(lastCompleted, history: history) {
            GroupBox {
                ValueRow(title: lastCompleted.title, value: lastCompleted.reading?.formatted(.reading(units: units)))
            }
        }
        .groupBoxStyle(.card)
        .tint(lastCompleted.pictogram.color)
    }
}
