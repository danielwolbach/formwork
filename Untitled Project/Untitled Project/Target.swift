//
//  Target.swift
//  MyApp
//
//  Created by Daniel Wolbach on 29.09.26.
//

import Foundation
import Playgrounds

enum Units: Codable {
    case metric, imperial

    static var current: Self {
        Locale.current.measurementSystem == .us ? .imperial : .metric
    }
}

enum ExerciseTarget {
    case weight(kilograms: Double = 10.0, reps: Int = 10, sets: Int = 3)
    case bodyweight(reps: Int = 10, sets: Int = 3)
    case duration(seconds: Int = 60 * 10, sets: Int = 1)
    case distance(meters: Double = 1000 * 1, sets: Int = 1)
}

struct ExerciseTargetFormatStyle: FormatStyle {
    typealias FormatInput = ExerciseTarget

    typealias FormatOutput = String

    private let units: Units

    init(units: Units = .current) {
        self.units = units
    }

    func format(_ value: FormatInput) -> FormatOutput {
        switch value {
        case let .weight(kilograms, reps, sets):
            switch units {
            case .metric: "\(kilograms) kg, \(sets) x \(reps)"
            case .imperial: "\(kilograms * 2.204623) lbs, \(sets) x \(reps)"
            }
        case let .bodyweight(reps, sets): "\(sets) x \(reps)"
        case let .duration(seconds, sets): "\(sets) x \(seconds)"
        case let .distance(meters, sets):
            switch units {
            case .metric: "\(sets) x \(meters * 0.001) km"
            case .imperial: "\(sets) x \(meters * 0.0006213712) mi"
            }
        }
    }
}

extension FormatStyle where Self == ExerciseTargetFormatStyle {
    static var exerciseTarget: ExerciseTargetFormatStyle {
        .init(units: .current)
    }

    static func exerciseTarget(units: Units) -> ExerciseTargetFormatStyle {
        .init(units: units)
    }
}

extension ExerciseTarget {
    func formatted() -> String {
        ExerciseTargetFormatStyle().format(self)
    }

    func formatted<F: FormatStyle>(_ style: F) -> F.FormatOutput where F.FormatInput == ExerciseTarget {
        style.format(self)
    }
}

#Playground {
    ExerciseTarget.distance().formatted(.exerciseTarget(units: .imperial))
}
