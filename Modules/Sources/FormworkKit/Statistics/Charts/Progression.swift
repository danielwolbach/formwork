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

extension Progression: Statistic {
    public init(_ window: History.Window) {
        let history = window.history
        let last = history.calendar.date(byAdding: .day, value: -1, to: window.interval.end) ?? window.interval.end
        let weekly = sequence(first: last) { history.calendar.date(byAdding: .weekOfYear, value: -1, to: $0) }
            .prefix { $0 >= window.interval.start }

        // From the exercise, not the points: the curve looks back before the window and may have no point to go on.
        self.kind = Self.exercise(of: history.subject)?.kind
        self.period = window.period
        self.points = Self.bests(in: window)
        self.curve = weekly.reversed().compactMap { day in
            TypicalBest(history.days(History.recentDays, endingOn: day)).target.map { Point(date: day, target: $0) }
        }
    }

    public static var info: String {
        String(localized: .statisticProgressionInfo)
    }

    public static var pictogram: Pictogram {
        .progression
    }

    public static var title: String {
        String(localized: .statisticProgressionTitle)
    }

    static func bests(in window: History.Window) -> [Point] {
        guard let exercise = exercise(of: window.history.subject) else {
            return []
        }

        let best = window.entries
            .filter { $0.status.isCompleted && $0.target.exerciseKind == exercise.kind }
            .reduce(into: [Date: ExerciseTarget]()) { best, entry in
                guard let day = entry.session?.period(of: .day, in: window.history.calendar)?.start else {
                    return
                }

                if best[day].map({ $0.rank < entry.target.rank }) ?? true {
                    best[day] = entry.target
                }
            }

        return best
            .sorted { $0.key < $1.key }
            .map { Point(date: $0.key, target: $0.value) }
    }

    private static func exercise(of subject: History.Subject) -> Exercise? {
        switch subject {
        case .all, .workout: nil
        case let .exercise(exercise): exercise
        case let .entry(slot): slot.exercise
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
