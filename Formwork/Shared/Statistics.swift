//
//  Statistics.swift
//  Formwork
//
//  Created by Daniel Wolbach on 06.09.26.
//

import Foundation
import SwiftData

extension Calendar {
    nonisolated func weekStart(for date: Date) -> Date? {
        dateInterval(of: .weekOfYear, for: date)?.start
    }
}

nonisolated struct WorkoutStats {
    let completions: [Date]

    private let starts: [Date]

    init(completions: [Date], starts: [Date] = []) {
        self.completions = completions.sorted()
        self.starts = starts.sorted()
    }
}

extension WorkoutStats {
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

struct Stats {
    let overall: WorkoutStats

    private let perWorkout: [PersistentIdentifier: WorkoutStats]

    init(sessions: [Session]) {
        var completions: [Date] = []
        var groupedCompletions: [PersistentIdentifier: [Date]] = [:]
        var groupedStarts: [PersistentIdentifier: [Date]] = [:]

        for session in sessions {
            let workout = session.workout?.persistentModelID

            if let workout {
                groupedStarts[workout, default: []].append(session.started)
            }

            guard let completion = session.completion else {
                continue
            }

            completions.append(completion)

            if let workout {
                groupedCompletions[workout, default: []].append(completion)
            }
        }

        var perWorkout: [PersistentIdentifier: WorkoutStats] = [:]

        for workout in Set(groupedCompletions.keys).union(groupedStarts.keys) {
            perWorkout[workout] = WorkoutStats(
                completions: groupedCompletions[workout] ?? [],
                starts: groupedStarts[workout] ?? []
            )
        }

        self.overall = WorkoutStats(completions: completions, starts: sessions.map(\.started))
        self.perWorkout = perWorkout
    }

    subscript(workout: Workout) -> WorkoutStats {
        perWorkout[workout.persistentModelID] ?? WorkoutStats(completions: [])
    }
}

extension Array where Element == Session {
    /// `finished.stats()` — the intended entry point from a `@Query`.
    func stats() -> Stats {
        Stats(sessions: self)
    }
}
