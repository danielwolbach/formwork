//
//  Workout+Statistics.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 06.08.26.
//

import Foundation

struct WorkoutDurationDataPoint: Identifiable {
    let date: Date
    let duration: TimeInterval

    var id: Date {
        date
    }
}

@MainActor
extension Workout {
    private static let estimationHistoryLimit = 5
    private static let durationTrendHistoryLimit = 6

    var finishedSessions: [Session] {
        sessions.finishedSessions
    }

    var completedSessions: [Session] {
        finishedSessions.filter(\.pending.isEmpty)
    }

    var completedSessionHistory: [Session] {
        completedSessions.sorted { ($0.ended ?? .distantPast) > ($1.ended ?? .distantPast) }
    }

    var totalCompletionCount: Int {
        completedSessions.count
    }

    var lastCompletedDate: Date? {
        completedSessions.compactMap(\.ended).max()
    }

    var typicalDuration: Duration? {
        medianDuration(for: recentCompletedSessions.compactMap(sessionDuration))
    }

    var completionRate: Double? {
        guard !finishedSessions.isEmpty else {
            return nil
        }

        return Double(completedSessions.count) / Double(finishedSessions.count)
    }

    var averageSkippedExerciseCount: Double? {
        guard !finishedSessions.isEmpty else {
            return nil
        }

        let skippedCount = finishedSessions.reduce(into: 0) { count, session in
            count += session.entries.count { $0.status == .skipped }
        }

        return Double(skippedCount) / Double(finishedSessions.count)
    }

    var recentDurationTrend: [WorkoutDurationDataPoint] {
        completedSessions
            .sorted { ($0.ended ?? .distantPast) > ($1.ended ?? .distantPast) }
            .prefix(Self.durationTrendHistoryLimit)
            .compactMap { session in
                guard let ended = session.ended else {
                    return nil
                }

                return WorkoutDurationDataPoint(
                    date: ended,
                    duration: ended.timeIntervalSince(session.started)
                )
            }
            .sorted { $0.date < $1.date }
    }

    var typicalEntryDuration: Duration? {
        let entryDurations = recentCompletedSessions.compactMap { session -> TimeInterval? in
            guard let ended = session.ended, !session.entries.isEmpty else {
                return nil
            }

            return ended.timeIntervalSince(session.started) / Double(session.entries.count)
        }

        return medianDuration(for: entryDurations)
    }

    var disciplineDistribution: [Discipline: Double] {
        .init(exercises: entries.map(\.exercise))
    }

    private var recentCompletedSessions: [Session] {
        Array(
            completedSessionHistory
                .prefix(Self.estimationHistoryLimit)
        )
    }

    private func sessionDuration(_ session: Session) -> TimeInterval? {
        guard let ended = session.ended else {
            return nil
        }

        return ended.timeIntervalSince(session.started)
    }

    private func medianDuration(for durations: [TimeInterval]) -> Duration? {
        guard !durations.isEmpty else {
            return nil
        }

        let sortedDurations = durations.sorted()
        let middleIndex = sortedDurations.count / 2

        if sortedDurations.count.isMultiple(of: 2) {
            return .seconds((sortedDurations[middleIndex - 1] + sortedDurations[middleIndex]) / 2)
        }

        return .seconds(sortedDurations[middleIndex])
    }
}
