//
//  DowngradeScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 01.10.26.
//

import FormworkKit
import FormworkUI
import SwiftData
import SwiftUI

struct DowngradeScreen: View {
    private enum Sort: Hashable {
        case name, newest
    }

    @Environment(\.presentPaywall)
    private var presentPaywall: PresentPaywallAction

    @Query(filter: #Predicate<Workout> { !$0.isArchived }, sort: \Workout.creationDate, order: .reverse)
    private var workouts: [Workout]

    @Query(filter: #Predicate<Exercise> { !$0.isArchived }, sort: \Exercise.creationDate, order: .reverse)
    private var exercises: [Exercise]

    @State
    private var keptWorkouts: Set<Workout> = []

    @State
    private var keptExercises: Set<Exercise> = []

    @State
    private var sort: Sort = .newest

    var body: some View {
        ScrollView {
            ContentStack {
                header

                KeepSection(
                    String(localized: .fieldWorkoutsTitle),
                    items: sortedWorkouts,
                    selection: $keptWorkouts,
                    limit: FullVersion.workoutLimit
                ) { workout in
                    PictogramRow(
                        workout.pictogram,
                        title: workout.title,
                        subtitle: workout.formatted(.workoutDetails)
                    )
                }

                KeepSection(
                    String(localized: .fieldExercisesTitle),
                    items: sortedExercises,
                    selection: $keptExercises,
                    limit: FullVersion.exerciseLimit
                ) { exercise in
                    PictogramRow(
                        exercise.pictogram,
                        title: exercise.title,
                        subtitle: exercise.categories.formatted(.exerciseCategories)
                    )
                }
            }
        }
        .contentMargins(.bottom, .sections, for: .scrollContent)
        .animation(.snappy, value: sort)
        .safeAreaBar(edge: .bottom) {
            Button(.unlockFullVersion) {
                presentPaywall()
            }
            .labelStyle(.fixedTitleAndIcon)
            .buttonStyle(.glassProminent)
            .controlSize(.large)
            .fontWeight(.medium)
            .padding(.horizontal)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Menu(.sort) {
                    Picker(.fieldSortTitle, selection: $sort) {
                        Label(.fieldSortNameTitle, systemImage: "character")
                            .tag(Sort.name)

                        Label(.fieldSortNewestTitle, systemImage: "clock")
                            .tag(Sort.newest)
                    }
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button(.confirm) {
                    confirm()
                }
            }
        }
        .onAppear {
            keptWorkouts = Set(workouts.prefix(FullVersion.workoutLimit))
            keptExercises = Set(exercises.prefix(FullVersion.exerciseLimit))
        }
    }

    private var header: some View {
        VStack(spacing: .items) {
            Image(systemName: "archivebox")
                .font(.system(size: 48))
                .frame(width: 64, height: 64)
                .foregroundStyle(.tint)

            Text(.downgradeTitle)
                .font(.title)
                .fontWeight(.bold)

            Text(.downgradeMessage(workoutLimit: FullVersion.workoutLimit, exerciseLimit: FullVersion.exerciseLimit))
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
    }

    private var sortedWorkouts: [Workout] {
        switch sort {
        case .name: workouts.sorted(using: SortDescriptor(\.name))
        case .newest: workouts
        }
    }

    private var sortedExercises: [Exercise] {
        switch sort {
        case .name: exercises.sorted(using: SortDescriptor(\.name))
        case .newest: exercises
        }
    }

    private func confirm() {
        for workout in workouts where !keptWorkouts.contains(workout) {
            workout.isArchived = true
        }

        for exercise in exercises where !keptExercises.contains(exercise) {
            exercise.isArchived = true
        }
    }
}

private struct KeepSection<Item: PersistentModel, Row: View>: View {
    private let title: String

    private let items: [Item]

    private let limit: Int

    private let row: (Item) -> Row

    @Binding
    private var selection: Set<Item>

    init(
        _ title: String,
        items: [Item],
        selection: Binding<Set<Item>>,
        limit: Int,
        @ViewBuilder row: @escaping (Item) -> Row
    ) {
        self.title = title
        self.items = items
        self._selection = selection
        self.limit = limit
        self.row = row
    }

    var body: some View {
        SectionView(title, subtitle: "\(selection.count)/\(limit)") {
            LazyVStack(spacing: 0) {
                ForEach(items) { item in
                    KeepRow(isKept: selection.contains(item), isSelectable: canToggle(item)) {
                        toggle(item)
                    } content: {
                        row(item)
                    }
                }
            }
            .edgeToEdge()
        } accessory: {
            ZStack {
                if !selection.isEmpty {
                    Button(.deselectAll) {
                        selection.removeAll()
                    }
                    .labelStyle(.fixedTitleAndIcon)
                    .buttonStyle(.glass)
                    .transition(.blurReplace)
                }
            }
            .animation(.snappy, value: selection.isEmpty)
        }
        .monospacedDigit()
        .sensoryFeedback(.selection, trigger: selection)
    }

    private func canToggle(_ item: Item) -> Bool {
        selection.contains(item) || limit == 1 || selection.count < limit
    }

    private func toggle(_ item: Item) {
        if selection.contains(item) {
            selection.remove(item)
        } else if limit == 1 {
            selection = [item]
        } else if selection.count < limit {
            selection.insert(item)
        }
    }
}

private struct KeepRow<Content: View>: View {
    private let isKept: Bool

    private let isSelectable: Bool

    private let action: () -> Void

    private let content: Content

    init(isKept: Bool, isSelectable: Bool, action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.isKept = isKept
        self.isSelectable = isSelectable
        self.action = action
        self.content = content()
    }

    var body: some View {
        Button(action: action) {
            HStack {
                content

                Image(systemName: isKept ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isKept ? AnyShapeStyle(.tint) : AnyShapeStyle(.tertiary))
            }
            .padding(8)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .disabled(!isSelectable)
        .padding(.horizontal, 8)
    }
}

#Preview {
    NavigationRoot {
        DowngradeScreen()
    }
    .sampleData()
}
