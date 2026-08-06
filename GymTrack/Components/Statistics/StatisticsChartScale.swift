//
//  StatisticsChartScale.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 06.08.26.
//

import Foundation

enum StatisticsChartScale {
    static func domain(for values: [Double]) -> ClosedRange<Double> {
        guard let minimum = values.min(), let maximum = values.max() else {
            return 0 ... 1
        }

        let range = maximum - minimum
        let padding = max(range * 0.1, maximum.magnitude * 0.05, 1)

        return (minimum - padding) ... (maximum + padding)
    }

    static func indicatorDomain(for values: [Double], step: Double) -> ClosedRange<Double> {
        guard let minimum = values.min(), let maximum = values.max(), step > 0 else {
            return 0 ... 1
        }

        let lowerBound = floor(minimum / step) * step
        let upperBound = (floor(maximum / step) + 1) * step

        return lowerBound ... upperBound
    }

    static func indicatorValues(in domain: ClosedRange<Double>, step: Double) -> [Double] {
        stride(from: domain.lowerBound, through: domain.upperBound, by: step).map(\.self)
    }
}
