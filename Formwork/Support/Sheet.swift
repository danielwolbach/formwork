//
//  Sheet.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import SwiftUI

enum Sheet: Hashable, View {
    case createExercise
    case createExerciseInCategory(category: ExerciseCategory)
    case editExercise(exercise: Exercise)
    case createWorkout
    case editWorkout(workout: Workout)
    case addWorkoutExercise(workout: Workout)

    var body: some View {
        NavigationStack {
            switch self {
            case .createExercise: ExerciseForm()
            case let .createExerciseInCategory(category): ExerciseForm(category: category)
            case let .editExercise(exercise): ExerciseForm(exercise: exercise)
            case .createWorkout: WorkoutForm()
            case let .editWorkout(workout): WorkoutForm(workout: workout)
            case let .addWorkoutExercise(workout): WorkoutAddExerciseForm(workout: workout)
            }
        }
    }
}

extension Sheet: Identifiable {
    var id: Self {
        self
    }
}
