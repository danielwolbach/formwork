//
//  ExerciseTarget.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 04.09.26.
//

import Foundation

public enum ExerciseTarget: Codable, Hashable, Sendable {
    case weight(kilograms: Double = 10, reps: Int = 10, sets: Int = 3)
    case bodyweight(reps: Int = 10, sets: Int = 3)
    case duration(seconds: Int = 60 * 10, sets: Int = 1)
    case distance(meters: Int = 1000 * 1, sets: Int = 1)
}

extension ExerciseTarget {
    public var pictogram: Pictogram {
        exerciseKind.pictogram
    }

    public var title: String {
        exerciseKind.title
    }

    public var rank: Double {
        switch self {
        case let .weight(kilograms, _, _): kilograms
        case let .bodyweight(reps, _): Double(reps)
        case let .duration(seconds, _): Double(seconds)
        case let .distance(meters, _): Double(meters)
        }
    }

    public var volume: Double? {
        guard case let .weight(kilograms, reps, sets) = self else {
            return nil
        }

        return kilograms * Double(reps * sets)
    }

    public var exerciseKind: Exercise.Kind {
        switch self {
        case .weight: Exercise.Kind.weight
        case .bodyweight: Exercise.Kind.bodyweight
        case .duration: Exercise.Kind.duration
        case .distance: Exercise.Kind.distance
        }
    }

    public func isImprovement(over other: ExerciseTarget) -> Bool {
        switch (self, other) {
        case let (.weight(kilograms, reps, sets), .weight(otherKilograms, otherReps, otherSets)):
            kilograms == otherKilograms ? reps * sets > otherReps * otherSets : kilograms > otherKilograms
        case let (.bodyweight(reps, sets), .bodyweight(otherReps, otherSets)):
            reps == otherReps ? sets > otherSets : reps > otherReps
        case let (.duration(seconds, sets), .duration(otherSeconds, otherSets)):
            seconds == otherSeconds ? sets > otherSets : seconds > otherSeconds
        case let (.distance(meters, sets), .distance(otherMeters, otherSets)):
            meters == otherMeters ? sets > otherSets : meters > otherMeters
        default:
            true
        }
    }
}

extension ExerciseTarget {
    public static func initial(for kind: Exercise.Kind, in units: Units) -> ExerciseTarget {
        switch kind {
        case .weight:
            let load = units.weight == .metric ? Measurement(value: 10, unit: UnitMass.kilograms) : Measurement(value: 20, unit: UnitMass.pounds)
            return .weight(kilograms: load.converted(to: .kilograms).value)
        case .bodyweight:
            return .bodyweight()
        case .duration:
            return .duration()
        case .distance:
            let distance = units.distance == .metric ? Measurement(value: 1, unit: UnitLength.kilometers) : Measurement(value: 1, unit: UnitLength.miles)
            return .distance(meters: Int(distance.converted(to: .meters).value.rounded()))
        }
    }
}
