//
//  OneRepMax.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 28.09.26.
//

import Foundation

public struct OneRepMax {
    public let kilograms: Double?

    public let unitSystem: UnitSystem
}

extension OneRepMax: Metric {
    public typealias Format = TargetFormat

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
        self.unitSystem = .current
    }

    public static var info: String {
        String(localized: .statisticOneRepMaxInfo)
    }

    public static var tolerance: Double? {
        0.02
    }

    public var pictogram: Pictogram {
        .strength
    }

    public var title: String {
        String(localized: .statisticOneRepMaxTitle)
    }

    public var value: Double? {
        kilograms
    }

    public var format: Format {
        TargetFormat(kind: .weight, system: unitSystem)
    }
}
