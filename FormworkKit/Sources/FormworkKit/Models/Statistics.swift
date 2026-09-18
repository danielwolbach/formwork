//
//  Statistics.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 06.09.26.
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

extension Statistic where Value == Date {
    static func lastCompleted(_ date: Date?) -> Self {
        Statistic(date, title: String(localized: .statisticLastCompletedTitle), pictogram: .date) {
            $0.formatted(.relative(presentation: .named)).localizedCapitalized
        }
    }
}

extension Statistic where Value == Int {
    static func completions(_ count: Int) -> Self {
        Statistic(count, title: String(localized: .statisticCompletionsTitle), pictogram: .tally) {
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

extension Statistic where Value == Duration {
    static func typicalDuration(_ duration: Duration?) -> Self {
        Statistic(duration, title: String(localized: .statisticTypicalDurationTitle), pictogram: .duration) {
            $0.formatted(.units(allowed: [.hours, .minutes], width: .abbreviated))
        }
    }
}

extension Statistic where Value == DateComponents {
    static func typicalStartTime(_ time: DateComponents?, calendar: Calendar) -> Self {
        Statistic(time, title: String(localized: .statisticTypicalStartTimeTitle), pictogram: .time) {
            calendar.date(from: $0)?.formatted(date: .omitted, time: .shortened)
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

public struct WorkoutStatistics {
    public let lastCompleted: Statistic<Date>
    public let completions: Statistic<Int>
    public let completionRate: Statistic<Double>
    public let typicalDuration: Statistic<Duration>
    public let typicalStartTime: Statistic<DateComponents>
    public let mostSkippedExercise: Statistic<Exercise>

    init(workout: Workout, calendar: Calendar = .current) {
        let finished = workout.sessions.filter { !$0.isActive }
        let entries = finished.flatMap(\.entries)
        let skipped = entries.filter(\.status.isSkipped).compactMap(\.exercise)
        let startTime = finished
            .map { $0.started.timeIntervalSince(calendar.startOfDay(for: $0.started)) }
            .median
            .map { DateComponents(hour: Int($0) / 3600, minute: Int($0) % 3600 / 60) }

        self.lastCompleted = .lastCompleted(finished.compactMap(\.ended).max())
        self.completions = .completions(finished.count)
        self.completionRate = .completionRate(entries.isEmpty ? nil : Double(entries.count(where: \.status.isCompleted)) / Double(entries.count))
        self.typicalDuration = .typicalDuration(finished.compactMap(\.duration).median.map { .seconds($0) })
        self.typicalStartTime = .typicalStartTime(startTime, calendar: calendar)
        self.mostSkippedExercise = .mostSkipped(Dictionary(grouping: skipped) { $0 }.max { $0.value.count < $1.value.count }?.key)
    }
}

public struct ExerciseStatistics {
    public let lastCompleted: Statistic<Date>
    public let completionRate: Statistic<Double>
    public let completions: Statistic<Int>
    public let personalBest: Statistic<ExerciseTarget>

    init(exercise: Exercise, calendar _: Calendar = .current) {
        let entries = exercise.sessionEntries.filter { $0.session?.isActive == false }
        let completed = entries.filter(\.status.isCompleted)
        let dates = completed.compactMap(\.status.resolved)

        self.lastCompleted = .lastCompleted(dates.max())
        self.completions = .completions(completed.count)
        self.completionRate = .completionRate(entries.isEmpty ? nil : Double(completed.count) / Double(entries.count))
        self.personalBest = .personalBest(completed.map(\.target).filter { $0.type == exercise.type }.max { $0.rank < $1.rank })
    }
}

public extension Workout {
    var statistics: WorkoutStatistics {
        WorkoutStatistics(workout: self)
    }
}

public extension Exercise {
    var statistics: ExerciseStatistics {
        ExerciseStatistics(exercise: self)
    }
}

private extension ExerciseTarget {
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

private extension [Double] {
    var median: Double? {
        guard !isEmpty else { return nil }
        let sorted = sorted(), middle = count / 2
        return count.isMultiple(of: 2) ? (sorted[middle - 1] + sorted[middle]) / 2 : sorted[middle]
    }
}
