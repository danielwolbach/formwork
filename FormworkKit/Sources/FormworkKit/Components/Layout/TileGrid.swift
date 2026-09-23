//
//  TileGrid.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 21.09.26.
//

import SwiftUI

public struct TileGrid: Layout {
    /// How many cells a tile covers, counted as rows by columns.
    struct Span: Equatable {
        let rows: Int

        let columns: Int

        init(rows: Int, columns: Int) {
            self.rows = max(1, rows)
            self.columns = max(1, columns)
        }

        /// Keeps a tile inside the grid, so a two column tile still shows up in a single column layout.
        func clamped(toColumns limit: Int) -> Span {
            Span(rows: rows, columns: min(columns, limit))
        }
    }

    /// A tile's span together with the slot it was packed into.
    struct Slot {
        let row: Int

        let column: Int

        let span: Span
    }

    struct SpanKey: LayoutValueKey {
        static let defaultValue = Span(rows: 1, columns: 1)
    }

    private let columns: Int

    private let spacing: CGFloat

    private let aspectRatio: CGFloat

    public init(columns: Int = 2, spacing: CGFloat = 8, aspectRatio: CGFloat = 1.7) {
        self.columns = max(1, columns)
        self.spacing = spacing
        self.aspectRatio = aspectRatio
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
        let width = proposal.replacingUnspecifiedDimensions().width
        let cell = cellSize(forWidth: width)
        let grid = grid(forWidth: width, subviews: subviews)
        return CGSize(width: width, height: grid.rows > 0 ? length(ofCells: grid.rows, cell: cell.height) : 0)
    }

    public func placeSubviews(in bounds: CGRect, proposal _: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
        let cell = cellSize(forWidth: bounds.width)

        for (subview, slot) in zip(subviews, grid(forWidth: bounds.width, subviews: subviews).slots) {
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

    /// Packs every tile into the grid. Each one is offered the room its span asks for, and only a tile that
    /// answers with more than that takes further rows: a cell is always `aspectRatio`, so a tile that can't
    /// be made to fit grows into the grid rather than stretching every other tile with it. Anything that can
    /// make do with the room it was offered, like a chart, stays the size it was asked to be.
    private func grid(forWidth width: CGFloat, subviews: Subviews) -> (slots: [Slot], rows: Int) {
        let cell = cellSize(forWidth: width)
        var occupancy: [[Bool]] = []
        var slots: [Slot] = []

        for subview in subviews {
            let span = subview[SpanKey.self].clamped(toColumns: columns)
            let tileWidth = length(ofCells: span.columns, cell: cell.width)
            let tileHeight = length(ofCells: span.rows, cell: cell.height)
            let needed = subview.sizeThatFits(ProposedViewSize(width: tileWidth, height: tileHeight)).height
            let rows = max(span.rows, rows(forHeight: needed, cell: cell.height))

            slots.append(pack(Span(rows: rows, columns: span.columns), into: &occupancy))
        }

        return (slots, occupancy.count)
    }

    /// How many whole cells a tile of that height covers. The hair of tolerance keeps a tile that fits
    /// exactly from rounding up into a row it doesn't need.
    private func rows(forHeight height: CGFloat, cell: CGFloat) -> Int {
        guard height > 0, cell > 0 else {
            return 1
        }

        return max(1, Int(((height + spacing) / (cell + spacing) - 0.001).rounded(.up)))
    }

    /// Takes the first slot the tile fits into and grows the grid by as many rows as that takes.
    private func pack(_ span: Span, into occupancy: inout [[Bool]]) -> Slot {
        let slot = firstFit(for: span, in: occupancy)

        while occupancy.count < slot.row + span.rows {
            occupancy.append(Array(repeating: false, count: columns))
        }

        occupy(row: slot.row, column: slot.column, span: span, in: &occupancy)
        return slot
    }

    /// Walks the grid top to bottom and left to right, looking for room. A tile always fits below everything
    /// placed so far, so the search never has to look past the rows already in use.
    private func firstFit(for span: Span, in occupancy: [[Bool]]) -> Slot {
        for row in 0 ..< occupancy.count {
            for column in 0 ... (columns - span.columns) where isFree(row: row, column: column, span: span, in: occupancy) {
                return Slot(row: row, column: column, span: span)
            }
        }

        return Slot(row: occupancy.count, column: 0, span: span)
    }

    /// Rows below the grid count as free, so a tile may hang off the bottom and pull the missing rows in with it.
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

    /// Cells are as wide as the columns allow and as tall as `aspectRatio` asks for, whatever the tiles hold.
    private func cellSize(forWidth width: CGFloat) -> CGSize {
        let cellWidth = (width - spacing * CGFloat(columns - 1)) / CGFloat(columns)
        return CGSize(width: cellWidth, height: cellWidth / aspectRatio)
    }

    private func length(ofCells count: Int, cell: CGFloat) -> CGFloat {
        CGFloat(count) * cell + CGFloat(count - 1) * spacing
    }
}

extension View {
    /// The number of cells this tile covers inside a `TileGrid`. Has no effect anywhere else.
    public func tileSpan(rows: Int = 1, columns: Int = 1) -> some View {
        layoutValue(key: TileGrid.SpanKey.self, value: TileGrid.Span(rows: rows, columns: columns))
    }
}

private struct PreviewTile: View {
    let label: String

    let pictogram: Pictogram

    var body: some View {
        Text(verbatim: label)
            .font(.system(.headline, design: .rounded))
            .foregroundStyle(pictogram.color)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(pictogram.color.quinary)
            .clipShape(.rect(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    ScrollView {
        TileGrid(columns: 2) {
            PreviewTile(label: "1 × 1", pictogram: .streak)
            PreviewTile(label: "1 × 1", pictogram: .duration)
            PreviewTile(label: "1 × 1", pictogram: .tally)

            PreviewTile(label: "1 × 2", pictogram: .record)
                .tileSpan(columns: 2)

            PreviewTile(label: "1 × 1", pictogram: .volume)

            PreviewTile(label: "2 × 1", pictogram: .date)
                .tileSpan(rows: 2)

            PreviewTile(label: "1 × 1", pictogram: .time)
            PreviewTile(label: "1 × 1", pictogram: .workout)

            PreviewTile(label: "2 × 2", pictogram: .streak)
                .tileSpan(rows: 2, columns: 2)

            PreviewTile(label: "A tile that holds more than a single row of cells can take", pictogram: .categories)
                .tileSpan(columns: 2)
        }
        .padding()
    }
}
