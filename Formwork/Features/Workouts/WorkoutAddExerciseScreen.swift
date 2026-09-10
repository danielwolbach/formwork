//
//  WorkoutAddExerciseScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 05.09.26.
//

import FormworkKit
import SwiftData
import SwiftUI

struct WorkoutAddExerciseScreen: View {
    @Environment(\.dismiss) private var dismiss: DismissAction
    @Query(sort: \Exercise.name) private var exercises: [Exercise]
    @State private var sheet: Sheet? = nil
    @State private var selectedCategories: Set<ExerciseCategory> = []
    @State private var searchText = ""

    let workout: Workout

    var body: some View {
        ScrollView {
            RowStack(navigating: matchingExercises)
        }
        .navigationTitle(.screenWorkoutAddExerciseTitle)
        .navigationSubtitle(workout.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Exercise.self) { exercise in
            ExerciseTargetConfigurator(exercise: exercise) { target in
                save(exercise: exercise, target: target)
            }
        }
        .safeAreaInset(edge: .bottom) {
            ExerciseCategoryFilterBar(selection: $selectedCategories)
        }
        .searchable(text: $searchText.animated())
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(.cancel) {
                    dismiss()
                }
            }

            ToolbarItem {
                Button(.create) {
                    sheet = .createExercise
                }
            }
        }
        .sheet(item: $sheet) { sheet in
            NavigationStack {
                sheet
            }
        }
    }

    private var matchingExercises: [Exercise] {
        let searchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let categorical = selectedCategories.isEmpty ? exercises : exercises
            .filter { selectedCategories.isSubset(of: $0.categories) }

        if searchText.isEmpty {
            return categorical
        } else {
            return categorical.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    private func save(exercise: Exercise, target: ExerciseTarget) {
        let order = (workout.entries.map(\.order).max() ?? -1) + 1
        let entry = WorkoutEntry(order: order, exercise: exercise, target: target)
        workout.entries.append(entry)
        dismiss()
    }
}

private struct ExerciseTargetConfigurator: View {
    let exercise: Exercise
    let onConfirm: (ExerciseTarget) -> Void

    @State private var target: ExerciseTarget

    init(exercise: Exercise, onConfirm: @escaping (ExerciseTarget) -> Void) {
        self.exercise = exercise
        self.onConfirm = onConfirm
        self._target = State(initialValue: .defaults(for: exercise.type))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                DisplayableHero(displayable: exercise)

                ExerciseTargetView(target: $target)
            }
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

private struct ExerciseCategoryFilterBar: View {
    @Binding var selection: Set<ExerciseCategory>

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(ExerciseCategory.allCases) { category in
                    ExerciseCategoryFilterChip(category: category, isHighlighted: highlighted(category)) {
                        toggle(category)
                    }
                }
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 8)
        }
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
    }

    private func highlighted(_ category: ExerciseCategory) -> Bool {
        selection.isEmpty || selection.contains(category)
    }

    private func toggle(_ category: ExerciseCategory) {
        withAnimation {
            selection.formSymmetricDifference([category])
        }
    }
}

private struct ExerciseCategoryFilterChip: View {
    let category: ExerciseCategory
    let isHighlighted: Bool
    let action: () -> Void

    var body: some View {
        if isHighlighted {
            Button(category.title, systemImage: category.pictogram.icon, action: action)
                .tint(category.pictogram.color)
                .labelStyle(.fixedTitleAndIcon)
                .buttonStyle(.glassProminent)
                .accessibilityAddTraits(.isSelected)
        } else {
            Button(category.title, systemImage: category.pictogram.icon, action: action)
                .labelStyle(.fixedTitleAndIcon)
                .buttonStyle(.glass)
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutAddExerciseScreen(workout: Samples.workouts.first!)
            .sampleData()
    }
}
