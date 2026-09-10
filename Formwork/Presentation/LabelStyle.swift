//
//  LabelStyle.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import SwiftUI

struct FixedLabelStyle: LabelStyle {
    var showsTitle: Bool = true

    @ScaledMetric private var iconSize: CGFloat = 20

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            configuration.icon
                .frame(width: iconSize, height: iconSize)

            if showsTitle {
                configuration.title
                    .fontWeight(.semibold)
            }
        }
    }
}

extension LabelStyle where Self == FixedLabelStyle {
    static var fixedIconOnly: FixedLabelStyle {
        FixedLabelStyle(showsTitle: false)
    }

    static var fixedTitleAndIcon: FixedLabelStyle {
        FixedLabelStyle(showsTitle: true)
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
