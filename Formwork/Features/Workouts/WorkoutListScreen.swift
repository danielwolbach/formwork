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
        ScrollView {
            LazyVGrid(columns: [.init(.flexible(), spacing: 8)], spacing: 8) {
                ForEach(workouts) { workout in
                    NavigationLink(value: workout) {
                        WorkoutCard(workout: workout)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
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
        .sheet(item: $sheet) { $0 }
    }
}

#Preview {
    NavigationStack {
        WorkoutListScreen()
    }
    .sampleData()
}
