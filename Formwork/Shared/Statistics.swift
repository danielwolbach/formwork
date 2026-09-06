//
//  Statistics.swift
//  Formwork
//
//  Created by Daniel Wolbach on 06.09.26.
//

import Foundation
import SwiftData

nonisolated struct WorkoutStatistics {
    let completions: [Date]

    private let starts: [Date]

    private let durations: [TimeInterval]

    /// Name of the exercise skipped most often in this workout's sessions, or
    /// `nil` if none has ever been skipped. A name rather than a model, so
    /// `Statistics` still retains nothing from the context it was built in.
    let mostSkippedExercise: String?

    init(
        completions: [Date],
        starts: [Date] = [],
        durations: [TimeInterval] = [],
        mostSkippedExercise: String? = nil
    ) {
        self.completions = completions.sorted()
        self.starts = starts.sorted()
        self.durations = durations.sorted()
        self.mostSkippedExercise = mostSkippedExercise
    }

    var lastCompleted: Date? {
        completions.last
    }

    var lastStarted: Date? {
        starts.last
    }

    /// Seconds since midnight of the most recent session start, or `nil` if the
    /// workout has never been started.
    var lastStartTimeOfDay: TimeInterval? {
        guard let lastStarted else {
            return nil
        }

        let parts = Calendar.autoupdatingCurrent.dateComponents([.hour, .minute, .second], from: lastStarted)

        guard let hour = parts.hour, let minute = parts.minute, let second = parts.second else {
            return nil
        }

        return TimeInterval(hour * 3600 + minute * 60 + second)
    }

    /// Median length of the sessions that counted as a completion, or `nil` if
    /// the workout has never been completed. Median rather than mean: finishing
    /// a session is manual, so one forgotten overnight session would sit in a
    /// mean forever.
    var typicalDuration: TimeInterval? {
        guard !durations.isEmpty else {
            return nil
        }

        return durations[durations.count / 2]
    }

    /// Whether the given day holds at least one completion.
    func hasCompletion(on date: Date) -> Bool {
        let calendar = Calendar.autoupdatingCurrent

        return completions.contains { calendar.isDate($0, inSameDayAs: date) }
    }

    /// Consecutive weeks, counting back from `date`, that hold at least one
    /// completion.
    func weekStreak(asOf date: Date = .now) -> Int {
        let calendar = Calendar.autoupdatingCurrent
        let weeks = Set(completions.compactMap { calendar.weekStart(for: $0) })

        guard var week = calendar.weekStart(for: date) else {
            return 0
        }

        var streak = weeks.contains(week) ? 1 : 0

        while
            let earlier = calendar.date(byAdding: .weekOfYear, value: -1, to: week),
            let previous = calendar.weekStart(for: earlier),
            weeks.contains(previous)
        {
            streak += 1
            week = previous
        }

        return streak
    }
}

nonisolated struct ExerciseStatistics {
    let completions: [Date]

    let skips: [Date]

    /// Best target ever completed, among those matching the exercise's current
    /// type.
    let personalBest: ExerciseTarget?

    init(completions: [Date], skips: [Date] = [], targets: [ExerciseTarget] = []) {
        self.completions = completions.sorted()
        self.skips = skips.sorted()
        self.personalBest = targets.max { Self.ranking(of: $0) < Self.ranking(of: $1) }
    }

    var lastCompleted: Date? {
        completions.last
    }

    /// Share of resolved attempts that were completed rather than skipped, or
    /// `nil` if the exercise has never come up in a finished session.
    var completionRate: Double? {
        let attempts = completions.count + skips.count

        guard attempts > 0 else {
            return nil
        }

        return Double(completions.count) / Double(attempts)
    }

    /// Ranking key for personal bests. Only meaningful between two targets of
    /// the same case.
    private static func ranking(of target: ExerciseTarget) -> (Double, Int, Int) {
        switch target {
        case let .weight(weight, sets, reps): (weight, reps, sets)
        case let .bodyweight(sets, reps): (0, reps, sets)
        case let .duration(minutes): (0, minutes, 0)
        case let .distance(meters): (0, meters, 0)
        }
    }
}

struct Statistics {
    let overall: WorkoutStatistics

    private let perWorkout: [PersistentIdentifier: WorkoutStatistics]

    private let perExercise: [PersistentIdentifier: ExerciseStatistics]

    init(sessions: [Session]) {
        var completions: [Date] = []
        var groupedCompletions: [PersistentIdentifier: [Date]] = [:]
        var groupedStarts: [PersistentIdentifier: [Date]] = [:]
        var durations: [TimeInterval] = []
        var groupedDurations: [PersistentIdentifier: [TimeInterval]] = [:]
        var groupedExercises: [PersistentIdentifier: [Date]] = [:]
        var groupedTargets: [PersistentIdentifier: [ExerciseTarget]] = [:]
        var groupedSkips: [PersistentIdentifier: [Date]] = [:]
        var workoutSkips: [PersistentIdentifier: [PersistentIdentifier: [Date]]] = [:]
        var skippedExerciseNames: [PersistentIdentifier: String] = [:]

        for session in sessions {
            let workout = session.workout?.persistentModelID

            if let workout {
                groupedStarts[workout, default: []].append(session.started)
            }

            if session.ended != nil {
                for entry in session.entries {
                    guard let exercise = entry.exercise else {
                        continue
                    }

                    let identifier = exercise.persistentModelID

                    switch entry.status {
                    case .pending:
                        continue
                    case let .completed(date):
                        groupedExercises[identifier, default: []].append(date)

                        if entry.target.type == exercise.type {
                            groupedTargets[identifier, default: []].append(entry.target)
                        }
                    case let .skipped(date):
                        groupedSkips[identifier, default: []].append(date)

                        if let workout {
                            workoutSkips[workout, default: [:]][identifier, default: []].append(date)
                            skippedExerciseNames[identifier] = exercise.name
                        }
                    }
                }
            }

            guard let completion = session.completion else {
                continue
            }

            let duration = completion.timeIntervalSince(session.started)

            completions.append(completion)
            durations.append(duration)

            if let workout {
                groupedCompletions[workout, default: []].append(completion)
                groupedDurations[workout, default: []].append(duration)
            }
        }

        var perWorkout: [PersistentIdentifier: WorkoutStatistics] = [:]

        for workout in Set(groupedCompletions.keys).union(groupedStarts.keys) {
            let mostSkipped = workoutSkips[workout]?.max { lhs, rhs in
                // Ties resolve to the most recently skipped, which is both the
                // more useful answer and stable — dictionary order is not, so
                // without a tie-break the card would flip on every rebuild.
                lhs.value.count == rhs.value.count
                    ? (lhs.value.max() ?? .distantPast) < (rhs.value.max() ?? .distantPast)
                    : lhs.value.count < rhs.value.count
            }

            perWorkout[workout] = WorkoutStatistics(
                completions: groupedCompletions[workout] ?? [],
                starts: groupedStarts[workout] ?? [],
                durations: groupedDurations[workout] ?? [],
                mostSkippedExercise: mostSkipped.flatMap { skippedExerciseNames[$0.key] }
            )
        }

        var perExercise: [PersistentIdentifier: ExerciseStatistics] = [:]

        for exercise in Set(groupedExercises.keys).union(groupedSkips.keys) {
            perExercise[exercise] = ExerciseStatistics(
                completions: groupedExercises[exercise] ?? [],
                skips: groupedSkips[exercise] ?? [],
                targets: groupedTargets[exercise] ?? []
            )
        }

        self.overall = WorkoutStatistics(
            completions: completions,
            starts: sessions.map(\.started),
            durations: durations
        )
        self.perWorkout = perWorkout
        self.perExercise = perExercise
    }

    subscript(workout: Workout) -> WorkoutStatistics {
        perWorkout[workout.persistentModelID] ?? WorkoutStatistics(completions: [])
    }

    subscript(exercise: Exercise) -> ExerciseStatistics {
        perExercise[exercise.persistentModelID] ?? ExerciseStatistics(completions: [])
    }
}

extension Array where Element == Session {
    /// `finished.statistics()` — the intended entry point from a `@Query`.
    func statistics() -> Statistics {
        Statistics(sessions: self)
    }
}
