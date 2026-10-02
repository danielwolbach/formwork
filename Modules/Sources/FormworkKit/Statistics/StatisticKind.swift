//
//  StatisticKind.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 02.10.26.
//

import Foundation

/// Pins persist the raw values, so renaming a case orphans its pins.
public enum StatisticKind: String, Codable, CaseIterable, Sendable {
    case lastCompleted
    case weekStreak
    case weeklySessions
    case typicalDuration
    case typicalStartTime
    case completionRate
    case completions
    case favoriteWorkout
    case favoriteExercise
    case mostSkippedExercise
    case personalBest
    case activeDays
    case categories
    case progression
    case totalVolume
    case oneRepMax
    case typicalInterval
}

extension StatisticKind: Identifiable {
    public var id: Self {
        self
    }
}

extension StatisticKind {
    public var statistic: any Statistic.Type {
        switch self {
        case .lastCompleted: LastCompleted.self
        case .weekStreak: WeekStreak.self
        case .weeklySessions: WeeklySessions.self
        case .typicalDuration: TypicalDuration.self
        case .typicalStartTime: TypicalStartTime.self
        case .completionRate: CompletionRate.self
        case .completions: Completions.self
        case .favoriteWorkout: FavoriteWorkout.self
        case .favoriteExercise: FavoriteExercise.self
        case .mostSkippedExercise: MostSkippedExercise.self
        case .personalBest: PersonalBest.self
        case .activeDays: ActiveDays.self
        case .categories: Categories.self
        case .progression: Progression.self
        case .totalVolume: TotalVolume.self
        case .oneRepMax: OneRepMax.self
        case .typicalInterval: TypicalInterval.self
        }
    }

    public var isChart: Bool {
        !(statistic is any Indicator.Type)
    }
}

extension History.Subject {
    public var statistics: [StatisticKind] {
        switch self {
        case .all:
            [
                .weekStreak,
                .lastCompleted,
                .activeDays,
                .weeklySessions,
                .completions,
                .typicalDuration,
                .typicalStartTime,
                .categories,
                .favoriteWorkout,
                .favoriteExercise,
                .totalVolume,
            ]
        case .workout:
            [
                .lastCompleted,
                .typicalDuration,
                .completionRate,
                .mostSkippedExercise,
                .activeDays,
                .typicalStartTime,
                .completions,
                .typicalInterval,
                .totalVolume,
                .categories,
            ]
        case let .exercise(exercise):
            Self.exerciseStatistics(for: exercise)
        case let .entry(entry):
            Self.exerciseStatistics(for: entry.exercise)
        }
    }

    private static func exerciseStatistics(for exercise: Exercise?) -> [StatisticKind] {
        let weight: [StatisticKind] = exercise?.kind == .weight ? [.oneRepMax, .totalVolume] : []

        return [.lastCompleted, .completionRate, .personalBest, .completions, .typicalDuration, .typicalInterval] + weight + [.progression, .activeDays]
    }
}
