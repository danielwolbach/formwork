//
//  ChipLabelStyle.swift
//  FormworkUI
//
//  Created by Daniel Wolbach on 05.10.26.
//

import SwiftUI

public struct ChipLabelStyle: LabelStyle {
    private var tint: Color

    @ScaledMetric(relativeTo: .subheadline)
    private var iconSize: CGFloat = 20

    public init(tint: Color = .accentColor) {
        self.tint = tint
    }

    public func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 6) {
            configuration.icon.frame(width: iconSize, height: iconSize)
            configuration.title
        }
        .font(.subheadline)
        .lineLimit(1)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .foregroundStyle(tint)
        .background(tint.quinary, in: .capsule)
        .contentShape(.capsule)
    }
}

extension LabelStyle where Self == ChipLabelStyle {
    public static func chip(tint: Color = .accentColor) -> ChipLabelStyle {
        ChipLabelStyle(tint: tint)
    }
}
