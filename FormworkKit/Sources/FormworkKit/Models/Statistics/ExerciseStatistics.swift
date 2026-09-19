//
//  ExerciseStatistics.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 19.09.26.
//

import Foundation

public struct ExerciseStatistics {
    /// When the exercise was last completed in a finished session.
    public let lastCompleted: Statistic<Date>

    /// The share of the exercise's entries in finished sessions that were completed.
    public let completionRate: Statistic<Double>

    /// How often the exercise was completed in finished sessions.
    public let completions: Statistic<Int>

    /// The best completed target of the exercise's current type, e.g. the heaviest weight.
    public let personalBest: Statistic<ExerciseTarget>

    init(exercise: Exercise, interval: DateInterval = .until(.now), calendar: Calendar = .current) {
        let context = StatisticsContext(sessions: exercise.sessionEntries.compactMap(\.session), interval: interval, calendar: calendar)
        let included = Set(context.records.map(\.session))
        let entries = exercise.sessionEntries.filter { $0.session.map(included.contains) ?? false }
        let completed = entries.filter(\.status.isCompleted)

        self.lastCompleted = .lastCompleted(completed.compactMap(\.status.resolved).max())
        self.completions = .completions(completed.count)
        self.completionRate = .completionRate(entries.isEmpty ? nil : Double(completed.count) / Double(entries.count))
        self.personalBest = .personalBest(completed.map(\.target).filter { $0.type == exercise.type }.max { $0.rank < $1.rank })
    }
}

public extension Exercise {
    func statistics(in interval: DateInterval = .until(.now)) -> ExerciseStatistics {
        ExerciseStatistics(exercise: self, interval: interval)
    }
}
