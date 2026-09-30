//
//  ProgressionCard.swift
//  Formwork
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Charts
import FormworkKit
import FormworkUI
import SwiftUI

struct ProgressionCard: View {
    private let progression: Progression

    init(_ progression: Progression) {
        self.progression = progression
    }

    var body: some View {
        GroupBox {
            if progression.points.isEmpty {
                Image(systemName: progression.pictogram.image)
                    .font(.largeTitle)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ProgressionChart(progression)
                    .padding(.top)
            }
        } label: {
            Label(progression.title, systemImage: progression.pictogram.image)
        }
        .groupBoxStyle(.card)
    }
}
