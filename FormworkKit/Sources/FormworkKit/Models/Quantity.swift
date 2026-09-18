//
//  Quantity.swift
//  Formwork
//
//  Created by Daniel Wolbach on 17.09.26.
//

import Foundation

public struct Quantity: Codable, Hashable, Sendable {
    public var base: Double
    public var unit: Unit

    public init(_ value: Double, in unit: Unit) {
        self.unit = unit
        self.base = value * unit.factor
    }

    public var value: Double {
        get {
            unit.value(base)
        }
        set {
            base = newValue * unit.factor
        }
    }

    public var formatted: String {
        unit.formatted(base)
    }

    public var symbol: String {
        unit.symbol
    }

    public var stepSize: Double {
        unit.stepSize
    }

    public var fractionLength: Int {
        unit.fractionLength
    }
}

public extension Quantity {
    enum Unit: String, Identifiable, Codable, CaseIterable, Sendable {
        case kilograms, pounds, seconds, minutes, hours, meters, kilometers, miles

        public var id: Self {
            self
        }

        public var factor: Double {
            switch self {
            case .kilograms, .seconds, .meters: 1
            case .pounds: 0.45359237
            case .minutes: 60
            case .hours: 3600
            case .kilometers: 1000
            case .miles: 1609.344
            }
        }

        public var symbol: String {
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

        public var name: String {
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

        public var stepSize: Double {
            switch self {
            case .kilograms: 5
            case .pounds: 2.5
            case .seconds: 10
            case .minutes: 5
            case .hours: 0.25
            case .meters: 100
            case .kilometers, .miles: 0.25
            }
        }

        public var fractionLength: Int {
            switch self {
            case .kilograms, .pounds: 1
            case .seconds, .minutes, .meters: 0
            case .hours, .kilometers, .miles: 2
            }
        }

        public func value(_ base: Double) -> Double {
            let scale = pow(10.0, Double(fractionLength))
            return (base / factor * scale).rounded() / scale
        }

        public func formatted(_ base: Double) -> String {
            "\(value(base).formatted(.number.precision(.fractionLength(fractionLength)))) \(symbol)"
        }
    }
}

public extension Quantity.Unit {
    enum Dimension: Sendable {
        case weight, duration, distance
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

public extension Quantity {
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
