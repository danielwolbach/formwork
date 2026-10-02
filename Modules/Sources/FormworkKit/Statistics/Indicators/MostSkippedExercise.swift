//
//  MostSkippedExercise.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 24.09.26.
//

import Foundation

public struct MostSkippedExercise {
    public let exercise: Exercise?
}

extension MostSkippedExercise: Indicator {
    public init(_ window: History.Window) {
        self.exercise = window.entries.filter(\.status.isSkipped).mostFrequent { entry in
            guard let exercise = entry.exercise, let skipped = entry.status.resolvedDate else {
                return nil
            }

            return (exercise, skipped)
        }
    }

    public static var info: String {
        String(localized: .statisticMostSkippedExerciseInfo)
    }

    public static var pictogram: Pictogram {
        .skipped
    }

    public static var title: String {
        String(localized: .statisticMostSkippedExerciseTitle)
    }

    public var reading: Reading? {
        exercise.map { .name($0.title) }
    }
}
