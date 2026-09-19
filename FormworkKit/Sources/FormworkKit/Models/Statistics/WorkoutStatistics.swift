//
//  WorkoutStatistics.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 19.09.26.
//

import Foundation

public struct WorkoutStatistics {
    /// When the most recent session of the workout ended.
    public let lastCompleted: Statistic<Date>

    /// How many sessions of the workout were finished.
    public let completions: Statistic<Int>

    /// The share of all exercises in finished sessions that were completed rather than skipped or left pending.
    public let completionRate: Statistic<Double>

    /// The median duration of a finished session.
    public let typicalDuration: Statistic<Duration>

    /// The median wall-clock time a session was started at, as hour and minute.
    public let typicalStartTime: Statistic<DateComponents>

    /// The exercise skipped most often across finished sessions.
    public let mostSkippedExercise: Statistic<Exercise>

    init(workout: Workout, interval: DateInterval = .allTime, calendar: Calendar = .current) {
        let context = StatisticsContext(sessions: workout.sessions, interval: interval, calendar: calendar)
        let sessions = context.sessions
        let last = context.lastSession
        let entries = sessions.flatMap(\.entries)
        let skipped = entries.filter(\.status.isSkipped).compactMap(\.exercise)
        let startTime = sessions
            .map { $0.timeOfDay(in: calendar) }
            .map { Double(($0.hour ?? 0) * 60 + ($0.minute ?? 0)) }
            .median
            .map { DateComponents(hour: Int($0) / 60, minute: Int($0) % 60) }

        self.lastCompleted = .lastCompleted(last?.ended, in: last, calendar: calendar)
        self.completions = .completions(sessions.count)
        self.completionRate = .completionRate(entries.isEmpty ? nil : Double(entries.count(where: \.status.isCompleted)) / Double(entries.count))
        self.typicalDuration = .typicalDuration(sessions.compactMap(\.duration).median.map { .seconds($0) })
        self.typicalStartTime = .typicalStartTime(startTime, calendar: calendar)
        self.mostSkippedExercise = .mostSkipped(Dictionary(grouping: skipped) { $0 }.max { $0.value.count < $1.value.count }?.key)
    }
}

public extension Workout {
    func statistics(in interval: DateInterval = .allTime) -> WorkoutStatistics {
        WorkoutStatistics(workout: self, interval: interval)
    }
}
