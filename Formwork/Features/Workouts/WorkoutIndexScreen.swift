//
//  WorkoutIndexScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import FormworkUI
import SwiftData
import SwiftUI

struct WorkoutIndexScreen: View {
    private enum Sort: Hashable {
        case name, newest

        var descriptor: [SortDescriptor<Workout>] {
            switch self {
            case .name: [SortDescriptor(\.name)]
            case .newest: [SortDescriptor(\.creationDate, order: .reverse)]
            }
        }
    }

    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass: UserInterfaceSizeClass?

    @Environment(\.modelContext)
    private var context: ModelContext

    @Environment(\.paywall)
    private var paywall: Paywall

    @Environment(\.presentPaywall)
    private var presentPaywall: PresentPaywallAction

    @Query(filter: #Predicate<Workout> { !$0.isArchived })
    private var workouts: [Workout]

    @State
    private var searchText: String = ""

    @State
    private var sort: Sort = .name

    @State
    private var sheet: Sheet? = nil

    @State
    private var selection: Workout.ID?

    @State
    private var detailIdentity = UUID()

    @State
    private var compactColumn: NavigationSplitViewColumn = .sidebar

    var body: some View {
        let matching = matchingWorkouts

        NavigationSplitView(preferredCompactColumn: $compactColumn) {
            Group {
                if workouts.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        ContentStack {
                            LazyVStack(spacing: 0) {
                                ForEach(matching) { workout in
                                    Button {
                                        select(workout.id)
                                    } label: {
                                        WorkoutCard(workout, isSelected: isShownSelected(workout.id))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .swipeActionsContainer()
                            .animation(.snappy, value: workouts.count)
                            .edgeToEdge()
                        }
                    }
                    .overlay {
                        if !trimmedSearchText.isEmpty, matching.isEmpty {
                            ContentUnavailableView.search(text: trimmedSearchText)
                        }
                    }
                    .contentMargins(.bottom, .sections, for: .scrollContent)
                    .searchable(text: $searchText)
                }
            }
            .navigationTitle(.screenWorkoutsTitle)
            .toolbar {
                Menu(.more) {
                    Section {
                        Button(.createWorkout) {
                            createWorkout()
                        }
                    }

                    Section {
                        Menu(.sort) {
                            Picker(.fieldSortTitle, selection: $sort) {
                                Label(.fieldSortNameTitle, systemImage: "character")
                                    .tag(Sort.name)

                                Label(.fieldSortNewestTitle, systemImage: "clock")
                                    .tag(Sort.newest)
                            }
                        }
                    }
                }
            }
            .animation(.snappy, value: searchText)
            .animation(.snappy, value: sort)
        } detail: {
            ZStack {
                NavigationRoot {
                    if let id = selection, let workout = workouts.first(where: { $0.id == id }) {
                        WorkoutScreen(workout)
                    } else {
                        ContentUnavailableView(.emptyWorkoutSelectionTitle, systemImage: "clipboard")
                    }
                }
                // A fresh stack pops whatever was pushed, even when the same workout is tapped again.
                .id(detailIdentity)
            }
        }
        .sheet(item: $sheet) { sheet in
            sheet
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label(.emptyWorkoutsTitle, systemImage: "clipboard")
        } description: {
            Text(.emptyWorkoutsMessage)
        } actions: {
            Button(.createWorkout) {
                createWorkout()
            }
            .labelStyle(.fixedTitleAndIcon)
            .buttonStyle(.cardProminent)
        }
    }

    private var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var matchingWorkouts: [Workout] {
        let searchText = trimmedSearchText

        return workouts
            .filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }
            .sorted(using: sort.descriptor)
    }

    /// A collapsed split view keeps the selection after going back, so it is only shown side by side with the detail.
    private func isShownSelected(_ workout: Workout.ID) -> Bool {
        horizontalSizeClass == .regular && selection == workout
    }

    private func select(_ workout: Workout.ID) {
        selection = workout
        detailIdentity = UUID()
        // Buttons don't drive a collapsed split view the way list selection does, so it has to be told to show the detail.
        compactColumn = .detail
    }

    private func createWorkout() {
        if paywall.canAddWorkout(in: context) {
            sheet = .createWorkout
        } else {
            presentPaywall()
        }
    }
}

#Preview {
    WorkoutIndexScreen()
        .sampleData()
}
