//
//  WeeklySessions.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

public struct WeeklySessions {
    public let value: Double?
}

extension WeeklySessions: Metric {
    public init(_ window: History.Window) {
        self.value = window.lengthInWeeks.map { Double(window.sessions.count) / $0 }
    }

    public static var info: String {
        String(localized: .statisticWeeklySessionsInfo)
    }

    public static var tolerance: Double? {
        0.1
    }

    public var pictogram: Pictogram {
        .frequency
    }

    public var title: String {
        String(localized: .statisticWeeklySessionsTitle)
    }

    public func reading(of value: Double) -> Reading {
        .rate(value)
    }
}
