//
//  ProgressionCard.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Charts
import FormworkKit
import SwiftUI

struct ProgressionCard: View {
    private let progression: Progression

    init(_ progression: Progression) {
        self.progression = progression
    }

    var body: some View {
        VStack(alignment: .leading) {
            Label(progression.title, systemImage: progression.pictogram.image)
                .font(.subheadline)
                .lineLimit(1)
                .foregroundStyle(.secondary)

            if progression.points.isEmpty {
                Image(systemName: progression.pictogram.image)
                    .font(.largeTitle)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ProgressionChart(progression)
                    .padding(.top)
            }
        }
        .padding()
        .card()
    }
}
