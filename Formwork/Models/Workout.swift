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
    
    @Relationship(deleteRule: .cascade, inverse: \WorkoutEntry.workout)
    var entries: [WorkoutEntry] = []
    
    init(name: String, pictogram: Pictogram = Pictogram(icon: "figure.strengthtraining.traditional", tint: .blue), entries: [WorkoutEntry]) {
        self.name = name
        self.pictogram = pictogram
        self.entries = entries
    }
}
