//
//  Exercise.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import SwiftData

@Model
public final class Exercise {
    public var name: String = ""

    public var type: ExerciseType = ExerciseType.weight

    public var categories: Set<ExerciseCategory> = []

    @Relationship(deleteRule: .cascade, inverse: \WorkoutEntry.exercise)
    public var workoutEntries: [WorkoutEntry] = []

    @Relationship(deleteRule: .nullify, inverse: \SessionEntry.exercise)
    public var sessionEntries: [SessionEntry] = []

    public init(name: String, type: ExerciseType, categories: Set<ExerciseCategory>) {
        self.name = name
        self.type = type
        self.categories = categories
    }
}
