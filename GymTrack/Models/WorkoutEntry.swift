//
//  WorkoutEntry.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftData

@Model
final class WorkoutEntry: Comparable {
    var order: Int

    var target: ExerciseTarget

    var exercise: Exercise

    init(order: Int, exercise: Exercise, target: ExerciseTarget) {
        self.order = order
        self.exercise = exercise
        self.target = target
    }

    static func < (lhs: WorkoutEntry, rhs: WorkoutEntry) -> Bool {
        lhs.order < rhs.order
    }
}
