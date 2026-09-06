//
//  Workout.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import Foundation
import SwiftData

@Model
final class Workout {
    var name: String = String(localized: .unknown)
    
    var pictogram: Pictogram = Pictogram(icon: "figure.strengthtraining.traditional", tint: .blue)
    
    var schedule: Schedule = Schedule.inactive
    
    @Relationship(deleteRule: .cascade, inverse: \WorkoutEntry.workout)
    var entries: [WorkoutEntry] = []
    
    @Relationship(deleteRule: .nullify, inverse: \Session.workout)
    var sessions: [Session] = []
    
    init(name: String, pictogram: Pictogram, entries: [WorkoutEntry], schedule: Schedule = .inactive) {
        self.name = name
        self.pictogram = pictogram
        self.entries = entries
        self.schedule = schedule
    }
}
