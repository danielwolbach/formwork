//
//  WeekStreak.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

public struct WeekStreak {
    public let weeks: Int

    public let isCurrentWeekFulfilled: Bool
}

extension WeekStreak: Indicator {
    public init(_ window: History.Window) {
        guard let streak = window.streakWeeks else {
            self.weeks = 0
            self.isCurrentWeekFulfilled = false
            return
        }

        let calendar = window.history.calendar
        let fulfilled = streak.weeks.contains(streak.current)
        var week = fulfilled ? streak.current : calendar.date(byAdding: .weekOfYear, value: -1, to: streak.current)
        var count = 0
        while let start = week, streak.weeks.contains(start) {
            count += 1
            week = calendar.date(byAdding: .weekOfYear, value: -1, to: start)
        }

        self.weeks = count
        self.isCurrentWeekFulfilled = fulfilled
    }

    public static var info: String {
        String(localized: .statisticWeekStreakInfo)
    }

    public var pictogram: Pictogram {
        .streak
    }

    public var title: String {
        String(localized: .statisticWeekStreakTitle)
    }

    public var reading: Reading? {
        .count(weeks)
    }
}
