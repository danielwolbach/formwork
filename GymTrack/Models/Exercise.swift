//
//  Exercise.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import Foundation
import SwiftData

@Model
final class Exercise {
    var name: String

    var type: ExerciseType

    var disciplines: Set<Discipline>

    @Relationship(deleteRule: .cascade, inverse: \WorkoutEntry.exercise)
    var workoutEntries: [WorkoutEntry] = []

    @Relationship(deleteRule: .cascade, inverse: \SessionEntry.exercise)
    var sessionEntries: [SessionEntry] = []

    init(name: String, type: ExerciseType, disciplines: Set<Discipline>) {
        self.name = name
        self.type = type
        self.disciplines = disciplines
    }
}
