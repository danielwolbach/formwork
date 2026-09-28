//
//  Progression.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

public struct Progression {
    public struct Point: Identifiable {
        public let date: Date

        public let target: ExerciseTarget

        public var id: Date {
            date
        }
    }

    public let period: DateInterval

    public let points: [Point]

    public let curve: [Point]

    public let unitSystem: UnitSystem
}

extension Progression: Statistic {
    public init(_ window: History.Window) {
        let history = window.history
        let last = history.calendar.date(byAdding: .day, value: -1, to: window.interval.end) ?? window.interval.end
        let weekly = sequence(first: last) { history.calendar.date(byAdding: .weekOfYear, value: -1, to: $0) }
            .prefix { $0 >= window.interval.start }

        self.period = window.period
        self.points = Self.bests(in: window)
        self.curve = weekly.reversed().compactMap { day in
            TypicalBest(history.days(History.recentDays, endingOn: day)).target.map { Point(date: day, target: $0) }
        }
        self.unitSystem = .current
    }

    public static var info: String {
        String(localized: .statisticProgressionInfo)
    }

    public var pictogram: Pictogram {
        .progression
    }

    public var title: String {
        String(localized: .statisticProgressionTitle)
    }

    public var format: TargetFormat {
        TargetFormat(kind: points.last?.target.exerciseKind, system: unitSystem)
    }

    static func bests(in window: History.Window) -> [Point] {
        let exercise: Exercise? = switch window.history.subject {
        case .all, .workout: nil
        case let .exercise(exercise): exercise
        case let .entry(slot): slot.exercise
        }

        guard let exercise else {
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
}
