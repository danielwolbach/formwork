//
//  WorkoutEntry.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import SwiftData

@Model
final class WorkoutEntry {
    var order: Int = 0

    var target: ExerciseTarget = ExerciseTarget.bodyweight(sets: 1, reps: 1)

    var exercise: Exercise?

    var workout: Workout?

    @Relationship(deleteRule: .nullify, inverse: \SessionEntry.workoutEntry)
    var sessionEntries: [SessionEntry] = []

    init(order: Int, exercise: Exercise, target: ExerciseTarget) {
        self.order = order
        self.exercise = exercise
        self.target = target
    }
}

extension WorkoutEntry: Comparable {
    static func < (lhs: borrowing WorkoutEntry, rhs: borrowing WorkoutEntry) -> Bool {
        lhs.order < rhs.order
    }
}
