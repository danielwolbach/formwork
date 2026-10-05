//
//  StatisticDetails.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 02.10.26.
//

import Foundation

/// What a statistic's sheet shows, top to bottom: its values, the category breakdowns, and a chart paged by year.
public struct StatisticDetails {
    public enum Value: Hashable {
        /// Recent against before; `before` is nil while there isn't enough history to compare.
        case trend(recent: Reading?, before: Reading?, direction: Trend.Direction?)
        case recent(Reading?)
        case overall(Reading?)
        case named(String, Reading?, footnote: String? = nil)
    }

    public enum Chart {
        case monthly(Series<Double?>, reading: (Double) -> Reading)
        case activeDays(ActiveDays)
        case categories(Series<Categories>)
        case progression(Progression)
    }

    public struct Yearly {
        public let years: ClosedRange<Int>

        /// Works out one year at a time, so only the year on screen is computed.
        public let chart: (Int) -> Chart

        init(_ history: History, chart: @escaping (Int) -> Chart) {
            self.years = history.years
            self.chart = chart
        }
    }

    public let values: [Value]

    public let categories: (recent: Categories, overall: Categories)?

    public let yearly: Yearly?

    init(values: [Value] = [], categories: (recent: Categories, overall: Categories)? = nil, yearly: Yearly? = nil) {
        self.values = values
        self.categories = categories
        self.yearly = yearly
    }
}

extension StatisticKind {
    public func details(of history: History) -> StatisticDetails {
        let allTime = history.allTime

        switch self {
        case .weekStreak:
            return StatisticDetails(values: [
                .named(
                    definition.title,
                    .count(allTime.weekStreak.weeks),
                    footnote: String(localized: allTime.weekStreak.isCurrentWeekFulfilled ? .statisticWeekStreakFulfilledSubtitle : .statisticWeekStreakPendingSubtitle)
                ),
                .named(String(localized: .statisticLongestWeekStreakTitle), .count(allTime.longestWeekStreak)),
            ])
        case .activeDays:
            return StatisticDetails(yearly: StatisticDetails.Yearly(history) { .activeDays(ActiveDays(history.year($0))) })
        case .categories:
            return StatisticDetails(
                categories: (Categories(history.recent), Categories(allTime)),
                yearly: StatisticDetails.Yearly(history) { .categories(Series(history, year: $0, value: Categories.init)) }
            )
        case .progression:
            let read = { Reading(rank: $0, of: history.subject.exercise?.kind) }
            let trend = Trend(history, tolerance: 0.02) { $0.typicalBest?.rank }

            return StatisticDetails(
                values: [
                    .trend(recent: trend.recent.map(read), before: trend.before.map(read), direction: trend.direction),
                    .overall(StatisticKind.personalBest.reading(in: allTime)),
                ],
                yearly: StatisticDetails.Yearly(history) { .progression(Progression(history.year($0))) }
            )
        default:
            return valueDetails(of: history)
        }
    }

    private func valueDetails(of history: History) -> StatisticDetails {
        switch definition.value {
        case let .metric(unit, tolerance, _, value):
            let read = { Reading($0, as: unit, of: history.subject.exercise?.kind) }
            let trend = Trend(history, tolerance: tolerance, value: value)
            let comparison: StatisticDetails.Value = if tolerance == nil {
                .recent(trend.recent.map(read))
            } else {
                .trend(recent: trend.recent.map(read), before: trend.before.map(read), direction: trend.direction)
            }

            return StatisticDetails(
                values: [comparison, .overall(reading(in: history.allTime))],
                yearly: StatisticDetails.Yearly(history) { .monthly(Series(history, year: $0, value: value), reading: read) }
            )
        case .indicator(card: .recent, _):
            return StatisticDetails(values: [.recent(reading(in: history.recent)), .overall(reading(in: history.allTime))])
        case .indicator(card: .allTime, _):
            return StatisticDetails(values: [.named(definition.title, reading(in: history.allTime))])
        case .chart:
            preconditionFailure("\(self) describes its own chart.")
        }
    }
}
