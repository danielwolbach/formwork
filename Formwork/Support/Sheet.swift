//
//  Sheet.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import SwiftUI

enum Sheet: Identifiable, Hashable, View {
    case createExercise
    case createExerciseInCategory(category: ExerciseCategory)
    case editExercise(exercise: Exercise)
    case createWorkout
    case editWorkout(workout: Workout)
    case addWorkoutExercise(workout: Workout)
    case addExerciseToWorkout(exercise: Exercise, workout: Workout)
    case workoutStats(workout: Workout)

    var id: Self {
        self
    }

    var body: some View {
        switch self {
        case .createExercise: ExerciseForm()
        case let .createExerciseInCategory(category): ExerciseForm(category: category)
        case let .editExercise(exercise): ExerciseForm(exercise: exercise)
        case .createWorkout: WorkoutForm()
        case let .editWorkout(workout): WorkoutForm(workout: workout)
        case let .addWorkoutExercise(workout): WorkoutAddExerciseScreen(workout: workout)
        case let .addExerciseToWorkout(exercise, workout): WorkoutEntryForm(exercise: exercise, workout: workout)
        case let .workoutStats(workout): WorkoutStatisticsScreen(workout: workout)
        }
    }
}
