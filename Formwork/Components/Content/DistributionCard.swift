//
//  DistributionCard.swift
//  Formwork
//
//  Created by Daniel Wolbach on 10.09.26.
//

import FormworkKit
import SwiftUI

struct DistributionCard: View {
    let title: LocalizedStringResource
    let distribution: CategoryDistribution

    var body: some View {
        let shares = distribution.shares

        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .lineLimit(1)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if shares.isEmpty {
                Text(verbatim: "—")
                    .font(.title)
            } else {
                bar(of: shares)

                legend(of: shares)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial)
        .cardSurface()
    }

    private func bar(of shares: [CategoryDistribution.Share]) -> some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                ForEach(shares) { share in
                    share.category.pictogram.color
                        .frame(width: proxy.size.width * share.value)
                }
            }
        }
        .frame(height: 24)
        .clipShape(.capsule)
    }

    private func legend(of shares: [CategoryDistribution.Share]) -> some View {
        FlowLayout {
            ForEach(shares) { share in
                PictogramChip(
                    displayable: share.category,
                    detail: share.value.formatted(.percent.precision(.fractionLength(0)))
                )
            }
        }
    }
}

private struct DistributionCardGallery: View {
    var body: some View {
        ScreenStack {
            DistributionCard(
                title: .statisticDistributionTitle,
                distribution: CategoryDistribution(categories: [
                    [.chest],
                    [.chest, .arms],
                    [.arms],
                    [.core],
                    [.legs, .cardio],
                ])
            )

            DistributionCard(
                title: .statisticCompletedDistributionTitle,
                distribution: CategoryDistribution(categories: [[.mindfulness]])
            )

            DistributionCard(
                title: .statisticDistributionTitle,
                distribution: CategoryDistribution(categories: ExerciseCategory.allCases.map { [$0] })
            )

            DistributionCard(
                title: .statisticDistributionTitle,
                distribution: CategoryDistribution()
            )
        }
    }
}

#Preview {
    DistributionCardGallery()
}
