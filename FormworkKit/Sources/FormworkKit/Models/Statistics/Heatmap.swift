//
//  Heatmap.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 22.09.26.
//

import Foundation

public struct Heatmap {
    public struct Day {
        public let date: Date

        public let value: Int?

        public let intensity: Double

        public let isAhead: Bool
    }

    public struct Week {
        public let start: Date

        public let days: [Day]
    }

    public let pictogram: Pictogram
    public let title: String

    private let values: [Date: Int]
    private let end: Date?
    private let calendar: Calendar

    init(_ values: [Date: Int], endingOn end: Date?, calendar: Calendar, title: String, pictogram: Pictogram) {
        self.values = values
        self.end = end
        self.calendar = calendar
        self.title = title
        self.pictogram = pictogram
    }

    var weekdays: [Schedule.Weekday] {
        Schedule.Weekday.ordered(in: calendar)
    }

    /// The grid as it stood on the day it ends on. There is none before that day, so a span that hasn't
    /// started yet has no weeks to show.
    func weeks(_ count: Int) -> [Week] {
        guard count > 0, let end, let last = calendar.dateInterval(of: .weekOfYear, for: end)?.start else {
            return []
        }

        let starts = (0 ..< count)
            .reversed()
            .compactMap { calendar.date(byAdding: .weekOfYear, value: -$0, to: last) }

        let dates = starts.map { start in
            (0 ..< 7)
                .compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
                .map { calendar.startOfDay(for: $0) }
        }

        let peak = dates.joined().compactMap { values[$0] }.max() ?? 0
        let lastDay = calendar.startOfDay(for: end)

        return zip(starts, dates).map { start, dates in
            Week(start: start, days: dates.map { date in
                let value = values[date]

                return Day(
                    date: date,
                    value: value,
                    intensity: peak > 0 ? Double(value ?? 0) / Double(peak) : 0,
                    isAhead: date > lastDay
                )
            })
        }
    }
}

extension Heatmap.Day: Identifiable {
    public var id: Date {
        date
    }
}

extension Heatmap.Week: Identifiable {
    public var id: Date {
        start
    }
}

extension Heatmap {
    static func activity(_ days: [Date], endingOn end: Date?, calendar: Calendar) -> Self {
        let counts = days.reduce(into: [Date: Int]()) { $0[$1, default: 0] += 1 }

        return Heatmap(
            counts,
            endingOn: end,
            calendar: calendar,
            title: String(localized: .statisticActivityTitle),
            pictogram: .activity
        )
    }
}
