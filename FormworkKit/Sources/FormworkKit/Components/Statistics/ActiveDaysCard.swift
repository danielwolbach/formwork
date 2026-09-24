//
//  ActiveDaysCard.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import SwiftUI

/// The days trained, a column per week with the weekdays down the side. Every day that has passed has its cell,
/// so the grid is full up to today and only the rest of the current week stays open. Needs whole weeks.
struct ActiveDaysCard: View {
    private let activeDays: ActiveDays

    init(_ activeDays: ActiveDays) {
        self.activeDays = activeDays
    }

    var body: some View {
        let weeks = stride(from: 0, to: activeDays.days.count, by: 7).map { Array(activeDays.days[$0 ..< min($0 + 7, activeDays.days.count)]) }

        ChartCard(title: activeDays.title) {
            HStack(spacing: 2) {
                weekdays

                ForEach(weeks, id: \.first?.date) { week in
                    column(of: week)
                }
            }

            Spacer(minLength: 0)
        }
    }

    private var weekdays: some View {
        VStack(spacing: 2) {
            ForEach(activeDays.weekdays) { weekday in
                cell(.clear)
                    .overlay {
                        Text(verbatim: weekday.symbol())
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

private struct ActiveDaysPreview: View {
    let workout: Workout

    var body: some View {
        TileGrid {
            ActiveDaysCard(ActiveDays(History(.workout(workout)).weeks(16)))
                .tileSpan(rows: 2, columns: 2)
        }
    }
}

#Preview {
    ActiveDaysPreview(workout: Samples.workouts[0])
        .padding()
        .sampleData()
}
