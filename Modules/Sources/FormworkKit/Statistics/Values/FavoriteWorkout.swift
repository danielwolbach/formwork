//
//  FavoriteWorkout.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

public struct FavoriteWorkout {
    public let workout: Workout?
}

extension FavoriteWorkout: Statistic {
    public init(_ window: History.Window) {
        let tally = window.sessions.reduce(into: [Workout: (count: Int, latest: Date)]()) { tally, session in
            guard let workout = session.workout else {
                return
            }

            let current = tally[workout] ?? (0, .distantPast)
            tally[workout] = (current.count + 1, max(current.latest, session.endDate ?? .distantPast))
        }

        self.workout = tally.max { ($0.value.count, $0.value.latest) < ($1.value.count, $1.value.latest) }?.key
    }

    public static var info: String {
        String(localized: .statisticFavoriteWorkoutInfo)
    }

    public var pictogram: Pictogram {
        .workout
    }

    public var title: String {
        String(localized: .statisticFavoriteWorkoutTitle)
    }

    public var subtitle: String? {
        workout?.title
    }
}
