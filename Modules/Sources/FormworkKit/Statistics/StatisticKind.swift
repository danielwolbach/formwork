//
//  StatisticKind.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 02.10.26.
//

import Foundation

/// Raw values are meant to identify pinned statistics once pins come back, so keep them stable.
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

    /// Everything a statistic brings of its own. Cards and sheets follow from its `value`.
    public struct Definition {
        enum Value {
            /// A number that compares recent against before (unless `tolerance` is nil) and charts by month.
            case metric(Reading.Unit, tolerance: Double?, card: Period, (History.Window) -> Double?)
            case indicator(card: Period, (History.Window) -> Reading?)
            /// Draws its own card and sheet.
            case chart
        }

        /// What a card shows without a label: habits read right over recent days, records over all time.
        enum Period {
            case recent
            case allTime
        }

        public let pictogram: Pictogram

        let value: Value

        private let titleResource: LocalizedStringResource

        private let infoResource: LocalizedStringResource

        init(title: LocalizedStringResource, info: LocalizedStringResource, pictogram: Pictogram, value: Value) {
            self.pictogram = pictogram
            self.value = value
            self.titleResource = title
            self.infoResource = info
        }
    }
}

extension StatisticKind.Definition {
    public var title: String {
        String(localized: titleResource)
    }

    public var info: String {
        String(localized: infoResource)
    }
}

extension StatisticKind.Definition.Period {
    func window(of history: History) -> History.Window {
        switch self {
        case .recent: history.recent
        case .allTime: history.allTime
        }
    }
}

extension StatisticKind: Identifiable {
    public var id: Self {
        self
    }
}

extension StatisticKind {
    public var definition: Definition {
        switch self {
        case .lastCompleted:
            Definition(
                title: .statisticLastCompletedTitle,
                info: .statisticLastCompletedInfo,
                pictogram: .date,
                value: .indicator(card: .allTime) { window in
                    // The day it started on its own clock, like the rest of the app shows sessions.
                    window.lastCompletion.map { .day($0.session.startDate, calendar: $0.session.localCalendar(from: window.history.calendar)) }
                }
            )
        case .weekStreak:
            Definition(
                title: .statisticWeekStreakTitle,
                info: .statisticWeekStreakInfo,
                pictogram: .streak,
                value: .indicator(card: .allTime) { .count($0.weekStreak.weeks) }
            )
        case .weeklySessions:
            Definition(
                title: .statisticWeeklySessionsTitle,
                info: .statisticWeeklySessionsInfo,
                pictogram: .frequency,
                value: .metric(.rate, tolerance: 0.1, card: .recent) { $0.weeklySessions }
            )
        case .typicalDuration:
            Definition(
                title: .statisticTypicalDurationTitle,
                info: .statisticTypicalDurationInfo,
                pictogram: .duration,
                value: .metric(.duration, tolerance: 0.05, card: .recent) { $0.typicalDuration }
            )
        case .typicalStartTime:
            Definition(
                title: .statisticTypicalStartTimeTitle,
                info: .statisticTypicalStartTimeInfo,
                pictogram: .time,
                value: .indicator(card: .recent) { window in
                    window.typicalStartTime.flatMap { Reading(minuteOfDay: $0, in: window.history.calendar) }
                }
            )
        case .completionRate:
            Definition(
                title: .statisticCompletionRateTitle,
                info: .statisticCompletionRateInfo,
                pictogram: .completed,
                value: .metric(.percent, tolerance: 0.05, card: .recent) { $0.completionRate }
            )
        case .completions:
            Definition(
                title: .statisticCompletionsTitle,
                info: .statisticCompletionsInfo,
                pictogram: .tally,
                value: .metric(.count, tolerance: nil, card: .recent) { Double($0.completionCount) }
            )
        case .favoriteWorkout:
            Definition(
                title: .statisticFavoriteWorkoutTitle,
                info: .statisticFavoriteWorkoutInfo,
                pictogram: .workout,
                value: .indicator(card: .recent) { $0.favoriteWorkout.map { .name($0.title) } }
            )
        case .favoriteExercise:
            Definition(
                title: .statisticFavoriteExerciseTitle,
                info: .statisticFavoriteExerciseInfo,
                pictogram: .exercise,
                value: .indicator(card: .recent) { $0.favoriteExercise.map { .name($0.title) } }
            )
        case .mostSkippedExercise:
            Definition(
                title: .statisticMostSkippedExerciseTitle,
                info: .statisticMostSkippedExerciseInfo,
                pictogram: .skipped,
                value: .indicator(card: .recent) { $0.mostSkippedExercise.map { .name($0.title) } }
            )
        case .personalBest:
            Definition(
                title: .statisticPersonalBestTitle,
                info: .statisticPersonalBestInfo,
                pictogram: .record,
                value: .metric(.rank, tolerance: nil, card: .allTime) { $0.personalBest?.rank }
            )
        case .activeDays:
            Definition(
                title: .statisticActiveDaysTitle,
                info: .statisticActiveDaysInfo,
                pictogram: .activity,
                value: .chart
            )
        case .categories:
            Definition(
                title: .statisticCategoriesTitle,
                info: .statisticCategoriesInfo,
                pictogram: .categories,
                value: .chart
            )
        case .progression:
            Definition(
                title: .statisticProgressionTitle,
                info: .statisticProgressionInfo,
                pictogram: .progression,
                value: .chart
            )
        case .totalVolume:
            Definition(
                title: .statisticTotalVolumeTitle,
                info: .statisticTotalVolumeInfo,
                pictogram: .volume,
                value: .metric(.weight, tolerance: nil, card: .recent) { $0.totalVolume }
            )
        case .oneRepMax:
            Definition(
                title: .statisticOneRepMaxTitle,
                info: .statisticOneRepMaxInfo,
                pictogram: .strength,
                value: .metric(.weight, tolerance: 0.02, card: .allTime) { $0.oneRepMax }
            )
        case .typicalInterval:
            Definition(
                title: .statisticTypicalIntervalTitle,
                info: .statisticTypicalIntervalInfo,
                pictogram: .frequency,
                value: .metric(.days, tolerance: 0.1, card: .recent) { $0.typicalInterval }
            )
        }
    }

    public var isChart: Bool {
        if case .chart = definition.value {
            return true
        }

        return false
    }

    func reading(in window: History.Window) -> Reading? {
        switch definition.value {
        case let .metric(unit, _, _, value): value(window).map { Reading($0, as: unit, of: window.history.subject.exercise?.kind) }
        case let .indicator(_, reading): reading(window)
        case .chart: nil
        }
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
