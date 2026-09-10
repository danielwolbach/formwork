//
//  LabelStyle.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import SwiftUI

struct FixedLabelStyle: LabelStyle {
    enum IconPlacement {
        case leading
        case trailing
    }

    var showsTitle: Bool = true

    var iconPlacement: IconPlacement = .leading

    @ScaledMetric private var iconSize: CGFloat = 20

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            if iconPlacement == .leading {
                icon(configuration)
            }

            if showsTitle {
                configuration.title
                    .fontWeight(.semibold)
            }

            if iconPlacement == .trailing {
                icon(configuration)
            }
        }
    }

    private func icon(_ configuration: Configuration) -> some View {
        configuration.icon
            .frame(width: iconSize, height: iconSize)
    }
}

extension LabelStyle where Self == FixedLabelStyle {
    static var fixedIconOnly: FixedLabelStyle {
        FixedLabelStyle(showsTitle: false)
    }

    static var fixedTitleAndIcon: FixedLabelStyle {
        FixedLabelStyle(showsTitle: true)
    }

    static var fixedTitleAndTrailingIcon: FixedLabelStyle {
        FixedLabelStyle(showsTitle: true, iconPlacement: .trailing)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 16) {
        Label("Complete", systemImage: "checkmark")
            .labelStyle(.fixedTitleAndIcon)

        Label("Complete", systemImage: "checkmark")
            .labelStyle(.fixedIconOnly)

        Label("Complete", systemImage: "chevron.right")
            .labelStyle(.fixedTitleAndTrailingIcon)
    }
    .padding()
}
