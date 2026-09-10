//
//  WorkoutsScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import SwiftData
import SwiftUI

struct WorkoutListScreen: View {
    @Query(sort: \Workout.name) private var workouts: [Workout]
    @State private var sheet: Sheet? = nil
    @State private var searchText = ""

    var body: some View {
        Group {
            if workouts.isEmpty {
                ContentUnavailableView {
                    Label(.emptyWorkoutsTitle, systemImage: "clipboard")
                } description: {
                    Text(.emptyWorkoutsMessage)
                } actions: {
                    Button(.create) {
                        sheet = .createWorkout
                    }
                    .buttonStyle(.glassProminent)
                }
            } else {
                searchableWorkouts
            }
        }
        .navigationTitle(.screenWorkoutsTitle)
        .navigationDestination(for: Workout.self) { workout in
            WorkoutScreen(workout: workout)
        }
        .toolbar {
            Button(.create) {
                sheet = .createWorkout
            }
        }
        .sheet(item: $sheet) { sheet in
            NavigationStack {
                sheet
            }
        }
    }

    /// `.searchable` lives on this branch only: with no workouts at all there
    /// is nothing to search, and without a `ScrollView` behind it the bar would
    /// render expanded instead of collapsed.
    private var searchableWorkouts: some View {
        Group {
            if matchingWorkouts.isEmpty {
                ContentUnavailableView.search(text: searchText)
            } else {
                ScreenStack {
                    RowStack(items: matchingWorkouts) { workout in
                        NavigationLink(value: workout) {
                            WorkoutCard(workout: workout)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .searchable(text: $searchText.animated())
    }

    private var matchingWorkouts: [Workout] {
        let searchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        if searchText.isEmpty {
            return workouts
        } else {
            return workouts.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutListScreen()
    }
    .sampleData()
}
