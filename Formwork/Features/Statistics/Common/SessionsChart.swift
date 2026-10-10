//
//  SessionsChart.swift
//  Formwork
//
//  Created by Daniel Wolbach on 05.10.26.
//

import Charts
import FormworkKit
import FormworkUI
import SwiftUI

/// Placed by date, so breaks between sessions show as gaps.
struct SessionsChart: View {
    private let series: Series

    private let title: String

    @Environment(\.units)
    private var units: Units

    @State
    private var selectedDate: Date? = nil

    init(_ series: Series, title: String) {
        self.series = series
        self.title = title
    }

    var body: some View {
        let selected = selectedPoint

        Chart {
            ForEach(series.points) { point in
                if let value = point.value {
                    LineMark(x: .value(.chartDate, point.date), y: .value(title, value))
                        .foregroundStyle(.tint)

                    // A carried value only leads the line in, it wasn't recorded then.
                    if !point.isCarried {
                        PointMark(x: .value(.chartDate, point.date), y: .value(title, value))
                            .foregroundStyle(.tint)
                            .symbolSize(point.isHighlighted ? 120 : 30)
                    }
                }
            }

            if let selected, let value = selected.value {
                RuleMark(x: .value(.chartDate, selected.date))
                    .foregroundStyle(.tint.secondary)
                    .lineStyle(StrokeStyle(lineWidth: 4))
                    .annotation(position: .top, spacing: 0, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                        ChartSelectionLabel(series.reading(of: value).formatted(.reading(units: units)))
                    }
            }
        }
        .chartXScale(domain: series.span.start ... series.span.end)
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 4)) {
                AxisValueLabel(format: .dateTime.day().month(.abbreviated))
            }
        }
        .chartXSelection(value: $selectedDate)
        .sensoryFeedback(.selection, trigger: selected?.id)
        .readingAxis(upTo: series.values.max() ?? 0, reading: series.reading(of:))
        .frame(height: 192)
    }

    private var selectedPoint: Series.Point? {
        guard let selectedDate else {
            return nil
        }

        return series.points
            .filter { $0.value != nil && !$0.isCarried }
            .min { abs($0.date.timeIntervalSince(selectedDate)) < abs($1.date.timeIntervalSince(selectedDate)) }
    }
}
