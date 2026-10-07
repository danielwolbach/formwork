//
//  PictogramHeader.swift
//  FormworkUI
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import SwiftUI

public struct PictogramHeader: View {
    private let pictogram: Pictogram

    private let title: String

    private let subtitle: String?

    private let badge: Pictogram?

    public init(_ pictogram: Pictogram, title: String, subtitle: String? = nil, badge: Pictogram? = nil) {
        self.pictogram = pictogram
        self.title = title
        self.subtitle = subtitle
        self.badge = badge
    }

    public var body: some View {
        VStack(spacing: 16) {
            PictogramView(pictogram, badge: badge)
                .frame(width: 128 + 64, height: 128 + 64)

            VStack {
                Text(title)
                    .font(.headline)
                    .lineLimit(1)

                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

#Preview {
    let exercise = Samples.exercises.first!

    PictogramHeader(exercise.pictogram, title: exercise.title, subtitle: exercise.categories.formatted(.exerciseCategories))
}
