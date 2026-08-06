//
//  Session.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import Foundation
import SwiftData

@Model
final class Session {
    var started: Date

    var ended: Date?

    var workout: Workout?

    @Relationship(deleteRule: .cascade, inverse: \SessionEntry.session)
    var entries: [SessionEntry]

    var current: SessionEntry

    init(workout: Workout) {
        let entries = workout.entries.sorted()
            .map {
                SessionEntry(
                    order: $0.order,
                    exercise: $0.exercise,
                    target: $0.target,
                    workoutEntry: $0
                )
            }

        precondition(!entries.isEmpty, "Cannot create a session for an empty workout.")

        started = Date.now
        ended = nil
        self.workout = workout
        self.entries = entries
        current = entries[0]
    }
}
