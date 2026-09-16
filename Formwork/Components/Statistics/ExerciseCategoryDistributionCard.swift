//
//  ExerciseCategoryDistributionCard.swift
//  Formwork
//
//  Created by Daniel Wolbach on 10.09.26.
//

import FormworkKit
import SwiftUI

struct ExerciseCategoryDistributionCard: View {
    let title: LocalizedStringResource
    let shares: [(category: ExerciseCategory, share: Double)]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .lineLimit(1)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if shares.isEmpty {
                Text(verbatim: "—")
                    .font(.title)
            } else {
                bar

                legend
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial)
        .cardSurface()
    }

    private var bar: some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                ForEach(shares.indices, id: \.self) { index in
                    shares[index].category.pictogram.color
                        .frame(width: proxy.size.width * shares[index].share)
                }
            }
        }
        .frame(height: 24)
        .clipShape(.capsule)
    }

    private var legend: some View {
        FlowLayout {
            ForEach(shares.indices, id: \.self) { index in
                PictogramChip(
                    displayable: shares[index].category,
                    detail: shares[index].share.formatted(.percent.precision(.fractionLength(0)))
                )
            }
        }
    }
}

private struct CategoryDistributionCardGallery: View {
    var body: some View {
        ScreenStack {
            ExerciseCategoryDistributionCard(
                title: .statisticDistributionTitle,
                shares: ExerciseCategory.shares(of: [
                    [.chest],
                    [.chest, .arms],
                    [.arms],
                    [.core],
                    [.legs, .cardio],
                ])
            )

            ExerciseCategoryDistributionCard(
                title: .statisticCompletedDistributionTitle,
                shares: ExerciseCategory.shares(of: [[.mindfulness]])
            )

            ExerciseCategoryDistributionCard(
                title: .statisticDistributionTitle,
                shares: ExerciseCategory.shares(of: ExerciseCategory.allCases.map { [$0] })
            )

            ExerciseCategoryDistributionCard(
                title: .statisticDistributionTitle,
                shares: []
            )
        }
    }
}

#Preview {
    CategoryDistributionCardGallery()
}
