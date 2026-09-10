//
//  PictogramChip.swift
//  Formwork
//
//  Created by Daniel Wolbach on 10.09.26.
//

import FormworkKit
import SwiftUI

struct PictogramChip: View {
    private let title: String
    private let pictogram: Pictogram
    private let detail: String?

    init(displayable: some Displayable, detail: String? = nil) {
        self.title = displayable.title
        self.pictogram = displayable.pictogram
        self.detail = detail
    }

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: pictogram.icon)

            Text(title)
                .lineLimit(1)

            if let detail {
                Text(detail)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
        }
        .font(.caption)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .foregroundStyle(pictogram.color)
        .background {
            Capsule().fill(pictogram.color.quinary)
        }
    }
}

#Preview("Plain") {
    FlowLayout {
        ForEach(ExerciseCategory.allCases) { category in
            PictogramChip(displayable: category)
        }
    }
    .padding()
}

#Preview("Detailed") {
    FlowLayout {
        ForEach(ExerciseCategory.allCases) { category in
            PictogramChip(displayable: category, detail: "42%")
        }
    }
    .padding()
}
