//
//  MonthlyChart.swift
//  Formwork
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Charts
import FormworkKit
import FormworkUI
import SwiftUI

struct MonthlyChart: View {
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
        let selected = selectedBar

        Chart {
            ForEach(series.points) { bar in
                if let value = bar.value {
                    BarMark(
                        x: .value(.chartMonth, bar.date, unit: .month),
                        y: .value(title, value)
                    )
                    .foregroundStyle(.tint)
                }
            }

            if let selected, let value = selected.value {
                RuleMark(x: .value(.chartMonth, selected.date, unit: .month))
                    .foregroundStyle(.tint.secondary)
                    .lineStyle(StrokeStyle(lineWidth: 4))
                    .annotation(position: .top, spacing: 0, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                        ChartSelectionLabel(series.reading(of: value).formatted(.reading(units: units)))
                    }
            }
        }
        .chartXScale(domain: series.span.start ... series.span.end)
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) {
                AxisValueLabel(format: .dateTime.month(.narrow), centered: true)
            }
        }
        .chartXSelection(value: $selectedDate)
        .sensoryFeedback(.selection, trigger: selected?.id)
        .readingAxis(upTo: series.values.max() ?? 0, reading: series.reading(of:))
        .frame(height: 192)
    }

    private var selectedBar: Series.Point? {
        guard let selectedDate else {
            return nil
        }

        return series.points.first { Calendar.current.isDate($0.date, equalTo: selectedDate, toGranularity: .month) }
    }
}

#Preview {
    NavigationRoot {}
        .sheet(isPresented: .constant(true)) {
            NavigationRoot {
                StatisticSheet(.completionRate, of: History(.all, among: Samples.sessions))
            }
            .presentationDetents([.medium, .large])
        }
        .sampleData()
}
