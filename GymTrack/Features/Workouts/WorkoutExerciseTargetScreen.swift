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
        _target = State(initialValue: .defaults(for: exercise.metric))
    }

    var body: some View {
        ScrollView {
            ScreenStack {
                DetailHero(
                    title: exercise.name,
                    subtitle: exercise.disciplinesText,
                    systemImage: target.systemImage,
                    color: target.color
                )

                metricMenu

                ExerciseTargetEditor(target: $target)
            }
        }
        .navigationTitle("Add Exercise")
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

    private var metricMenu: some View {
        Menu {
            ExerciseTargetMetricPicker(target: $target)
        } label: {
            Label(target.metric.title, systemImage: target.metric.systemImage)
        }
        .fontWeight(.semibold)
        .buttonStyle(.glass)
        .controlSize(.large)
    }

    private func save() {
        let order = (workout.entries.map(\.order).max() ?? -1) + 1
        let entry = WorkoutEntry(order: order, exercise: exercise, target: target)
        workout.entries.append(entry)

        do {
            try modelContext.save()
            dismissPicker()
        } catch {
            fatalError("Failed to add workout exercise: \(error)")
        }
    }
}
