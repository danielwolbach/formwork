//
//  Completions.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

public struct Completions {
    public let count: Int
}

extension Completions: Metric {
    public init(_ window: History.Window) {
        self.count = window.completions.count
    }

    public static var info: String {
        String(localized: .statisticCompletionsInfo)
    }

    public static var pictogram: Pictogram {
        .tally
    }

    public static var title: String {
        String(localized: .statisticCompletionsTitle)
    }

    public static var tolerance: Double? {
        nil
    }

    public var value: Double? {
        Double(count)
    }

    public func reading(of value: Double) -> Reading {
        .count(Int(value.rounded()))
    }
}
