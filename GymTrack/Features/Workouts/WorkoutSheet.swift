//
//  WorkoutSheet.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftData
import SwiftUI

enum WorkoutSheet: Identifiable {
    case createWorkout
    case editWorkout(Workout)
    case addWorkoutExercise(Workout)

    var id: String {
        switch self {
        case .createWorkout:
            "createWorkout"
        case let .editWorkout(workout):
            "editWorkout-\(workout.persistentModelID)"
        case let .addWorkoutExercise(workout):
            "addWorkoutExercise-\(workout.persistentModelID)"
        }
    }
}

extension View {
    func workoutSheet(item: Binding<WorkoutSheet?>) -> some View {
        sheet(item: item) { sheet in
            NavigationStack {
                switch sheet {
                case .createWorkout:
                    WorkoutFormScreen()
                case let .editWorkout(workout):
                    WorkoutFormScreen(workout: workout)
                case let .addWorkoutExercise(workout):
                    WorkoutExercisePicker(workout: workout)
                }
            }
        }
    }
}
