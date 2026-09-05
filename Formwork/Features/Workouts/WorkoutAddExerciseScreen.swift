//
//  WorkoutExercisePicker.swift
//  Formwork
//
//  Created by Daniel Wolbach on 05.09.26.
//

import SwiftData
import SwiftUI

struct WorkoutAddExerciseScreen: View {
    @Query(sort: \Exercise.name) private var exercises: [Exercise]
    @Environment(\.dismiss) private var dismiss: DismissAction
    @State private var sheet: Sheet? = nil
    @State private var selectedCategories: Set<ExerciseCategory> = []
    @State private var searchText = ""
    @State private var target: ExerciseTarget = ExerciseTarget.defaults(for: .weight)
    
    let workout: Workout
    
    var body: some View {
        ScrollView {
            RowStack(items: matchinigExercises) { exercise in
                NavigationRow(value: exercise) {
                    DisplayableRow(displayable: exercise)
                }
            }
        }
        .navigationTitle(.screenWorkoutAddExerciseTitle)
        .navigationSubtitle(workout.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Exercise.self) { exercise in
            configurator(for: exercise)
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
    
    private var matchinigExercises: [Exercise] {
        let searchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let categorical = selectedCategories.isEmpty ? exercises : exercises.filter { selectedCategories.isSubset(of: $0.categories) }
        
        if searchText.isEmpty {
            return categorical
        } else {
            return categorical.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    private func configurator(for exercise: Exercise) -> some View {
        ScrollView {
            VStack(spacing: 32) {
                DisplayableHero(displayable: exercise)
                
                ExerciseTargetView(target: $target)
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(.confirm) {
                    save(exercise: exercise)
                }
            }
        }
        .task {
            target = ExerciseTarget.defaults(for: exercise.type)
        }
    }
    
    private func save(exercise: Exercise) {
        let order = (workout.entries.map(\.order).max() ?? -1) + 1
        let entry = WorkoutEntry(order: order, exercise: exercise, target: target)
        workout.entries.append(entry)
        dismiss()
    }
}

private struct ExerciseCategoryFilterBar: View {
    @Binding var selection: Set<ExerciseCategory>
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(ExerciseCategory.allCases) { category in
                    ExerciseCategoryFilterChip(category: category, selected: highlighted(category)) {
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
    
    private func highlighted(_ discipline: ExerciseCategory) -> Bool {
        selection.isEmpty || selection.contains(discipline)
    }
    
    private func toggle(_ discipline: ExerciseCategory) {
        withAnimation {
            selection.formSymmetricDifference([discipline])
        }
    }
}

private struct ExerciseCategoryFilterChip: View {
    let category: ExerciseCategory
    let highlighted: Bool
    let action: () -> Void
    
    init(category: ExerciseCategory, selected: Bool, action: @escaping () -> Void) {
        self.category = category
        self.highlighted = selected
        self.action = action
    }
    
    var body: some View {
        if highlighted {
            Button(category.title, systemImage: category.pictogram.icon) {
                action()
            }
            .tint(category.pictogram.color)
            .labelStyle(.fixedTitleAndIcon)
            .buttonStyle(.glassProminent)
        } else {
            Button(category.title, systemImage: category.pictogram.icon) {
                action()
            }
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
