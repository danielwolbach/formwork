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

                SectionView(String(localized: .fieldWorkoutsTitle), subtitle: count(keptWorkouts, limit: FullVersion.workoutLimit)) {
                    LazyVStack(spacing: 0) {
                        ForEach(sortedWorkouts) { workout in
                            KeepRow(
                                workout.pictogram,
                                title: workout.title,
                                subtitle: workout.formatted(.workoutDetails),
                                isKept: keptWorkouts.contains(workout),
                                isSelectable: canToggle(workout, in: keptWorkouts, limit: FullVersion.workoutLimit)
                            ) {
                                toggle(workout, in: &keptWorkouts, limit: FullVersion.workoutLimit)
                            }
                        }
                    }
                    .edgeToEdge()
                } accessory: {
                    if !keptWorkouts.isEmpty {
                        Button(.deselectAll) {
                            keptWorkouts.removeAll()
                        }
                        .labelStyle(.fixedTitleAndIcon)
                        .buttonStyle(.glass)
                    }
                }

                SectionView(String(localized: .fieldExercisesTitle), subtitle: count(keptExercises, limit: FullVersion.exerciseLimit)) {
                    LazyVStack(spacing: 0) {
                        ForEach(sortedExercises) { exercise in
                            KeepRow(
                                exercise.pictogram,
                                title: exercise.title,
                                subtitle: exercise.categories.formatted(.exerciseCategories),
                                isKept: keptExercises.contains(exercise),
                                isSelectable: canToggle(exercise, in: keptExercises, limit: FullVersion.exerciseLimit)
                            ) {
                                toggle(exercise, in: &keptExercises, limit: FullVersion.exerciseLimit)
                            }
                        }
                    }
                    .edgeToEdge()
                } accessory: {
                    if !keptExercises.isEmpty {
                        Button(.deselectAll) {
                            keptExercises.removeAll()
                        }
                        .labelStyle(.fixedTitleAndIcon)
                        .buttonStyle(.glass)
                    }
                }
            }
        }
        .contentMargins(.bottom, .sections, for: .scrollContent)
        .animation(.snappy, value: sort)
        .sensoryFeedback(.selection, trigger: keptWorkouts)
        .sensoryFeedback(.selection, trigger: keptExercises)
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

    private func count(_ selection: Set<some Hashable>, limit: Int) -> String {
        "\(selection.count)/\(limit)"
    }

    private func canToggle<Item: Hashable>(_ item: Item, in selection: Set<Item>, limit: Int) -> Bool {
        selection.contains(item) || limit == 1 || selection.count < limit
    }

    private func toggle<Item: Hashable>(_ item: Item, in selection: inout Set<Item>, limit: Int) {
        if selection.contains(item) {
            selection.remove(item)
        } else if limit == 1 {
            selection = [item]
        } else if selection.count < limit {
            selection.insert(item)
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

private struct KeepRow: View {
    private let pictogram: Pictogram

    private let title: String

    private let subtitle: String

    private let isKept: Bool

    private let isSelectable: Bool

    private let action: () -> Void

    init(_ pictogram: Pictogram, title: String, subtitle: String, isKept: Bool, isSelectable: Bool, action: @escaping () -> Void) {
        self.pictogram = pictogram
        self.title = title
        self.subtitle = subtitle
        self.isKept = isKept
        self.isSelectable = isSelectable
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack {
                PictogramRow(pictogram, title: title, subtitle: subtitle)

                Image(systemName: isKept ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isKept ? AnyShapeStyle(.tint) : AnyShapeStyle(.tertiary))
                    .transaction {
                        $0.animation = nil
                    }
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
    NavigationStack {
        DowngradeScreen()
    }
    .sampleData()
}
