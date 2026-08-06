//
//  WeeklySessionsChart.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 06.08.26.
//

import Charts
import SwiftUI

struct WeeklySessionsChart: View {
    let data: [WeeklySessionCount]
    let tint: Color

    init(data: [WeeklySessionCount], tint: Color = .accentColor) {
        self.data = data
        self.tint = tint
    }

    var body: some View {
        StatisticsCard(title: .statsLastSixWeeks, icon: "chart.bar", tint: tint) {
            Chart(data) { point in
                BarMark(
                    x: .value(String(localized: .statsWeek), point.week, unit: .weekOfYear),
                    y: .value(String(localized: .statsSessions), point.count)
                )
                .foregroundStyle(tint)
            }
            .chartYScale(domain: 0 ... maximumSessionCount)
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { _ in
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .weekOfYear)) { _ in
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                }
            }
            .frame(height: 128)
        }
    }

    private var maximumSessionCount: Int {
        max(data.map(\.count).max() ?? 0, 1)
    }
}

#Preview {
    let calendar = Calendar.current
    let now = Date.now
    let data = (0 ..< 6).reversed().compactMap { offset in
        calendar.date(byAdding: .weekOfYear, value: -offset, to: now)
            .map { WeeklySessionCount(week: $0, count: [2, 3, 1, 4, 2, 3][offset]) }
    }

    WeeklySessionsChart(data: data, tint: .green)
        .padding()
}
