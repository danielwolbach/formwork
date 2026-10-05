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
    @Environment(\.modelContext)
    private var context: ModelContext

    @Environment(\.fullVersion)
    private var fullVersion: FullVersion

    @Environment(\.presentPaywall)
    private var presentPaywall: PresentPaywallAction

    @Query(filter: #Predicate<Workout> { !$0.isArchived }, sort: \Workout.name)
    private var workouts: [Workout]

    @State
    private var searchText = ""

    @State
    private var sortOrder = [SortDescriptor(\Workout.name)]

    @State
    private var sheet: Sheet? = nil

    var body: some View {
        let matching = matchingWorkouts

        Group {
            if workouts.isEmpty {
                emptyState
            } else {
                ScrollView {
                    ContentStack {
                        LazyVStack(spacing: .items) {
                            ForEach(matching) { workout in
                                WorkoutCard(workout)
                            }
                        }
                        .swipeActionsContainer()
                        .animation(.snappy, value: matching.count)
                        .edgeToEdge()
                    }
                }
                .contentMargins(.bottom, .sections, for: .scrollContent)
                .overlay {
                    if !trimmedSearchText.isEmpty, matching.isEmpty {
                        ContentUnavailableView.search(text: trimmedSearchText)
                    }
                }
                .searchable(text: $searchText)
            }
        }
        .navigationTitle(.screenWorkoutsTitle)
        .toolbar {
            Menu(.more) {
                Section {
                    Button(.createWorkout) {
                        if fullVersion.canAddWorkout(in: context) {
                            sheet = .createWorkout
                        } else {
                            presentPaywall()
                        }
                    }
                }

                Section {
                    Menu(.sort) {
                        Picker(.fieldSortTitle, selection: $sortOrder) {
                            Label(.fieldSortNameTitle, systemImage: "character")
                                .tag([SortDescriptor(\Workout.name)])

                            Label(.fieldSortNewestTitle, systemImage: "clock")
                                .tag([SortDescriptor(\Workout.creationDate, order: .reverse)])
                        }
                    }
                }
            }
        }
        .sheet(item: $sheet) { sheet in
            sheet
        }
        .animation(.snappy, value: searchText)
        .animation(.snappy, value: sortOrder)
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label(.emptyWorkoutsTitle, systemImage: "clipboard")
        } description: {
            Text(.emptyWorkoutsMessage)
        } actions: {
            Button(.createWorkout) {
                sheet = .createWorkout
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
            .sorted(using: sortOrder)
    }
}

#Preview {
    NavigationRoot {
        WorkoutIndexScreen()
    }
    .sampleData()
}
