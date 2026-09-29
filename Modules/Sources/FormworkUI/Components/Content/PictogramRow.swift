//
//  PictogramRow.swift
//  FormworkUI
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import SwiftUI

public struct PictogramRow: View {
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
        HStack {
            PictogramView(pictogram, badge: badge)
                .frame(width: 64, height: 64)

            VStack(alignment: .leading) {
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

            Spacer(minLength: 0)
        }
        .contentShape(.rect)
    }
}

#Preview {
    let exercise = Samples.exercises.first!

    PictogramRow(exercise.pictogram, title: exercise.title, subtitle: exercise.categories.formatted(.exerciseCategories))
        .padding()
}
