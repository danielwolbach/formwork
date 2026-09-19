//
//  OverallStatistics.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 19.09.26.
//

import Foundation

public struct OverallStatistics {
    /// Consecutive weeks with at least one finished session as seen on the last day of the interval, or now
    /// while it's ongoing. The week containing that day doesn't break the streak until it's over.
    public let weekStreak: Statistic<Int>

    /// The longest run of consecutive weeks with at least one finished session up to the end of the interval,
    /// or up to now while it's ongoing. For May, it's the best streak as seen on May 31.
    public let longestWeekStreak: Statistic<Int>

    /// When the most recent session within the interval ended.
    public let lastSession: Statistic<Date>

    init(sessions: [Session], interval: DateInterval = .allTime, now: Date = .now, calendar: Calendar = .current) {
        let context = StatisticsContext(sessions: sessions, interval: interval, calendar: calendar)
        let last = context.lastSession

        self.weekStreak = .weekStreak(context.currentWeekStreak(at: now))
        self.longestWeekStreak = .longestWeekStreak(context.longestWeekStreak(at: now))
        self.lastSession = .lastCompleted(last?.ended, in: last, calendar: calendar)
    }
}

public extension [Session] {
    func statistics(in interval: DateInterval = .allTime) -> OverallStatistics {
        OverallStatistics(sessions: self, interval: interval)
    }
}
