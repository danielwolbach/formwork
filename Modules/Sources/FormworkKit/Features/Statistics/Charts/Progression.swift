//
//  Progression.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

public struct Progression {
    public struct Point {
        public let date: Date

        public let target: ExerciseTarget
    }

    public let kind: Exercise.Kind?

    public let period: DateInterval

    public let points: [Point]

    public let curve: [Point]
}

extension Progression {
    public init(_ window: History.Window) {
        let history = window.history
        let last = history.calendar.date(byAdding: .day, value: -1, to: window.interval.end) ?? window.interval.end
        let weekly = sequence(first: last) { history.calendar.date(byAdding: .weekOfYear, value: -1, to: $0) }
            .prefix { $0 >= window.interval.start }

        // From the exercise, not the points: the curve looks back before the window and may have no point to go on.
        self.kind = history.subject.exercise?.kind
        self.period = window.period
        self.points = window.dailyBests
        self.curve = weekly.reversed().compactMap { day in
            history.days(History.recentDays, endingOn: day).typicalBest.map { Point(date: day, target: $0) }
        }
    }

    public func reading(of rank: Double) -> Reading {
        Reading(rank: rank, of: kind)
    }
}

extension Progression.Point: Identifiable {
    public var id: Date {
        date
    }
}
