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
    let distribution: [ExerciseCategory: Double]

    private var categories: [ExerciseCategory] {
        ExerciseCategory.allCases
            .filter { distribution[$0] != nil }
            .sorted { lhs, rhs in
                let left = distribution[lhs] ?? 0
                let right = distribution[rhs] ?? 0

                return left == right
                    ? (ExerciseCategory.allCases.firstIndex(of: lhs) ?? .max)
                    < (ExerciseCategory.allCases.firstIndex(of : rhs) ?? .max):
                    left > right
            }
    }

    var body: some View {
        let categories = categories

        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .lineLimit(1)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if categories.isEmpty {
                Text(verbatim: "—")
                    .font(.title)
            } else {
                bar(of: categories)

                legend(of: categories)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial)
        .cardSurface()
    }

    private func bar(of categories: [ExerciseCategory]) -> some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                ForEach(categories) { category in
                    category.pictogram.color
                        .frame(width: proxy.size.width * (distribution[category] ?? 0))
                }
            }
        }
        .frame(height: 24)
        .clipShape(.capsule)
    }

    private func legend(of categories: [ExerciseCategory]) -> some View {
        FlowLayout {
            ForEach(categories) { category in
                PictogramChip(
                    displayable: category,
                    detail: (distribution[category] ?? 0).formatted(.percent.precision(.fractionLength(0)))
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
                distribution: Statistics.distribution(of: [
                    [.chest],
                    [.chest, .arms],
                    [.arms],
                    [.core],
                    [.legs, .cardio],
                ])
            )

            ExerciseCategoryDistributionCard(
                title: .statisticCompletedDistributionTitle,
                distribution: Statistics.distribution(of: [[.mindfulness]])
            )

            ExerciseCategoryDistributionCard(
                title: .statisticDistributionTitle,
                distribution: Statistics.distribution(of: ExerciseCategory.allCases.map { [$0] })
            )

            ExerciseCategoryDistributionCard(
                title: .statisticDistributionTitle,
                distribution: [:]
            )
        }
    }
}

#Preview {
    CategoryDistributionCardGallery()
}
