//
//  Workout.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftData

@Model
final class Workout {
    var name: String

    @Relationship(deleteRule: .cascade)
    var entries: [WorkoutEntry]

    init(name: String, entries: [WorkoutEntry] = []) {
        self.name = name
        self.entries = entries
    }
}
