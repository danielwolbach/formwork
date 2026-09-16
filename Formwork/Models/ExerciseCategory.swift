//
//  ExerciseCategory.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import Foundation

nonisolated enum ExerciseCategory: Identifiable, Codable, CaseIterable {
    case arms
    case legs
    case chest
    case shoulders
    case core
    case back
    case cardio
    case flexibility
    case mindfulness
    case other

    var id: Self {
        self
    }
}

extension ExerciseCategory {
    static func shares(of exercises: [Set<ExerciseCategory>]) -> [(category: ExerciseCategory, share: Double)] {
        var weights: [ExerciseCategory: Double] = [:]

        for categories in exercises where !categories.isEmpty {
            let weight = 1 / Double(categories.count)

            for category in categories {
                weights[category, default: 0] += weight
            }
        }

        let total = weights.values.reduce(0, +)

        guard total > 0 else {
            return []
        }

        var shares: [(category: ExerciseCategory, share: Double)] = []

        for category in allCases {
            guard let weight = weights[category] else {
                continue
            }

            let share = weight / total
            let index = shares.firstIndex { $0.share < share } ?? shares.count

            shares.insert((category: category, share: share), at: index)
        }

        return shares
    }
}
