//
//  WorkoutAddExerciseForm.swift
//  Formwork
//
//  Created by Daniel Wolbach on 05.09.26.
//

import FormworkKit
import SwiftData
import SwiftUI

struct WorkoutAddExerciseForm: View {
    let workout: Workout

    @Environment(\.dismiss)
    private var dismiss: DismissAction

    @Environment(\.modelContext)
    private var modelContext: ModelContext

    @Query(sort: \Exercise.name)
    private var exercises: [Exercise]

    @State
    private var selection: [(exercise: Exercise, target: ExerciseTarget)] = []

    @State
    private var selectedCategories: Set<ExerciseCategory> = []

    @State
    private var searchText = ""

    @State
    private var sheet: Sheet? = nil

    var body: some View {
        content
            .sensoryFeedback(.selection, trigger: selection.count)
            .navigationTitle(.screenWorkoutAddExerciseTitle)
            .navigationSubtitle(workout.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(.confirm) {
                        commit()
                        dismiss()
                    }
                    .disabled(selection.isEmpty)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button(.cancel) {
                        dismiss()
                    }
                }
            }
            .sheet(item: $sheet) { $0 }
    }

    @ViewBuilder
    private var content: some View {
        if exercises.isEmpty {
            ContentUnavailableView {
                Label(.emptyExercisesTitle, systemImage: "dumbbell")
            } description: {
                Text(.emptyExercisesDescription)
            } actions: {
                Button(.create) {
                    sheet = .createExercise
                }
                .buttonStyle(.glassProminent)
            }
        } else {
            searchContent
                .searchable(text: $searchText.animated())
                .safeAreaInset(edge: .bottom) {
                    ExerciseCategoryFilterBar(selection: $selectedCategories)
                }
        }
    }

    @ViewBuilder
    private var searchContent: some View {
        if matchingExercises.isEmpty {
            if trimmedSearchText.isEmpty {
                ContentUnavailableView.search
            } else {
                ContentUnavailableView.search(text: trimmedSearchText)
            }
        } else {
            Form {
                Section(.sectionWorkoutAddExerciseExercisesTitle) {
                    ForEach(matchingExercises) { exercise in
                        row(for: exercise)

                        if isSelected(exercise).wrappedValue {
                            editor(for: exercise)
                        }
                    }
                }
            }
        }
    }

    private var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var matchingExercises: [Exercise] {
        let searchText = trimmedSearchText
        let categorical = selectedCategories.isEmpty ? exercises : exercises
            .filter { !selectedCategories.isDisjoint(with: $0.categories) }

        if searchText.isEmpty {
            return categorical
        } else {
            return categorical.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    private func row(for exercise: Exercise) -> some View {
        let isSelected = isSelected(exercise)

        return Button {
            isSelected.wrappedValue.toggle()
        } label: {
            HStack {
                PictogramRow(exercise)

                Toggle(.select, isOn: isSelected)
                    .toggleStyle(.card())
                    .labelStyle(.fixedIconOnly)
                    .buttonBorderShape(.circle)
                    .transaction { $0.animation = nil }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .listRowSeparator(isSelected.wrappedValue ? .hidden : .automatic, edges: .bottom)
    }

    private func editor(for exercise: Exercise) -> some View {
        VStack {
            ExerciseTargetEditor(target: target(for: exercise))
                .padding()

            ExerciseTargetUnitPicker(target: target(for: exercise))
                .padding()
        }
    }

    private func index(of exercise: Exercise) -> Int? {
        selection.firstIndex { $0.exercise == exercise }
    }

    private func target(for exercise: Exercise) -> Binding<ExerciseTarget> {
        Binding(
            get: {
                index(of: exercise).map { selection[$0].target }
                    ?? initialTarget(for: exercise)
            },
            set: { newValue in
                withAnimation {
                    if let index = index(of: exercise) {
                        selection[index].target = newValue
                    }
                }
            }
        )
    }

    private func isSelected(_ exercise: Exercise) -> Binding<Bool> {
        Binding(
            get: { index(of: exercise) != nil },
            set: { isOn in
                withAnimation(.easeOut(duration: 0.1)) {
                    let index = index(of: exercise)

                    if isOn, index == nil {
                        selection.append((exercise, initialTarget(for: exercise)))
                    } else if !isOn, let index {
                        selection.remove(at: index)
                    }
                }
            }
        )
    }

    private func commit() {
        for entry in selection {
            workout.append(exercise: entry.exercise, target: entry.target)
        }
    }

    private func initialTarget(for exercise: Exercise) -> ExerciseTarget {
        if let current = exercise.currentHighestTarget {
            return current
        }

        return switch exercise.type {
        case .weight: .weight(target: .init(weight: .defaultWeight, sets: 3, reps: 10))
        case .bodyweight: .bodyweight(target: .init(sets: 3, reps: 10))
        case .duration: .duration(target: .init(duration: .defaultDuration))
        case .distance: .distance(target: .init(distance: .defaultDistance))
        }
    }
}

private struct ExerciseCategoryFilterBar: View {
    @Binding
    var selection: Set<ExerciseCategory>

    var body: some View {
        ScrollView(.horizontal) {
            GlassEffectContainer(spacing: 8) {
                HStack(spacing: 8) {
                    ForEach(ExerciseCategory.allCases) { category in
                        Toggle(isOn: binding(for: category)) {
                            Label(category.title, systemImage: category.pictogram.image)
                        }
                        .labelStyle(.fixedTitleAndIcon)
                        .toggleStyle(.glass(tint: category.pictogram.color))
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

    private func binding(for category: ExerciseCategory) -> Binding<Bool> {
        Binding(
            get: { highlighted(category) },
            set: { _ in
                withAnimation {
                    selection.formSymmetricDifference([category])
                }
            }
        )
    }
}

#Preview {
    NavigationStack {
        WorkoutAddExerciseForm(workout: Samples.workouts.first!)
    }
    .sampleData()
}
