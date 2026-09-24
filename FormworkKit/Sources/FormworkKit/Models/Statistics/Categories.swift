//
//  Categories.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

/// What was trained, by the categories of the exercises completed.
struct Categories {
    struct Share {
        let category: ExerciseCategory

        let count: Int

        let fraction: Double
    }

    /// Most first; level ones in the order categories are declared.
    let shares: [Share]
}

extension Categories: Statistic {
    init(_ window: History.Window) {
        let counts = window.entries
            .filter(\.status.isCompleted)
            .compactMap(\.exercise)
            .flatMap(\.categories)
            .reduce(into: [ExerciseCategory: Int]()) { $0[$1, default: 0] += 1 }
        let total = counts.values.reduce(0, +)

        self.shares = ExerciseCategory.allCases.enumerated()
            .compactMap { order, category -> (order: Int, share: Share)? in
                guard let count = counts[category] else {
                    return nil
                }

                return (order, Share(category: category, count: count, fraction: Double(count) / Double(total)))
            }
            .sorted { $0.share.count == $1.share.count ? $0.order < $1.order : $0.share.count > $1.share.count }
            .map(\.share)
    }

    static var explanation: String {
        String(localized: ._Placeholder)
    }

    var pictogram: Pictogram {
        .categories
    }

    var title: String {
        String(localized: .statisticCategoriesTitle)
    }
}

extension Categories.Share: Identifiable {
    var id: ExerciseCategory {
        category
    }
}
