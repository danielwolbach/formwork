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
        let statistic = kind.statistic
        let details = kind.details(of: history)

        DetailSheet(statistic.pictogram, title: statistic.title, subtitle: history.subject.title, info: statistic.info) {
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
            }

            if let categories = details.categories {
                SectionView(.init(localized: .fieldRecentTitle), subtitle: .init(localized: .fieldRecentSubtitle(days: History.recentDays))) {
                    GroupBox {
                        CategoriesBreakdown(categories.recent)
                    }
                    .groupBoxStyle(.card)
                }

                SectionView(.init(localized: .fieldOverallTitle)) {
                    GroupBox {
                        CategoriesBreakdown(categories.overall)
                    }
                    .groupBoxStyle(.card)
                }
            }

            if let yearly = details.yearly {
                YearSection(years: yearly.years) { year in
                    chart(yearly.chart(year))
                }
            }
        } accessory: {
            StatisticPinControl(kind, of: history.subject) { isPinned in
                Toggle(.pin, isOn: isPinned)
                    .symbolVariant(isPinned.wrappedValue ? .fill : .none)
                    .labelStyle(.iconOnly)
                    .toggleStyle(.button)
                    .buttonStyle(.cardProminent)
                    .buttonBorderShape(.circle)
                    .sensoryFeedback(.selection, trigger: isPinned.wrappedValue)
            }
        }
    }

    @ViewBuilder
    private func value(_ value: StatisticDetails.Value) -> some View {
        switch value {
        case let .trend(recent, before, direction): ValueComparison(recent: recent, before: before, direction: direction)
        case let .recent(reading): ValueComparison(recent: reading)
        case let .overall(reading): ValueRow(title: String(localized: .fieldOverallTitle), reading: reading)
        case let .named(title, reading): ValueRow(title: title, reading: reading)
        }
    }

    @ViewBuilder
    private func chart(_ chart: StatisticDetails.Chart) -> some View {
        switch chart {
        case let .monthly(monthly): MonthlyChart(monthly)
        case let .activeDays(activeDays): ActiveDaysYear(activeDays)
        case let .categories(series): CategoriesChart(series: series)
        case let .progression(progression): ProgressionChart(progression, isYear: true).frame(height: 200)
        }
    }
}

#Preview("Streak") {
    NavigationStack {}
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
                StatisticSheet(.weekStreak, of: History(.all, among: Samples.sessions))
            }
            .presentationDetents([.medium, .large])
        }
        .sampleData()
}

#Preview("Indicator") {
    NavigationStack {}
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
                StatisticSheet(.typicalStartTime, of: History(.all, among: Samples.sessions))
            }
            .presentationDetents([.medium, .large])
        }
        .sampleData()
}

#Preview("Categories") {
    NavigationStack {}
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
                StatisticSheet(.categories, of: History(.all, among: Samples.sessions))
            }
            .presentationDetents([.medium, .large])
        }
        .sampleData()
}

#Preview("Progression") {
    NavigationStack {}
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
                StatisticSheet(.progression, of: History(.exercise(Samples.exercises[2]), among: Samples.sessions))
            }
            .presentationDetents([.medium, .large])
        }
        .sampleData()
}
