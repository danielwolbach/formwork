//
//  OverallStatistics.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 19.09.26.
//

import Foundation

public struct OverallStatistics {
    /// Consecutive weeks with at least one finished session, up to the end of the interval.
    /// The week containing the end doesn't break the streak until it's over.
    public let weekStreak: Statistic<Int>

    /// The longest run of consecutive weeks with at least one finished session within the interval.
    public let longestWeekStreak: Statistic<Int>

    /// When the most recent session within the interval ended.
    public let lastSession: Statistic<Date>

    init(sessions: [Session], interval: DateInterval = .until(.now), calendar: Calendar = .current) {
        let context = StatisticsContext(sessions: sessions, interval: interval, calendar: calendar)

        self.weekStreak = .weekStreak(context.currentWeekStreak)
        self.longestWeekStreak = .longestWeekStreak(context.longestWeekStreak)
        self.lastSession = .lastCompleted(context.records.compactMap(\.session.ended).max())
    }
}

public extension [Session] {
    func statistics(in interval: DateInterval = .until(.now)) -> OverallStatistics {
        OverallStatistics(sessions: self, interval: interval)
    }
}
