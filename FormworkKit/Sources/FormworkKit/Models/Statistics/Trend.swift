//
//  Trend.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

/// Which way a trend went.
enum Direction: Sendable {
    case up
    case down
    case flat
}

/// A metric over the recent days next to the days before them.
struct Trend<M: Metric> {
    let recent: M

    /// There's none for a metric that doesn't compare, or while the earlier days hold too few sessions to say
    /// anything.
    let baseline: M?

    init(_: M.Type = M.self, of history: History) {
        let baseline = history.baseline
        self.recent = M(history.recent)
        self.baseline = M.tolerance == nil || baseline.sessions.count < Self.minimumSessions ? nil : M(baseline)
    }
}

extension Trend {
    /// How many sessions the earlier days need before a trend says anything.
    static var minimumSessions: Int {
        3
    }

    var direction: Direction? {
        M.tolerance.flatMap { Direction(from: baseline?.value, to: recent.value, tolerance: $0) }
    }
}

extension Direction {
    /// How `new` compares with `old`, flat within `tolerance` of it. There's none without both.
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

    var image: String {
        switch self {
        case .up: "arrow.up.right"
        case .down: "arrow.down.right"
        case .flat: "arrow.right"
        }
    }
}
