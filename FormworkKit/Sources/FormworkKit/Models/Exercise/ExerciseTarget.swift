//
//  ExerciseTarget.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 04.09.26.
//

public enum ExerciseTarget: Codable, Sendable {
    public struct WeightTarget: Codable, Hashable, Sendable {
        public var weight: Quantity
        public var sets: Int
        public var reps: Int

        public init(weight: Quantity, sets: Int, reps: Int) {
            self.weight = weight
            self.sets = sets
            self.reps = reps
        }
    }

    public struct BodyweightTarget: Codable, Hashable, Sendable {
        public var sets: Int
        public var reps: Int

        public init(sets: Int, reps: Int) {
            self.sets = sets
            self.reps = reps
        }
    }

    public struct DurationTarget: Codable, Hashable, Sendable {
        public var duration: Quantity

        public init(duration: Quantity) {
            self.duration = duration
        }
    }

    public struct DistanceTarget: Codable, Hashable, Sendable {
        public var distance: Quantity

        public init(distance: Quantity) {
            self.distance = distance
        }
    }

    case weight(target: WeightTarget)
    case bodyweight(target: BodyweightTarget)
    case duration(target: DurationTarget)
    case distance(target: DistanceTarget)
}

public extension ExerciseTarget {
    var volume: Quantity? {
        guard case let .weight(target) = self else {
            return nil
        }

        var quantity = target.weight
        quantity.base = target.weight.base * Double(target.sets * target.reps)
        return quantity
    }
}

public extension ExerciseTarget.WeightTarget {
    var symbol: String {
        weight.unit.symbol
    }

    var stepSize: Double {
        switch weight.unit {
        case .pounds: 2.5
        default: 5
        }
    }

    var fractionLength: Int {
        weight.unit.fractionLength
    }

    var range: ClosedRange<Double> {
        switch weight.unit {
        case .pounds: 1 ... 2000
        default: 1 ... 1000
        }
    }
}

public extension ExerciseTarget.BodyweightTarget {
    var symbol: String {
        String(localized: .unitRepsSymbol)
    }

    var stepSize: Int {
        2
    }

    var range: ClosedRange<Int> {
        1 ... 1000
    }
}

public extension ExerciseTarget.DurationTarget {
    var symbol: String {
        duration.unit.symbol
    }

    var stepSize: Double {
        switch duration.unit {
        case .hours: 0.25
        case .minutes: 5
        default: 10
        }
    }

    var fractionLength: Int {
        duration.unit.fractionLength
    }

    var range: ClosedRange<Double> {
        switch duration.unit {
        case .hours: 1 ... 100
        case .minutes: 1 ... 10000
        default: 1 ... 100_000
        }
    }
}

public extension ExerciseTarget.DistanceTarget {
    var symbol: String {
        distance.unit.symbol
    }

    var stepSize: Double {
        switch distance.unit {
        case .meters: 100
        default: 0.25
        }
    }

    var fractionLength: Int {
        distance.unit.fractionLength
    }

    var range: ClosedRange<Double> {
        switch distance.unit {
        case .meters: 1 ... 100_000
        default: 1 ... 1000
        }
    }
}

extension ExerciseTarget: Displayable {
    public var type: ExerciseType {
        switch self {
        case .weight: .weight
        case .bodyweight: .bodyweight
        case .duration: .duration
        case .distance: .distance
        }
    }

    public var pictogram: Pictogram {
        type.pictogram
    }

    public var title: String {
        type.title
    }

    public var subtitle: String? {
        switch self {
        case let .weight(target): String(localized: .exerciseTargetWeightSubtitle(target.weight.formatted, target.sets, target.reps))
        case let .bodyweight(target): String(localized: .exerciseTargetBodyweightSubtitle(target.sets, target.reps))
        case let .duration(target): target.duration.formatted
        case let .distance(target): target.distance.formatted
        }
    }
}

extension ExerciseTarget: Rankable {
    public var rank: Double {
        switch self {
        case let .weight(target): target.weight.base
        case let .bodyweight(target): Double(target.reps)
        case let .duration(target): target.duration.base
        case let .distance(target): target.distance.base
        }
    }

    public var symbol: String {
        switch self {
        case let .weight(target): target.symbol
        case let .bodyweight(target): target.symbol
        case let .duration(target): target.symbol
        case let .distance(target): target.symbol
        }
    }

    public func label(for rank: Double) -> String {
        guard let quantity else {
            return "\(rank.rounded().formatted(.number.precision(.fractionLength(0)))) \(symbol)"
        }

        var measured = quantity
        measured.base = rank
        return measured.formatted
    }

    public var formattedRank: String {
        formattedRank(rank)
    }

    public func formattedRank(_ rank: Double) -> String {
        guard case .bodyweight = self else {
            return label(for: rank)
        }

        return String(localized: .exerciseTargetRepsTitle(Int(rank.rounded())))
    }

    private var quantity: Quantity? {
        switch self {
        case let .weight(target): target.weight
        case let .duration(target): target.duration
        case let .distance(target): target.distance
        case .bodyweight: nil
        }
    }
}
