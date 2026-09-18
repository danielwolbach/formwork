//
//  FixedLabelStyle.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 04.09.26.
//

import SwiftUI

public struct FixedLabelStyle: LabelStyle {
    @ScaledMetric private var iconSize: CGFloat = 20

    var showsTitle: Bool = true

    public func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 6) {
            icon(configuration)

            if showsTitle {
                configuration.title
            }
        }
    }

    private func icon(_ configuration: Configuration) -> some View {
        configuration.icon.frame(width: iconSize, height: iconSize)
    }
}

public extension LabelStyle where Self == FixedLabelStyle {
    static var fixedIconOnly: FixedLabelStyle {
        FixedLabelStyle(showsTitle: false)
    }

    static var fixedTitleAndIcon: FixedLabelStyle {
        FixedLabelStyle(showsTitle: true)
    }
}

#Preview("Fixed Label") {
    Label(ExerciseCategory.cardio.title, systemImage: ExerciseCategory.cardio.pictogram.image)
        .labelStyle(.fixedTitleAndIcon)
}
