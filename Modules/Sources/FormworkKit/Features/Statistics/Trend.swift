//
//  Trend.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

public struct Trend {
    public enum Direction: Sendable {
        case up
        case down
        case flat
    }

    let recent: Double?

    let before: Double?

    let direction: Direction?

    /// Without a tolerance the value doesn't compare, so `before` and `direction` stay nil. With `perSession`, only
    /// sessions that have a value of their own count towards the minimum; otherwise the value exists across several.
    init(_ history: History, tolerance: Double?, perSession: Bool, value: (History.Window) -> Double?) {
        let baseline = history.baseline
        let recent = value(history.recent)
        let count = perSession ? baseline.sessions.count { value(history.session($0)) != nil } : baseline.sessions.count
        let before = tolerance == nil || count < History.minimumValues ? nil : value(baseline)

        self.recent = recent
        self.before = before
        self.direction = tolerance.flatMap { Direction(from: before, to: recent, tolerance: $0) }
    }
}

extension Trend.Direction {
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
