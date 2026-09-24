//
//  Statistic.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

/// Anything worked out from a history's window.
protocol Statistic: Displayable {
    /// What the statistic means and how it's worked out, for its sheet.
    static var explanation: String {
        get
    }

    init(_ window: History.Window)
}

/// A statistic that comes down to one number, so two windows can be compared and a year charted by month.
protocol Metric: Statistic {
    /// The relative change that still counts as flat. There's none for a metric that grows with the length of
    /// its window, like a count: four weeks would always look worse than twelve.
    static var tolerance: Double? {
        get
    }

    /// The steps an axis may take, smallest first, for units whose round numbers aren't round in the metric's
    /// own terms: 2,000 seconds reads as 33 min 20 sec. Empty leaves the axis to the chart.
    static var axisSteps: [Double] {
        get
    }

    /// In the metric's own units, e.g. seconds or a share. There's none without anything to work it out from.
    var value: Double? {
        get
    }

    /// A value written out the way the metric writes its own, e.g. for axis labels.
    func label(for value: Double) -> String
}

extension Metric {
    static var axisSteps: [Double] {
        []
    }

    var subtitle: String? {
        value.map { label(for: $0) }
    }

    /// The smallest of `axisSteps` that reaches `peak` in at most `count` marks, or the largest if none does.
    /// There's none without steps or without anything to show.
    static func axisStep(upTo peak: Double, count: Int = 4) -> Double? {
        guard peak > 0 else {
            return nil
        }

        return axisSteps.first { (peak / $0).rounded(.up) <= Double(count) } ?? axisSteps.last
    }
}
