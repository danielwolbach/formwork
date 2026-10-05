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

    private let isSelectable: Bool

    @Environment(\.units)
    private var units: Units

    @State
    private var selectedDate: Date? = nil

    init(_ progression: Progression, isYear: Bool = false, isSelectable: Bool = false) {
        self.progression = progression
        self.isYear = isYear
        self.isSelectable = isSelectable
    }

    var body: some View {
        let color = StatisticKind.progression.definition.pictogram.color
        let selected = selectedPoint

        Chart {
            ForEach(progression.curve) { point in
                AreaMark(x: .value(.chartDate, point.date, unit: .day), y: .value(.chartTarget, point.target.rank))
                    .interpolationMethod(.monotone)
                    .foregroundStyle(LinearGradient(colors: [color.opacity(0.35), color.opacity(0)], startPoint: .top, endPoint: .bottom))

                LineMark(x: .value(.chartDate, point.date, unit: .day), y: .value(.chartTarget, point.target.rank))
                    .interpolationMethod(.monotone)
                    .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    .foregroundStyle(color)
            }

            ForEach(progression.points) { point in
                PointMark(x: .value(.chartDate, point.date, unit: .day), y: .value(.chartTarget, point.target.rank))
                    .symbolSize(16)
                    .foregroundStyle(color.opacity(0.35))
            }

            if let selected {
                RuleMark(x: .value(.chartDate, selected.date, unit: .day))
                    .foregroundStyle(color.secondary)
                    .lineStyle(StrokeStyle(lineWidth: 4))
                    .annotation(position: .top, spacing: 0, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                        ChartSelectionLabel(progression.reading(of: selected.target.rank).formatted(.reading(units: units)))
                            .tint(color)
                    }
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
        // Off in the small card, where a drag would fight the tap that opens the sheet.
        .chartXSelection(value: isSelectable ? $selectedDate : .constant(nil))
        .sensoryFeedback(.selection, trigger: selected?.date)
        .font(.caption2)
        .foregroundStyle(.tertiary)
    }

    private var selectedPoint: Progression.Point? {
        guard let selectedDate else {
            return nil
        }

        return progression.points.min { abs($0.date.timeIntervalSince(selectedDate)) < abs($1.date.timeIntervalSince(selectedDate)) }
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
