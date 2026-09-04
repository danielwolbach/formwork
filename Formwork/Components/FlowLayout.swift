//
//  FlowLayout.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import SwiftUI

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    var alignment: HorizontalAlignment = .leading
    var expandElements: Bool = false

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let containerWidth = proposal.width ?? .infinity
        let rows = rows(for: subviews, containerWidth: containerWidth)
        let height = rows.reduce(0) { $0 + $1.height } + CGFloat(max(rows.count - 1, 0)) * spacing
        let width = rows.map(\.width).max() ?? 0
        return CGSize(width: containerWidth.isFinite ? containerWidth : width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = rows(for: subviews, containerWidth: bounds.width)
        var y = bounds.minY

        for row in rows {
            let extra = expandElements ? max(0, bounds.width - row.width) / CGFloat(row.elements.count) : 0
            let effectiveRowWidth = row.width + extra * CGFloat(row.elements.count)
            var x: CGFloat
            
            switch alignment {
            case .leading: x = bounds.minX
            case .trailing: x = bounds.maxX - effectiveRowWidth
            default: x = bounds.minX + (bounds.width - effectiveRowWidth) / 2
            }

            for element in row.elements {
                let width = element.size.width + extra
                let placementProposal = expandElements
                    ? ProposedViewSize(width: width, height: element.size.height)
                    : ProposedViewSize.unspecified
                element.subview.place(at: CGPoint(x: x, y: y), anchor: .topLeading, proposal: placementProposal)
                x += width + spacing
            }

            y += row.height + spacing
        }
    }

    private struct Row {
        var elements: [(subview: LayoutSubview, size: CGSize)]
        var width: CGFloat
        var height: CGFloat
    }

    private func rows(for subviews: Subviews, containerWidth: CGFloat) -> [Row] {
        var rows: [Row] = []
        var current: [(subview: LayoutSubview, size: CGSize)] = []
        var currentWidth: CGFloat = 0
        var currentHeight: CGFloat = 0

        func commitRow() {
            guard !current.isEmpty else { return }
            rows.append(Row(elements: current, width: currentWidth - spacing, height: currentHeight))
            current = []
            currentWidth = 0
            currentHeight = 0
        }

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentWidth + size.width > containerWidth, !current.isEmpty {
                commitRow()
            }

            current.append((subview, size))
            currentWidth += size.width + spacing
            currentHeight = max(currentHeight, size.height)
        }
        commitRow()

        return rows
    }
}
