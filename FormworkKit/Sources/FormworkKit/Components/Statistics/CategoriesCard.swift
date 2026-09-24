//
//  CategoriesCard.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import SwiftUI

/// What was trained, as one bar of the categories and the leading ones as chips.
struct CategoriesCard: View {
    private let categories: Categories

    init(_ categories: Categories) {
        self.categories = categories
    }

    var body: some View {
        ChartCard(title: categories.title) {
            CategoriesBreakdown(categories: categories, rowLimit: 3)

            Spacer(minLength: 0)
        }
    }
}

/// The shares as one bar, then each as a chip.
struct CategoriesBreakdown: View {
    let categories: Categories

    var rowLimit: Int?

    var body: some View {
        VStack(alignment: .leading) {
            bar
                .frame(height: 16)

            FlowLayout(alignment: .leading, rowLimit: rowLimit) {
                ForEach(categories.shares) { share in
                    Label {
                        Text(share.category.title)

                        Text(share.fraction, format: .percent.precision(.fractionLength(0)))
                            .foregroundStyle(.secondary)
                    } icon: {
                        Image(systemName: share.category.pictogram.image)
                    }
                    .labelStyle(.chip(tint: share.category.pictogram.color))
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(legend)
        }
    }

    @ViewBuilder
    private var bar: some View {
        if categories.shares.isEmpty {
            Capsule()
                .fill(.quaternary)
        } else {
            GeometryReader { geometry in
                let spacing = 2.0
                let gaps = spacing * CGFloat(categories.shares.count - 1)
                // A layout pass can offer no width at all, and the gaps alone would then ask for a negative bar.
                let width = geometry.size.width.isFinite ? max(geometry.size.width - gaps, 0) : 0

                HStack(spacing: spacing) {
                    ForEach(categories.shares) { share in
                        Rectangle()
                            .fill(share.category.pictogram.color)
                            .frame(width: width * share.fraction)
                    }
                }
                .clipShape(.capsule)
            }
        }
    }

    /// Every share, including the ones the rows have no room for: the layout only puts those out of sight, so
    /// reading the whole legend as one label is what keeps a chip nobody can see from being announced on its own.
    private var legend: String {
        categories.shares
            .map { "\($0.category.title) \($0.fraction.formatted(.percent.precision(.fractionLength(0))))" }
            .joined(separator: ", ")
    }
}

private struct CategoriesPreview: View {
    let workout: Workout

    var body: some View {
        TileGrid {
            CategoriesCard(Categories(History(.workout(workout)).recent))
                .tileSpan(columns: 2)
        }
    }
}

#Preview {
    CategoriesPreview(workout: Samples.workouts[0])
        .padding()
        .sampleData()
}
