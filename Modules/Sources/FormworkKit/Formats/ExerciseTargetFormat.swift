//
//  ExerciseTargetFormat.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 29.09.26.
//

import Foundation

public struct ExerciseTargetFormat: FormatStyle {
    let system: UnitSystem

    public init(system: UnitSystem) {
        self.system = system
    }

    public func format(_ target: ExerciseTarget) -> String {
        let rank = RankFormat(kind: target.exerciseKind, system: system).format(target.rank)

        return switch target {
        case let .weight(_, reps, sets): [rank, String(localized: .exerciseTargetWeightScheme(sets: sets, reps: reps))].formatted(.dotList)
        case let .bodyweight(reps, sets): String(localized: .exerciseTargetBodyweightScheme(sets: sets, reps: reps))
        case let .duration(_, sets): sets == 1 ? rank : String(localized: .exerciseTargetDurationScheme(sets: sets, duration: rank))
        case let .distance(_, sets): sets == 1 ? rank : String(localized: .exerciseTargetDistanceScheme(sets: sets, distance: rank))
        }
    }
}

extension FormatStyle where Self == ExerciseTargetFormat {
    public static func exerciseTarget(system: UnitSystem) -> ExerciseTargetFormat {
        ExerciseTargetFormat(system: system)
    }
}

extension ExerciseTarget {
    public func formatted<Style: FormatStyle>(_ style: Style) -> Style.FormatOutput where Style.FormatInput == Self {
        style.format(self)
    }
}
