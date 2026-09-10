//
//  CategoryDistribution.swift
//  Formwork
//
//  Created by Daniel Wolbach on 10.09.26.
//

import Foundation

/// How a collection of exercises divides across categories. Every exercise
/// contributes a single whole, split evenly across its own categories, so the
/// shares always sum to one — counting a chest-and-arms exercise fully under
/// both would push a pie chart past 100%.
nonisolated struct CategoryDistribution {
    /// Accumulated weight per category, measured in exercises. A category
    /// nothing counted towards is absent rather than zero, so it never reaches
    /// the chart as an empty slice.
    private let weights: [ExerciseCategory: Double]

    /// Categories are taken by value rather than as `[Exercise]` so a
    /// distribution retains nothing from the context its exercises came from.
    init(categories: [Set<ExerciseCategory>] = []) {
        var weights: [ExerciseCategory: Double] = [:]

        for group in categories where !group.isEmpty {
            let weight = 1 / Double(group.count)

            for category in group {
                weights[category, default: 0] += weight
            }
        }

        self.weights = weights
    }

    var isEmpty: Bool {
        weights.isEmpty
    }

    /// Every category carrying weight, largest share first. Ties resolve to the
    /// declaration order of `ExerciseCategory`: dictionary order is not stable
    /// and neither is `sorted`, so without a tie-break two equally weighted
    /// slices would swap places on every rebuild.
    var shares: [Share] {
        let total = weights.values.reduce(0, +)

        guard total > 0 else {
            return []
        }

        return ExerciseCategory.allCases
            .compactMap { category in
                weights[category].map { Share(category: category, value: $0 / total) }
            }
            .sorted { lhs, rhs in
                lhs.value == rhs.value
                    ? Self.rank(of: lhs.category) < Self.rank(of: rhs.category)
                    : lhs.value > rhs.value
            }
    }

    private static func rank(of category: ExerciseCategory) -> Int {
        ExerciseCategory.allCases.firstIndex(of: category) ?? .max
    }
}

extension CategoryDistribution {
    nonisolated struct Share: Identifiable {
        let category: ExerciseCategory

        /// Fraction of the whole distribution, between zero and one.
        let value: Double

        var id: ExerciseCategory {
            category.id
        }
    }
}
