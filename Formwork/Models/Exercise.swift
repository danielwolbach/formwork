//
//  Exercise.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import Foundation
import SwiftData

@Model
final class Exercise {
    var name: String = String(localized: .unknown)
    
    var type: ExerciseType = ExerciseType.bodyweight
    
    var categories: Set<ExerciseCategory> = [ExerciseCategory.other]
    
    @Relationship(deleteRule: .cascade, inverse: \WorkoutEntry.exercise)
    var workoutEntries: [WorkoutEntry] = []

    init(name: String, type: ExerciseType, categories: Set<ExerciseCategory>) {
        self.name = name
        self.type = type
        self.categories = categories
    }
}
