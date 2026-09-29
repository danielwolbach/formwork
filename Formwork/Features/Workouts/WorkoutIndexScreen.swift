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
    @Query(sort: \Workout.name)
    private var workouts: [Workout]

    @State
    private var sheet: Sheet? = nil

    var body: some View {
        Group {
            if workouts.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(workouts) { workout in
                            WorkoutCard(workout)
                        }
                    }
                    .swipeActionsContainer()
                    .animation(.snappy, value: workouts.count)
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle(.screenWorkoutsTitle)
        .navigationDestination(for: Workout.self) { workout in
            WorkoutScreen(workout)
        }
        .toolbar {
            Menu(.more) {
                Section {
                    Button(.createWorkout) {
                        sheet = .createWorkout
                    }
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
            Label(.emptyWorkoutsTitle, systemImage: "clipboard")
        } description: {
            Text(.emptyWorkoutsMessage)
        } actions: {
            Button(.createWorkout) {
                sheet = .createWorkout
            }
            .labelStyle(.fixedTitleAndIcon)
            .buttonStyle(.cardProminent())
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutIndexScreen()
    }
    .sampleData()
}
