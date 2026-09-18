//
//  PictogramHeader.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import SwiftUI

struct PictogramHeader: View {
    let pictogram: Pictogram
    let title: String
    let subtitle: String?
    let badge: Pictogram?

    init(pictogram: Pictogram, title: String, subtitle: String? = nil, badge: Pictogram? = nil) {
        self.pictogram = pictogram
        self.title = title
        self.subtitle = subtitle
        self.badge = badge
    }

    init(_ item: some Displayable, badge: Pictogram? = nil) {
        self.init(pictogram: item.pictogram, title: item.title, subtitle: item.subtitle, badge: badge)
    }

    var body: some View {
        VStack(spacing: 16) {
            PictogramView(pictogram: pictogram, badge: badge)
                .frame(width: 192, height: 192)

            VStack {
                Text(title)
                    .font(.headline)

                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .contentShape(.rect)
    }
}

#Preview {
    PictogramHeader(pictogram: .unknown, title: "Title", subtitle: "Subtitle")
}
