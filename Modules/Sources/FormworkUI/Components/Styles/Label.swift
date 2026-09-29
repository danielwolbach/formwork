//
//  Label.swift
//  FormworkUI
//
//  Created by Daniel Wolbach on 18.09.26.
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

public struct ChipLabelStyle: LabelStyle {
    private var tint: Color = .accentColor

    @ScaledMetric
    private var iconSize: CGFloat = 20

    public init(tint: Color) {
        self.tint = tint
    }

    public func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 6) {
            icon(configuration)
            configuration.title
        }
        .font(.subheadline)
        .lineLimit(1)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .foregroundStyle(tint)
        .background {
            Capsule().fill(tint.quinary)
        }
        .contentShape(Capsule())
    }

    private func icon(_ configuration: Configuration) -> some View {
        configuration.icon.frame(width: iconSize, height: iconSize)
    }
}

extension LabelStyle where Self == ChipLabelStyle {
    public static func chip(tint: Color = .accentColor) -> ChipLabelStyle {
        ChipLabelStyle(tint: tint)
    }
}
