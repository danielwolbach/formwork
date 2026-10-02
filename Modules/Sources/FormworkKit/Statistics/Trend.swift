//
//  Trend.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

public struct Trend<M: Metric> {
    public let recent: M

    public let baseline: M?

    public init(_ history: History) {
        let baseline = history.baseline
        self.recent = M(history.recent)
        self.baseline = M.tolerance == nil || baseline.sessions.count < History.minimumSessions ? nil : M(baseline)
    }
}

extension Trend {
    public var direction: Direction? {
        M.tolerance.flatMap { Direction(from: baseline?.value, to: recent.value, tolerance: $0) }
    }
}
