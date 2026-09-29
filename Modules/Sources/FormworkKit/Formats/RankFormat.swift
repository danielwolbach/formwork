//
//  RankFormat.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 27.09.26.
//

import Foundation

public struct RankFormat: FormatStyle {
    let kind: Exercise.Kind?

    let system: UnitSystem

    public init(kind: Exercise.Kind?, system: UnitSystem) {
        self.kind = kind
        self.system = system
    }

    public func format(_ rank: Double) -> String {
        switch kind {
        case .weight:
            Measurement(value: rank, unit: UnitMass.kilograms)
                .converted(to: system.weightUnit)
                .formatted(.measurement(width: .abbreviated, usage: .asProvided, numberFormatStyle: .number.precision(.fractionLength(0 ... 1))))
        case .distance:
            distance(rank)
        case .duration:
            DurationFormat().format(rank)
        case .bodyweight:
            String(localized: .exerciseTargetBodyweightRank(count: Int(rank.rounded())))
        case nil:
            rank.formatted(.number.precision(.fractionLength(0)))
        }
    }

    private func distance(_ meters: Double) -> String {
        let measurement = Measurement(value: meters, unit: UnitLength.meters)
        let unit = system == .metric && meters < 1000 ? UnitLength.meters : system.distanceUnit

        return measurement
            .converted(to: unit)
            .formatted(.measurement(width: .abbreviated, usage: .asProvided, numberFormatStyle: .number.precision(.fractionLength(0 ... 2))))
    }
}
