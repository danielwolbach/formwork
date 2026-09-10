//
//  DisplayableRow.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import SwiftUI

struct DisplayableRow: View {
    private let title: String
    private let subtitle: String?
    private let pictogram: Pictogram
    private let badge: Pictogram?

    init(displayable: some Displayable) {
        self.title = displayable.title
        self.subtitle = displayable.subtitle
        self.pictogram = displayable.pictogram
        self.badge = displayable.badge
    }

    var body: some View {
        HStack {
            PictogramView(pictogram: pictogram, size: 64, badge: badge)

            VStack(alignment: .leading) {
                Text(title).font(.headline).lineLimit(1)

                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .lineLimit(1)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .contentShape(.rect)
    }
}

#Preview {
    VStack(spacing: 16) {
        DisplayableRow(displayable: Samples.exercises[0])
        DisplayableRow(displayable: Samples.workouts[0])
        DisplayableRow(displayable: ExerciseCategory.cardio)
    }
    .padding()
}
