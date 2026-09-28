//
//  CategoriesCard.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import FormworkKit
import SwiftUI

struct CategoriesCard: View {
    private let categories: Categories

    init(_ categories: Categories) {
        self.categories = categories
    }

    var body: some View {
        VStack(alignment: .leading) {
            Label(categories.title, systemImage: categories.pictogram.image)
                .font(.subheadline)
                .lineLimit(1)
                .foregroundStyle(.secondary)

            CategoriesBreakdown(categories, rowLimit: 3)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .card()
    }
}

struct CategoriesBreakdown: View {
    private let categories: Categories

    private let rowLimit: Int?

    init(_ categories: Categories, rowLimit: Int? = nil) {
        self.categories = categories
        self.rowLimit = rowLimit
    }

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

    private var legend: String {
        categories.shares
            .map { "\($0.category.title) \($0.fraction.formatted(.percent.precision(.fractionLength(0))))" }
            .joined(separator: ", ")
    }
}

#Preview {
    TileGrid(columns: 1) {
        CategoriesCard(Categories(History(.all(Samples.sessions)).recent))
    }
    .padding()
}
