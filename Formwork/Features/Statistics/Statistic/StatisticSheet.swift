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

        DetailSheet(definition.pictogram, title: definition.title, subtitle: history.subject.title, info: definition.info) {
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
                SectionView(.fieldRecentTitle, subtitle: .init(localized: .fieldRecentSubtitle(days: History.recentDays))) {
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
