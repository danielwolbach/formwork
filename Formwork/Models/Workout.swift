//
//  Workout.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import Foundation
import SwiftData

@Model
final class Workout {
    var name: String = String(localized: .unknown)
    
    @Relationship(deleteRule: .cascade, inverse: \WorkoutEntry.workout)
    var entries: [WorkoutEntry] = []
    
    init(name: String, entries: [WorkoutEntry]) {
        self.name = name
        self.entries = entries
    }
}
