//
//  TypicalDuration.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

public struct TypicalDuration {
    public let value: Double?
}

extension TypicalDuration: Metric {
    public init(_ window: History.Window) {
        self.value = window.completions.compactMap(\.duration).median
    }

    public static var info: String {
        String(localized: .statisticTypicalDurationInfo)
    }

    public static var pictogram: Pictogram {
        .duration
    }

    public static var title: String {
        String(localized: .statisticTypicalDurationTitle)
    }

    public static var tolerance: Double? {
        0.05
    }

    public func reading(of value: Double) -> Reading {
        .duration(seconds: value)
    }
}
