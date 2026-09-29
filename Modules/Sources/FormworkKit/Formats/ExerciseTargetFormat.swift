//
//  ExerciseTargetFormat.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 29.09.26.
//

import Foundation

public struct ExerciseTargetFormat: FormatStyle {
    let units: Units

    public init(units: Units) {
        self.units = units
    }

    public func format(_ target: ExerciseTarget) -> String {
        let rank = Reading(rank: target.rank, of: target.exerciseKind).formatted(.reading(units: units))

        return switch target {
        case let .weight(_, reps, sets): [rank, String(localized: .exerciseTargetWeightScheme(sets: sets, reps: reps))].formatted(.dotList)
        case let .bodyweight(reps, sets): String(localized: .exerciseTargetBodyweightScheme(sets: sets, reps: reps))
        case let .duration(_, sets): sets == 1 ? rank : String(localized: .exerciseTargetDurationScheme(sets: sets, duration: rank))
        case let .distance(_, sets): sets == 1 ? rank : String(localized: .exerciseTargetDistanceScheme(sets: sets, distance: rank))
        }
    }
}

extension FormatStyle where Self == ExerciseTargetFormat {
    public static func exerciseTarget(units: Units) -> ExerciseTargetFormat {
        ExerciseTargetFormat(units: units)
    }
}

extension ExerciseTarget {
    public func formatted<Style: FormatStyle>(_ style: Style) -> Style.FormatOutput where Style.FormatInput == Self {
        style.format(self)
    }
}
