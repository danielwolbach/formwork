//
//  ExerciseTarget.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 04.09.26.
//

public enum ExerciseTarget: Codable, Sendable {
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
}
