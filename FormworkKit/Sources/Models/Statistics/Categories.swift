//
//  Categories.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

public struct Categories {
    public struct Share {
        public let category: Exercise.Category

        public let count: Int

        public let fraction: Double
    }

    public let shares: [Share]
}

extension Categories: Statistic {
    public init(_ window: History.Window) {
        let counts = window.entries
            .filter(\.status.isCompleted)
            .compactMap(\.exercise)
            .flatMap(\.categories)
            .reduce(into: [Exercise.Category: Int]()) { $0[$1, default: 0] += 1 }
        let total = counts.values.reduce(0, +)

        self.shares = Exercise.Category.allCases.enumerated()
            .compactMap { order, category -> (order: Int, share: Share)? in
                guard let count = counts[category] else {
                    return nil
                }

                return (order, Share(category: category, count: count, fraction: Double(count) / Double(total)))
            }
            .sorted { $0.share.count == $1.share.count ? $0.order < $1.order : $0.share.count > $1.share.count }
            .map(\.share)
    }

    public static var explanation: String {
        String(localized: .placeholder)
    }

    public var pictogram: Pictogram {
        .categories
    }

    public var title: String {
        String(localized: .statisticCategoriesTitle)
    }
}

extension Categories.Share: Identifiable {
    public var id: Exercise.Category {
        category
    }
}
