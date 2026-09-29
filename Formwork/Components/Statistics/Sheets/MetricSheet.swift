//
//  MetricSheet.swift
//  Formwork
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Charts
import FormworkKit
import FormworkUI
import SwiftUI

struct MetricSheet<M: Metric>: View {
    private let history: History

    private let overall: M

    private let trend: Trend<M>

    @Environment(\.units)
    private var units: Units

    init(history: History) {
        self.history = history
        self.overall = M(history.allTime)
        self.trend = Trend(history)
    }

    var body: some View {
        StatisticSheet(overall, history: history) {
            ValuesSection(
                overall: overall.reading?.formatted(.reading(units: units)),
                recent: trend.recent.reading?.formatted(.reading(units: units)),
                baseline: trend.baseline?.reading?.formatted(.reading(units: units)),
                direction: trend.direction
            )

            YearSection(years: history.years) { year in
                MonthlyChart(series: Series<M>(history, year: year), metric: overall)
            }
        }
        .tint(overall.pictogram.color)
    }
}

private struct MonthlyChart<M: Metric>: View {
    let series: Series<M>

    let metric: M

    @Environment(\.units)
    private var units: Units

    var body: some View {
        let peak = series.bars.compactMap(\.statistic.value).max() ?? 0
        let step = M.axisStep(upTo: peak)
        let chart = Chart(series.bars) { bar in
            if let value = bar.statistic.value {
                BarMark(
                    x: .value(.placeholder, bar.month, unit: .month),
                    y: .value(.placeholder, value)
                )
                .foregroundStyle(.tint)
            }
        }
        .chartXScale(domain: series.period.start ... series.period.end)
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) {
                AxisValueLabel(format: .dateTime.month(.narrow), centered: true)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: step.map { .stride(by: $0) } ?? .automatic) { mark in
                AxisGridLine()
                AxisTick()

                if let value = mark.as(Double.self) {
                    AxisValueLabel {
                        Text(verbatim: metric.reading(of: value).formatted(.reading(units: units)))
                    }
                }
            }
        }

        scaled(chart, step: step, peak: peak)
            .frame(height: 192)
    }

    @ViewBuilder
    private func scaled(_ chart: some View, step: Double?, peak: Double) -> some View {
        if let step {
            chart.chartYScale(domain: 0 ... step * (peak / step).rounded(.up))
        } else {
            chart
        }
    }
}

#Preview("Metric") {
    NavigationStack {}
        .sheet(isPresented: .constant(true)) {
            MetricSheet<CompletionRate>(history: History(.all(Samples.sessions)))
                .presentationDetents([.medium, .large])
        }
}
