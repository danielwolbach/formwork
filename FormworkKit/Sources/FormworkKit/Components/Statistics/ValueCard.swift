//
//  ValueCard.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import SwiftUI

/// A single value: title over value, the pictogram large in the corner. A trend adds its arrow after the value.
public struct ValueCard: View {
    private let pictogram: Pictogram

    private let title: String

    private let value: String?

    private let direction: Direction?

    init(_ item: some Displayable, direction: Direction?) {
        self.pictogram = item.pictogram
        self.title = item.title
        self.value = item.subtitle
        self.direction = direction
    }

    public var body: some View {
        VStack(alignment: .leading) {
            Spacer(minLength: 0)

            Text(title)
                .font(.subheadline)
                .lineLimit(1)
                .foregroundStyle(.secondary)

            HStack(spacing: 4) {
                Text(verbatim: value ?? "—")
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)

                if let direction, direction != .flat {
                    Image(systemName: direction.image)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background {
            GeometryReader { geometry in
                let side = min(geometry.size.height, geometry.size.width)

                Image(systemName: pictogram.image)
                    .font(.system(size: side))
                    .foregroundStyle(pictogram.color.secondary)
                    .offset(x: side * 0.25, y: -side * (1.0 / 3.0))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
        }
        .background(pictogram.tint.color.quinary)
        .clipShape(.rect(cornerRadius: 16, style: .continuous))
    }
}

extension ValueCard {
    public init(_ item: some Displayable) {
        self.init(item, direction: nil)
    }

    /// The recent value with the arrow of where it went.
    init(_ trend: Trend<some Metric>) {
        self.init(trend.recent, direction: trend.direction)
    }
}

#Preview {
    TileGrid {
        ValueCard(Samples.weekStreak)
        ValueCard(Samples.weeklySessions, direction: .up)
        ValueCard(Samples.personalBest)
        ValueCard(Samples.totalVolume)
    }
    .padding()
}
