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

    @Relationship(deleteRule: .cascade)
    var entries: [SessionEntry]

    var current: SessionEntry?

    init(workout: Workout) {
        started = Date.now
        entries = workout.entries.sorted()
            .map { SessionEntry(order: $0.order, exercise: $0.exercise, target: $0.target) }
        current = entries.first
    }
}
