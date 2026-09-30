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
    private let activeDays: ActiveDays

    init(_ activeDays: ActiveDays) {
        self.activeDays = activeDays
    }

    var body: some View {
        let days = activeDays.days
        let weeks = stride(from: 0, to: days.count, by: 7).map { Array(days[$0 ..< min($0 + 7, days.count)]) }

        GroupBox {
            HStack(spacing: 2) {
                weekdays

                ForEach(weeks, id: \.first?.date) { week in
                    column(of: week)
                }
            }

            Spacer(minLength: 0)
        } label: {
            Label(activeDays.title, systemImage: activeDays.pictogram.image)
        }
        .groupBoxStyle(.card)
    }

    private var weekdays: some View {
        let symbols = activeDays.weekdaySymbols

        return VStack(spacing: 2) {
            ForEach(symbols.indices, id: \.self) { index in
                cell(.clear)
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

    private func cell(_ style: some ShapeStyle) -> some View {
        RoundedRectangle(cornerRadius: 4, style: .continuous)
            .fill(style)
            .aspectRatio(1, contentMode: .fit)
    }

    private func column(of week: [ActiveDays.Day]) -> some View {
        VStack(spacing: 2) {
            ForEach(week) { day in
                cell(fill(of: day))
            }
        }
    }

    private func fill(of day: ActiveDays.Day) -> AnyShapeStyle {
        if day.isAhead {
            AnyShapeStyle(.clear)
        } else if day.sessionCount == 0 {
            AnyShapeStyle(.gray.quaternary)
        } else {
            AnyShapeStyle(activeDays.pictogram.color)
        }
    }
}

#Preview {
    let history = History(.all(Samples.sessions))

    TileGrid {
        ActiveDaysCard(ActiveDays(history.weeks(16)))
            .tileSpan(rows: 2, columns: 2)
    }
    .padding()
}
