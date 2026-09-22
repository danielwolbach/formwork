//
//  Rankable.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 22.09.26.
//

import Foundation

public protocol Rankable {
    var rank: Double {
        get
    }

    /// What every rank of this kind is measured in. It's the same whatever the rank reads, so a field can
    /// carry it once as a suffix while an axis repeats it on each of its marks.
    var symbol: String {
        get
    }

    /// A rank of this kind as it reads on its own: the number in the unit it was recorded in, with that
    /// unit after it.
    func label(for rank: Double) -> String
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

    /// The target's own rank as it reads on its own. Reps are counted as well as measured, so a target of
    /// them reads as the count, which leaves the plural to the catalog rather than to the unit.
    public var formattedRank: String {
        guard case let .bodyweight(target) = self else {
            return label(for: rank)
        }

        return String(localized: .exerciseTargetRepsTitle(target.reps))
    }

    /// What the target is measured in, if it's measured at all: a bodyweight target counts reps instead.
    private var quantity: Quantity? {
        switch self {
        case let .weight(target): target.weight
        case let .duration(target): target.duration
        case let .distance(target): target.distance
        case .bodyweight: nil
        }
    }
}
