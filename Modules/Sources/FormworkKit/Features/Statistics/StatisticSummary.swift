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
    public func summary(of history: History) -> StatisticSummary {
        switch definition.value {
        case let .metric(unit, tolerance, .recent, perSession, value):
            let trend = Trend(history, tolerance: tolerance, perSession: perSession, value: value)
            return .reading(trend.recent.map { Reading($0, as: unit, of: history.subject.exercise?.kind) }, direction: trend.direction)
        case let .metric(_, _, card, _, _), let .indicator(card, _):
            return .reading(reading(in: card.window(of: history)), direction: nil)
        case .chart:
            return chartSummary(of: history)
        }
    }

    private func chartSummary(of history: History) -> StatisticSummary {
        switch self {
        case .activeDays: .activeDays(ActiveDays(history.weeks(History.comparedWeeks)))
        case .categories: .categories(Categories(history.recent))
        case .progression: .progression(Progression(history.weeks(History.comparedWeeks)))
        default: preconditionFailure("\(self) has no chart.")
        }
    }
}
