//
//  DisplayableRow.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import SwiftUI

struct DisplayableRow: View {
    private let title: String
    private let subtitle: String?
    private let pictogram: Pictogram

    init(displayable: some SubtitledDisplayable) {
        title = displayable.title
        subtitle = displayable.subtitle
        pictogram = displayable.pictogram
    }

    init(displayable: some Displayable) {
        title = displayable.title
        subtitle = nil
        pictogram = displayable.pictogram
    }

    var body: some View {
        HStack {
            PictogramView(pictogram: pictogram, size: 64)

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
