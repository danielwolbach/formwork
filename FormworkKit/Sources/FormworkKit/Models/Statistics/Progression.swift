//
//  Progression.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

/// How an exercise went, day by day and as a curve through the days. Only means something for an exercise.
struct Progression {
    struct Point {
        let date: Date

        let target: ExerciseTarget
    }

    /// The days the window asked for, for a chart to span.
    let period: DateInterval

    /// The best completed target on each day within the window, oldest first.
    let points: [Point]

    /// The typical best as it stood once a week, up to the window's last day on record. Each looks back the
    /// `recentDays` up to it, before the window's start too, so the curve ends on the recent typical best. A week
    /// with no day to look back on has none, so a line through the others bridges the gap.
    let curve: [Point]
}

extension Progression: Statistic {
    init(_ window: History.Window) {
        let history = window.history
        let last = history.calendar.date(byAdding: .day, value: -1, to: window.interval.end) ?? window.interval.end
        let weekly = sequence(first: last) { history.calendar.date(byAdding: .weekOfYear, value: -1, to: $0) }
            .prefix { $0 >= window.interval.start }

        self.period = window.period
        self.points = Self.bests(in: window)
        self.curve = weekly.reversed().compactMap { day in
            TypicalBest(history.days(History.recentDays, endingOn: day)).target.map { Point(date: day, target: $0) }
        }
    }

    static var explanation: String {
        String(localized: ._Placeholder)
    }

    var pictogram: Pictogram {
        .progression
    }

    var title: String {
        String(localized: .statisticProgressionTitle)
    }

    /// The best completed target of the exercise's current type on each day within the window, oldest first. The
    /// exercise's other types are left out: their ranks don't compare. There are none for any other subject.
    static func bests(in window: History.Window) -> [Point] {
        guard case let .exercise(exercise) = window.history.subject else {
            return []
        }

        let best = window.entries
            .filter { $0.status.isCompleted && $0.target.type == exercise.type }
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

    /// A rank written out in the unit the latest day was recorded in, e.g. for axis labels.
    func label(for rank: Double) -> String {
        points.last?.target.label(for: rank) ?? rank.formatted(.number.precision(.fractionLength(0)))
    }
}

extension Progression.Point: Identifiable {
    var id: Date {
        date
    }
}
