//
//  WorkoutEntry.swift
//  FormworkKit
//
//  Created by Daniel Wolbach on 04.09.26.
//

import SwiftData

@Model
public final class WorkoutEntry: Comparable {
    public var order: Int = 0

    public var exercise: Exercise?

    public var target: ExerciseTarget = ExerciseTarget.bodyweight(target: .init(sets: 3, reps: 10))

    public var workout: Workout?

    @Relationship(deleteRule: .nullify, inverse: \SessionEntry.workoutEntry)
    var sessionEntries: [SessionEntry] = []

    public init(order: Int, exercise: Exercise, target: ExerciseTarget) {
        self.order = order
        self.exercise = exercise
        self.target = target
    }

    public static func < (lhs: borrowing WorkoutEntry, rhs: borrowing WorkoutEntry) -> Bool {
        lhs.order < rhs.order
    }
}
