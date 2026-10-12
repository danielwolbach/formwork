//
//  DistanceFormat.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 12.10.26.
//

import Foundation

struct DistanceFormat: FormatStyle {
    let units: Units

    func format(_ meters: Double) -> String {
        let unit = units.distance == .metric && meters < 1000 ? UnitLength.meters : units.distanceUnit

        return Measurement(value: meters, unit: UnitLength.meters)
            .converted(to: unit)
            .formatted(.measurement(width: .abbreviated, usage: .asProvided, numberFormatStyle: .number.precision(.fractionLength(0 ... 2))))
    }
}
