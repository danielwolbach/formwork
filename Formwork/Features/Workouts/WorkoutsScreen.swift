//
//  WorkoutsScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import SwiftData
import SwiftUI

struct WorkoutsScreen: View {
    @Query(sort: \Workout.name) private var workouts: [Workout]
    @State private var sheet: Sheet? = nil

    var body: some View {
        ScreenStack {
            RowStack(items: workouts) { workout in
                NavigationLink(value: workout) {
                    WorkoutCard(workout: workout)
                }
                .buttonStyle(.plain)
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
}

#Preview {
    NavigationStack {
        WorkoutsScreen()
    }
    .sampleData()
}
