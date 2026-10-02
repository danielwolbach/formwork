//
//  TypicalInterval.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 28.09.26.
//

import Foundation

public struct TypicalInterval {
    public let value: Double?
}

extension TypicalInterval: Metric {
    public init(_ window: History.Window) {
        let calendar = window.history.calendar
        let days = Set(window.completions.compactMap { $0.session.period(of: .day, in: calendar)?.start }).sorted()
        self.value = zip(days, days.dropFirst())
            .compactMap { calendar.dateComponents([.day], from: $0, to: $1).day }
            .map(Double.init)
            .median
    }

    public static var info: String {
        String(localized: .statisticTypicalIntervalInfo)
    }

    public static var pictogram: Pictogram {
        .frequency
    }

    public static var title: String {
        String(localized: .statisticTypicalIntervalTitle)
    }

    public static var tolerance: Double? {
        0.1
    }

    public func reading(of value: Double) -> Reading {
        .days(value)
    }
}
