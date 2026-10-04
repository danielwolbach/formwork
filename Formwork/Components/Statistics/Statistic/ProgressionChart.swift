//
//  ProgressionChart.swift
//  Formwork
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Charts
import FormworkKit
import FormworkUI
import SwiftUI

struct ProgressionChart: View {
    private let progression: Progression

    private let isYear: Bool

    @Environment(\.units)
    private var units: Units

    init(_ progression: Progression, isYear: Bool = false) {
        self.progression = progression
        self.isYear = isYear
    }

    var body: some View {
        let color = StatisticKind.progression.definition.pictogram.color

        Chart {
            ForEach(progression.curve) { point in
                AreaMark(x: .value(.placeholder, point.date, unit: .day), y: .value(.placeholder, point.target.rank))
                    .interpolationMethod(.monotone)
                    .foregroundStyle(LinearGradient(colors: [color.opacity(0.35), color.opacity(0)], startPoint: .top, endPoint: .bottom))

                LineMark(x: .value(.placeholder, point.date, unit: .day), y: .value(.placeholder, point.target.rank))
                    .interpolationMethod(.monotone)
                    .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    .foregroundStyle(color)
            }

            ForEach(progression.points) { point in
                PointMark(x: .value(.placeholder, point.date, unit: .day), y: .value(.placeholder, point.target.rank))
                    .symbolSize(16)
                    .foregroundStyle(color.opacity(0.35))
            }
        }
        .chartXScale(domain: progression.period.start ... progression.period.end)
        .chartXAxis {
            if isYear {
                AxisMarks(values: .stride(by: .month)) {
                    AxisValueLabel(format: .dateTime.month(.narrow), centered: true)
                }
            } else {
                AxisMarks(values: .automatic(desiredCount: 3)) {
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                }
            }
        }
        .chartYScale(domain: .automatic(includesZero: false))
        .chartYAxis {
            AxisMarks(position: .leading, values: axisStep.map { .stride(by: $0) } ?? .automatic(desiredCount: 3)) { mark in
                AxisGridLine()

                if let rank = mark.as(Double.self) {
                    AxisValueLabel {
                        Text(verbatim: progression.reading(of: rank).formatted(.reading(units: units)))
                    }
                }
            }
        }
        .font(.caption2)
        .foregroundStyle(.tertiary)
    }

    private var axisStep: Double? {
        let peak = (progression.curve.map(\.target.rank) + progression.points.map(\.target.rank)).max() ?? 0
        return ReadingAxis.step(upTo: peak, count: 3, reading: progression.reading(of:))
    }
}

#Preview {
    let history = History(.exercise(Samples.exercises[2]), among: Samples.sessions)

    ProgressionChart(Progression(history.year(history.years.upperBound)), isYear: true)
        .frame(height: 200)
        .padding()
        .sampleData()
}
