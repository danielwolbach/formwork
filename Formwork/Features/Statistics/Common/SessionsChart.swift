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
    private let points: [SessionComparison.Point]

    private let period: DateInterval?

    private let title: String

    private let reading: (Double) -> Reading?

    @Environment(\.units)
    private var units: Units

    @State
    private var selectedDate: Date? = nil

    init(_ points: [SessionComparison.Point], period: DateInterval? = nil, title: String, reading: @escaping (Double) -> Reading?) {
        self.points = points
        self.period = period
        self.title = title
        self.reading = reading
    }

    var body: some View {
        let selected = selectedPoint

        Chart {
            ForEach(points) { point in
                if let value = point.value {
                    LineMark(x: .value(.chartDate, point.date), y: .value(title, value))
                        .foregroundStyle(.tint)

                    PointMark(x: .value(.chartDate, point.date), y: .value(title, value))
                        .foregroundStyle(.tint)
                        .symbolSize(point.isCurrent ? 120 : 30)
                }
            }

            if let selected, let value = selected.value, let reading = reading(value) {
                RuleMark(x: .value(.chartDate, selected.date))
                    .foregroundStyle(.tint.secondary)
                    .lineStyle(StrokeStyle(lineWidth: 4))
                    .annotation(position: .top, spacing: 0, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                        ChartSelectionLabel(reading.formatted(.reading(units: units)))
                    }
            }
        }
        .chartXScale(domain: domain)
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 4)) {
                AxisValueLabel(format: .dateTime.day().month(.abbreviated))
            }
        }
        .chartXSelection(value: $selectedDate)
        .sensoryFeedback(.selection, trigger: selected?.id)
        .readingAxis(upTo: points.compactMap(\.value).max() ?? 0, reading: reading)
        .frame(height: 192)
    }

    private var domain: ClosedRange<Date> {
        if let period {
            return period.start ... period.end
        }

        let dates = points.map(\.date)
        return (dates.min() ?? .now) ... (dates.max() ?? .now)
    }

    private var selectedPoint: SessionComparison.Point? {
        guard let selectedDate else {
            return nil
        }

        return points
            .filter { $0.value != nil }
            .min { abs($0.date.timeIntervalSince(selectedDate)) < abs($1.date.timeIntervalSince(selectedDate)) }
    }
}
