//
//  BodyMeasurement.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 10.10.26.
//

import Foundation

public enum BodyMeasurement: CaseIterable, Sendable {
    case weight
    case bodyFat

    public struct Sample: Hashable, Sendable {
        public let date: Date

        public let value: Double

        public init(date: Date, value: Double) {
            self.date = date
            self.value = value
        }
    }
}

extension BodyMeasurement {
    var unit: Reading.Unit {
        switch self {
        case .weight: .weight
        case .bodyFat: .percent
        }
    }
}
