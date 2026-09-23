//
//  Progression.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 22.09.26.
//

import Foundation

public struct Progression<Value: Rankable> {
    public struct Point {
        public let date: Date

        public let value: Value
    }

    public let pictogram: Pictogram

    public let title: String

    public let points: [Point]

    init(_ points: [Point], title: String, pictogram: Pictogram) {
        self.points = points
        self.title = title
        self.pictogram = pictogram
    }

    func label(for rank: Double) -> String {
        points.last?.value.label(for: rank) ?? rank.formatted(.number.precision(.fractionLength(0)))
    }
}

extension Progression.Point: Identifiable {
    public var id: Date {
        date
    }
}

extension Progression.Point {
    public var rank: Double {
        value.rank
    }
}

extension Progression where Value == ExerciseTarget {
    /// The best of the given entries on each day they fall on. They are the ones that were completed: what
    /// an exercise got to says nothing about the days it was skipped on.
    static func targets(_ completed: [SessionEntry], of type: ExerciseType, calendar: Calendar) -> Self {
        let best = completed
            .filter { $0.target.type == type }
            .reduce(into: [Date: ExerciseTarget]()) { best, entry in
                guard let day = entry.session?.period(of: .day, in: calendar)?.start else {
                    return
                }

                if best[day].map({ $0.rank < entry.target.rank }) ?? true {
                    best[day] = entry.target
                }
            }

        let points = best
            .sorted { $0.key < $1.key }
            .map { Point(date: $0.key, value: $0.value) }

        return Progression(points, title: String(localized: .statisticProgressionTitle), pictogram: .progression)
    }
}
