//
//  WorkoutList.swift
//  GymTrack
//
//  Created by Daniel Wolbach on 08.07.26.
//

import SwiftUI

struct WorkoutList: View {
    let workouts: [Workout]

    var body: some View {
        if workouts.isEmpty {
            ContentUnavailableView("No Workouts", systemImage: Workout.systemImage)
        } else {
            ScrollView {
                ScreenStack {
                    RowStack {
                        ForEach(workouts) { workout in
                            NavigationLink(value: workout) {
                                NavigationRow(
                                    title: workout.name,
                                    subtitle: "\(workout.entries.count) Exercises",
                                    systemImage: workout.systemImage,
                                    color: workout.color
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }
}

#Preview("Samples") {
    NavigationStack {
        WorkoutList(workouts: Workout.samples)
    }
}

#Preview("Empty") {
    NavigationStack {
        WorkoutList(workouts: [])
    }
}
