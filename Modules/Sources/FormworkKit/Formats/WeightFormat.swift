//
//  WeightFormat.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 12.10.26.
//

import Foundation

struct WeightFormat: FormatStyle {
    let units: Units

    func format(_ kilograms: Double) -> String {
        Measurement(value: kilograms, unit: UnitMass.kilograms)
            .converted(to: units.weightUnit)
            .formatted(.measurement(width: .abbreviated, usage: .asProvided, numberFormatStyle: .number.precision(.fractionLength(0 ... 1))))
    }
}
