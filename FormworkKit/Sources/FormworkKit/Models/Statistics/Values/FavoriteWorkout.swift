//
//  FavoriteWorkout.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

/// The workout finished most often, the most recently done one of them if several are level.
struct FavoriteWorkout {
    let workout: Workout?
}

extension FavoriteWorkout: Statistic {
    init(_ window: History.Window) {
        let tally = window.sessions.reduce(into: [Workout: (count: Int, latest: Date)]()) { tally, session in
            guard let workout = session.workout else {
                return
            }

            let current = tally[workout] ?? (0, .distantPast)
            tally[workout] = (current.count + 1, max(current.latest, session.ended ?? .distantPast))
        }

        self.workout = tally.max { ($0.value.count, $0.value.latest) < ($1.value.count, $1.value.latest) }?.key
    }

    static var explanation: String {
        String(localized: ._Placeholder)
    }

    var pictogram: Pictogram {
        .workout
    }

    var title: String {
        String(localized: .statisticFavoriteWorkoutTitle)
    }

    var subtitle: String? {
        workout?.title
    }
}
