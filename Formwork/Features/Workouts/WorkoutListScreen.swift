//
//  WorkoutListScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import FormworkKit
import SwiftData
import SwiftUI

struct WorkoutListScreen: View {
    @Query(sort: \Workout.name) private var workouts: [Workout]
    @State private var sheet: Sheet? = nil

    var body: some View {
        content
            .navigationTitle(.screenWorkoutsTitle)
            .navigationDestination(for: Workout.self) { workout in
                WorkoutScreen(workout: workout)
            }
            .toolbar {
                Button(.create) {
                    sheet = .createWorkout
                }
            }
            .sheet(item: $sheet) { $0 }
    }

    @ViewBuilder
    private var content: some View {
        if workouts.isEmpty {
            ContentUnavailableView {
                Label(.emptyWorkoutsTitle, systemImage: "clipboard")
            } description: {
                Text(.emptyWorkoutsDescription)
            } actions: {
                Button(.create) {
                    sheet = .createWorkout
                }
                .buttonStyle(.glassProminent)
            }
        } else {
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(workouts) { workout in
                        NavigationLink(value: workout) {
                            WorkoutCard(workout: workout)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutListScreen()
    }
    .sampleData()
}
