//
//  FixedLabelStyle.swift
//  FormworkUI
//
//  Created by Daniel Wolbach on 05.10.26.
//

import SwiftUI

public struct FixedLabelStyle: LabelStyle {
    private let showsTitle: Bool

    @ScaledMetric
    private var iconSize: CGFloat = 20

    public init(showsTitle: Bool = true) {
        self.showsTitle = showsTitle
    }

    public func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 6) {
            configuration.icon.frame(width: iconSize, height: iconSize)

            if showsTitle {
                configuration.title
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel { _ in configuration.title }
    }
}

extension LabelStyle where Self == FixedLabelStyle {
    public static var fixedIconOnly: FixedLabelStyle {
        FixedLabelStyle(showsTitle: false)
    }

    public static var fixedTitleAndIcon: FixedLabelStyle {
        FixedLabelStyle(showsTitle: true)
    }
}
