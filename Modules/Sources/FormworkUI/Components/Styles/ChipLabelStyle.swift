//
//  ChipLabelStyle.swift
//  FormworkModules
//
//  Created by Daniel Wolbach on 05.10.26.
//

import SwiftUI

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
