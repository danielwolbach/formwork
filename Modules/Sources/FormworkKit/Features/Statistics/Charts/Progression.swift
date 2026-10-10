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

    public let span: DateInterval

    public let points: [Point]

    public let curve: [Point]
}

extension Progression {
    public init(_ period: Period) {
        let history = period.history
        let last = history.calendar.date(byAdding: .day, value: -1, to: period.interval.end) ?? period.interval.end
        let weekly = sequence(first: last) { history.calendar.date(byAdding: .weekOfYear, value: -1, to: $0) }
            .prefix { $0 >= period.interval.start }

        // From the exercise, not the points: the curve looks back before the period and may have no point to go on.
        self.kind = history.subject.exercise?.kind
        self.span = period.span
        self.points = period.dailyBests
        self.curve = weekly.reversed().compactMap { day in
            history.days(History.recentWeeks * 7, endingOn: day).typicalBest.map { Point(date: day, target: $0) }
        }
    }

    /// The typical best recently against the one before.
    public static func comparison(in history: History) -> Comparison {
        Comparison(history, tolerance: 0.02, unit: .rank(history.subject.exercise?.kind), samples: \.occurrences.count) { $0.typicalBest?.rank }
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

extension Period {
    var dailyBests: [Progression.Point] {
        guard let exercise = history.subject.exercise else {
            return []
        }

        let best = occurrences
            .flatMap(\.entries)
            .filter { $0.status.isCompleted && $0.target.exerciseKind == exercise.kind }
            .reduce(into: [Date: ExerciseTarget]()) { best, entry in
                guard let day = entry.session?.period(of: .day, in: history.calendar)?.start else {
                    return
                }

                if best[day].map({ $0.rank < entry.target.rank }) ?? true {
                    best[day] = entry.target
                }
            }

        return best
            .sorted { $0.key < $1.key }
            .map { Progression.Point(date: $0.key, target: $0.value) }
    }

    /// The middle day's best, and one actually done rather than between two.
    var typicalBest: ExerciseTarget? {
        let ranked = dailyBests.map(\.target).sorted { $0.rank < $1.rank }
        return ranked.isEmpty ? nil : ranked[(ranked.count - 1) / 2]
    }
}
