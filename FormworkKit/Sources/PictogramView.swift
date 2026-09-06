//
//  PictogramView.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 04.09.26.
//

import SwiftUI

public struct PictogramView: View {
    private let pictogram: Pictogram
    private let badge: Pictogram?
    private let size: CGFloat
    private let cornerRadius: CGFloat

    public init(
        pictogram: Pictogram,
        size: CGFloat,
        cornerRadius: CGFloat? = nil,
        badge: Pictogram? = nil
    ) {
        self.pictogram = pictogram
        self.badge = badge
        self.size = size
        self.cornerRadius = cornerRadius ?? 2 * size.squareRoot()
    }

    private var badgeSize: CGFloat {
        size * 0.33
    }

    private var badgeOffset: CGFloat {
        badgeSize * 0.25
    }

    public var body: some View {
        Image(systemName: pictogram.icon)
            .font(.system(size: size * 0.33))
            .frame(width: size, height: size)
            .foregroundStyle(pictogram.color)
            .background(pictogram.color.quaternary)
            .clipShape(.rect(cornerRadius: cornerRadius, style: .continuous))
            .overlay(alignment: .bottomTrailing) {
                if let badge {
                    Image(systemName: badge.icon)
                        .font(.system(size: badgeSize))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.background, badge.color)
                        .offset(x: badgeOffset, y: badgeOffset)
                }
            }
            .frame(width: size, height: size)
    }
}

#Preview {
    HStack(spacing: 32) {
        PictogramView(
            pictogram: Pictogram(icon: "dumbbell", tint: .indigo),
            size: 96,
            badge: Pictogram(icon: "checkmark.circle.fill", tint: .green)
        )

        PictogramView(
            pictogram: Pictogram(icon: "figure.run", tint: .red),
            size: 96,
            badge: Pictogram(icon: "forward.end.circle.fill", tint: .orange)
        )

        PictogramView(pictogram: Pictogram(icon: "timer", tint: .orange), size: 96)
    }
    .padding()
}
