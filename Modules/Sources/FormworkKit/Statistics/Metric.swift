//
//  Metric.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

public protocol Metric: Statistic {
    associatedtype Format: FormatStyle where Format.FormatInput == Double, Format.FormatOutput == String

    static var tolerance: Double? {
        get
    }

    static var axisSteps: [Double] {
        get
    }

    var value: Double? {
        get
    }

    var format: Format {
        get
    }
}

extension Metric {
    public static var tolerance: Double? {
        0.05
    }

    public static var axisSteps: [Double] {
        []
    }

    public var subtitle: String? {
        value.map(format.format)
    }

    public static func axisStep(upTo peak: Double, count: Int = 4) -> Double? {
        guard peak > 0 else {
            return nil
        }

        return axisSteps.first { (peak / $0).rounded(.up) <= Double(count) } ?? axisSteps.last
    }
}
