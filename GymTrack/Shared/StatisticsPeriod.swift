//
//  StatisticsPeriod.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 06.08.26.
//

import Foundation

enum StatisticsPeriod: Hashable, Sendable {
    case currentWeek
    case currentMonth
    case currentYear
    case allTime
    case trailingWeeks(Int)
    case trailingMonths(Int)

    func dateInterval(
        relativeTo date: Date = .now,
        calendar: Calendar = .autoupdatingCurrent
    ) -> DateInterval? {
        switch self {
        case .currentWeek:
            calendar.dateInterval(of: .weekOfYear, for: date)
        case .currentMonth:
            calendar.dateInterval(of: .month, for: date)
        case .currentYear:
            calendar.dateInterval(of: .year, for: date)
        case .allTime:
            nil
        case let .trailingWeeks(count):
            trailingDateInterval(
                component: .weekOfYear,
                count: count,
                relativeTo: date,
                calendar: calendar
            )
        case let .trailingMonths(count):
            trailingDateInterval(
                component: .month,
                count: count,
                relativeTo: date,
                calendar: calendar
            )
        }
    }

    private func trailingDateInterval(
        component: Calendar.Component,
        count: Int,
        relativeTo date: Date,
        calendar: Calendar
    ) -> DateInterval? {
        guard
            count > 0,
            let currentPeriod = calendar.dateInterval(of: component, for: date),
            let start = calendar.date(byAdding: component, value: 1 - count, to: currentPeriod.start)
        else {
            return nil
        }

        return DateInterval(start: start, end: currentPeriod.end)
    }
}
