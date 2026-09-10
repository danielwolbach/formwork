//
//  DisplayableHero.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import SwiftUI

struct DisplayableHero: View {
    private let title: String
    private let subtitle: String?
    private let pictogram: Pictogram
    private let badge: Pictogram?

    init(displayable: (some Displayable)?) {
        if let displayable {
            self.title = displayable.title
            self.subtitle = displayable.subtitle
            self.pictogram = displayable.pictogram
            self.badge = displayable.badge
        } else {
            self.title = String(localized: .unknown)
            self.subtitle = nil
            self.pictogram = .unknown
            self.badge = nil
        }
    }

    var body: some View {
        VStack(spacing: 32) {
            PictogramView(pictogram: pictogram, size: 192, badge: badge)

            VStack {
                Text(title).font(.headline).lineLimit(1)

                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .lineLimit(1)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview("Subtitled") {
    DisplayableHero(displayable: Samples.exercises.first)
}

#Preview("Plain") {
    DisplayableHero(displayable: ExerciseType.weight)
}

#Preview("Missing") {
    DisplayableHero(displayable: Exercise?.none)
}
