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
