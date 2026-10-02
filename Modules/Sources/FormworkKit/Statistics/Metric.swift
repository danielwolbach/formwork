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

    var value: Double? {
        get
    }

    func reading(of value: Double) -> Reading
}

extension Metric {
    public var reading: Reading? {
        value.map(reading(of:))
    }
}
