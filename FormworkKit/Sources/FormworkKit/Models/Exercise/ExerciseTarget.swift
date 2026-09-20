//
//  ExerciseTarget.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 04.09.26.
//

public enum ExerciseTarget: Codable, Sendable {
    case weight(target: WeightTarget)
    case bodyweight(target: BodyweightTarget)
    case duration(target: DurationTarget)
    case distance(target: DistanceTarget)

    var rank: Double {
        switch self {
        case let .weight(target): target.weight.base
        case let .bodyweight(target): Double(target.reps)
        case let .duration(target): target.duration.base
        case let .distance(target): target.distance.base
        }
    }

    var formattedRank: String {
        switch self {
        case let .weight(target): target.weight.formatted
        case let .bodyweight(target): String(localized: .exerciseTargetRepsTitle(target.reps))
        case let .duration(target): target.duration.formatted
        case let .distance(target): target.distance.formatted
        }
    }

    var volume: Quantity? {
        guard case let .weight(target) = self else {
            return nil
        }

        var quantity = target.weight
        quantity.base = target.weight.base * Double(target.sets * target.reps)
        return quantity
    }
}

public extension ExerciseTarget {
    struct WeightTarget: Codable, Hashable, Sendable {
        public var weight: Quantity
        public var sets: Int
        public var reps: Int

        public init(weight: Quantity, sets: Int, reps: Int) {
            self.weight = weight
            self.sets = sets
            self.reps = reps
        }
    }

    struct BodyweightTarget: Codable, Hashable, Sendable {
        public var sets: Int
        public var reps: Int

        public init(sets: Int, reps: Int) {
            self.sets = sets
            self.reps = reps
        }
    }

    struct DurationTarget: Codable, Hashable, Sendable {
        public var duration: Quantity

        public init(duration: Quantity) {
            self.duration = duration
        }
    }

    struct DistanceTarget: Codable, Hashable, Sendable {
        public var distance: Quantity

        public init(distance: Quantity) {
            self.distance = distance
        }
    }
}
