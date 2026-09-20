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

    /// The wall-clock time a session was typically started at, as hour and minute: the recorded start time
    /// closest to all the others on the clock.
    public let typicalStartTime: Statistic<DateComponents>

    /// The exercise skipped most often across finished sessions.
    public let mostSkippedExercise: Statistic<Exercise>

    init(workout: Workout, interval: DateInterval = .allTime, calendar: Calendar = .current) {
        let context = StatisticsContext(sessions: workout.sessions, interval: interval, calendar: calendar)
        let sessions = context.sessions
        let last = context.lastSession
        let entries = sessions.flatMap(\.entries)
        let skips = entries
            .filter(\.status.isSkipped)
            .reduce(into: [Exercise: (count: Int, latest: Date)]()) { tally, entry in
                guard let exercise = entry.exercise, let skipped = entry.status.resolved else { return }
                let current = tally[exercise] ?? (0, .distantPast)
                tally[exercise] = (current.count + 1, max(current.latest, skipped))
            }
        let startTime = sessions
            .compactMap { $0.startMinute(in: calendar) }
            .clockMedoid
            .map { DateComponents(hour: $0 / 60, minute: $0 % 60) }

        self.lastCompleted = .lastCompleted(last?.ended, in: last, calendar: calendar)
        self.completions = .completions(sessions.count)
        self.completionRate = .completionRate(entries.isEmpty ? nil : Double(entries.count(where: \.status.isCompleted)) / Double(entries.count))
        self.typicalDuration = .typicalDuration(sessions.compactMap(\.duration).median.map { .seconds($0) })
        self.typicalStartTime = .typicalStartTime(startTime, calendar: calendar)
        self.mostSkippedExercise = .mostSkipped(skips.max { ($0.value.count, $0.value.latest) < ($1.value.count, $1.value.latest) }?.key)
    }
}

public extension Workout {
    func statistics(in interval: DateInterval = .allTime) -> WorkoutStatistics {
        WorkoutStatistics(workout: self, interval: interval)
    }
}
