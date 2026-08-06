//
//  Session+Statistics.swift
//  GymTrack
//  Created by Daniel Wolbach on 06.08.26.
//

import Foundation

struct WeeklySessionCount: Identifiable {
    let week: Date
    let count: Int

    var id: Date {
        week
    }
}

@MainActor
extension Session {
    var duration: Duration? {
        guard let ended else {
            return nil
        }

        return .seconds(ended.timeIntervalSince(started))
    }

    var completedEntryCount: Int {
        entries.count { $0.status == .done }
    }

    var skippedEntryCount: Int {
        entries.count { $0.status == .skipped }
    }

    var completionRate: Double? {
        let performedEntryCount = completedEntryCount + skippedEntryCount
        guard performedEntryCount > 0 else {
            return nil
        }

        return Double(completedEntryCount) / Double(performedEntryCount)
    }

    var estimatedTotalDuration: Duration? {
        guard let typicalEntryDuration = workout?.typicalEntryDuration else {
            return nil
        }

        return typicalEntryDuration * entries.count
    }

    var estimatedRemainingDuration: Duration? {
        guard let estimatedTotalDuration else {
            return nil
        }

        guard !pending.isEmpty else {
            return .zero
        }

        let elapsedDuration = Duration.seconds(Date.now.timeIntervalSince(started))
        return max(.zero, estimatedTotalDuration - elapsedDuration)
    }
}

extension Collection<Session> {
    var finishedSessions: [Session] {
        filter { $0.ended != nil }
    }

    var completedDisciplineDistribution: [Discipline: Double] {
        .init(exercises: finishedSessions.flatMap { session in
            session.entries.filter { $0.status == .done }.map(\.exercise)
        })
    }

    func finishedSessions(
        in period: StatisticsPeriod,
        relativeTo date: Date = .now,
        calendar: Calendar = .autoupdatingCurrent
    ) -> [Session] {
        guard let interval = period.dateInterval(relativeTo: date, calendar: calendar) else {
            return finishedSessions
        }

        return finishedSessions.filter { session in
            guard let ended = session.ended else {
                return false
            }

            return interval.contains(ended)
        }
    }

    func finishedSessionCount(
        in period: StatisticsPeriod,
        relativeTo date: Date = .now,
        calendar: Calendar = .autoupdatingCurrent
    ) -> Int {
        finishedSessions(in: period, relativeTo: date, calendar: calendar).count
    }

    func weeklySessionCounts(
        endingAt date: Date = .now,
        weeks: Int = 6,
        calendar: Calendar = .autoupdatingCurrent
    ) -> [WeeklySessionCount] {
        guard
            weeks > 0,
            let currentWeek = calendar.dateInterval(of: .weekOfYear, for: date)
        else {
            return []
        }

        let sessions = finishedSessions(in: .trailingWeeks(weeks), relativeTo: date, calendar: calendar)

        return (0 ..< weeks).reversed().compactMap { offset in
            guard
                let weekStart = calendar.date(byAdding: .weekOfYear, value: -offset, to: currentWeek.start),
                let week = calendar.dateInterval(of: .weekOfYear, for: weekStart)
            else {
                return nil
            }

            return WeeklySessionCount(
                week: week.start,
                count: sessions.count { session in
                    guard let ended = session.ended else {
                        return false
                    }

                    return week.contains(ended)
                }
            )
        }
    }
}
