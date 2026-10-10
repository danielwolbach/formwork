//
//  Streak.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 04.10.26.
//

import Foundation

public struct Streak {
    public let weeks: Int

    public let longest: Int

    public let isCurrentWeekFulfilled: Bool
}

extension Period {
    public var streak: Streak {
        let calendar = history.calendar

        guard
            isOnRecord,
            let last = calendar.date(byAdding: .day, value: -1, to: interval.end),
            let current = calendar.dateInterval(of: .weekOfYear, for: last)?.start
        else {
            return Streak(weeks: 0, longest: 0, isCurrentWeekFulfilled: false)
        }

        let weeks = Set(history.occurrences.compactMap { occurrence in
            occurrence.isCompleted && occurrence.day < interval.end ? calendar.dateInterval(of: .weekOfYear, for: occurrence.day)?.start : nil
        })

        // The current week only breaks the streak once it's over.
        let isFulfilled = weeks.contains(current)
        var week = isFulfilled ? current : calendar.date(byAdding: .weekOfYear, value: -1, to: current)
        var count = 0
        while let start = week, weeks.contains(start) {
            count += 1
            week = calendar.date(byAdding: .weekOfYear, value: -1, to: start)
        }

        var longest = 0, run = 0, previous: Date?
        for week in weeks.sorted() {
            run = previous.flatMap { calendar.date(byAdding: .weekOfYear, value: 1, to: $0) } == week ? run + 1 : 1
            longest = max(longest, run)
            previous = week
        }

        return Streak(weeks: count, longest: longest, isCurrentWeekFulfilled: isFulfilled)
    }
}
