//
//  StatisticSummary.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 02.10.26.
//

import Foundation

/// What a statistic shows at a glance, worked out over the window that reads right without a label.
public enum StatisticSummary {
    case reading(Reading?, direction: Direction?)
    case activeDays(ActiveDays)
    case categories(Categories)
    case progression(Progression)
}

extension StatisticSummary {
    static func indicator(_ indicator: some Indicator) -> Self {
        .reading(indicator.reading, direction: nil)
    }

    static func trend(_ trend: Trend<some Metric>) -> Self {
        .reading(trend.recent.reading, direction: trend.direction)
    }
}

extension StatisticKind {
    /// Chart cards cover the span a trend compares, so a sheet's before and recent sum up the card's chart.
    static var chartWeeks: Int {
        (History.recentDays + History.baselineDays) / 7
    }

    public func summary(of history: History) -> StatisticSummary {
        switch self {
        case .lastCompleted: .indicator(LastCompleted(history.allTime))
        case .weekStreak: .indicator(WeekStreak(history.allTime))
        case .weeklySessions: .trend(Trend<WeeklySessions>(history))
        case .typicalDuration: .trend(Trend<TypicalDuration>(history))
        case .typicalStartTime: .indicator(TypicalStartTime(history.recent))
        case .completionRate: .trend(Trend<CompletionRate>(history))
        case .completions: .trend(Trend<Completions>(history))
        case .favoriteWorkout: .indicator(FavoriteWorkout(history.recent))
        case .favoriteExercise: .indicator(FavoriteExercise(history.recent))
        case .mostSkippedExercise: .indicator(MostSkippedExercise(history.recent))
        case .personalBest: .indicator(PersonalBest(history.allTime))
        case .activeDays: .activeDays(ActiveDays(history.weeks(Self.chartWeeks)))
        case .categories: .categories(Categories(history.recent))
        case .progression: .progression(Progression(history.weeks(Self.chartWeeks)))
        case .totalVolume: .trend(Trend<TotalVolume>(history))
        case .oneRepMax: .indicator(OneRepMax(history.allTime))
        case .typicalInterval: .trend(Trend<TypicalInterval>(history))
        }
    }
}
