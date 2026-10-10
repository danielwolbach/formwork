//
//  Statistic.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 02.10.26.
//

import Foundation

public enum Statistic: String, Codable, CaseIterable, Sendable {
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
    case bodyWeight
    case bodyFat

    public enum Kind {
        case formula(Formula, tolerance: Double?)
        case measurement(BodyMeasurement, tolerance: Double)
        case streak
        case activeDays
        case categories
        case progression
    }
}

extension Statistic: Identifiable {
    public var id: Self {
        self
    }
}

extension Statistic: Describable {
    public var title: String {
        switch self {
        case .lastCompleted: String(localized: .statisticLastCompletedTitle)
        case .weekStreak: String(localized: .statisticWeekStreakTitle)
        case .weeklySessions: String(localized: .statisticWeeklySessionsTitle)
        case .typicalDuration: String(localized: .statisticTypicalDurationTitle)
        case .typicalStartTime: String(localized: .statisticTypicalStartTimeTitle)
        case .completionRate: String(localized: .statisticCompletionRateTitle)
        case .completions: String(localized: .statisticCompletionsTitle)
        case .favoriteWorkout: String(localized: .statisticFavoriteWorkoutTitle)
        case .favoriteExercise: String(localized: .statisticFavoriteExerciseTitle)
        case .mostSkippedExercise: String(localized: .statisticMostSkippedExerciseTitle)
        case .personalBest: String(localized: .statisticPersonalBestTitle)
        case .activeDays: String(localized: .statisticActiveDaysTitle)
        case .categories: String(localized: .statisticCategoriesTitle)
        case .progression: String(localized: .statisticProgressionTitle)
        case .totalVolume: String(localized: .statisticTotalVolumeTitle)
        case .oneRepMax: String(localized: .statisticOneRepMaxTitle)
        case .typicalInterval: String(localized: .statisticTypicalIntervalTitle)
        case .bodyWeight: String(localized: .statisticBodyWeightTitle)
        case .bodyFat: String(localized: .statisticBodyFatTitle)
        }
    }

    public var info: String {
        switch self {
        case .lastCompleted: String(localized: .statisticLastCompletedInfo)
        case .weekStreak: String(localized: .statisticWeekStreakInfo)
        case .weeklySessions: String(localized: .statisticWeeklySessionsInfo)
        case .typicalDuration: String(localized: .statisticTypicalDurationInfo)
        case .typicalStartTime: String(localized: .statisticTypicalStartTimeInfo)
        case .completionRate: String(localized: .statisticCompletionRateInfo)
        case .completions: String(localized: .statisticCompletionsInfo)
        case .favoriteWorkout: String(localized: .statisticFavoriteWorkoutInfo)
        case .favoriteExercise: String(localized: .statisticFavoriteExerciseInfo)
        case .mostSkippedExercise: String(localized: .statisticMostSkippedExerciseInfo)
        case .personalBest: String(localized: .statisticPersonalBestInfo)
        case .activeDays: String(localized: .statisticActiveDaysInfo)
        case .categories: String(localized: .statisticCategoriesInfo)
        case .progression: String(localized: .statisticProgressionInfo)
        case .totalVolume: String(localized: .statisticTotalVolumeInfo)
        case .oneRepMax: String(localized: .statisticOneRepMaxInfo)
        case .typicalInterval: String(localized: .statisticTypicalIntervalInfo)
        case .bodyWeight: String(localized: .statisticBodyWeightInfo)
        case .bodyFat: String(localized: .statisticBodyFatInfo)
        }
    }

    public var pictogram: Pictogram {
        switch self {
        case .lastCompleted: .date
        case .weekStreak: .streak
        case .weeklySessions, .typicalInterval: .frequency
        case .typicalDuration: .duration
        case .typicalStartTime: .time
        case .completionRate: .completed
        case .completions: .tally
        case .favoriteWorkout: .workout
        case .favoriteExercise: .exercise
        case .mostSkippedExercise: .skipped
        case .personalBest: .record
        case .activeDays: .activity
        case .categories: .categories
        case .progression: .progression
        case .totalVolume: .volume
        case .oneRepMax: .strength
        case .bodyWeight: .bodyWeight
        case .bodyFat: .bodyFat
        }
    }
}

extension Statistic {
    public var kind: Kind {
        switch self {
        case .lastCompleted: .formula(.latest, tolerance: nil)
        case .completions: .formula(.count, tolerance: nil)
        case .weeklySessions: .formula(.perWeek, tolerance: 0.1)
        case .typicalInterval: .formula(.typicalGap, tolerance: 0.1)
        case .typicalDuration: .formula(.typical(.duration), tolerance: 0.05)
        case .typicalStartTime: .formula(.typical(.startTime), tolerance: nil)
        case .completionRate: .formula(.share(.completedExercises, of: .plannedExercises), tolerance: 0.05)
        case .totalVolume: .formula(.total(.volume), tolerance: nil)
        case .personalBest: .formula(.maximum(.best), tolerance: nil)
        case .oneRepMax: .formula(.maximum(.oneRepMax), tolerance: 0.02)
        case .favoriteWorkout: .formula(.mostFrequent(.workout), tolerance: nil)
        case .favoriteExercise: .formula(.mostFrequent(.exercise), tolerance: nil)
        case .mostSkippedExercise: .formula(.mostFrequent(.skippedExercise), tolerance: nil)
        case .bodyWeight: .measurement(.weight, tolerance: 0.01)
        case .bodyFat: .measurement(.bodyFat, tolerance: 0.03)
        case .weekStreak: .streak
        case .activeDays: .activeDays
        case .categories: .categories
        case .progression: .progression
        }
    }

    public var isChart: Bool {
        switch kind {
        case .formula, .measurement, .streak: false
        case .activeDays, .categories, .progression: true
        }
    }

    public func isShown(in history: History, isHealthConnected: Bool) -> Bool {
        guard case let .measurement(measurement, _) = kind else {
            return true
        }

        return isHealthConnected || !(history.measurements[measurement] ?? []).isEmpty
    }

    /// What its card shows, or nil for a chart.
    public func reading(in history: History) -> Reading? {
        switch kind {
        case let .formula(formula, _): (formula.isRecord ? history.allTime : history.recent).reading(formula)
        case let .measurement(measurement, _): history.body.latest(measurement).map { Reading($0.value, as: measurement.unit) }
        case .streak: .count(history.allTime.streak.weeks)
        case .activeDays, .categories, .progression: nil
        }
    }

    public func direction(in history: History) -> Comparison.Direction? {
        switch kind {
        case let .formula(formula, tolerance): formula.isRecord ? nil : history.comparison(formula, tolerance: tolerance).direction
        case let .measurement(measurement, tolerance): history.body.comparison(measurement, tolerance: tolerance).direction
        case .streak, .activeDays, .categories, .progression: nil
        }
    }
}

extension History.Subject {
    public var statistics: [Statistic] {
        switch self {
        case .all:
            [
                .weekStreak,
                .lastCompleted,
                .bodyWeight,
                .bodyFat,
                .activeDays,
                .weeklySessions,
                .completions,
                .typicalDuration,
                .typicalStartTime,
                .categories,
                .favoriteWorkout,
                .favoriteExercise,
                .mostSkippedExercise,
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

    private static func exerciseStatistics(for exercise: Exercise?) -> [Statistic] {
        let weight: [Statistic] = exercise?.kind == .weight ? [.oneRepMax, .totalVolume] : []

        return [.lastCompleted, .completionRate, .personalBest, .completions, .typicalDuration, .typicalInterval] + weight + [.progression, .activeDays]
    }
}
