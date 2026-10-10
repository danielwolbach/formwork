//
//  StatisticSheet.swift
//  Formwork
//
//  Created by Daniel Wolbach on 24.09.26.
//

import FormworkKit
import FormworkUI
import SwiftUI

struct StatisticSheet: View {
    private let statistic: Statistic

    private let history: History

    init(_ statistic: Statistic, of history: History) {
        self.statistic = statistic
        self.history = history
    }

    var body: some View {
        DetailSheet(statistic, subtitle: history.subject.title) {
            switch statistic.kind {
            case let .formula(formula, tolerance): details(of: formula, tolerance: tolerance)
            case let .measurement(measurement, tolerance): details(of: measurement, tolerance: tolerance)
            case .streak: streakDetails
            case .activeDays: activeDaysDetails
            case .categories: categoriesDetails
            case .progression: progressionDetails
            }
        }
    }

    @ViewBuilder
    private var streakDetails: some View {
        let streak = history.allTime.streak

        ValueList {
            ValueRow(
                title: statistic.title,
                reading: .count(streak.weeks),
                footnote: String(localized: streak.isCurrentWeekFulfilled ? .statisticWeekStreakFulfilledSubtitle : .statisticWeekStreakPendingSubtitle)
            )

            ValueRow(title: String(localized: .statisticLongestWeekStreakTitle), reading: .count(streak.longest))
        }
    }

    private var activeDaysDetails: some View {
        YearSection(years: history.years) { year in
            ActiveDaysYear(ActiveDays(history.year(year)))
        }
    }

    @ViewBuilder
    private var categoriesDetails: some View {
        SectionView(.fieldRecentTitle, subtitle: .init(localized: .fieldLastWeeksSubtitle(count: History.recentWeeks))) {
            GroupBox {
                CategoriesBreakdown(Categories(history.recent))
            }
            .groupBoxStyle(.card)
        }

        SectionView(.fieldOverallTitle) {
            GroupBox {
                CategoriesBreakdown(Categories(history.allTime))
            }
            .groupBoxStyle(.card)
        }

        YearSection(years: history.years) { year in
            CategoriesChart(history, year: year)
        }
    }

    @ViewBuilder
    private var progressionDetails: some View {
        ValueList {
            ValueComparison(Progression.comparison(in: history))

            ValueRow(title: String(localized: .fieldOverallTitle), reading: history.allTime.reading(.maximum(.best)))
        }

        YearSection(years: history.years) { year in
            ProgressionChart(Progression(history.year(year)), isYear: true, isSelectable: true)
                .frame(height: 200)
        }
    }

    @ViewBuilder
    private func details(of formula: Formula, tolerance: Double?) -> some View {
        ValueList {
            if formula == .latest {
                ValueRow(title: statistic.title, reading: history.allTime.reading(formula))
            } else {
                if tolerance == nil {
                    ValueComparison(recent: history.recent.reading(formula))
                } else {
                    ValueComparison(history.comparison(formula, tolerance: tolerance))
                }

                ValueRow(title: String(localized: .fieldOverallTitle), reading: history.allTime.reading(formula))
            }
        }

        if let series = history.series(formula) {
            sessions(series)
        }

        if formula.isNumeric {
            YearSection(years: history.years) { year in
                if let monthly = history.monthly(formula, in: year) {
                    MonthlyChart(monthly, title: statistic.title)
                }
            }
        }
    }

    @ViewBuilder
    private func details(of measurement: BodyMeasurement, tolerance: Double) -> some View {
        ValueList {
            ValueComparison(history.body.comparison(measurement, tolerance: tolerance), latestOn: history.body.latest(measurement)?.date)
        }

        MeasurementLogButton(measurement, title: statistic.title, latest: history.body.latest(measurement)?.value)

        sessions(history.body.series(measurement))

        if let years = history.body.years(of: measurement) {
            YearSection(years: years) { year in
                MonthlyChart(history.body.monthly(measurement, in: year), title: statistic.title)
            }
        }
    }

    @ViewBuilder
    private func sessions(_ series: Series) -> some View {
        if series.values.count > 1 {
            SectionView(.fieldLatestTitle, subtitle: String(localized: .fieldLastWeeksSubtitle(count: History.chartedWeeks))) {
                GroupBox {
                    SessionsChart(series, title: statistic.title)
                }
                .groupBoxStyle(.card)
            }
        }
    }
}

private struct ValueList<Content: View>: View {
    @ViewBuilder
    let content: Content

    var body: some View {
        GroupBox {
            Group(subviews: content) { subviews in
                VStack(spacing: .groups) {
                    ForEach(subviews.indices, id: \.self) { index in
                        if index > 0 {
                            Divider()
                        }

                        subviews[index]
                    }
                }
            }
        }
        .groupBoxStyle(.card)
    }
}

private struct MeasurementLogButton: View {
    private let measurement: BodyMeasurement

    private let title: String

    private let latest: Double?

    @Environment(\.units)
    private var units: Units

    @State
    private var isLogging: Bool = false

    init(_ measurement: BodyMeasurement, title: String, latest: Double?) {
        self.measurement = measurement
        self.title = title
        self.latest = latest
    }

    var body: some View {
        Button(.logMeasurement) {
            isLogging = true
        }
        .labelStyle(.fixedTitleAndIcon)
        .buttonStyle(.cardProminent)
        .sheet(isPresented: $isLogging) {
            NumberEntrySheet(title, value: value, suffix: suffix, range: range)
                .tint(nil)
        }
    }

    private var value: Binding<Double> {
        Binding(
            get: {
                (latest ?? 0) / factor
            },
            set: { newValue in
                guard newValue > 0 else {
                    return
                }

                Task {
                    await Health.shared.log(newValue * factor, as: measurement)
                }
            }
        )
    }

    private var factor: Double {
        switch measurement {
        case .weight: Measurement(value: 1, unit: units.weightUnit).converted(to: .kilograms).value
        case .bodyFat: 0.01
        }
    }

    private var suffix: String {
        switch measurement {
        case .weight: units.weightUnit.symbol
        case .bodyFat: "%"
        }
    }

    private var range: ClosedRange<Double> {
        switch measurement {
        case .weight: 0 ... 500 / factor
        case .bodyFat: 0 ... 100
        }
    }
}

#Preview("Streak") {
    NavigationRoot {}
        .sheet(isPresented: .constant(true)) {
            NavigationRoot {
                StatisticSheet(.weekStreak, of: History(.all, among: Samples.sessions))
            }
            .presentationDetents([.medium, .large])
        }
        .sampleData()
}

#Preview("Indicator") {
    NavigationRoot {}
        .sheet(isPresented: .constant(true)) {
            NavigationRoot {
                StatisticSheet(.typicalStartTime, of: History(.all, among: Samples.sessions))
            }
            .presentationDetents([.medium, .large])
        }
        .sampleData()
}

#Preview("Measurement") {
    NavigationRoot {}
        .sheet(isPresented: .constant(true)) {
            NavigationRoot {
                StatisticSheet(.bodyWeight, of: History(.all, among: Samples.sessions, measurements: Samples.measurements))
            }
            .presentationDetents([.medium, .large])
        }
        .sampleData()
}

#Preview("Categories") {
    NavigationRoot {}
        .sheet(isPresented: .constant(true)) {
            NavigationRoot {
                StatisticSheet(.categories, of: History(.all, among: Samples.sessions))
            }
            .presentationDetents([.medium, .large])
        }
        .sampleData()
}

#Preview("Progression") {
    NavigationRoot {}
        .sheet(isPresented: .constant(true)) {
            NavigationRoot {
                StatisticSheet(.progression, of: History(.exercise(Samples.exercises[2]), among: Samples.sessions))
            }
            .presentationDetents([.medium, .large])
        }
        .sampleData()
}
