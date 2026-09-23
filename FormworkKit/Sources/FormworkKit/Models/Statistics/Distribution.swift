//
//  Distribution.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 22.09.26.
//

import Foundation

public struct Distribution<Value: Displayable & CaseIterable & Hashable> {
    public struct Share {
        public let value: Value

        public let count: Int

        public let fraction: Double
    }

    public let pictogram: Pictogram

    public let title: String

    public let shares: [Share]

    init(_ counts: [Value: Int], title: String, pictogram: Pictogram) {
        let total = counts.values.reduce(0, +)

        let ranked = Value.allCases.enumerated().compactMap { order, value -> (order: Int, share: Share)? in
            guard let count = counts[value], total > 0 else {
                return nil
            }

            return (order, Share(value: value, count: count, fraction: Double(count) / Double(total)))
        }

        let shares = ranked
            .sorted { $0.share.count == $1.share.count ? $0.order < $1.order : $0.share.count > $1.share.count }
            .map(\.share)

        self.shares = shares
        self.title = title
        self.pictogram = pictogram
    }
}

extension Distribution.Share: Identifiable {
    public var id: Value {
        value
    }
}

extension Distribution where Value == ExerciseCategory {
    static func categories(_ exercises: [Exercise]) -> Self {
        let counts = exercises
            .flatMap(\.categories)
            .reduce(into: [ExerciseCategory: Int]()) { $0[$1, default: 0] += 1 }

        return Distribution(counts, title: String(localized: .statisticCategoriesTitle), pictogram: .categories)
    }
}
