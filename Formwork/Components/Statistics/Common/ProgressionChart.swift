//
//  ProgressionChart.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Charts
import FormworkKit
import SwiftUI

struct ProgressionChart: View {
    private let progression: Progression

    private var isYear = false

    init(_ progression: Progression, isYear: Bool = false) {
        self.progression = progression
        self.isYear = isYear
    }

    var body: some View {
        let color = progression.pictogram.color
        let format = progression.format

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
            AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) { mark in
                AxisGridLine()

                if let rank = mark.as(Double.self) {
                    AxisValueLabel {
                        Text(verbatim: format.format(rank))
                    }
                }
            }
        }
        .font(.caption2)
        .foregroundStyle(.tertiary)
    }
}
