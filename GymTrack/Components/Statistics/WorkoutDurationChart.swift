//
//  WorkoutDurationChart.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 06.08.26.
//

import Charts
import SwiftUI

struct WorkoutDurationChart: View {
    let data: [WorkoutDurationDataPoint]
    let tint: Color

    init(data: [WorkoutDurationDataPoint], tint: Color = .accentColor) {
        self.data = data
        self.tint = tint
    }

    var body: some View {
        StatisticsCard(title: .statsRecentDuration, icon: "chart.line.uptrend.xyaxis", tint: tint) {
            Chart {
                ForEach(data) { point in
                    LineMark(
                        x: .value(String(localized: .statsDate), point.date),
                        y: .value(String(localized: .statsDuration), point.duration)
                    )
                    .foregroundStyle(tint)

                    PointMark(
                        x: .value(String(localized: .statsDate), point.date),
                        y: .value(String(localized: .statsDuration), point.duration)
                    )
                    .foregroundStyle(tint)
                }
            }
            .chartYScale(domain: yDomain)
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) { value in
                    AxisGridLine()

                    if let seconds = value.as(Double.self) {
                        AxisValueLabel(Duration.seconds(seconds)
                            .formatted(.time(pattern: .hourMinute(padHourToLength: 1))))
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 3)) {
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                }
            }
            .frame(height: 180)
        }
    }

    private var yDomain: ClosedRange<Double> {
        StatisticsChartScale.domain(for: data.map(\.duration))
    }
}

#Preview {
    let now = Date.now
    let calendar = Calendar.current
    let data = [100, 110, 105, 115, 108].compactMap { minutes in
        calendar.date(byAdding: .day, value: -minutes / 10, to: now)
            .map { WorkoutDurationDataPoint(date: $0, duration: Double(minutes * 60)) }
    }

    WorkoutDurationChart(data: data, tint: .purple)
        .padding()
}
