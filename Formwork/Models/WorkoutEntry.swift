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
    
    var exercise: Exercise? = nil
    
    // FIXME: This reference is technically not needed here, do we still need
    // to keep it around to keep the relationship properly working?
    var workout: Workout? = nil
    
    init(order: Int, target: ExerciseTarget, exercise: Exercise) {
        self.order = order
        self.target = target
        self.exercise = exercise
    }
}

extension WorkoutEntry: Comparable {
    static func < (lhs: borrowing WorkoutEntry, rhs: borrowing WorkoutEntry) -> Bool {
        lhs.order < rhs.order
    }
}
