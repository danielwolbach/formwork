//
//  WorkoutAddEntriesForm.swift
//  Formwork
//
//  Created by Daniel Wolbach on 05.09.26.
//

import FormworkKit
import FormworkUI
import SwiftData
import SwiftUI

struct WorkoutAddEntriesForm: View {
    @Environment(\.dismiss)
    private var dismiss: DismissAction

    @Environment(\.units)
    private var units: Units

    @Environment(\.modelContext)
    private var context: ModelContext

    @Environment(\.fullVersion)
    private var fullVersion: FullVersion

    @Environment(\.presentPaywall)
    private var presentPaywall: PresentPaywallAction

    @Query(filter: #Predicate<Exercise> { !$0.isArchived })
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
                .contentMargins(.bottom, .sections, for: .scrollContent)
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
        .interactiveDismissDisabled(hasChanges)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                CancelButton(hasChanges: hasChanges)
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
                    createExercise()
                }
            }
        }
        .sheet(item: $sheet) { sheet in
            sheet
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label(.emptyExercisesTitle, systemImage: "dumbbell")
        } description: {
            Text(.emptyExercisesMessage)
        } actions: {
            Button(.createExercise) {
                createExercise()
            }
            .labelStyle(.fixedTitleAndIcon)
            .buttonStyle(.cardProminent)
        }
    }

    private var hasChanges: Bool {
        !selection.isEmpty
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
                PictogramRow(exercise.pictogram, title: exercise.title, subtitle: exercise.categories.formatted(.exerciseCategories))

                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(selected ? AnyShapeStyle(.tint) : AnyShapeStyle(.tertiary))
                    .animation(.snappy(duration: 0.1), value: selected)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)

        if selected {
            GroupBox {
                ExerciseTargetEditor(target: target(for: exercise))
                    .frame(maxWidth: .infinity)
            }
            .groupBoxStyle(.card)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .transition(.blurReplace)
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
        exercise.currentHighestTarget ?? .initial(for: exercise.kind, in: units)
    }

    private func createExercise() {
        if fullVersion.canAddExercise(in: context) {
            sheet = .createExerciseInCategories(selectedCategories)
        } else {
            presentPaywall()
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
                        Button(category.title, systemImage: category.pictogram.image) {
                            selection.formSymmetricDifference([category])
                        }
                        .labelStyle(.fixedTitleAndIcon)
                        .buttonStyle(.glassProminent)
                        .tint(isSelected(category) ? category.pictogram.color : .clear)
                        .foregroundStyle(isSelected(category) ? .white : .secondary)
                    }
                }
            }
            .buttonBorderShape(.capsule)
            .padding(.horizontal, 32)
            .padding(.vertical, 8)
        }
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
    }

    private func isSelected(_ category: Exercise.Category) -> Bool {
        selection.isEmpty || selection.contains(category)
    }
}

#Preview {
    @Previewable @State
    var entries: [WorkoutEntry] = []

    NavigationRoot {
        WorkoutAddEntriesForm(entries: $entries)
    }
    .sampleData()
}
