//
//  VolumeFormat.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 28.09.26.
//

import Foundation

public struct VolumeFormat: FormatStyle {
    let system: UnitSystem

    public init(system: UnitSystem = .current) {
        self.system = system
    }

    public func format(_ kilograms: Double) -> String {
        Measurement(value: kilograms, unit: UnitMass.kilograms)
            .converted(to: system.weightUnit)
            .formatted(.measurement(width: .abbreviated, usage: .asProvided, numberFormatStyle: .number.precision(.fractionLength(0 ... 1))))
    }
}
