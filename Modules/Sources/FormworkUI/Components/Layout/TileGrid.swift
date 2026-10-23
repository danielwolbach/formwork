//
//  TileGrid.swift
//  FormworkUI
//
//  Created by Daniel Wolbach on 21.09.26.
//

import SwiftUI

public struct TileGrid: Layout {
    fileprivate struct Span: Equatable {
        let rows: Int

        let columns: Int

        init(rows: Int, columns: Int) {
            self.rows = max(1, rows)
            self.columns = max(1, columns)
        }

        func clamped(toColumns limit: Int) -> Span {
            Span(rows: rows, columns: min(columns, limit))
        }

        /// Wide tiles take half the row or all of it, so they never leave a gap that only narrower tiles could fill.
        func expanded(toColumns limit: Int) -> Span {
            guard columns > 1 else {
                return self
            }

            let half = limit >= 4 && limit.isMultiple(of: 2) ? limit / 2 : limit
            return Span(rows: rows, columns: columns <= half ? half : min(columns, limit))
        }
    }

    fileprivate struct SpanKey: LayoutValueKey {
        static let defaultValue = Span(rows: 1, columns: 1)
    }

    private enum ColumnMode {
        case fixed(Int)
        case adaptive(minimumWidth: CGFloat)
    }

    private struct Slot {
        let row: Int

        let column: Int

        let span: Span
    }

    private let columnMode: ColumnMode

    private let spacing: CGFloat

    private let aspectRatio: CGFloat

    public init(minimumWidth: CGFloat = 160, spacing: CGFloat = .items, aspectRatio: CGFloat = 1.7) {
        self.columnMode = .adaptive(minimumWidth: minimumWidth)
        self.spacing = spacing
        self.aspectRatio = aspectRatio
    }

    public init(columns: Int, spacing: CGFloat = .items, aspectRatio: CGFloat = 1.7) {
        self.columnMode = .fixed(max(1, columns))
        self.spacing = spacing
        self.aspectRatio = aspectRatio
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
        let width = proposal.replacingUnspecifiedDimensions().width
        let columns = columnCount(forWidth: width)
        let cell = cellSize(forWidth: width, columns: columns)
        let grid = grid(columns: columns, cell: cell, subviews: subviews)
        return CGSize(width: width, height: grid.rows > 0 ? length(ofCells: grid.rows, cell: cell.height) : 0)
    }

    public func placeSubviews(in bounds: CGRect, proposal _: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
        let columns = columnCount(forWidth: bounds.width)
        let cell = cellSize(forWidth: bounds.width, columns: columns)

        for (subview, slot) in zip(subviews, grid(columns: columns, cell: cell, subviews: subviews).slots) {
            let origin = CGPoint(
                x: bounds.minX + CGFloat(slot.column) * (cell.width + spacing),
                y: bounds.minY + CGFloat(slot.row) * (cell.height + spacing)
            )
            let size = CGSize(
                width: length(ofCells: slot.span.columns, cell: cell.width),
                height: length(ofCells: slot.span.rows, cell: cell.height)
            )
            subview.place(at: origin, anchor: .topLeading, proposal: ProposedViewSize(size))
        }
    }

    private func grid(columns: Int, cell: CGSize, subviews: Subviews) -> (slots: [Slot], rows: Int) {
        var occupancy: [[Bool]] = []
        var slots: [Slot] = []

        for subview in subviews {
            let span = switch columnMode {
            case .fixed: subview[SpanKey.self].clamped(toColumns: columns)
            case .adaptive: subview[SpanKey.self].expanded(toColumns: columns)
            }
            let tileWidth = length(ofCells: span.columns, cell: cell.width)
            let tileHeight = length(ofCells: span.rows, cell: cell.height)
            let needed = subview.sizeThatFits(ProposedViewSize(width: tileWidth, height: tileHeight)).height
            let rows = max(span.rows, rows(forHeight: needed, cell: cell.height))

            slots.append(pack(Span(rows: rows, columns: span.columns), columns: columns, into: &occupancy))
        }

        return (slots, occupancy.count)
    }

    private func rows(forHeight height: CGFloat, cell: CGFloat) -> Int {
        guard height > 0, cell > 0 else {
            return 1
        }

        return max(1, Int(((height + spacing) / (cell + spacing) - 0.001).rounded(.up)))
    }

    private func pack(_ span: Span, columns: Int, into occupancy: inout [[Bool]]) -> Slot {
        let slot = firstFit(for: span, columns: columns, in: occupancy)

        while occupancy.count < slot.row + span.rows {
            occupancy.append(Array(repeating: false, count: columns))
        }

        occupy(row: slot.row, column: slot.column, span: span, in: &occupancy)
        return slot
    }

    private func firstFit(for span: Span, columns: Int, in occupancy: [[Bool]]) -> Slot {
        for row in 0 ..< occupancy.count {
            for column in 0 ... (columns - span.columns) where isFree(row: row, column: column, span: span, in: occupancy) {
                return Slot(row: row, column: column, span: span)
            }
        }

        return Slot(row: occupancy.count, column: 0, span: span)
    }

    private func isFree(row: Int, column: Int, span: Span, in occupancy: [[Bool]]) -> Bool {
        (row ..< row + span.rows).allSatisfy { row in
            row >= occupancy.count || !occupancy[row][column ..< column + span.columns].contains(true)
        }
    }

    private func occupy(row: Int, column: Int, span: Span, in occupancy: inout [[Bool]]) {
        for index in row ..< row + span.rows {
            occupancy[index].replaceSubrange(column ..< column + span.columns, with: repeatElement(true, count: span.columns))
        }
    }

    private func columnCount(forWidth width: CGFloat) -> Int {
        switch columnMode {
        case let .fixed(count): count
        case let .adaptive(minimumWidth): width.isFinite ? max(1, Int((width + spacing) / (minimumWidth + spacing))) : 1
        }
    }

    private func cellSize(forWidth width: CGFloat, columns: Int) -> CGSize {
        let cellWidth = (width - spacing * CGFloat(columns - 1)) / CGFloat(columns)
        return CGSize(width: cellWidth, height: cellWidth / aspectRatio)
    }

    private func length(ofCells count: Int, cell: CGFloat) -> CGFloat {
        CGFloat(count) * cell + CGFloat(count - 1) * spacing
    }
}

extension View {
    public func tileSpan(rows: Int = 1, columns: Int = 1) -> some View {
        layoutValue(key: TileGrid.SpanKey.self, value: TileGrid.Span(rows: rows, columns: columns))
    }
}
