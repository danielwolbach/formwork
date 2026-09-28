//
//  WeekStreak.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

public struct WeekStreak {
    public let weeks: Int
}

extension WeekStreak: Statistic {
    public init(_ window: History.Window) {
        guard let streak = window.streakWeeks else {
            self.weeks = 0
            return
        }

        let calendar = window.history.calendar
        var week = streak.weeks.contains(streak.current) ? streak.current : calendar.date(byAdding: .weekOfYear, value: -1, to: streak.current)
        var count = 0
        while let start = week, streak.weeks.contains(start) {
            count += 1
            week = calendar.date(byAdding: .weekOfYear, value: -1, to: start)
        }

        self.weeks = count
    }

    public static var explanation: String {
        String(localized: .placeholder)
    }

    public var pictogram: Pictogram {
        .streak
    }

    public var title: String {
        String(localized: .statisticWeekStreakTitle)
    }

    public var subtitle: String? {
        weeks.formatted()
    }
}
