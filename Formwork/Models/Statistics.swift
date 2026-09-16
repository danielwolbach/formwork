//
//  Statistics.swift
//  Formwork
//
//  Created by Daniel Wolbach on 06.09.26.
//

import Foundation
import SwiftData

/// Everything the statistics screens show about a set of finished sessions —
/// either across every workout, or for a single one.
///
/// Computed once at initialisation. Every property is the value to display,
/// needing at most a `formatted()` at the call site.
struct SessionStatistics {
    /// Sessions that counted as a completion.
    let completionCount: Int

    /// Completions falling in the current calendar month.
    let completionsThisMonth: Int

    let lastCompleted: Date?

    /// Midnights of the days holding at least one completion. A day is either
    /// trained or it is not — how many sessions it held is not worth telling
    /// apart, so a set of days answers everything asked of it.
    let completedDays: Set<Date>

    /// Consecutive weeks, counting back from now, holding a completion.
    let currentStreak: Int

    /// Longest such run over the whole history. Never smaller than
    /// `currentStreak`.
    let longestStreak: Int

    /// Share of resolved entries that were completed rather than skipped, or
    /// `nil` if nothing has been resolved yet. Entries whose exercise has since
    /// been deleted count towards neither.
    let completionRate: Double?

    /// Median length of the sessions that counted as a completion, or `nil` if
    /// there has never been one. Median rather than mean: finishing a session
    /// is manual, so one forgotten overnight session would sit in a mean
    /// forever.
    let typicalDuration: Duration?

    /// Median session start, carried on today's date — only the time of day is
    /// meaningful. Median for the same reason as `typicalDuration`. Starts are
    /// compared as offsets from midnight, so a habit that straddles midnight
    /// lands in the middle of the day rather than in either half of it.
    let typicalStartTime: Date?

    /// Name of the exercise skipped most often, or `nil` if none ever was. A
    /// name rather than a model, so nothing is retained from the context this
    /// was built in. Ties resolve to the most recently skipped, which is both
    /// the more useful answer and a stable one.
    let mostSkippedExercise: String?

    /// Category mix of the exercises actually completed. History, not plan —
    /// the plan's mix is `ExerciseCategory.shares(of:)` over a workout's
    /// current entries, which needs no sessions at all.
    let completedShares: [(category: ExerciseCategory, share: Double)]

    /// - Parameters:
    ///   - sessions: The sessions to measure, in any order.
    ///   - workout: Limits the statistics to this workout's sessions. `nil`
    ///     covers every workout.
    init(_ sessions: [Session], of workout: Workout? = nil) {
        let calendar = Calendar.autoupdatingCurrent
        let matching = workout.map { workout in
            sessions.filter { $0.workout?.persistentModelID == workout.persistentModelID }
        } ?? sessions

        var completions: [Date] = []
        var durations: [TimeInterval] = []
        var startOffsets: [TimeInterval] = []
        var completedCategories: [Set<ExerciseCategory>] = []
        var skips: [String: (count: Int, latest: Date)] = [:]
        var skippedEntries = 0

        for session in matching {
            startOffsets.append(session.started.timeIntervalSince(calendar.startOfDay(for: session.started)))

            if session.ended != nil {
                for entry in session.entries {
                    guard let exercise = entry.exercise else {
                        continue
                    }

                    switch entry.status {
                    case .pending:
                        continue
                    case .completed:
                        completedCategories.append(exercise.categories)
                    case .skipped:
                        skippedEntries += 1

                        let skip = skips[exercise.name]
                        skips[exercise.name] = (
                            count: (skip?.count ?? 0) + 1,
                            latest: max(skip?.latest ?? .distantPast, session.started)
                        )
                    }
                }
            }

            if let completion = session.completion {
                completions.append(session.started)
                durations.append(completion.timeIntervalSince(session.started))
            }
        }

        let attempts = completedCategories.count + skippedEntries
        let weeks = Set(completions.compactMap { calendar.weekStart(for: $0) })

        self.completionCount = completions.count
        self.completionsThisMonth = completions.count { calendar.isDate($0, equalTo: .now, toGranularity: .month) }
        self.lastCompleted = completions.max()
        self.completedDays = Set(completions.map { calendar.startOfDay(for: $0) })
        self.currentStreak = Self.streak(in: weeks, endingAt: .now)
        self.longestStreak = Self.longestStreak(in: weeks)
        self.completionRate = attempts > 0 ? Double(completedCategories.count) / Double(attempts) : nil
        self.typicalDuration = Self.median(of: durations).map { Duration.seconds($0) }
        self.typicalStartTime = Self.median(of: startOffsets).flatMap(Self.timeOfDay(_:))
        self.mostSkippedExercise = skips.max { lhs, rhs in
            lhs.value.count == rhs.value.count
                ? lhs.value.latest < rhs.value.latest
                : lhs.value.count < rhs.value.count
        }?.key
        self.completedShares = ExerciseCategory.shares(of: completedCategories)
    }

    private static func median(of values: [TimeInterval]) -> TimeInterval? {
        let values = values.sorted()

        guard !values.isEmpty else {
            return nil
        }

        return values[values.count / 2]
    }

    /// Today at the clock time `offset` seconds after midnight.
    private static func timeOfDay(_ offset: TimeInterval) -> Date? {
        let seconds = Int(offset)

        return Calendar.autoupdatingCurrent.date(
            bySettingHour: seconds / 3600 % 24,
            minute: seconds / 60 % 60,
            second: 0,
            of: .now
        )
    }

    /// Consecutive weeks up to the one `date` falls in. The current week not
    /// counting yet does not end the streak — the walk starts from it either
    /// way — so a week is only lost once it passes without a session.
    private static func streak(in weeks: Set<Date>, endingAt date: Date) -> Int {
        let calendar = Calendar.autoupdatingCurrent

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

    private static func longestStreak(in weeks: Set<Date>) -> Int {
        let calendar = Calendar.autoupdatingCurrent

        var longest = 0
        var run = 0
        var previous: Date?

        for week in weeks.sorted() {
            let follows = previous
                .flatMap { calendar.date(byAdding: .weekOfYear, value: 1, to: $0) }
                .flatMap { calendar.weekStart(for: $0) } == week

            run = follows ? run + 1 : 1
            longest = max(longest, run)
            previous = week
        }

        return longest
    }
}

/// Everything the exercise screen shows about one exercise, measured over a set
/// of finished sessions.
struct ExerciseStatistics {
    /// Times the exercise was completed, counting repeats within a session.
    let completionCount: Int

    let lastCompleted: Date?

    /// Midnights of the days the exercise was completed on.
    let completedDays: Set<Date>

    /// Share of resolved attempts that were completed rather than skipped, or
    /// `nil` if the exercise has never come up in a finished session.
    let completionRate: Double?

    /// Best target ever completed, among those matching the exercise's current
    /// type.
    let personalBest: ExerciseTarget?

    /// `ExerciseTarget.progress` of every completed target of the exercise's
    /// current type, oldest first. Same-day repeats stay as separate points:
    /// what was actually logged.
    let progress: [(date: Date, value: Double)]

    init(_ sessions: [Session], of exercise: Exercise) {
        let calendar = Calendar.autoupdatingCurrent
        let identifier = exercise.persistentModelID

        var completions: [Date] = []
        var skippedEntries = 0
        var targets: [(date: Date, target: ExerciseTarget)] = []

        for session in sessions where session.ended != nil {
            for entry in session.entries where entry.exercise?.persistentModelID == identifier {
                switch entry.status {
                case .pending:
                    continue
                case .completed:
                    completions.append(session.started)

                    if entry.target.type == exercise.type {
                        targets.append((date: session.started, target: entry.target))
                    }
                case .skipped:
                    skippedEntries += 1
                }
            }
        }

        let attempts = completions.count + skippedEntries
        let ordered = targets.sorted { $0.date < $1.date }

        self.completionCount = completions.count
        self.lastCompleted = completions.max()
        self.completedDays = Set(completions.map { calendar.startOfDay(for: $0) })
        self.completionRate = attempts > 0 ? Double(completions.count) / Double(attempts) : nil
        self.personalBest = targets.map { $0.target }.max { Self.ranking(of: $0) < Self.ranking(of: $1) }
        self.progress = ordered.map { (date: $0.date, value: $0.target.progress) }
    }

    /// Ranking key for personal bests. Only meaningful between two targets of
    /// the same case.
    private static func ranking(of target: ExerciseTarget) -> (Double, Int, Int) {
        switch target {
        case let .weight(_, sets, reps): (target.progress, reps, sets)
        case let .bodyweight(sets, _): (target.progress, sets, 0)
        case .duration, .distance: (target.progress, 0, 0)
        }
    }
}

private extension Calendar {
    func weekStart(for date: Date) -> Date? {
        dateInterval(of: .weekOfYear, for: date)?.start
    }
}
