//
//  TileGrid.swift
//  Formwork
//
//  Created by Daniel Wolbach on 09.09.26.
//

import FormworkKit
import SwiftUI

struct TileGrid: Layout {
    var columns: Int = 2
    var spacing: CGFloat = 8

    struct Cell: Hashable {
        var row: Int
        var column: Int
    }

    struct Placement {
        var index: Int
        var cell: Cell
        var span: TileSpan
    }

    struct Cache {
        var containerWidth: CGFloat = .nan
        var placements: [Placement] = []
        var rowHeights: [CGFloat] = []
    }

    func makeCache(subviews _: Subviews) -> Cache {
        Cache()
    }

    func updateCache(_ cache: inout Cache, subviews _: Subviews) {
        cache = Cache()
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
        let containerWidth = proposal.replacingUnspecifiedDimensions().width

        resolve(subviews: subviews, containerWidth: containerWidth, cache: &cache)

        return CGSize(width: containerWidth, height: height(of: cache.rowHeights.indices, in: cache.rowHeights))
    }

    func placeSubviews(in bounds: CGRect, proposal _: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
        resolve(subviews: subviews, containerWidth: bounds.width, cache: &cache)

        let cellWidth = cellWidth(in: bounds.width)

        for placement in cache.placements {
            let origin = CGPoint(
                x: bounds.minX + CGFloat(placement.cell.column) * (cellWidth + spacing),
                y: bounds.minY + offset(ofRow: placement.cell.row, in: cache.rowHeights)
            )

            subviews[placement.index].place(
                at: origin,
                anchor: .topLeading,
                proposal: ProposedViewSize(size(of: placement, cellWidth: cellWidth, rowHeights: cache.rowHeights))
            )
        }
    }

    private func resolve(subviews: Subviews, containerWidth: CGFloat, cache: inout Cache) {
        guard cache.containerWidth != containerWidth else {
            return
        }

        let columns = max(columns, 1)
        let cellWidth = cellWidth(in: containerWidth)

        var placements: [Placement] = []
        var occupied: Set<Cell> = []

        for index in subviews.indices {
            let requested = subviews[index][TileSpanKey.self]
            let span = TileSpan(rows: requested.rows, columns: min(requested.columns, columns))
            let cell = firstFreeCell(for: span, columns: columns, occupied: occupied)

            for row in cell.row ..< cell.row + span.rows {
                for column in cell.column ..< cell.column + span.columns {
                    occupied.insert(Cell(row: row, column: column))
                }
            }

            placements.append(Placement(index: index, cell: cell, span: span))
        }

        let rows = placements.map { $0.cell.row + $0.span.rows }.max() ?? 0
        var rowHeights = [CGFloat](repeating: 0, count: rows)

        for placement in placements where placement.span.rows == 1 {
            let height = subviews[placement.index].sizeThatFits(ProposedViewSize(
                width: width(of: placement.span, cellWidth: cellWidth),
                height: nil
            )).height

            rowHeights[placement.cell.row] = max(rowHeights[placement.cell.row], height)
        }

        for placement in placements where placement.span.rows > 1 {
            let rows = placement.cell.row ..< placement.cell.row + placement.span.rows
            let height = subviews[placement.index].sizeThatFits(ProposedViewSize(
                width: width(of: placement.span, cellWidth: cellWidth),
                height: nil
            )).height

            let deficit = height - self.height(of: rows, in: rowHeights)

            guard deficit > 0 else {
                continue
            }

            for row in rows {
                rowHeights[row] += deficit / CGFloat(placement.span.rows)
            }
        }

        cache.containerWidth = containerWidth
        cache.placements = placements
        cache.rowHeights = rowHeights
    }

    private func firstFreeCell(for span: TileSpan, columns: Int, occupied: Set<Cell>) -> Cell {
        var row = 0

        while true {
            for column in 0 ... (columns - span.columns) {
                let fits = (row ..< row + span.rows).allSatisfy { row in
                    (column ..< column + span.columns).allSatisfy { column in
                        !occupied.contains(Cell(row: row, column: column))
                    }
                }

                if fits {
                    return Cell(row: row, column: column)
                }
            }

            row += 1
        }
    }

    private func cellWidth(in containerWidth: CGFloat) -> CGFloat {
        let columns = max(columns, 1)

        return (containerWidth - CGFloat(columns - 1) * spacing) / CGFloat(columns)
    }

    private func width(of span: TileSpan, cellWidth: CGFloat) -> CGFloat {
        cellWidth * CGFloat(span.columns) + spacing * CGFloat(span.columns - 1)
    }

    private func size(of placement: Placement, cellWidth: CGFloat, rowHeights: [CGFloat]) -> CGSize {
        let rows = placement.cell.row ..< placement.cell.row + placement.span.rows

        return CGSize(
            width: width(of: placement.span, cellWidth: cellWidth),
            height: height(of: rows, in: rowHeights)
        )
    }

    private func height(of rows: Range<Int>, in rowHeights: [CGFloat]) -> CGFloat {
        guard !rows.isEmpty else {
            return 0
        }

        return rowHeights[rows].reduce(0, +) + CGFloat(rows.count - 1) * spacing
    }

    private func offset(ofRow row: Int, in rowHeights: [CGFloat]) -> CGFloat {
        rowHeights[..<row].reduce(0, +) + CGFloat(row) * spacing
    }
}

nonisolated struct TileSpan: Hashable {
    var rows: Int = 1
    var columns: Int = 1

    init(rows: Int = 1, columns: Int = 1) {
        self.rows = max(rows, 1)
        self.columns = max(columns, 1)
    }
}

private nonisolated struct TileSpanKey: LayoutValueKey {
    static let defaultValue = TileSpan()
}

extension View {
    func tileSpan(rows: Int = 1, columns: Int = 1) -> some View {
        layoutValue(key: TileSpanKey.self, value: TileSpan(rows: rows, columns: columns))
    }
}
