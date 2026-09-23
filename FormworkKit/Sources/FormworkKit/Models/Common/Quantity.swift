//
//  Quantity.swift
//  Formwork
//
//  Created by Daniel Wolbach on 17.09.26.
//

import Foundation

public struct Quantity: Codable, Hashable, Sendable {
    public enum Unit: String, Codable, CaseIterable, Sendable {
        public enum Dimension: Sendable {
            case weight, duration, distance
        }

        case kilograms, pounds, seconds, minutes, hours, meters, kilometers, miles
    }

    public var base: Double
    public var unit: Unit

    public init(_ value: Double, in unit: Unit) {
        self.unit = unit
        self.base = value * unit.factor
    }
}

public extension Quantity {
    var value: Double {
        get {
            let scale = pow(10.0, Double(unit.fractionLength))
            return (base / unit.factor * scale).rounded() / scale
        }
        set {
            base = newValue * unit.factor
        }
    }

    var formatted: String {
        "\(value.formatted(.number.precision(.fractionLength(unit.fractionLength)))) \(unit.symbol)"
    }

    static var defaultWeight: Self {
        switch Locale.current.measurementSystem {
        case .us: Quantity(25, in: .pounds)
        default: Quantity(10, in: .kilograms)
        }
    }

    static var defaultDuration: Self {
        Quantity(10, in: .minutes)
    }

    static var defaultDistance: Self {
        switch Locale.current.measurementSystem {
        case .metric: Quantity(1, in: .kilometers)
        default: Quantity(1, in: .miles)
        }
    }
}

extension Quantity.Unit: Identifiable {
    public var id: Self {
        self
    }
}

public extension Quantity.Unit {
    var factor: Double {
        switch self {
        case .kilograms, .seconds, .meters: 1
        case .pounds: 0.45359237
        case .minutes: 60
        case .hours: 3600
        case .kilometers: 1000
        case .miles: 1609.344
        }
    }

    var symbol: String {
        // FIXME: Does this need string catalog entries or are they the same worldwide?
        switch self {
        case .kilograms: "kg"
        case .pounds: "lbs"
        case .seconds: "s"
        case .minutes: "min"
        case .hours: "h"
        case .meters: "m"
        case .kilometers: "km"
        case .miles: "mi"
        }
    }

    var name: String {
        switch self {
        case .kilograms: String(localized: .unitKilogramsTitle)
        case .pounds: String(localized: .unitPoundsTitle)
        case .seconds: String(localized: .unitSecondsTitle)
        case .minutes: String(localized: .unitMinutesTitle)
        case .hours: String(localized: .unitHoursTitle)
        case .meters: String(localized: .unitMetersTitle)
        case .kilometers: String(localized: .unitKilometersTitle)
        case .miles: String(localized: .unitMilesTitle)
        }
    }

    var fractionLength: Int {
        switch self {
        case .kilograms, .pounds: 1
        case .seconds, .minutes, .meters: 0
        case .hours, .kilometers, .miles: 2
        }
    }

    var dimension: Dimension {
        switch self {
        case .kilograms, .pounds: .weight
        case .seconds, .minutes, .hours: .duration
        case .meters, .kilometers, .miles: .distance
        }
    }

    var alternatives: [Self] {
        Self.allCases.filter { $0.dimension == dimension }
    }
}
