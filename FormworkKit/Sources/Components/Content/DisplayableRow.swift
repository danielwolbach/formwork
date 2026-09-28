//
//  DisplayableRow.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 04.09.26.
//

import SwiftUI

public struct DisplayableRow: View {
    private let pictogram: Pictogram

    private let title: String

    private let subtitle: String?

    private let badge: Pictogram?

    public init(_ item: some Displayable, badge: Pictogram? = nil) {
        self.pictogram = item.pictogram
        self.title = item.title
        self.subtitle = item.subtitle
        self.badge = badge
    }

    public init(pictogram: Pictogram, title: String, subtitle: String? = nil, badge: Pictogram? = nil) {
        self.pictogram = pictogram
        self.title = title
        self.subtitle = subtitle
        self.badge = badge
    }

    public var body: some View {
        HStack {
            PictogramView(pictogram)
                .frame(width: 64, height: 64)

            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .lineLimit(1)

                if let subtitle {
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
    DisplayableRow(Samples.exercises.first!)
        .padding()
}
