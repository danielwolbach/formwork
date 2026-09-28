//
//  UnitSystem.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 28.09.26.
//

import Foundation

public enum UnitSystem: String, Codable, CaseIterable, Sendable {
    case metric, imperial
}

extension UnitSystem {
    public static var current: UnitSystem {
        Locale.current.measurementSystem == .us ? .imperial : .metric
    }

    public var title: String {
        switch self {
        case .metric: .init(localized: .unitSystemMetricTitle)
        case .imperial: .init(localized: .unitSystemImperialTitle)
        }
    }

    public var weightUnit: UnitMass {
        switch self {
        case .metric: .kilograms
        case .imperial: .pounds
        }
    }

    public var distanceUnit: UnitLength {
        switch self {
        case .metric: .kilometers
        case .imperial: .miles
        }
    }
}

extension UnitSystem: Identifiable {
    public var id: Self {
        self
    }
}
