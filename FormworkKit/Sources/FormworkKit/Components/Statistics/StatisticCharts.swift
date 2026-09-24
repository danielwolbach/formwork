//
//  StatisticCharts.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Charts
import SwiftUI

/// A metric's year as a bar per month.
struct MonthlyChart<M: Metric>: View {
    let series: Series<M>

    /// Writes out the axis: a metric with a value knows its unit.
    let label: (Double) -> String

    var body: some View {
        let color = series.bars.first?.statistic.pictogram.color ?? .accentColor
        let peak = series.bars.compactMap(\.statistic.value).max() ?? 0
        let step = M.axisStep(upTo: peak)
        let chart = Chart(series.bars) { bar in
            if let value = bar.statistic.value {
                BarMark(x: .value(String(localized: .chartDateTitle), bar.month, unit: .month), y: .value(bar.statistic.title, value))
                    .foregroundStyle(color)
                    .cornerRadius(4)
            }
        }
        .chartXScale(domain: series.period.start ... series.period.end)
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) {
                AxisValueLabel(format: .dateTime.month(.narrow), centered: true)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: step.map { .stride(by: $0) } ?? .automatic(desiredCount: 3)) { mark in
                AxisGridLine()

                if let value = mark.as(Double.self), value > 0 {
                    AxisValueLabel {
                        Text(verbatim: label(value))
                    }
                }
            }
        }

        scaled(chart, step: step, peak: peak)
            .font(.caption2)
            .foregroundStyle(.tertiary)
            .frame(height: 180)
            .padding(.top)
    }

    /// With a step, the axis runs up to the first round mark above the peak, so the top one is labelled too.
    /// Without, the chart picks its own range.
    @ViewBuilder
    private func scaled(_ chart: some View, step: Double?, peak: Double) -> some View {
        if let step {
            chart.chartYScale(domain: 0 ... step * (peak / step).rounded(.up))
        } else {
            chart
        }
    }
}

/// Completed exercises per month, stacked by category.
struct CategoriesChart: View {
    let series: Series<Categories>

    var body: some View {
        Chart(series.bars) { bar in
            ForEach(bar.statistic.shares) { share in
                BarMark(x: .value(String(localized: .chartDateTitle), bar.month, unit: .month), y: .value(share.category.title, share.count))
                    .foregroundStyle(share.category.pictogram.color)
            }
        }
        .chartXScale(domain: series.period.start ... series.period.end)
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) {
                AxisValueLabel(format: .dateTime.month(.narrow), centered: true)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) {
                AxisGridLine()

                AxisValueLabel()
            }
        }
        .font(.caption2)
        .foregroundStyle(.tertiary)
        .frame(height: 180)
        .padding(.top)
    }
}

/// A year of active days as twelve small months, each laid out like a calendar page: only its own days, with
/// the ones still to come as empty cells, so the whole year keeps its shape.
struct ActiveDaysYear: View {
    let activeDays: ActiveDays

    var body: some View {
        let calendar = activeDays.calendar
        let months = Dictionary(grouping: activeDays.days) { calendar.dateInterval(of: .month, for: $0.date)?.start ?? $0.date }
            .sorted { $0.key < $1.key }

        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12, alignment: .top), count: 3), spacing: 16) {
            ForEach(months, id: \.key) { month, days in
                VStack(alignment: .leading, spacing: 4) {
                    Text(month, format: .dateTime.month(.abbreviated))
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    page(of: days)
                }
            }
        }
    }

    /// A month's days a week to a row, starting on the weekday it starts on. The rows are padded to whole weeks,
    /// so every cell is as wide as the others.
    private func page(of days: [ActiveDays.Day]) -> some View {
        let calendar = activeDays.calendar
        let offset = days.first.map { (calendar.component(.weekday, from: $0.date) - calendar.firstWeekday + 7) % 7 } ?? 0
        let slots = Array(repeating: nil, count: offset) + days.map(Optional.some)
        let weeks = stride(from: 0, to: slots.count, by: 7).map { start in
            (start ..< start + 7).map { $0 < slots.count ? slots[$0] : nil }
        }

        return VStack(spacing: 2) {
            ForEach(weeks.indices, id: \.self) { week in
                HStack(spacing: 2) {
                    ForEach(weeks[week].indices, id: \.self) { weekday in
                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                            .fill(fill(of: weeks[week][weekday]))
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
        }
    }

    /// Nothing for the slots before and after the month, the colour for days trained, grey for every other day of
    /// it, past or to come.
    private func fill(of day: ActiveDays.Day?) -> AnyShapeStyle {
        guard let day else {
            return AnyShapeStyle(.clear)
        }

        return day.sessionCount > 0 ? AnyShapeStyle(activeDays.pictogram.color) : AnyShapeStyle(.gray.quaternary)
    }
}

private struct StatisticChartsPreview: View {
    let workout: Workout

    var body: some View {
        let history = History(.workout(workout))
        let year = history.years.upperBound

        ScrollView {
            VStack(spacing: 16) {
                ChartCard {
                    MonthlyChart(series: Series(TypicalDuration.self, of: history, year: year), label: TypicalDuration(history.allTime).label(for:))
                }

                ChartCard {
                    CategoriesChart(series: Series(Categories.self, of: history, year: year))
                }

                ChartCard {
                    ActiveDaysYear(activeDays: ActiveDays(history.year(year)))
                }
            }
            .padding()
        }
    }
}

#Preview {
    StatisticChartsPreview(workout: Samples.workouts[0])
        .sampleData()
}
