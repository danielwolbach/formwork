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
    typealias Selection = [(exercise: Exercise, target: ExerciseTarget)]

    private enum Sort: Hashable {
        case name, newest

        var descriptor: [SortDescriptor<Exercise>] {
            switch self {
            case .name: [SortDescriptor(\.name)]
            case .newest: [SortDescriptor(\.creationDate, order: .reverse)]
            }
        }
    }

    private let add: (Selection) -> Void

    @Environment(\.dismiss)
    private var dismiss: DismissAction

    @Environment(\.units)
    private var units: Units

    @Environment(\.modelContext)
    private var context: ModelContext

    @Environment(\.paywall)
    private var paywall: Paywall

    @Environment(\.presentPaywall)
    private var presentPaywall: PresentPaywallAction

    @Query(filter: #Predicate<Exercise> { !$0.isArchived })
    private var exercises: [Exercise]

    @State
    private var selection: Selection = []

    @State
    private var selectedCategories: Set<Exercise.Category> = []

    @State
    private var sort: Sort = .name

    @State
    private var searchText: String = ""

    @State
    private var searchPresented: Bool = false

    @State
    private var sheet: Sheet?

    init(onAdd: @escaping (Selection) -> Void) {
        self.add = onAdd
    }

    init(workout: Workout) {
        self.add = { selection in
            for item in selection {
                workout.append(exercise: item.exercise, target: item.target)
            }
        }
    }

    init(session: Session) {
        self.add = { selection in
            withAnimation(.snappy) {
                session.add(selection)
            }
        }
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
        .animation(.snappy, value: sort)
        .animation(.snappy, value: selection.count)
        .sensoryFeedback(.selection, trigger: selection.count)
        .sensoryFeedback(.selection, trigger: selectedCategories)
        .scrollDismissesKeyboard(.immediately)
        .safeAreaBar(edge: .bottom) {
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
                    Picker(.fieldSortTitle, selection: $sort) {
                        Label(.fieldSortNameTitle, systemImage: "character")
                            .tag(Sort.name)

                        Label(.fieldSortNewestTitle, systemImage: "clock")
                            .tag(Sort.newest)
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
            .sorted(using: sort.descriptor)
    }

    @ViewBuilder
    private func row(for exercise: Exercise) -> some View {
        let selected = isSelected(exercise)

        SelectableRow(isSelected: selected) {
            searchPresented = false
            toggle(exercise)
        } content: {
            PictogramRow(exercise.pictogram, title: exercise.title, subtitle: exercise.categories.formatted(.exerciseCategories))
        }

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
        if let index = index(of: exercise) {
            selection.remove(at: index)
        } else {
            selection.append((exercise, initialTarget(for: exercise)))
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
        if paywall.canAddExercise(in: context) {
            sheet = .createExerciseInCategories(selectedCategories)
        } else {
            presentPaywall()
        }
    }

    private func commit() {
        add(selection)
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
                        .tint(isActive(category) ? category.pictogram.color : .clear)
                        .foregroundStyle(isActive(category) ? .white : .secondary)
                        .accessibilityAddTraits(selection.contains(category) ? [.isSelected] : [])
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

    private func isActive(_ category: Exercise.Category) -> Bool {
        selection.isEmpty || selection.contains(category)
    }
}

#Preview {
    NavigationRoot {
        WorkoutAddEntriesForm { _ in }
    }
    .sampleData()
}
