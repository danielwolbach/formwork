//
//  WorkoutEntryForm.swift
//  Formwork
//
//  Created by Daniel Wolbach on 10.09.26.
//

import SwiftUI

struct WorkoutEntryForm: View {
    @Environment(\.dismiss) private var dismiss: DismissAction

    let exercise: Exercise
    let workout: Workout

    var body: some View {
        ExerciseTargetConfigurator(exercise: exercise) { target in
            workout.append(exercise: exercise, target: target)
            dismiss()
        }
        .navigationTitle(.screenWorkoutAddExerciseTitle)
        .navigationSubtitle(workout.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(.cancel) {
                    dismiss()
                }
            }
        }
    }
}

struct ExerciseTargetConfigurator: View {
    let exercise: Exercise
    let onConfirm: (ExerciseTarget) -> Void

    @State private var target: ExerciseTarget

    init(exercise: Exercise, onConfirm: @escaping (ExerciseTarget) -> Void) {
        self.exercise = exercise
        self.onConfirm = onConfirm
        self._target = State(initialValue: .defaults(for: exercise.type))
    }

    var body: some View {
        ScreenStack {
            DisplayableHero(displayable: exercise)

            ExerciseTargetView(target: $target)
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(.confirm) {
                    onConfirm(target)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutEntryForm(
            exercise: Samples.exercises.first!,
            workout: Samples.workouts.first!
        )
    }
    .sampleData()
}
