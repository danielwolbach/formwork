//
//  DisplayableHeader.swift
//  FormworkUI
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import SwiftUI

public struct DisplayableHeader: View {
    private let pictogram: Pictogram

    private let title: String

    private let subtitle: String?

    private let badge: Pictogram?

    public init(_ displayable: some Displayable) {
        self.pictogram = displayable.pictogram
        self.title = displayable.title
        self.subtitle = displayable.subtitle
        self.badge = nil
    }

    public init(pictogram: Pictogram, title: String, subtitle: String? = nil, badge: Pictogram? = nil) {
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
                    .lineLimit(1)
                    .font(.headline)

                if let subtitle {
                    Text(subtitle)
                        .lineLimit(1)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview {
    DisplayableHeader(Samples.exercises.first!)
}
