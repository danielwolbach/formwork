//
//  FavoriteExercise.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

public struct FavoriteExercise {
    public let exercise: Exercise?
}

extension FavoriteExercise: Statistic {
    public init(_ window: History.Window) {
        let tally = window.entries
            .filter(\.status.isCompleted)
            .reduce(into: [Exercise: (count: Int, latest: Date)]()) { tally, entry in
                guard let exercise = entry.exercise, let completed = entry.status.resolvedDate else {
                    return
                }

                let current = tally[exercise] ?? (0, .distantPast)
                tally[exercise] = (current.count + 1, max(current.latest, completed))
            }

        self.exercise = tally.max { ($0.value.count, $0.value.latest) < ($1.value.count, $1.value.latest) }?.key
    }

    public static var info: String {
        String(localized: .statisticFavoriteExerciseInfo)
    }

    public var pictogram: Pictogram {
        .exercise
    }

    public var title: String {
        String(localized: .statisticFavoriteExerciseTitle)
    }

    public var subtitle: String? {
        exercise?.title
    }
}
