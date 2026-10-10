//
//  ActiveDaysYear.swift
//  Formwork
//
//  Created by Daniel Wolbach on 24.09.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct ActiveDaysYear: View {
    private let activeDays: ActiveDays

    init(_ activeDays: ActiveDays) {
        self.activeDays = activeDays
    }

    var body: some View {
        let calendar = activeDays.calendar
        let months = Dictionary(grouping: activeDays.days) { calendar.dateInterval(of: .month, for: $0.date)?.start ?? $0.date }
            .sorted { $0.key < $1.key }

        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12, alignment: .top), count: 3), spacing: 16) {
            ForEach(months, id: \.key) { month, days in
                VStack(alignment: .leading, spacing: 4) {
                    Text(month, format: .dateTime.month(.abbreviated))
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    page(of: days)
                }
            }
        }
    }

    private func page(of days: [ActiveDays.Day]) -> some View {
        let calendar = activeDays.calendar
        let offset = days.first.map { (calendar.component(.weekday, from: $0.date) - calendar.firstWeekday + 7) % 7 } ?? 0
        let leading = Array(repeating: nil, count: offset) + days.map(Optional.some)
        let slots = leading + Array(repeating: nil, count: max(42 - leading.count, 0))
        let weeks = stride(from: 0, to: 42, by: 7).map { Array(slots[$0 ..< $0 + 7]) }

        return VStack(spacing: 2) {
            ForEach(weeks.indices, id: \.self) { week in
                HStack(spacing: 2) {
                    ForEach(weeks[week].indices, id: \.self) { weekday in
                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                            .fill(fill(of: weeks[week][weekday]))
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
        }
    }

    private func fill(of day: ActiveDays.Day?) -> AnyShapeStyle {
        guard let day else {
            return AnyShapeStyle(.clear)
        }

        return day.sessionCount > 0 ? AnyShapeStyle(Statistic.activeDays.pictogram.color) : AnyShapeStyle(.gray.quaternary)
    }
}

#Preview {
    let history = History(.all, among: Samples.sessions)

    ActiveDaysYear(ActiveDays(history.year(history.years.upperBound)))
        .padding()
}
