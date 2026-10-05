//
//  FixedLabelStyle.swift
//  FormworkModules
//
//  Created by Daniel Wolbach on 05.10.26.
//

import SwiftUI

public struct FixedLabelStyle: LabelStyle {
    public var showsTitle: Bool = true

    @ScaledMetric
    private var iconSize: CGFloat = 20

    public init(showsTitle: Bool) {
        self.showsTitle = showsTitle
    }

    public func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 6) {
            icon(configuration)

            if showsTitle {
                configuration.title
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel { _ in configuration.title }
    }

    private func icon(_ configuration: Configuration) -> some View {
        configuration.icon.frame(width: iconSize, height: iconSize)
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
