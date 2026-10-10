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

    init(recent: Double?, before: @autoclosure () -> Double?, values: Int, tolerance: Double?) {
        let before = tolerance == nil || values < History.minimumValues ? nil : before()

        self.recent = recent
        self.before = before
        self.direction = tolerance.flatMap { Direction(from: before, to: recent, tolerance: $0) }
    }
}

extension Trend {
    init(_ history: History, tolerance: Double?, perSession: Bool, value: (History.Window) -> Double?) {
        let baseline = history.baseline
        let count = perSession ? baseline.sessions.count { value(history.session($0)) != nil } : baseline.sessions.count

        self.init(recent: value(history.recent), before: value(baseline), values: count, tolerance: tolerance)
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
