//
//  FlowLayout.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import SwiftUI

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    var alignment: HorizontalAlignment = .leading

    struct Row {
        var indices: Range<Int>
        var sizes: [CGSize]
        var width: CGFloat
        var height: CGFloat
    }

    struct Cache {
        var containerWidth: CGFloat = .nan
        var rows: [Row] = []
    }

    func makeCache(subviews _: Subviews) -> Cache {
        Cache()
    }

    func updateCache(_ cache: inout Cache, subviews _: Subviews) {
        cache = Cache()
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
        let containerWidth = proposal.width ?? .infinity
        let rows = rows(for: subviews, containerWidth: containerWidth, cache: &cache)
        let height = rows.reduce(0) { $0 + $1.height } + CGFloat(max(rows.count - 1, 0)) * spacing
        let width = rows.map(\.width).max() ?? 0

        return CGSize(width: containerWidth.isFinite ? containerWidth : width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal _: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
        let rows = rows(for: subviews, containerWidth: bounds.width, cache: &cache)
        var y = bounds.minY

        for row in rows {
            var x = switch alignment {
            case .leading: bounds.minX
            case .trailing: bounds.maxX - row.width
            default: bounds.minX + (bounds.width - row.width) / 2
            }

            for (position, index) in row.indices.enumerated() {
                subviews[index].place(at: CGPoint(x: x, y: y), anchor: .topLeading, proposal: .unspecified)
                x += row.sizes[position].width + spacing
            }

            y += row.height + spacing
        }
    }

    private func rows(for subviews: Subviews, containerWidth: CGFloat, cache: inout Cache) -> [Row] {
        guard cache.containerWidth != containerWidth else {
            return cache.rows
        }

        var rows: [Row] = []
        var sizes: [CGSize] = []
        var start = subviews.startIndex
        var width: CGFloat = 0
        var height: CGFloat = 0

        func commitRow(endingAt end: Int) {
            guard !sizes.isEmpty else {
                return
            }

            rows.append(Row(indices: start ..< end, sizes: sizes, width: width - spacing, height: height))
            start = end
            sizes = []
            width = 0
            height = 0
        }

        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)

            if width + size.width > containerWidth, !sizes.isEmpty {
                commitRow(endingAt: index)
            }

            sizes.append(size)
            width += size.width + spacing
            height = max(height, size.height)
        }

        commitRow(endingAt: subviews.endIndex)

        cache.containerWidth = containerWidth
        cache.rows = rows

        return rows
    }
}

#Preview {
    FlowLayout(spacing: 8, alignment: .center) {
        ForEach(ExerciseCategory.allCases) { category in
            Text(category.title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .foregroundStyle(category.pictogram.color)
                .background(Capsule().fill(category.pictogram.color.quinary))
        }
    }
    .padding()
}
