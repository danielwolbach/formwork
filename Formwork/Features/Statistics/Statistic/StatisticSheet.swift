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
    private let kind: StatisticKind

    private let history: History

    init(_ kind: StatisticKind, of history: History) {
        self.kind = kind
        self.history = history
    }

    var body: some View {
        let definition = kind.definition
        let details = kind.details(of: history)

        DetailSheet(definition, subtitle: history.subject.title) {
            if !details.values.isEmpty {
                GroupBox {
                    VStack(spacing: .groups) {
                        ForEach(details.values.indices, id: \.self) { index in
                            if index > 0 {
                                Divider()
                            }

                            value(details.values[index])
                        }
                    }
                }
                .groupBoxStyle(.card)

                if let measurement = kind.measurement {
                    MeasurementLogButton(measurement, title: definition.title, latest: history.measurements[measurement].last?.value)
                }
            }

            if let categories = details.categories {
                SectionView(.fieldRecentTitle, subtitle: .init(localized: .fieldLastWeeksSubtitle(count: History.recentWeeks))) {
                    GroupBox {
                        CategoriesBreakdown(categories.recent)
                    }
                    .groupBoxStyle(.card)
                }

                SectionView(.fieldOverallTitle) {
                    GroupBox {
                        CategoriesBreakdown(categories.overall)
                    }
                    .groupBoxStyle(.card)
                }
            }

            if let sessions = details.sessions, sessions.points.count > 1 {
                SectionView(.fieldLatestTitle, subtitle: String(localized: .fieldLastWeeksSubtitle(count: History.comparedWeeks))) {
                    GroupBox {
                        SessionsChart(sessions.points, period: sessions.period, title: definition.title, reading: sessions.reading)
                    }
                    .groupBoxStyle(.card)
                }
            }

            if let yearly = details.yearly {
                YearSection(years: yearly.years) { year in
                    chart(yearly.chart(year))
                }
            }
        }
    }

    @ViewBuilder
    private func value(_ value: StatisticDetails.Value) -> some View {
        switch value {
        case let .trend(recent, before, direction): ValueComparison(recent: recent, before: before, direction: direction)
        case let .recent(reading): ValueComparison(recent: reading)
        case let .overall(reading): ValueRow(title: String(localized: .fieldOverallTitle), reading: reading)
        case let .named(title, reading, footnote): ValueRow(title: title, reading: reading, footnote: footnote)
        }
    }

    @ViewBuilder
    private func chart(_ chart: StatisticDetails.Chart) -> some View {
        switch chart {
        case let .monthly(series, reading): MonthlyChart(series, title: kind.definition.title, reading: reading)
        case let .activeDays(activeDays): ActiveDaysYear(activeDays)
        case let .categories(series): CategoriesChart(series: series)
        case let .progression(progression): ProgressionChart(progression, isYear: true, isSelectable: true).frame(height: 200)
        }
    }
}

private struct MeasurementLogButton: View {
    private let kind: BodyMeasurements.Kind

    private let title: String

    private let latest: Double?

    @Environment(\.units)
    private var units: Units

    @State
    private var isLogging: Bool = false

    init(_ kind: BodyMeasurements.Kind, title: String, latest: Double?) {
        self.kind = kind
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
                    await Health.shared.log(newValue * factor, as: kind)
                }
            }
        )
    }

    private var factor: Double {
        switch kind {
        case .weight: Measurement(value: 1, unit: units.weightUnit).converted(to: .kilograms).value
        case .bodyFat: 0.01
        }
    }

    private var suffix: String {
        switch kind {
        case .weight: units.weightUnit.symbol
        case .bodyFat: "%"
        }
    }

    private var range: ClosedRange<Double> {
        switch kind {
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
