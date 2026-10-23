//
//  ActiveDaysCard.swift
//  Formwork
//
//  Created by Daniel Wolbach on 24.09.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct ActiveDaysCard: View {
    private static let spacing: CGFloat = 2

    private let activeDays: ActiveDays

    init(_ activeDays: ActiveDays) {
        self.activeDays = activeDays
    }

    var body: some View {
        let days = activeDays.days
        let weeks = stride(from: 0, to: days.count, by: 7).map { Array(days[$0 ..< min($0 + 7, days.count)]) }

        GroupBox {
            GeometryReader { proxy in
                let layout = Self.layout(in: proxy.size, weeks: weeks.count)
                let visible = weeks.suffix(layout.weeks)

                HStack(alignment: .top, spacing: Self.spacing) {
                    weekdays(cell: layout.cell)

                    ForEach(visible, id: \.first?.date) { week in
                        column(of: week, cell: layout.cell)
                    }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text(Self.summary(of: visible.flatMap(\.self))))
            }
        } label: {
            Label(Statistic.activeDays.title, systemImage: Statistic.activeDays.pictogram.image)
        }
        .groupBoxStyle(.card)
    }

    static func summary(of days: [ActiveDays.Day]) -> LocalizedStringResource {
        let past = days.filter { !$0.isAhead }
        return .activeDaysSummaryLabel(active: past.count { $0.sessionCount > 0 }, total: past.count)
    }

    /// Cells shrink only as far as the charted weeks and the height require; any width left over shows more weeks.
    private static func layout(in size: CGSize, weeks available: Int) -> (cell: CGFloat, weeks: Int) {
        let minimumWeeks = CGFloat(min(History.chartedWeeks, available))
        let fittingHeight = (size.height - 6 * spacing) / 7
        let fittingWidth = (size.width - minimumWeeks * spacing) / (minimumWeeks + 1)
        let cell = min(fittingHeight, fittingWidth)

        guard cell > 0 else {
            return (0, 0)
        }

        let columns = Int((size.width + spacing) / (cell + spacing))
        return (cell, min(max(columns - 1, 0), available))
    }

    private func weekdays(cell size: CGFloat) -> some View {
        let symbols = activeDays.weekdaySymbols

        return VStack(spacing: Self.spacing) {
            ForEach(symbols.indices, id: \.self) { index in
                cell(.clear, size: size)
                    .overlay {
                        Text(verbatim: symbols[index])
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
            }
        }
        .font(.caption2)
        .foregroundStyle(.tertiary)
    }

    private func cell(_ style: some ShapeStyle, size: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 4, style: .continuous)
            .fill(style)
            .frame(width: size, height: size)
    }

    private func column(of week: [ActiveDays.Day], cell size: CGFloat) -> some View {
        VStack(spacing: Self.spacing) {
            ForEach(week) { day in
                cell(fill(of: day), size: size)
            }
        }
    }

    private func fill(of day: ActiveDays.Day) -> AnyShapeStyle {
        if day.isAhead {
            AnyShapeStyle(.clear)
        } else if day.sessionCount == 0 {
            AnyShapeStyle(.gray.quaternary)
        } else {
            AnyShapeStyle(Statistic.activeDays.pictogram.color)
        }
    }
}

#Preview {
    let history = History(.all, among: Samples.sessions)

    TileGrid {
        ActiveDaysCard(ActiveDays(history.weeks(History.activeDaysWeeks)))
            .tileSpan(rows: 2, columns: 2)
    }
    .padding()
}
