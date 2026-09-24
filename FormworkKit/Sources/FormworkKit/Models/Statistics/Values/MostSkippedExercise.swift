//
//  MostSkippedExercise.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

/// The exercise skipped most often, the most recently skipped one of them if several are level.
struct MostSkippedExercise {
    let exercise: Exercise?
}

extension MostSkippedExercise: Statistic {
    init(_ window: History.Window) {
        let tally = window.entries
            .filter(\.status.isSkipped)
            .reduce(into: [Exercise: (count: Int, latest: Date)]()) { tally, entry in
                guard let exercise = entry.exercise, let skipped = entry.status.resolved else {
                    return
                }

                let current = tally[exercise] ?? (0, .distantPast)
                tally[exercise] = (current.count + 1, max(current.latest, skipped))
            }

        self.exercise = tally.max { ($0.value.count, $0.value.latest) < ($1.value.count, $1.value.latest) }?.key
    }

    static var explanation: String {
        String(localized: ._Placeholder)
    }

    var pictogram: Pictogram {
        .skipped
    }

    var title: String {
        String(localized: .statisticMostSkippedTitle)
    }

    var subtitle: String? {
        exercise?.title
    }
}
