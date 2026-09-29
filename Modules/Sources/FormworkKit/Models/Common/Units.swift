//
//  Units.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 28.09.26.
//

import Foundation

public struct Units: Hashable, Codable, Sendable {
    public enum System: String, Codable, CaseIterable, Sendable {
        case metric, imperial
    }

    public var weight: System

    public var distance: System

    public init(weight: System, distance: System) {
        self.weight = weight
        self.distance = distance
    }
}

extension Units {
    public static var current: Units {
        Units(weight: .current, distance: .current)
    }

    public var weightUnit: UnitMass {
        switch weight {
        case .metric: .kilograms
        case .imperial: .pounds
        }
    }

    public var distanceUnit: UnitLength {
        switch distance {
        case .metric: .kilometers
        case .imperial: .miles
        }
    }
}

extension Units.System {
    public static var current: Self {
        Locale.current.measurementSystem == .us ? .imperial : .metric
    }

    public var title: String {
        switch self {
        case .metric: .init(localized: .unitSystemMetricTitle)
        case .imperial: .init(localized: .unitSystemImperialTitle)
        }
    }
}

extension Units.System: Identifiable {
    public var id: Self {
        self
    }
}
