//
//  WorkoutExercisePicker.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftData
import SwiftUI

struct WorkoutExercisePicker: View {
    @Environment(\.dismiss) private var dismiss: DismissAction
    @Query(sort: \Exercise.name) private var exercises: [Exercise]

    @State private var searchText = ""

    let workout: Workout

    var body: some View {
        content
            .navigationTitle("Add Exercise")
            .navigationSubtitle(workout.name)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search Exercises")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(.cancel) {
                        dismiss()
                    }
                }
            }
            .navigationDestination(for: Exercise.self) { exercise in
                WorkoutExerciseTargetScreen(
                    exercise: exercise,
                    workout: workout,
                    dismissPicker: dismiss
                )
            }
    }

    @ViewBuilder
    private var content: some View {
        if exercises.isEmpty {
            ContentUnavailableView("No Exercises", systemImage: Exercise.systemImage)
        } else if filteredExercises.isEmpty {
            ContentUnavailableView.search(text: searchText)
        } else {
            ScrollView {
                ScreenStack {
                    RowStack {
                        ForEach(filteredExercises) { exercise in
                            NavigationLink(value: exercise) {
                                NavigationRow(
                                    title: exercise.name,
                                    subtitle: exercise.disciplinesDescription,
                                    systemImage: exercise.systemImage,
                                    color: exercise.color
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private var filteredExercises: [Exercise] {
        let searchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !searchText.isEmpty else {
            return exercises
        }

        return exercises.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
}

private struct WorkoutExerciseTargetScreen: View {
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
                    subtitle: exercise.disciplinesDescription,
                    systemImage: exercise.systemImage,
                    color: exercise.color
                )

                metricMenu

                ExerciseTargetEditor(target: $target)
                    .padding(.horizontal)
            }
        }
        .navigationTitle("Target")
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
            Picker(ActionDescriptor.metric.title, selection: metric) {
                ForEach(ExerciseMetric.allCases) { metric in
                    Label(metric.description, systemImage: metric.systemImage)
                        .tag(metric)
                }
            }
        } label: {
            Label(target.metric.description, systemImage: target.metric.systemImage)
        }
        .fontWeight(.semibold)
        .buttonStyle(.glass)
        .controlSize(.large)
    }

    private var metric: Binding<ExerciseMetric> {
        Binding {
            target.metric
        } set: { metric in
            withAnimation(.snappy(duration: 0.25)) {
                target = .defaults(for: metric)
            }
        }
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

#Preview {
    NavigationStack {
        WorkoutExercisePicker(workout: Workout.samples[0])
    }
    .sampleData()
}
