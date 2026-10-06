//
//  EnergyFormat.swift
//  FormworkModules
//
//  Created by Daniel Wolbach on 06.10.26.
//

import Foundation

public struct EnergyFormat: FormatStyle {
    public init() {
        // Nothing to initialize.
    }

    public func format(_ kilocalories: Double) -> String {
        Measurement(value: kilocalories, unit: UnitEnergy.kilocalories)
            .formatted(.measurement(width: .abbreviated, usage: .workout, numberFormatStyle: .number.precision(.fractionLength(0))))
    }
}

extension FormatStyle where Self == EnergyFormat {
    public static var energy: EnergyFormat {
        EnergyFormat()
    }
}
