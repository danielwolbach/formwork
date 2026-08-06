//
//  SessionEntry.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftData

@Model
final class SessionEntry: Comparable {
    var order: Int

    var current: Int

    var status: Status

    var exercise: Exercise

    var target: ExerciseTarget

    var workoutEntry: WorkoutEntry?

    var session: Session?

    init(
        order: Int,
        exercise: Exercise,
        target: ExerciseTarget,
        workoutEntry: WorkoutEntry? = nil
    ) {
        precondition(target.type == exercise.type, "A session entry target must match its exercise type.")

        self.order = order
        current = 0
        status = .pending
        self.exercise = exercise
        self.target = target
        self.workoutEntry = workoutEntry
    }

    static func < (lhs: SessionEntry, rhs: SessionEntry) -> Bool {
        lhs.order < rhs.order
    }
}

extension SessionEntry {
    nonisolated enum Status: Codable {
        case pending
        case skipped
        case done
    }
}
