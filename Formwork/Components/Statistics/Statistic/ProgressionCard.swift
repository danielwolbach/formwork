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
                Image(systemName: Progression.pictogram.image)
                    .font(.largeTitle)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ProgressionChart(progression)
                    .padding(.top)
            }
        } label: {
            Label(Progression.title, systemImage: Progression.pictogram.image)
        }
        .groupBoxStyle(.card)
    }
}

#Preview {
    let history = History(.exercise(Samples.exercises[2]), among: Samples.sessions)

    TileGrid {
        ProgressionCard(Progression(history.weeks(16)))
            .tileSpan(rows: 2, columns: 2)
    }
    .padding()
    .sampleData()
}
