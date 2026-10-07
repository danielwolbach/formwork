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
    
    @Environment(\.modelContext)
    private var context: ModelContext

    @Environment(\.fullVersion)
    private var fullVersion: FullVersion

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
        .sheet(item: $sheet) { sheet in
            sheet
        }
        .animation(.snappy, value: searchText)
        .animation(.snappy, value: sort)
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
    
    private func createWorkout() {
        if fullVersion.canAddWorkout(in: context) {
            sheet = .createWorkout
        } else {
            presentPaywall()
        }
    }
}

#Preview {
    NavigationRoot {
        WorkoutIndexScreen()
    }
    .sampleData()
}
