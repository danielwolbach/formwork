//
//  MetricCard.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct MetricCard: View {
    private let pictogram: Pictogram

    private let title: String

    private let value: String?

    private let direction: Direction?

    init(pictogram: Pictogram, title: String, value: String?, direction: Direction? = nil) {
        self.pictogram = pictogram
        self.title = title
        self.value = value
        self.direction = direction
    }

    init(_ statistic: some Statistic, direction: Direction? = nil) {
        self.init(pictogram: statistic.pictogram, title: statistic.title, value: statistic.formattedValue, direction: direction)
    }

    init(_ trend: Trend<some Metric>) {
        self.init(trend.recent, direction: trend.direction)
    }

    init(_ figure: SessionSummary.Figure<some Any>) {
        self.init(pictogram: figure.pictogram, title: figure.title, value: figure.formattedValue)
    }

    var body: some View {
        VStack(alignment: .leading) {
            Spacer(minLength: 0)

            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(2)
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
                    .accessibilityHidden(true)
            }
        }
        .card(pictogram.tint.color.quinary)
    }
}

#Preview {
    MetricCard(StarterCatalog.Samples.weekStreak)
        .padding()
}
