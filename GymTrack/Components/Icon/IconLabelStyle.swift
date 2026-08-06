//
//  IconLabelStyle.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 06.08.26.
//

import SwiftUI

struct IconLabelStyle: LabelStyle {
    var showsTitle: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            configuration.icon.frame(width: 20, height: 20)

            if showsTitle {
                configuration.title.fontWeight(.semibold)
            }
        }
    }
}

extension LabelStyle where Self == IconLabelStyle {
    static var fixedIconOnly: IconLabelStyle {
        IconLabelStyle(showsTitle: false)
    }

    static var fixedTitleAndIcon: IconLabelStyle {
        IconLabelStyle(showsTitle: true)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 16) {
        Label("Complete", systemImage: "checkmark")
            .labelStyle(.fixedTitleAndIcon)

        Label("Complete", systemImage: "checkmark")
            .labelStyle(.fixedIconOnly)
    }
    .padding()
}
