//
//  WorkoutList.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftData
import SwiftUI

struct WorkoutListScreen: View {
    @Query(sort: \Workout.name) private var workouts: [Workout]
    @State private var sheet: WorkoutSheet?
    
    var body: some View {
        WorkoutList(workouts: workouts)
            .navigationTitle("Workouts")
            .navigationDestination(for: Workout.self) { workout in
                WorkoutDetailScreen(workout: workout)
            }
            .toolbar {
                ToolbarItem {
                    Button(.createWorkout) {
                        sheet = .createWorkout
                    }
                }
            }
            .workoutSheet(item: $sheet)
    }
}

#Preview {
    NavigationStack {
        WorkoutListScreen()
            .sampleData()
    }
}
