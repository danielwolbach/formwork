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

extension FavoriteExercise: Indicator {
    public init(_ window: History.Window) {
        self.exercise = window.entries.filter(\.status.isCompleted).mostFrequent { entry in
            guard let exercise = entry.exercise, let completed = entry.status.resolvedDate else {
                return nil
            }

            return (exercise, completed)
        }
    }

    public static var info: String {
        String(localized: .statisticFavoriteExerciseInfo)
    }

    public static var pictogram: Pictogram {
        .exercise
    }

    public static var title: String {
        String(localized: .statisticFavoriteExerciseTitle)
    }

    public var reading: Reading? {
        exercise.map { .name($0.title) }
    }
}
