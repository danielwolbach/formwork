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

        public var symbol: String {
            weight.unit.symbol
        }

        public var stepSize: Double {
            switch weight.unit {
            case .pounds: 2.5
            default: 5
            }
        }

        public var fractionLength: Int {
            weight.unit.fractionLength
        }

        public var range: ClosedRange<Double> {
            switch weight.unit {
            case .pounds: 1 ... 2000
            default: 1 ... 1000
            }
        }
    }
}

public extension ExerciseTarget {
    struct BodyweightTarget: Codable, Hashable, Sendable {
        public var sets: Int
        public var reps: Int

        public init(sets: Int, reps: Int) {
            self.sets = sets
            self.reps = reps
        }

        public var symbol: String {
            String(localized: .unitRepsSymbol)
        }

        public var stepSize: Int {
            2
        }

        public var range: ClosedRange<Int> {
            1 ... 1000
        }
    }
}

public extension ExerciseTarget {
    struct DurationTarget: Codable, Hashable, Sendable {
        public var duration: Quantity

        public init(duration: Quantity) {
            self.duration = duration
        }

        public var symbol: String {
            duration.unit.symbol
        }

        public var stepSize: Double {
            switch duration.unit {
            case .hours: 0.25
            case .minutes: 5
            default: 10
            }
        }

        public var fractionLength: Int {
            duration.unit.fractionLength
        }

        public var range: ClosedRange<Double> {
            switch duration.unit {
            case .hours: 1 ... 100
            case .minutes: 1 ... 10000
            default: 1 ... 100_000
            }
        }
    }
}

public extension ExerciseTarget {
    struct DistanceTarget: Codable, Hashable, Sendable {
        public var distance: Quantity

        public init(distance: Quantity) {
            self.distance = distance
        }

        public var symbol: String {
            distance.unit.symbol
        }

        public var stepSize: Double {
            switch distance.unit {
            case .meters: 100
            default: 0.25
            }
        }

        public var fractionLength: Int {
            distance.unit.fractionLength
        }

        public var range: ClosedRange<Double> {
            switch distance.unit {
            case .meters: 1 ... 100_000
            default: 1 ... 1000
            }
        }
    }
}
