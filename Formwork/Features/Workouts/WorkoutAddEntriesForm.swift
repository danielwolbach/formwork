//
//  WorkoutAddEntriesForm.swift
//  Formwork
//
//  Created by Daniel Wolbach on 05.09.26.
//

import FormworkKit
import SwiftData
import SwiftUI

struct WorkoutAddEntriesForm: View {
    @Environment(\.dismiss)
    private var dismiss: DismissAction

    @Query
    private var exercises: [Exercise]

    @Binding
    private var entries: [WorkoutEntry]

    @State
    private var selection: [(exercise: Exercise, target: ExerciseTarget)] = []

    @State
    private var selectedCategories: Set<Exercise.Category> = []

    @State
    private var sortOrder = [SortDescriptor(\Exercise.name)]

    @State
    private var searchText = ""

    @State
    private var searchPresented = false

    @State
    private var sheet: Sheet?

    init(entries: Binding<[WorkoutEntry]>) {
        self._entries = entries
    }

    init(workout: Workout) {
        self._entries = Bindable(workout).entries
    }

    var body: some View {
        let matching = matchingExercises

        Group {
            if exercises.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(matching) { exercise in
                            row(for: exercise)
                        }
                    }
                }
                .overlay {
                    if matching.isEmpty {
                        if trimmedSearchText.isEmpty {
                            ContentUnavailableView.search
                        } else {
                            ContentUnavailableView.search(text: trimmedSearchText)
                        }
                    }
                }
            }
        }
        .navigationTitle(.screenAddExerciseTitle)
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, isPresented: $searchPresented)
        .animation(.snappy, value: searchText)
        .animation(.snappy, value: selectedCategories)
        .animation(.snappy, value: sortOrder)
        .sensoryFeedback(.selection, trigger: selection.count)
        .sensoryFeedback(.selection, trigger: selectedCategories)
        .scrollDismissesKeyboard(.immediately)
        .safeAreaInset(edge: .bottom) {
            ExerciseCategoryFilterBar(selection: $selectedCategories)
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(.cancel) {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button(.confirm) {
                    commit()
                }
                .disabled(selection.isEmpty)
            }

            DefaultToolbarItem(kind: .search, placement: .bottomBar)

            ToolbarSpacer(.fixed, placement: .bottomBar)

            ToolbarItem(placement: .bottomBar) {
                Menu(.sort) {
                    Picker(.fieldSortTitle, selection: $sortOrder) {
                        Label(.fieldSortNameTitle, systemImage: "character")
                            .tag([SortDescriptor(\Exercise.name)])

                        Label(.fieldSortNewestTitle, systemImage: "clock")
                            .tag([SortDescriptor(\Exercise.creationDate, order: .reverse)])
                    }
                }
            }

            ToolbarItem(placement: .bottomBar) {
                Button(.createExercise) {
                    sheet = .createExerciseInCategories(selectedCategories)
                }
            }
        }
        .sheet(item: $sheet) { sheet in
            NavigationStack {
                sheet
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label(.emptyExercisesTitle, systemImage: "dumbbell")
        } description: {
            Text(.emptyExercisesMessage)
        } actions: {
            Button(.createExercise) {
                sheet = .createExerciseInCategories(selectedCategories)
            }
            .labelStyle(.fixedTitleAndIcon)
            .buttonStyle(.cardProminent())
        }
    }

    private var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var matchingExercises: [Exercise] {
        let searchText = trimmedSearchText

        return exercises
            .filter { selectedCategories.isEmpty || !selectedCategories.isDisjoint(with: $0.categories) }
            .filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }
            .sorted(using: sortOrder)
    }

    @ViewBuilder
    private func row(for exercise: Exercise) -> some View {
        let selected = isSelected(exercise)

        Button {
            searchPresented = false
            toggle(exercise)
        } label: {
            HStack {
                DisplayableRow(exercise)

                if selected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.accentColor)
                }
            }
            .animation(.snappy(duration: 0.2), value: selected)
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)

        if selected {
            ExerciseTargetEditor(target: target(for: exercise))
                .padding()
                .frame(maxWidth: .infinity)
                .card()
                .padding(.horizontal)
        }
    }

    private func index(of exercise: Exercise) -> Int? {
        selection.firstIndex { $0.exercise == exercise }
    }

    private func isSelected(_ exercise: Exercise) -> Bool {
        index(of: exercise) != nil
    }

    private func toggle(_ exercise: Exercise) {
        withAnimation(.snappy) {
            if let index = index(of: exercise) {
                selection.remove(at: index)
            } else {
                selection.append((exercise, initialTarget(for: exercise)))
            }
        }
    }

    private func target(for exercise: Exercise) -> Binding<ExerciseTarget> {
        Binding(
            get: {
                index(of: exercise).map { selection[$0].target } ?? initialTarget(for: exercise)
            },
            set: { newValue in
                if let index = index(of: exercise) {
                    selection[index].target = newValue
                }
            }
        )
    }

    private func initialTarget(for exercise: Exercise) -> ExerciseTarget {
        if let current = exercise.currentHighestTarget {
            return current
        }

        return switch exercise.kind {
        case .weight: .weight()
        case .bodyweight: .bodyweight()
        case .duration: .duration()
        case .distance: .distance()
        }
    }

    private func commit() {
        let firstOrder = (entries.map(\.order).max() ?? -1) + 1

        let newEntries = selection.enumerated().map { offset, item in
            let entry = WorkoutEntry(exercise: item.exercise, target: item.target)
            entry.order = firstOrder + offset
            return entry
        }

        entries.append(contentsOf: newEntries)
        dismiss()
    }
}

private struct ExerciseCategoryFilterBar: View {
    @Binding
    private var selection: Set<Exercise.Category>

    init(selection: Binding<Set<Exercise.Category>>) {
        self._selection = selection
    }

    var body: some View {
        ScrollView(.horizontal) {
            GlassEffectContainer(spacing: 8) {
                HStack(spacing: 8) {
                    ForEach(Exercise.Category.allCases) { category in
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

    private func binding(for category: Exercise.Category) -> Binding<Bool> {
        Binding(
            get: { selection.isEmpty || selection.contains(category) },
            set: { _ in selection.formSymmetricDifference([category]) }
        )
    }
}

#Preview {
    @Previewable @State
    var entries: [WorkoutEntry] = []

    NavigationStack {
        WorkoutAddEntriesForm(entries: $entries)
    }
    .sampleData()
}
