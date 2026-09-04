//
//  WorkoutsScreen.swift
//  Formwork
//
//  Created by Daniel Wolbach on 04.09.26.
//

import SwiftData
import SwiftUI

struct WorkoutsScreen: View {
    @Query private var workouts: [Workout]
    @State private var sheet: Sheet? = nil
    
    var body: some View {
        ScrollView {
            RowStack(items: workouts) { workout in
                WorkoutRow(workout: workout)
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

private struct WorkoutRow: View {
    let workout: Workout
    
    var body: some View {
        NavigationRow(value: workout) {
            DisplayableRow(displayable: workout)
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutsScreen()
    }
    .sampleData()
}
