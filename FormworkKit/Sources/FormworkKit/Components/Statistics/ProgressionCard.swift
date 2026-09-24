//
//  ProgressionCard.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Charts
import SwiftUI

/// How an exercise went: each day's best, and the typical best through them.
struct ProgressionCard: View {
    private let progression: Progression

    init(_ progression: Progression) {
        self.progression = progression
    }

    var body: some View {
        ChartCard(title: progression.title) {
            if progression.points.isEmpty {
                Image(systemName: "chart.xyaxis.line")
                    .font(.largeTitle)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ProgressionChart(progression: progression)
                    .padding(.top)
            }
        }
    }
}

/// Each day's best as a faded point and the typical best through them as a curve with an area under it, over
/// the progression's period. A year is labelled by month, a shorter stretch by a few dates.
struct ProgressionChart: View {
    let progression: Progression

    var isYear = false

    var body: some View {
        let color = progression.pictogram.color
        let date = String(localized: .chartDateTitle)

        Chart {
            ForEach(progression.curve) { point in
                AreaMark(x: .value(date, point.date, unit: .day), y: .value(progression.title, point.target.rank))
                    .interpolationMethod(.monotone)
                    .foregroundStyle(LinearGradient(colors: [color.opacity(0.35), color.opacity(0)], startPoint: .top, endPoint: .bottom))

                LineMark(x: .value(date, point.date, unit: .day), y: .value(progression.title, point.target.rank))
                    .interpolationMethod(.monotone)
                    .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    .foregroundStyle(color)
            }

            ForEach(progression.points) { point in
                PointMark(x: .value(date, point.date, unit: .day), y: .value(progression.title, point.target.rank))
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
                        Text(verbatim: progression.label(for: rank))
                    }
                }
            }
        }
        .font(.caption2)
        .foregroundStyle(.tertiary)
    }
}

private struct ProgressionPreview: View {
    let exercise: Exercise

    var body: some View {
        TileGrid {
            ProgressionCard(Progression(History(.exercise(exercise)).weeks(16)))
                .tileSpan(rows: 2, columns: 2)
        }
    }
}

#Preview {
    ProgressionPreview(exercise: Samples.exercises[10])
        .padding()
        .sampleData()
}
