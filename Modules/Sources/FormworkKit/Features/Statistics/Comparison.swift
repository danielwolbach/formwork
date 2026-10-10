//
//  Comparison.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 10.10.26.
//

import Foundation

public struct Comparison: Hashable {
    public enum Direction: Sendable {
        case up
        case down
        case flat
    }

    public let current: Reading?

    public let typical: Reading?

    public let direction: Direction?

    public init(current: Reading?, typical: Reading?, direction: Direction?) {
        self.current = current
        self.typical = typical
        self.direction = direction
    }
}

extension Comparison {
    public init(_ quantity: Quantity, of session: Session, among sessions: [Session], calendar: Calendar = .current) {
        let unit = quantity.unit(of: nil, in: calendar)
        let current = quantity.value(of: Occurrence(session, in: calendar), in: calendar)
        let typical = Self.before(session, among: sessions, calendar: calendar).flatMap { period in
            let formula = Formula.typical(quantity)
            return formula.sampleCount(in: period) < History.minimumValues ? nil : period.value(formula)
        }

        self.init(
            current: current.map { Reading($0, as: unit) },
            typical: typical.map { Reading($0, as: unit) },
            direction: quantity.isClock ? nil : Direction(from: typical, to: current, tolerance: 0.05)
        )
    }

    init(_ history: History, tolerance: Double?, unit: Reading.Unit, samples: (Period) -> Int, value: (Period) -> Double?) {
        let current = value(history.recent)
        let baseline = history.baseline
        let typical = tolerance == nil || samples(baseline) < History.minimumValues ? nil : value(baseline)

        self.init(
            current: current.map { Reading($0, as: unit) },
            typical: typical.map { Reading($0, as: unit) },
            direction: tolerance.flatMap { Direction(from: typical, to: current, tolerance: $0) }
        )
    }

    static func before(_ session: Session, among sessions: [Session], calendar: Calendar) -> Period? {
        guard
            let workout = session.workout,
            let day = session.period(of: .day, in: calendar)?.start,
            let before = calendar.date(byAdding: .day, value: -1, to: day)
        else {
            return nil
        }

        return History(.workout(workout), among: sessions, at: day, calendar: calendar).days(History.recentWeeks * 7, endingOn: before)
    }
}

extension Comparison.Direction {
    init?(from old: Double?, to new: Double?, tolerance: Double) {
        guard let old, let new else {
            return nil
        }

        guard old != 0 else {
            self = new == 0 ? .flat : .up
            return
        }

        let change = (new - old) / abs(old)
        self = abs(change) <= tolerance ? .flat : change > 0 ? .up : .down
    }

    public var image: String {
        switch self {
        case .up: "arrow.up.forward"
        case .down: "arrow.down.forward"
        case .flat: "arrow.forward"
        }
    }
}

extension History {
    public func comparison(_ formula: Formula, tolerance: Double?) -> Comparison {
        guard let unit = formula.unit(in: self) else {
            return Comparison(current: recent.reading(formula), typical: nil, direction: nil)
        }

        return Comparison(self, tolerance: tolerance, unit: unit, samples: formula.sampleCount(in:)) { $0.value(formula) }
    }
}
