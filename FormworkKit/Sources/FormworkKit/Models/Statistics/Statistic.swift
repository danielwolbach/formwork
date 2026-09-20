//
//  Statistic.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 19.09.26.
//

import Foundation

public struct Statistic<Value> {
    public let pictogram: Pictogram
    public let title: String
    public let subtitle: String?
    public let value: Value?

    init(_ value: Value?, title: String, pictogram: Pictogram, format: (Value) -> String?) {
        self.value = value
        self.title = title
        self.pictogram = pictogram
        self.subtitle = value.flatMap(format)
    }
}

extension Statistic where Value == Int {
    static func completions(_ count: Int) -> Self {
        Statistic(count, title: String(localized: .statisticCompletionsTitle), pictogram: .tally) {
            $0.formatted()
        }
    }

    static func weekStreak(_ count: Int) -> Self {
        Statistic(count, title: String(localized: .statisticWeekStreakTitle), pictogram: .streak) {
            $0.formatted()
        }
    }

    static func longestWeekStreak(_ count: Int) -> Self {
        Statistic(count, title: String(localized: .statisticLongestWeekStreakTitle), pictogram: .record) {
            $0.formatted()
        }
    }

    static func completedExercises(_ count: Int) -> Self {
        Statistic(count, title: String(localized: .statisticCompletedExercisesTitle), pictogram: .completed) {
            $0.formatted()
        }
    }
}

extension Statistic where Value == Quantity {
    static func totalVolume(_ volume: Quantity?) -> Self {
        Statistic(volume, title: String(localized: .statisticTotalVolumeTitle), pictogram: .volume) {
            $0.formatted
        }
    }
}

extension Statistic where Value == Double {
    static func completionRate(_ rate: Double?) -> Self {
        Statistic(rate, title: String(localized: .statisticCompletionRateTitle), pictogram: .completed) {
            $0.formatted(.percent.precision(.fractionLength(0)))
        }
    }

    static func sessionsPerWeek(_ rate: Double?) -> Self {
        Statistic(rate, title: String(localized: .statisticSessionsPerWeekTitle), pictogram: .frequency) {
            $0.formatted(.number.precision(.fractionLength(0 ... 1)))
        }
    }

    static func skipRate(_ rate: Double?) -> Self {
        Statistic(rate, title: String(localized: .statisticSkipRateTitle), pictogram: .skipped) {
            $0.formatted(.percent.precision(.fractionLength(0)))
        }
    }
}

extension Statistic where Value == Date {
    static func lastCompleted(_ date: Date?, in session: Session?, calendar: Calendar) -> Self {
        let local = session?.localCalendar(from: calendar) ?? calendar

        return Statistic(date, title: String(localized: .statisticLastCompletedTitle), pictogram: .date) { date in
            guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: .now), date < weekAgo else {
                var style = Date.RelativeFormatStyle(presentation: .named, calendar: calendar, capitalizationContext: .beginningOfSentence)
                style.allowedFields = [.day]
                return date.formatted(style)
            }

            let day = session?.started ?? date
            let style = local.formatStyle().day().month()
            return local.isDate(day, equalTo: .now, toGranularity: .year) ? day.formatted(style) : day.formatted(style.year())
        }
    }

    static func endTime(_ date: Date?, in session: Session?, calendar: Calendar) -> Self {
        let local = session?.localCalendar(from: calendar) ?? calendar

        return Statistic(date, title: String(localized: .statisticEndTimeTitle), pictogram: .time) {
            $0.formatted(local.formatStyle(time: .shortened))
        }
    }
}

extension Statistic where Value == DateComponents {
    static func typicalStartTime(_ time: DateComponents?, calendar: Calendar) -> Self {
        Statistic(time, title: String(localized: .statisticTypicalStartTimeTitle), pictogram: .time) {
            calendar.date(from: $0)?.formatted(calendar.formatStyle(time: .shortened))
        }
    }
}

extension Statistic where Value == Duration {
    static func typicalDuration(_ duration: Duration?) -> Self {
        Statistic(duration, title: String(localized: .statisticTypicalDurationTitle), pictogram: .duration) {
            $0.formatted(.sessionDuration)
        }
    }

    static func duration(_ duration: Duration?) -> Self {
        Statistic(duration, title: String(localized: .statisticDurationTitle), pictogram: .duration) {
            $0.formatted(.sessionDuration)
        }
    }

    static func medianExerciseDuration(_ duration: Duration?) -> Self {
        Statistic(duration, title: String(localized: .statisticMedianExerciseDurationTitle), pictogram: .pace) {
            $0.formatted(.exerciseDuration)
        }
    }
}

extension Statistic where Value == Exercise {
    static func mostSkipped(_ exercise: Exercise?) -> Self {
        Statistic(exercise, title: String(localized: .statisticMostSkippedTitle), pictogram: .skipped) {
            $0.title
        }
    }
}

extension Statistic where Value == ExerciseTarget {
    static func personalBest(_ target: ExerciseTarget?) -> Self {
        Statistic(target, title: String(localized: .statisticPersonalBestTitle), pictogram: .record) {
            $0.formattedRank
        }
    }
}
