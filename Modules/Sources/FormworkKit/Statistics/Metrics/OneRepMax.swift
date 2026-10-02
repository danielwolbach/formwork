//
//  OneRepMax.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 28.09.26.
//

import Foundation

public struct OneRepMax {
    public let kilograms: Double?
}

extension OneRepMax: Metric {
    public init(_ window: History.Window) {
        self.kilograms = window.entries
            .filter(\.status.isCompleted)
            .compactMap { entry -> Double? in
                guard case let .weight(kilograms, reps, _) = entry.target, reps > 0 else {
                    return nil
                }

                return kilograms * (1 + Double(reps) / 30)
            }
            .max()
    }

    public static var info: String {
        String(localized: .statisticOneRepMaxInfo)
    }

    public static var pictogram: Pictogram {
        .strength
    }

    public static var title: String {
        String(localized: .statisticOneRepMaxTitle)
    }

    public static var tolerance: Double? {
        0.02
    }

    public var value: Double? {
        kilograms
    }

    public func reading(of value: Double) -> Reading {
        .weight(kilograms: value)
    }
}
