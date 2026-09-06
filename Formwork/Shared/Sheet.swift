//
//  Sheet.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import SwiftUI

enum Sheet: Identifiable, Hashable, View {
    case createExercise
    case editExercise(exercise: Exercise)
    case createWorkout
    case editWorkout(workout: Workout)
    case addWorkoutExercise(workout: Workout)
    case workoutStats(workout: Workout)

    var id: Self {
        self
    }

    var body: some View {
        switch self {
        case .createExercise: ExerciseForm()
        case .editExercise(let exercise): ExerciseForm(exercise: exercise)
        case .createWorkout: WorkoutForm()
        case .editWorkout(let workout): WorkoutForm(workout: workout)
        case .addWorkoutExercise(let workout): WorkoutAddExerciseScreen(workout: workout)
        case .workoutStats(let workout): WorkoutStatisticsScreen(workout: workout)
        }
    }
}
