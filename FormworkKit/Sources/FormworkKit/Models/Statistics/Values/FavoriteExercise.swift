//
//  FavoriteExercise.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

/// The exercise completed most often, the most recently completed one of them if several are level.
struct FavoriteExercise {
    let exercise: Exercise?
}

extension FavoriteExercise: Statistic {
    init(_ window: History.Window) {
        let tally = window.entries
            .filter(\.status.isCompleted)
            .reduce(into: [Exercise: (count: Int, latest: Date)]()) { tally, entry in
                guard let exercise = entry.exercise, let completed = entry.status.resolved else {
                    return
                }

                let current = tally[exercise] ?? (0, .distantPast)
                tally[exercise] = (current.count + 1, max(current.latest, completed))
            }

        self.exercise = tally.max { ($0.value.count, $0.value.latest) < ($1.value.count, $1.value.latest) }?.key
    }

    static var explanation: String {
        String(localized: ._Placeholder)
    }

    var pictogram: Pictogram {
        .exercise
    }

    var title: String {
        String(localized: .statisticFavoriteExerciseTitle)
    }

    var subtitle: String? {
        exercise?.title
    }
}
