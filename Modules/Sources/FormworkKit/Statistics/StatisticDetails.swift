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
        case trend(recent: Reading?, before: Reading?, direction: Direction?)
        case recent(Reading?)
        case overall(Reading?)
        case named(String, Reading?)
    }

    public enum Chart {
        case monthly(MonthlyBars)
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

    /// A metric's `Series` without the metric's type, so a view can draw any of them.
    public struct MonthlyBars {
        public struct Bar {
            public let month: Date

            public let value: Double?
        }

        public let period: DateInterval

        public let bars: [Bar]

        public let reading: (Double) -> Reading
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

extension StatisticDetails {
    static func metric<M: Metric>(_: M.Type, of history: History) -> Self {
        let overall = M(history.allTime)

        return StatisticDetails(
            values: [.trend(Trend<M>(history)), .overall(overall.reading)],
            yearly: Yearly(history) { .monthly(MonthlyBars(Series<M>(history, year: $0), reading: overall.reading(of:))) }
        )
    }

    static func indicator<I: Indicator>(_: I.Type, of history: History) -> Self {
        StatisticDetails(values: [.recent(I(history.recent).reading), .overall(I(history.allTime).reading)])
    }
}

extension StatisticDetails.Value {
    /// A metric that never compares shows its recent value alone.
    static func trend<M: Metric>(_ trend: Trend<M>) -> Self {
        guard M.tolerance != nil else {
            return .recent(trend.recent.reading)
        }

        return .trend(recent: trend.recent.reading, before: trend.baseline?.reading, direction: trend.direction)
    }

    static func named<I: Indicator>(_ indicator: I) -> Self {
        .named(I.title, indicator.reading)
    }
}

extension StatisticDetails.MonthlyBars {
    init(_ series: Series<some Metric>, reading: @escaping (Double) -> Reading) {
        self.init(period: series.period, bars: series.bars.map { Bar(month: $0.month, value: $0.statistic.value) }, reading: reading)
    }
}

extension StatisticDetails.MonthlyBars.Bar: Identifiable {
    public var id: Date {
        month
    }
}

extension StatisticKind {
    public func details(of history: History) -> StatisticDetails {
        switch self {
        case .lastCompleted:
            StatisticDetails(values: [.named(LastCompleted(history.allTime))])
        case .weekStreak:
            StatisticDetails(values: [.named(WeekStreak(history.allTime)), .named(LongestWeekStreak(history.allTime))])
        case .weeklySessions:
            .metric(WeeklySessions.self, of: history)
        case .typicalDuration:
            .metric(TypicalDuration.self, of: history)
        case .typicalStartTime:
            .indicator(TypicalStartTime.self, of: history)
        case .completionRate:
            .metric(CompletionRate.self, of: history)
        case .completions:
            .metric(Completions.self, of: history)
        case .favoriteWorkout:
            .indicator(FavoriteWorkout.self, of: history)
        case .favoriteExercise:
            .indicator(FavoriteExercise.self, of: history)
        case .mostSkippedExercise:
            .indicator(MostSkippedExercise.self, of: history)
        case .personalBest:
            .metric(PersonalBest.self, of: history)
        case .activeDays:
            StatisticDetails(yearly: StatisticDetails.Yearly(history) { .activeDays(ActiveDays(history.year($0))) })
        case .categories:
            StatisticDetails(
                categories: (Categories(history.recent), Categories(history.allTime)),
                yearly: StatisticDetails.Yearly(history) { .categories(Series(history, year: $0)) }
            )
        case .progression:
            StatisticDetails(
                values: [.trend(Trend<TypicalBest>(history)), .overall(PersonalBest(history.allTime).reading)],
                yearly: StatisticDetails.Yearly(history) { .progression(Progression(history.year($0))) }
            )
        case .totalVolume:
            .metric(TotalVolume.self, of: history)
        case .oneRepMax:
            .metric(OneRepMax.self, of: history)
        case .typicalInterval:
            .metric(TypicalInterval.self, of: history)
        }
    }
}
