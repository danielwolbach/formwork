//
//  ExerciseStatistics.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 19.09.26.
//

import Foundation

public struct ExerciseStatistics {
    /// When the exercise was last completed in a finished session.
    public let lastCompleted: Metric<Date>

    /// The share of the exercise's entries in finished sessions that were completed.
    public let completionRate: Metric<Double>

    /// How often the exercise was completed in finished sessions.
    public let completions: Metric<Int>

    /// The best completed target of the exercise's current type, e.g. the heaviest weight.
    public let personalBest: Metric<ExerciseTarget>

    /// How far the exercise got over time, as one point per day it was completed on.
    public let progression: Progression<ExerciseTarget>

    /// The days the exercise was completed on, week by week.
    public let activity: Heatmap

    init(exercise: Exercise, interval: DateInterval = .allTime, now: Date = .now, calendar: Calendar = .current) {
        let context = StatisticsContext(sessions: exercise.sessionEntries.compactMap(\.session), interval: interval, calendar: calendar)
        let included = Set(context.sessions)
        let entries = exercise.sessionEntries.filter { $0.session.map(included.contains) ?? false }
        let completed = entries.filter(\.status.isCompleted)
        let last = completed.max { ($0.status.resolved ?? .distantPast) < ($1.status.resolved ?? .distantPast) }
        let progression = Progression.targets(completed, of: exercise.type, calendar: calendar)

        self.lastCompleted = .lastCompleted(last?.status.resolved, in: last?.session, calendar: calendar)
        self.completions = .completions(completed.count)
        self.completionRate = .completionRate(entries.isEmpty ? nil : Double(completed.count) / Double(entries.count))
        // The best day of the progression is the best the exercise ever got to, so there's one rule for both.
        self.personalBest = .personalBest(progression.points.map(\.value).max { $0.rank < $1.rank })
        self.progression = progression
        self.activity = context.heatmap(of: completed.compactMap(\.session), at: now)
    }
}

extension Exercise {
    public func statistics(in interval: DateInterval = .allTime) -> ExerciseStatistics {
        ExerciseStatistics(exercise: self, interval: interval)
    }
}
