//
//  WorkoutExerciseTargetScreen.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 13.07.26.
//

import SwiftData
import SwiftUI

struct WorkoutExerciseTargetScreen: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @State private var target: ExerciseTarget

    let exercise: Exercise
    let workout: Workout
    let dismissPicker: DismissAction

    init(exercise: Exercise, workout: Workout, dismissPicker: DismissAction) {
        self.exercise = exercise
        self.workout = workout
        self.dismissPicker = dismissPicker
        _target = State(initialValue: .defaults(for: exercise.type))
    }

    var body: some View {
        ScrollView {
            ScreenStack {
                ScreenSection {
                    IconHero(
                        icon: exercise.icon,
                        color: exercise.color,
                        title: exercise.name,
                        subtitle: exercise.subtitle
                    )

                    ExerciseTargetEditor(target: $target)
                }
            }
        }
        .navigationTitle(.screenAddExercise)
        .navigationSubtitle(workout.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(.confirm) {
                    save()
                }
            }
        }
    }

    private func save() {
        do {
            let order = (workout.entries.map(\.order).max() ?? -1) + 1
            let entry = WorkoutEntry(order: order, exercise: exercise, target: target)
            workout.entries.append(entry)
            try modelContext.save()
            dismissPicker()
        } catch {
            fatalError("Failed to add workout exercise: \(error)")
        }
    }
}
