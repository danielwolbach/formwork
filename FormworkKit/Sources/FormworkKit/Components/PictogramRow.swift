//
//  PictogramRow.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import SwiftUI

public struct PictogramRow: View {
    let pictogram: Pictogram
    let title: String
    let subtitle: String?
    let badge: Pictogram?

    public init(pictogram: Pictogram, title: String, subtitle: String? = nil, badge: Pictogram? = nil) {
        self.pictogram = pictogram
        self.title = title
        self.subtitle = subtitle
        self.badge = badge
    }

    public init(_ item: some Displayable, badge: Pictogram? = nil) {
        self.init(pictogram: item.pictogram, title: item.title, subtitle: item.subtitle, badge: badge)
    }

    public var body: some View {
        HStack {
            PictogramView(pictogram: pictogram, badge: badge)
                .frame(width: 64, height: 64)

            VStack(alignment: .leading) {
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

            Spacer()
        }
        .contentShape(.rect)
    }
}

#Preview {
    PictogramRow(pictogram: .unknown, title: "Title", subtitle: "Subtitle")
        .padding()
}
