//
//  MetricCard.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 22.09.26.
//

import SwiftUI

public struct MetricCard<Value>: View {
    private let metric: Metric<Value>

    public init(_ metric: Metric<Value>) {
        self.metric = metric
    }

    public var body: some View {
        VStack(alignment: .leading) {
            Spacer(minLength: 0)

            Text(metric.title)
                .font(.subheadline)
                .lineLimit(1)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(verbatim: metric.subtitle ?? "—")
                .font(.system(.title3, design: .rounded, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .padding()
        .background {
            GeometryReader { geometry in
                let side = min(geometry.size.height, geometry.size.width)

                Image(systemName: metric.pictogram.image)
                    .font(.system(size: side))
                    .foregroundStyle(metric.pictogram.color.secondary)
                    .offset(x: side * 0.25, y: -side * (1.0 / 3.0))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
        }
        .background(metric.pictogram.tint.color.quinary)
        .clipShape(.rect(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    TileGrid {
        MetricCard(Samples.weekStreak)
        MetricCard(Samples.sessionsPerWeek)
        MetricCard(Samples.personalBest)
        MetricCard(Samples.totalVolume)
    }
    .padding()
}
