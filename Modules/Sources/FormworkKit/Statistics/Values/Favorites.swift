//
//  Favorites.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 04.10.26.
//

import Foundation

extension History.Window {
    var favoriteWorkout: Workout? {
        sessions.mostFrequent { session in
            session.workout.map { ($0, session.endDate ?? .distantPast) }
        }
    }

    var favoriteExercise: Exercise? {
        entries.filter(\.status.isCompleted).mostFrequent { entry in
            guard let exercise = entry.exercise, let completed = entry.status.resolvedDate else {
                return nil
            }

            return (exercise, completed)
        }
    }

    var mostSkippedExercise: Exercise? {
        entries.filter(\.status.isSkipped).mostFrequent { entry in
            guard let exercise = entry.exercise, let skipped = entry.status.resolvedDate else {
                return nil
            }

            return (exercise, skipped)
        }
    }
}
