//
//  FlowLayout.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 04.09.26.
//

import SwiftUI

public struct FlowLayout: Layout {
    /// Far enough out of the way that whatever clips the layout, as a card does, keeps the rows it has no
    /// room for out of sight.
    private static let hiddenOffset: CGFloat = 10000

    private let alignment: HorizontalAlignment
    private let spacing: CGFloat
    private let rowLimit: Int?

    /// `rowLimit` caps how many rows the layout takes, so that it can't grow past the room it was given.
    /// Whatever doesn't fit is put out of sight rather than dropped, since a layout has to place everything
    /// it is handed: it keeps its place for VoiceOver, so cut the content itself when that matters.
    public init(alignment: HorizontalAlignment = .center, spacing: CGFloat = 8, rowLimit: Int? = nil) {
        self.alignment = alignment
        self.spacing = spacing
        self.rowLimit = rowLimit
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
        let containerWidth = proposal.width ?? .infinity
        let rows = rows(for: subviews, containerWidth: containerWidth)
        let height = rows.reduce(0) { $0 + $1.height } + CGFloat(max(rows.count - 1, 0)) * spacing
        let width = rows.map(\.width).max() ?? 0
        return CGSize(width: containerWidth.isFinite ? containerWidth : width, height: height)
    }

    public func placeSubviews(in bounds: CGRect, proposal _: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
        let rows = rows(for: subviews, containerWidth: bounds.width)
        var y = bounds.minY

        for row in rows {
            var x: CGFloat = 0

            switch alignment {
            case .leading: x = bounds.minX
            case .trailing: x = bounds.maxX - row.width
            default: x = bounds.minX + (bounds.width - row.width) / 2
            }

            for element in row.elements {
                let width = element.size.width
                element.subview.place(at: CGPoint(x: x, y: y), anchor: .topLeading, proposal: .unspecified)
                x += width + spacing
            }

            y += row.height + spacing
        }

        // Everything past the last row it has room for. Rows fill in order, so these are the trailing ones.
        let shown = rows.reduce(0) { $0 + $1.elements.count }
        let hidden = CGPoint(x: bounds.minX, y: bounds.maxY + Self.hiddenOffset)

        for index in shown ..< subviews.count {
            subviews[index].place(at: hidden, anchor: .topLeading, proposal: .zero)
        }
    }

    private func rows(for subviews: Subviews, containerWidth: CGFloat) -> [Row] {
        var rows: [Row] = []
        var current: [(subview: LayoutSubview, size: CGSize)] = []
        var currentWidth: CGFloat = 0
        var currentHeight: CGFloat = 0

        func commitRow() {
            guard !current.isEmpty else {
                return
            }

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

        guard let rowLimit else {
            return rows
        }

        return Array(rows.prefix(max(rowLimit, 0)))
    }

    private struct Row {
        var elements: [(subview: LayoutSubview, size: CGSize)]
        var width: CGFloat
        var height: CGFloat
    }
}

private struct PreviewChip: View {
    let title: String

    var body: some View {
        Label(title, systemImage: "figure.run")
            .labelStyle(.chip())
    }
}

#Preview {
    let titles = ExerciseCategory.allCases.map(\.title)

    VStack(alignment: .leading, spacing: 32) {
        FlowLayout(alignment: .leading) {
            ForEach(titles, id: \.self) { title in
                PreviewChip(title: title)
            }
        }

        FlowLayout(alignment: .leading, rowLimit: 2) {
            ForEach(titles, id: \.self) { title in
                PreviewChip(title: title)
            }
        }
    }
    .padding()
}
