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

    init(displayable: (some SubtitledDisplayable)?) {
        if let displayable {
            title = displayable.title
            subtitle = displayable.subtitle
            pictogram = displayable.pictogram
        } else {
            title = String(localized: .unknown)
            subtitle = nil
            pictogram = .unknown
        }
    }
    
    init(displayable: (some Displayable)?) {
        if let displayable {
            title = displayable.title
            subtitle = nil
            pictogram = displayable.pictogram
        } else {
            title = String(localized: .unknown)
            subtitle = nil
            pictogram = .unknown
        }
    }

    var body: some View {
        VStack(spacing: 32) {
            PictogramView(pictogram: pictogram, size: 192)

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
