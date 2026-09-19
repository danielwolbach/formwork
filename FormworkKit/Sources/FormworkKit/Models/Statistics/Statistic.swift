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
}

extension Statistic where Value == Double {
    static func completionRate(_ rate: Double?) -> Self {
        Statistic(rate, title: String(localized: .statisticCompletionRateTitle), pictogram: .completed) {
            $0.formatted(.percent.precision(.fractionLength(0)))
        }
    }
}

extension Statistic where Value == Date {
    static func lastCompleted(_ date: Date?, in session: Session?, calendar: Calendar) -> Self {
        let local = session?.localCalendar(from: calendar) ?? calendar

        return Statistic(date, title: String(localized: .statisticLastCompletedTitle), pictogram: .date) { date in
            guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: .now), date < weekAgo else {
                return date.formatted(Date.RelativeFormatStyle(presentation: .named, calendar: calendar, capitalizationContext: .beginningOfSentence))
            }

            let day = session?.started ?? date
            let style = Date.FormatStyle(calendar: local, timeZone: local.timeZone).day().month()
            return local.isDate(day, equalTo: .now, toGranularity: .year) ? day.formatted(style) : day.formatted(style.year())
        }
    }
}

extension Statistic where Value == DateComponents {
    static func typicalStartTime(_ time: DateComponents?, calendar: Calendar) -> Self {
        Statistic(time, title: String(localized: .statisticTypicalStartTimeTitle), pictogram: .time) {
            calendar.date(from: $0)?.formatted(Date.FormatStyle(date: .omitted, time: .shortened, calendar: calendar, timeZone: calendar.timeZone))
        }
    }
}

extension Statistic where Value == Duration {
    static func typicalDuration(_ duration: Duration?) -> Self {
        Statistic(duration, title: String(localized: .statisticTypicalDurationTitle), pictogram: .duration) {
            $0.formatted(.units(allowed: [.hours, .minutes], width: .abbreviated))
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

extension ExerciseTarget {
    var rank: Double {
        switch self {
        case let .weight(target): target.weight.base
        case let .bodyweight(target): Double(target.reps)
        case let .duration(target): target.duration.base
        case let .distance(target): target.distance.base
        }
    }

    var formattedRank: String {
        switch self {
        case let .weight(target): target.weight.formatted
        case let .bodyweight(target): String(localized: .exerciseTargetRepsTitle(target.reps))
        case let .duration(target): target.duration.formatted
        case let .distance(target): target.distance.formatted
        }
    }
}
