//
//  WorkoutIndexScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import SwiftData
import SwiftUI

struct WorkoutIndexScreen: View {
    @Query(sort: \Workout.name)
    private var workouts: [Workout]

    @State
    private var sheet: Sheet? = nil

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(workouts) { workout in
                    NavigationLink(value: workout) {
                        WorkoutCard(workout)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
        .overlay {
            if workouts.isEmpty {
                ContentUnavailableView {
                    Label(.placeholder, systemImage: "clipboard")
                } description: {
                    Text(.placeholder)
                } actions: {
                    Button(.createWorkout) {
                        sheet = .createWorkout
                    }
                    .labelStyle(.fixedTitleAndIcon)
                    .buttonStyle(.cardProminent())
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
}

#Preview {
    NavigationStack {
        WorkoutIndexScreen()
    }
    .sampleData()
}
