//
//  StatisticKind.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 02.10.26.
//

import Foundation

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
    case typicalHeartRate
    case bodyWeight
    case bodyFat

    public struct Value {
        var reading: (History.Window) -> Reading? = { _ in nil }

        let summary: (History) -> StatisticSummary

        let details: (History, _ title: String) -> StatisticDetails

        var measurement: BodyMeasurements.Kind?

        var isChart = false
    }

    enum Period {
        case recent
        case allTime
    }
}

extension StatisticKind.Period {
    func window(of history: History) -> History.Window {
        switch self {
        case .recent: history.recent
        case .allTime: history.allTime
        }
    }
}

extension StatisticKind.Value {
    static func metric(
        _ unit: Reading.Unit,
        tolerance: Double?,
        card: StatisticKind.Period,
        perSession: Bool,
        _ value: @escaping (History.Window) -> Double?
    ) -> Self {
        let reading = { (window: History.Window) in
            value(window).map { Reading($0, as: unit, of: window.history.subject.exercise?.kind) }
        }

        return Self(
            reading: reading,
            summary: { history in
                switch card {
                case .recent:
                    let trend = Trend(history, tolerance: tolerance, perSession: perSession, value: value)
                    return .reading(trend.recent.map { Reading($0, as: unit, of: history.subject.exercise?.kind) }, direction: trend.direction)
                case .allTime:
                    return .reading(reading(history.allTime), direction: nil)
                }
            },
            details: { history, _ in
                let read = { Reading($0, as: unit, of: history.subject.exercise?.kind) }
                let trend = Trend(history, tolerance: tolerance, perSession: perSession, value: value)
                let comparison: StatisticDetails.Value = if tolerance == nil {
                    .recent(trend.recent.map(read))
                } else {
                    .trend(recent: trend.recent.map(read), before: trend.before.map(read), direction: trend.direction)
                }

                return StatisticDetails(
                    values: [comparison, .overall(reading(history.allTime))],
                    sessions: perSession ? StatisticDetails.Sessions(history, reading: read) { window in
                        window.sessions.sorted { $0.startDate < $1.startDate }.map { ($0.startDate, value(history.session($0))) }
                    } : nil,
                    yearly: StatisticDetails.Yearly(history) { .monthly(Series(history, year: $0, value: value), reading: read) }
                )
            }
        )
    }

    static func indicator(card: StatisticKind.Period, _ reading: @escaping (History.Window) -> Reading?) -> Self {
        Self(
            reading: reading,
            summary: { .reading(reading(card.window(of: $0)), direction: nil) },
            details: { history, title in
                switch card {
                case .recent: StatisticDetails(values: [.recent(reading(history.recent)), .overall(reading(history.allTime))])
                case .allTime: StatisticDetails(values: [.named(title, reading(history.allTime))])
                }
            }
        )
    }

    static func measurement(_ kind: BodyMeasurements.Kind, tolerance: Double) -> Self {
        let read = { Reading($0, as: kind.unit) }
        // Compares the median of the samples recently against the median of the ones before.
        let trendOf = { (history: History) in
            let before = history.baseline.measurements[kind].map(\.value)
            return Trend(recent: history.recent.measurements[kind].map(\.value).median, before: before.median, values: before.count, tolerance: tolerance)
        }

        return Self(
            reading: { $0.measurements[kind].last.map { read($0.value) } },
            summary: { history in
                let latest = history.measurements[kind].last { $0.date < history.interval.end }
                return .reading(latest.map { read($0.value) }, direction: trendOf(history).direction)
            },
            details: { history, _ in
                let trend = trendOf(history)
                // From the year of the first sample, which may be before or after the first session, and only with one.
                let current = history.years.upperBound
                let yearly = history.measurements[kind].first.map { first in
                    let years = min(history.calendar.component(.year, from: first.date), current) ... current

                    return StatisticDetails.Yearly(history, years: years) { year in
                        .monthly(
                            Series(history, year: year, isOnRecord: { $0.measurementInterval.duration > 0 }) { $0.measurements[kind].map(\.value).median },
                            reading: read
                        )
                    }
                }

                return StatisticDetails(
                    values: [.trend(recent: trend.recent.map(read), before: trend.before.map(read), direction: trend.direction)],
                    sessions: StatisticDetails.Sessions(history, reading: read) { $0.measurements[kind].map { ($0.date, $0.value) } },
                    yearly: yearly
                )
            },
            measurement: kind
        )
    }

    static func chart(summary: @escaping (History) -> StatisticSummary, details: @escaping (History) -> StatisticDetails) -> Self {
        Self(summary: summary, details: { history, _ in details(history) }, isChart: true)
    }
}

extension StatisticKind: Identifiable {
    public var id: Self {
        self
    }
}

extension StatisticKind {
    public var definition: Definition<Value> {
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
                value: Value(
                    reading: { .count($0.weekStreak.weeks) },
                    summary: { .reading(.count($0.allTime.weekStreak.weeks), direction: nil) },
                    details: { history, title in
                        let streak = history.allTime.weekStreak

                        return StatisticDetails(values: [
                            .named(
                                title,
                                .count(streak.weeks),
                                footnote: String(localized: streak.isCurrentWeekFulfilled ? .statisticWeekStreakFulfilledSubtitle : .statisticWeekStreakPendingSubtitle)
                            ),
                            .named(String(localized: .statisticLongestWeekStreakTitle), .count(history.allTime.longestWeekStreak)),
                        ])
                    }
                )
            )
        case .weeklySessions:
            Definition(
                title: .statisticWeeklySessionsTitle,
                info: .statisticWeeklySessionsInfo,
                pictogram: .frequency,
                value: .metric(.rate, tolerance: 0.1, card: .recent, perSession: false) { $0.weeklySessions }
            )
        case .typicalDuration:
            Definition(
                title: .statisticTypicalDurationTitle,
                info: .statisticTypicalDurationInfo,
                pictogram: .duration,
                value: .metric(.duration, tolerance: 0.05, card: .recent, perSession: true) { $0.typicalDuration }
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
                value: .metric(.percent, tolerance: 0.05, card: .recent, perSession: true) { $0.completionRate }
            )
        case .completions:
            Definition(
                title: .statisticCompletionsTitle,
                info: .statisticCompletionsInfo,
                pictogram: .tally,
                value: .metric(.count, tolerance: nil, card: .recent, perSession: false) { Double($0.completionCount) }
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
                value: .metric(.rank, tolerance: nil, card: .allTime, perSession: true) { $0.personalBest?.rank }
            )
        case .activeDays:
            Definition(
                title: .statisticActiveDaysTitle,
                info: .statisticActiveDaysInfo,
                pictogram: .activity,
                value: .chart(
                    summary: { .activeDays(ActiveDays($0.weeks(History.comparedWeeks))) },
                    details: { history in
                        StatisticDetails(yearly: StatisticDetails.Yearly(history) { .activeDays(ActiveDays(history.year($0))) })
                    }
                )
            )
        case .categories:
            Definition(
                title: .statisticCategoriesTitle,
                info: .statisticCategoriesInfo,
                pictogram: .categories,
                value: .chart(
                    summary: { .categories(Categories($0.recent)) },
                    details: { history in
                        StatisticDetails(
                            categories: (Categories(history.recent), Categories(history.allTime)),
                            yearly: StatisticDetails.Yearly(history) { .categories(Series(history, year: $0, value: Categories.init)) }
                        )
                    }
                )
            )
        case .progression:
            Definition(
                title: .statisticProgressionTitle,
                info: .statisticProgressionInfo,
                pictogram: .progression,
                value: .chart(
                    summary: { .progression(Progression($0.weeks(History.comparedWeeks))) },
                    details: { history in
                        let read = { Reading(rank: $0, of: history.subject.exercise?.kind) }
                        let trend = Trend(history, tolerance: 0.02, perSession: false) { $0.typicalBest?.rank }

                        return StatisticDetails(
                            values: [
                                .trend(recent: trend.recent.map(read), before: trend.before.map(read), direction: trend.direction),
                                .overall(StatisticKind.personalBest.reading(in: history.allTime)),
                            ],
                            yearly: StatisticDetails.Yearly(history) { .progression(Progression(history.year($0))) }
                        )
                    }
                )
            )
        case .totalVolume:
            Definition(
                title: .statisticTotalVolumeTitle,
                info: .statisticTotalVolumeInfo,
                pictogram: .volume,
                value: .metric(.weight, tolerance: nil, card: .recent, perSession: true) { $0.totalVolume }
            )
        case .oneRepMax:
            Definition(
                title: .statisticOneRepMaxTitle,
                info: .statisticOneRepMaxInfo,
                pictogram: .strength,
                value: .metric(.weight, tolerance: 0.02, card: .allTime, perSession: true) { $0.oneRepMax }
            )
        case .typicalInterval:
            Definition(
                title: .statisticTypicalIntervalTitle,
                info: .statisticTypicalIntervalInfo,
                pictogram: .frequency,
                value: .metric(.days, tolerance: 0.1, card: .recent, perSession: false) { $0.typicalInterval }
            )
        case .typicalHeartRate:
            Definition(
                title: .statisticTypicalHeartRateTitle,
                info: .statisticTypicalHeartRateInfo,
                pictogram: .heartRate,
                value: .metric(.heartRate, tolerance: 0.05, card: .recent, perSession: true) { $0.typicalHeartRate }
            )
        case .bodyWeight:
            Definition(
                title: .statisticBodyWeightTitle,
                info: .statisticBodyWeightInfo,
                pictogram: .bodyWeight,
                value: .measurement(.weight, tolerance: 0.01)
            )
        case .bodyFat:
            Definition(
                title: .statisticBodyFatTitle,
                info: .statisticBodyFatInfo,
                pictogram: .bodyFat,
                value: .measurement(.bodyFat, tolerance: 0.03)
            )
        }
    }

    public var isChart: Bool {
        definition.value.isChart
    }

    public var measurement: BodyMeasurements.Kind? {
        definition.value.measurement
    }

    public func isShown(in history: History, isHealthConnected: Bool) -> Bool {
        measurement.map { isHealthConnected || !history.measurements[$0].isEmpty } ?? true
    }

    public func summary(of history: History) -> StatisticSummary {
        definition.value.summary(history)
    }

    public func details(of history: History) -> StatisticDetails {
        let definition = definition
        return definition.value.details(history, definition.title)
    }

    func reading(in window: History.Window) -> Reading? {
        definition.value.reading(window)
    }
}

extension History.Subject {
    public var statistics: [StatisticKind] {
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
                .typicalHeartRate,
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
