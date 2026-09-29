//
//  LastCompletedSheet.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct LastCompletedSheet: View {
    let history: History

    var body: some View {
        let lastCompleted = LastCompleted(history.allTime)

        StatisticSheet(lastCompleted, history: history) {
            ValueRow(title: lastCompleted.title, value: lastCompleted.subtitle)
                .padding()
                .card()
                .padding(.horizontal)
        }
        .tint(lastCompleted.pictogram.color)
    }
}
