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
    
    var metric: ExerciseMetric
    
    var disciplines: Set<Discipline>
    
    @Relationship(deleteRule: .cascade, inverse: \WorkoutEntry.exercise)
    var workoutEntries: [WorkoutEntry] = []
    
    @Relationship(deleteRule: .cascade, inverse: \SessionEntry.exercise)
    var sessionEntries: [SessionEntry] = []
    
    init(name: String, metric: ExerciseMetric, disciplines: Set<Discipline>) {
        self.name = name
        self.metric = metric
        self.disciplines = disciplines
    }
}
