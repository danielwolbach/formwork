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

extension FavoriteWorkout: Indicator {
    public init(_ window: History.Window) {
        self.workout = window.sessions.mostFrequent { session in
            session.workout.map { ($0, session.endDate ?? .distantPast) }
        }
    }

    public static var info: String {
        String(localized: .statisticFavoriteWorkoutInfo)
    }

    public static var pictogram: Pictogram {
        .workout
    }

    public static var title: String {
        String(localized: .statisticFavoriteWorkoutTitle)
    }

    public var reading: Reading? {
        workout.map { .name($0.title) }
    }
}
