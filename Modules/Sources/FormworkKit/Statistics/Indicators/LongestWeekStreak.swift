//
//  LongestWeekStreak.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

public struct LongestWeekStreak {
    let weeks: Int
}

extension LongestWeekStreak: Indicator {
    public init(_ window: History.Window) {
        guard let streak = window.streakWeeks else {
            self.weeks = 0
            return
        }

        let calendar = window.history.calendar
        var longest = 0, run = 0, previous: Date?
        for week in streak.weeks.sorted() {
            run = previous.flatMap { calendar.date(byAdding: .weekOfYear, value: 1, to: $0) } == week ? run + 1 : 1
            longest = max(longest, run)
            previous = week
        }

        self.weeks = longest
    }

    public static var info: String {
        String(localized: .statisticLongestWeekStreakInfo)
    }

    public static var pictogram: Pictogram {
        .record
    }

    public static var title: String {
        String(localized: .statisticLongestWeekStreakTitle)
    }

    public var reading: Reading? {
        .count(weeks)
    }
}
