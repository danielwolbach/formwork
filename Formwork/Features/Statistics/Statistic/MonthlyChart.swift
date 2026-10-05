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
    private let series: Series<Double?>

    private let title: String

    private let reading: (Double) -> Reading

    @Environment(\.units)
    private var units: Units

    @State
    private var selectedDate: Date? = nil

    init(_ series: Series<Double?>, title: String, reading: @escaping (Double) -> Reading) {
        self.series = series
        self.title = title
        self.reading = reading
    }

    var body: some View {
        let selected = selectedBar

        Chart {
            ForEach(series.bars) { bar in
                if let value = bar.value {
                    BarMark(
                        x: .value(.chartMonth, bar.month, unit: .month),
                        y: .value(title, value)
                    )
                    .foregroundStyle(.tint)
                }
            }

            if let selected, let value = selected.value {
                RuleMark(x: .value(.chartMonth, selected.month, unit: .month))
                    .foregroundStyle(.tint.secondary)
                    .lineStyle(StrokeStyle(lineWidth: 4))
                    .annotation(position: .top, spacing: 0, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                        ChartSelectionLabel(reading(value).formatted(.reading(units: units)))
                    }
            }
        }
        .chartXScale(domain: series.period.start ... series.period.end)
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) {
                AxisValueLabel(format: .dateTime.month(.narrow), centered: true)
            }
        }
        .chartXSelection(value: $selectedDate)
        .sensoryFeedback(.selection, trigger: selected?.id)
        .readingAxis(upTo: series.bars.compactMap(\.value).max() ?? 0, reading: reading)
        .frame(height: 192)
    }

    private var selectedBar: Series<Double?>.Bar? {
        guard let selectedDate else {
            return nil
        }

        return series.bars.first { Calendar.current.isDate($0.month, equalTo: selectedDate, toGranularity: .month) }
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
