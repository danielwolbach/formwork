//
//  WorkoutStatistics.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 19.09.26.
//

import Foundation

public struct WorkoutStatistics {
    /// When the most recent session of the workout ended.
    public let lastCompleted: Metric<Date>

    /// How many sessions of the workout were finished.
    public let completions: Metric<Int>

    /// The share of all exercises in finished sessions that were completed rather than skipped or left pending.
    public let completionRate: Metric<Double>

    /// The median duration of a finished session.
    public let typicalDuration: Metric<Duration>

    /// The wall-clock time a session was typically started at, as hour and minute: the recorded start time
    /// closest to all the others on the clock.
    public let typicalStartTime: Metric<DateComponents>

    /// The exercise skipped most often across finished sessions.
    public let mostSkippedExercise: Metric<Exercise>

    /// The days the workout was done on, week by week.
    public let activity: Heatmap

    /// What the workout sets out to train, by the exercises it holds now rather than by what was done of them.
    public let categories: Distribution<ExerciseCategory>

    init(workout: Workout, interval: DateInterval = .allTime, now: Date = .now, calendar: Calendar = .current) {
        let context = StatisticsContext(sessions: workout.sessions, interval: interval, calendar: calendar)
        let sessions = context.sessions
        let last = context.lastSession
        let entries = sessions.flatMap(\.entries)
        let skips = entries
            .filter(\.status.isSkipped)
            .reduce(into: [Exercise: (count: Int, latest: Date)]()) { tally, entry in
                guard let exercise = entry.exercise, let skipped = entry.status.resolved else {
                    return
                }
                let current = tally[exercise] ?? (0, .distantPast)
                tally[exercise] = (current.count + 1, max(current.latest, skipped))
            }
        self.lastCompleted = .lastCompleted(last?.ended, in: last, calendar: calendar)
        self.completions = .completions(sessions.count)
        self.completionRate = .completionRate(entries.isEmpty ? nil : Double(entries.count(where: \.status.isCompleted)) / Double(entries.count))
        self.typicalDuration = .typicalDuration(context.typicalDuration)
        self.typicalStartTime = .typicalStartTime(context.typicalStartTime, calendar: calendar)
        self.mostSkippedExercise = .mostSkipped(skips.max { ($0.value.count, $0.value.latest) < ($1.value.count, $1.value.latest) }?.key)
        self.activity = context.heatmap(of: sessions, at: now)
        self.categories = .categories(workout.entries.compactMap(\.exercise))
    }
}

extension Workout {
    public func statistics(in interval: DateInterval = .allTime) -> WorkoutStatistics {
        WorkoutStatistics(workout: self, interval: interval)
    }
}
