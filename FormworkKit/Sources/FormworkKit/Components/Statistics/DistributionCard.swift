//
//  DistributionCard.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 22.09.26.
//

import SwiftUI

public struct DistributionCard<Value: Displayable & CaseIterable & Hashable>: View {
    private let distribution: Distribution<Value>

    public init(_ distribution: Distribution<Value>) {
        self.distribution = distribution
    }

    public var body: some View {
        VStack {
            Text(distribution.title)
                .font(.subheadline)
                .lineLimit(1)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            bar.frame(height: 16)

            FlowLayout(alignment: .leading, rowLimit: 3) {
                ForEach(distribution.shares) { share in
                    Label {
                        Text(share.value.title)

                        Text(share.fraction, format: .percent.precision(.fractionLength(0)))
                            .foregroundStyle(.secondary)
                    } icon: {
                        Image(systemName: share.value.pictogram.image)
                    }
                    .labelStyle(.chip(tint: share.value.pictogram.color))
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(legend)

            Spacer(minLength: 0)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 16, style: .continuous))
    }

    @ViewBuilder
    private var bar: some View {
        if distribution.shares.isEmpty {
            Capsule().fill(.quaternary)
        } else {
            GeometryReader { geometry in
                let spacing = 2.0
                let gaps = spacing * CGFloat(distribution.shares.count - 1)
                // A layout pass can offer no width at all, and the gaps alone would then ask for a negative bar.
                let width = geometry.size.width.isFinite ? max(geometry.size.width - gaps, 0) : 0

                HStack(spacing: spacing) {
                    ForEach(distribution.shares) { share in
                        Rectangle()
                            .fill(share.value.pictogram.color)
                            .frame(width: width * share.fraction)
                    }
                }
                .clipShape(.capsule)
            }
        }
    }

    /// Every share, including the ones the rows have no room for: the layout only puts those out of sight,
    /// so reading the whole legend as one label is what keeps a chip nobody can see from being announced
    /// on its own.
    private var legend: String {
        distribution.shares
            .map { "\($0.value.title) \($0.fraction.formatted(.percent.precision(.fractionLength(0))))" }
            .joined(separator: ", ")
    }
}

private struct DistributionPreview: View {
    let workout: Workout

    var body: some View {
        TileGrid {
            DistributionCard(workout.statistics().categories)
                .tileSpan(rows: 2, columns: 2)
        }
    }
}

#Preview {
    DistributionPreview(workout: Samples.workouts[0])
        .padding()
        .sampleData()
}
