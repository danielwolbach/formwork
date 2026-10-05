//
//  StatisticSummary.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 02.10.26.
//

import Foundation

/// What a statistic shows at a glance, worked out over the window that reads right without a label.
public enum StatisticSummary {
    case reading(Reading?, direction: Trend.Direction?)
    case activeDays(ActiveDays)
    case categories(Categories)
    case progression(Progression)
}

extension StatisticKind {
    /// Chart cards cover the span a trend compares, so a sheet's before and recent sum up the card's chart.
    static var chartWeeks: Int {
        (History.recentDays + History.baselineDays) / 7
    }

    public func summary(of history: History) -> StatisticSummary {
        switch definition.value {
        case let .metric(unit, tolerance, .recent, value):
            let trend = Trend(history, tolerance: tolerance, value: value)
            return .reading(trend.recent.map { Reading($0, as: unit, of: history.subject.exercise?.kind) }, direction: trend.direction)
        case let .metric(_, _, card, _), let .indicator(card, _):
            return .reading(reading(in: card.window(of: history)), direction: nil)
        case .chart:
            return chartSummary(of: history)
        }
    }

    private func chartSummary(of history: History) -> StatisticSummary {
        switch self {
        case .activeDays: .activeDays(ActiveDays(history.weeks(Self.chartWeeks)))
        case .categories: .categories(Categories(history.recent))
        case .progression: .progression(Progression(history.weeks(Self.chartWeeks)))
        default: preconditionFailure("\(self) has no chart.")
        }
    }
}
