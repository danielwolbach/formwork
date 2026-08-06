//
//  ExerciseTargetHistoryChart.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 06.08.26.
//

import Charts
import SwiftUI

struct ExerciseTargetHistoryChart: View {
    let data: [ExerciseTargetDataPoint]
    let tint: Color

    init(data: [ExerciseTargetDataPoint], tint: Color = .accentColor) {
        self.data = data
        self.tint = tint
    }

    var body: some View {
        StatisticsCard(title: .statsTargetHistory, icon: "chart.line.uptrend.xyaxis", tint: tint) {
            Chart {
                ForEach(data) { point in
                    LineMark(
                        x: .value(String(localized: .statsDate), point.date),
                        y: .value(String(localized: .statsTarget), point.value)
                    )
                    .foregroundStyle(tint)

                    PointMark(
                        x: .value(String(localized: .statsDate), point.date),
                        y: .value(String(localized: .statsTarget), point.value)
                    )
                    .foregroundStyle(tint)
                }
            }
            .chartYScale(domain: yDomain)
            .chartYAxis {
                AxisMarks(position: .leading, values: yAxisValues) { value in
                    AxisGridLine()

                    if let targetValue = value.as(Double.self) {
                        AxisValueLabel(data.last?.target.formattedPrimaryTargetValue(targetValue) ?? targetValue
                            .formatted())
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
        StatisticsChartScale.indicatorDomain(for: data.map(\.value), step: indicatorStep)
    }

    private var yAxisValues: [Double] {
        StatisticsChartScale.indicatorValues(in: yDomain, step: indicatorStep)
    }

    private var indicatorStep: Double {
        guard let target = data.last?.target else {
            return 1
        }

        return switch target {
        case .weight, .duration: 5
        case .bodyweight: 1
        case .distance: 100
        }
    }
}

#Preview {
    let calendar = Calendar.current
    let data = [75, 77.5, 80, 82.5, 85].enumerated().compactMap { index, weight in
        calendar.date(byAdding: .day, value: -(4 - index) * 4, to: .now)
            .map { ExerciseTargetDataPoint(date: $0, target: .weight(weight: weight, sets: 3, reps: 10)) }
    }

    ExerciseTargetHistoryChart(data: data, tint: .purple)
        .padding()
}
