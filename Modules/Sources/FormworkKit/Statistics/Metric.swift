//
//  Metric.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

public protocol Metric: Indicator {
    static var tolerance: Double? {
        get
    }

    static var axisSteps: [Double] {
        get
    }

    var value: Double? {
        get
    }

    func reading(of value: Double) -> Reading
}

extension Metric {
    public static var tolerance: Double? {
        0.05
    }

    public static var axisSteps: [Double] {
        []
    }

    public var reading: Reading? {
        value.map(reading(of:))
    }

    public static func axisStep(upTo peak: Double, count: Int = 4) -> Double? {
        guard peak > 0 else {
            return nil
        }

        return axisSteps.first { (peak / $0).rounded(.up) <= Double(count) } ?? axisSteps.last
    }
}
